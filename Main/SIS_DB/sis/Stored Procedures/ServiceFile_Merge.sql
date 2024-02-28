-- =============================================
-- Author:      Ramesh Ramalingam (+ Sachin P)
-- Create Date: 20201027
-- Description: Merge external table [sis_stage].[ServiceFile] into [sis].[ServiceFile]
-- =============================================
CREATE PROCEDURE [sis].[ServiceFile_Merge]
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

    MERGE [sis].[ServiceFile] AS tgt
        USING [sis_stage].[ServiceFile] AS src
        ON (src.ServiceFile_ID = tgt.ServiceFile_ID)
        WHEN MATCHED AND EXISTS
        (
        SELECT src.InfoType_ID, src.ServiceFile_Name, src.Available_Flag, src.Mime_Type, src.ServiceFile_Size, src.Updated_Date, src.Created_Date, src.Insert_Date
        EXCEPT
        SELECT tgt.InfoType_ID, tgt.ServiceFile_Name, tgt.Available_Flag, tgt.Mime_Type, tgt.ServiceFile_Size, tgt.Updated_Date, tgt.Created_Date, tgt.Insert_Date
        )
        THEN
    UPDATE SET tgt.InfoType_ID = src.InfoType_ID, tgt.ServiceFile_Name = src.ServiceFile_Name, tgt.Available_Flag = src.Available_Flag, tgt.Mime_Type = src.Mime_Type, tgt.ServiceFile_Size = src.ServiceFile_Size,
        tgt.Updated_Date = src.Updated_Date, tgt.Created_Date = src.Created_Date, tgt.Insert_Date = src.Insert_Date
        WHEN NOT MATCHED BY TARGET
        THEN
    INSERT (ServiceFile_ID, InfoType_ID, ServiceFile_Name, Available_Flag, Mime_Type, ServiceFile_Size, Updated_Date, Created_Date, Insert_Date)
    VALUES (src.ServiceFile_ID, src.InfoType_ID, src.ServiceFile_Name, src.Available_Flag, src.Mime_Type, src.ServiceFile_Size, src.Updated_Date, src.Created_Date, src.Insert_Date)
        OUTPUT $ACTION,
        COALESCE(inserted.ServiceFile_ID, deleted.ServiceFile_ID) Number
    INTO @MERGE_RESULTS;

    SELECT @MERGED_ROWS = @@ROWCOUNT;

    SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                                        ,(SELECT MR.ACTIONTYPE
                                                                ,MR.Number
                                                            FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
                                                            ,WITHOUT_ARRAY_WRAPPER),'ServiceFile Modified Rows');
    EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

    Update STATISTICS sis.ServiceFile with fullscan

    EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

    END TRY

    BEGIN CATCH

    DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
    DECLARE @ERROELINE INT= ERROR_LINE()

    SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
    EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

    END CATCH

END
