-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181002
-- Modify Date: 20200223	Added [LOCATIONHIGHRES] and [FILESIZEBYTEHIGHRES]     
-- Modify Date: 20231003	Added [File_Location_Highres] in Update       
-- Description: Merge external table [sis_stage].[Illustration_File] into [sis].[Illustration_File]
-- =============================================
CREATE PROCEDURE [sis].[Illustration_File_Merge]
(@DEBUG      BIT = 'FALSE')
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY

            DECLARE @MERGED_ROWS                   INT              = 0
                ,@LOGMESSAGE                    VARCHAR(MAX);

            Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
            Declare @ProcessID uniqueidentifier = NewID()

            EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

            DECLARE @MERGE_RESULTS TABLE
            (ACTIONTYPE         NVARCHAR(10)
            ,Number         VARCHAR(50) NOT NULL
            );

            MERGE [sis].[Illustration_File] AS x
                USING [sis_stage].[Illustration_File] AS s
                ON (s.Illustration_ID = x.Illustration_ID and s.File_Location = x.File_Location)
                WHEN MATCHED AND EXISTS
                (
                SELECT s.Illustration_File_ID, s.File_Size_Byte, s.Mime_Type, s.File_Size_Byte_Highres, s.File_Location_Highres
                EXCEPT
                SELECT x.Illustration_File_ID, x.File_Size_Byte, x.Mime_Type, x.File_Size_Byte_Highres, x.File_Location_Highres
                )
                THEN
            UPDATE SET x.Illustration_File_ID = s.Illustration_File_ID, x.File_Size_Byte = s.File_Size_Byte, x.Mime_Type = s.Mime_Type, x.File_Size_Byte_Highres = s.File_Size_Byte_Highres
                     , x.File_Location_Highres = s.File_Location_Highres
                WHEN NOT MATCHED BY TARGET
                THEN
            INSERT (Illustration_File_ID, Illustration_ID, File_Location, File_Size_Byte, Mime_Type, File_Location_Highres, File_Size_Byte_Highres)
            VALUES (s.Illustration_File_ID, s.Illustration_ID, s.File_Location, s.File_Size_Byte, s.Mime_Type, s.File_Location_Highres, s.File_Size_Byte_Highres)
                OUTPUT $ACTION,
                COALESCE(inserted.Illustration_ID, deleted.Illustration_ID) Number
            INTO @MERGE_RESULTS;

            SELECT @MERGED_ROWS = @@ROWCOUNT;

            SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                                                ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                                                                ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                                                ,(SELECT MR.ACTIONTYPE
                                                                        ,MR.Number
                                                                    FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
                                                                    ,WITHOUT_ARRAY_WRAPPER),'Illustration File Modified Rows');
            EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

            Update STATISTICS sis.Illustration_File with fullscan

            EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

    END TRY

    BEGIN CATCH

            DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
            DECLARE @ERROELINE INT= ERROR_LINE()

            SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
            EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

    END CATCH

END