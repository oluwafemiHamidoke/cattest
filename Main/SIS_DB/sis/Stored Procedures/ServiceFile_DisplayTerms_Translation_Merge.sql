-- =============================================
-- Author:      Ramesh Ramalingam (+ Sachin P)
-- Create Date: 20201103
-- Description: Merge external table [sis_stage].[ServiceFile_DisplayTerms_Translation_Diff] into [sis].[ServiceFile_DisplayTerms_Translation]
-- =============================================
CREATE PROCEDURE [sis].[ServiceFile_DisplayTerms_Translation_Merge]
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

    MERGE [sis].[ServiceFile_DisplayTerms_Translation] AS x
        USING [sis_stage].[ServiceFile_DisplayTerms_Translation] AS s
        ON (s.ServiceFile_DisplayTerms_ID = x.ServiceFile_DisplayTerms_ID and s.Language_ID = x.Language_ID)
        WHEN MATCHED AND EXISTS
        (
        SELECT s.Value_Type, s.Value, s.Display_Value
        EXCEPT
        SELECT x.Value_Type, x.Value, x.Display_Value
        )
        THEN
    UPDATE SET x.Value_Type = s.Value_Type, x.Value = s.Value, x.Display_Value = s.Display_Value
        WHEN NOT MATCHED BY TARGET
        THEN
    INSERT (ServiceFile_DisplayTerms_ID, Language_ID, Value_Type, Value, Display_Value)
    VALUES (s.ServiceFile_DisplayTerms_ID, s.Language_ID, s.Value_Type, s.Value, s.Display_Value)
        OUTPUT $ACTION,
        COALESCE(inserted.ServiceFile_DisplayTerms_ID, deleted.ServiceFile_DisplayTerms_ID) Number
    INTO @MERGE_RESULTS;

    SELECT @MERGED_ROWS = @@ROWCOUNT;

    SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                                        ,(SELECT MR.ACTIONTYPE
                                                                ,MR.Number
                                                            FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
                                                            ,WITHOUT_ARRAY_WRAPPER),'ServiceFile DisplayTerms Translation Modified Rows');
    EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

    Update STATISTICS sis.ServiceFile_DisplayTerms_Translation with fullscan

    EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

    END TRY

    BEGIN CATCH

    DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
    DECLARE @ERROELINE INT= ERROR_LINE()

    SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
    EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

    END CATCH

END
