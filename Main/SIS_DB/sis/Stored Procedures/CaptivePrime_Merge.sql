
-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181002
-- Description: Merge external table [sis_stage].[CaptivePrime] into [sis].[CaptivePrime]
-- =============================================
CREATE PROCEDURE [sis].[CaptivePrime_Merge]
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

MERGE [sis].[CaptivePrime] AS x
USING [sis_stage].[CaptivePrime] AS s
    ON (s.Prime_SerialNumberPrefix_ID = x.Prime_SerialNumberPrefix_ID and s.Captive_SerialNumberPrefix_ID = x.Captive_SerialNumberPrefix_ID and s.Captive_SerialNumberRange_ID = x.Captive_SerialNumberRange_ID and s.Media_ID = x.Media_ID)
    WHEN MATCHED AND EXISTS
    (
        SELECT s.CaptivePrime_ID, s.Media_ID, s.Document_Title, s.Configuration_Type
        EXCEPT
        SELECT x.CaptivePrime_ID, x.Media_ID, x.Document_Title, x.Configuration_Type
    )
    THEN
        UPDATE SET CaptivePrime_ID = s.CaptivePrime_ID, Media_ID = s.Media_ID, Document_Title = s.Document_Title, Configuration_Type = s.Configuration_Type
    WHEN NOT MATCHED BY TARGET
    THEN
        INSERT(CaptivePrime_ID, Prime_SerialNumberPrefix_ID, Captive_SerialNumberPrefix_ID, Captive_SerialNumberRange_ID, Media_ID, Document_Title, Configuration_Type)
        VALUES(s.CaptivePrime_ID, s.Prime_SerialNumberPrefix_ID, s.Captive_SerialNumberPrefix_ID, s.Captive_SerialNumberRange_ID, s.Media_ID, s.Document_Title, s.Configuration_Type)
    OUTPUT $ACTION,
        COALESCE(inserted.CaptivePrime_ID, deleted.CaptivePrime_ID) Number
        INTO @MERGE_RESULTS;

    SELECT @MERGED_ROWS = @@ROWCOUNT;

    SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
    ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
    ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
    ,(SELECT MR.ACTIONTYPE
        ,MR.Number
        FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
        ,WITHOUT_ARRAY_WRAPPER),'CaptivePrime Modified Rows');
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

Update STATISTICS sis.CaptivePrime with fullscan

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

END TRY

BEGIN CATCH

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
DECLARE @ERROELINE INT= ERROR_LINE()

SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

END CATCH

END
