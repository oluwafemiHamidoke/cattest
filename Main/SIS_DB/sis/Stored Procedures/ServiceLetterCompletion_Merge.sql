-- =============================================
-- Author:      Kishor Padmanabhan
-- Create Date: 20221102
-- Description: Merge external table [sis_stage].[ServiceLetterCompletion] into [sis].[ServiceLetterCompletion]
-- =============================================
CREATE PROCEDURE [sis].[ServiceLetterCompletion_Merge]
(@DEBUG      BIT = 'FALSE')
AS
BEGIN
    SET NOCOUNT ON

BEGIN TRY

DECLARE @MERGED_ROWS                   INT              = 0
       ,@LOGMESSAGE                    VARCHAR(MAX);

DECLARE @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
DECLARE @ProcessID uniqueidentifier = NewID()

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

DECLARE @MERGE_RESULTS TABLE
(ACTIONTYPE         NVARCHAR(10)
,Media_ID         VARCHAR(50) NOT NULL
,SerialNumberPrefix_ID   VARCHAR(50) NOT NULL
,SerialNumberRange_ID   VARCHAR(50) NOT NULL
);

MERGE [sis].[ServiceLetterCompletion] AS x
    USING [sis_stage].[ServiceLetterCompletion] AS s
    ON (s.Media_ID = x.Media_ID AND s.SerialNumberPrefix_ID = x.SerialNumberPrefix_ID AND s.SerialNumberRange_ID = x.SerialNumberRange_ID)
    WHEN MATCHED AND EXISTS
    (
        SELECT s.Media_ID, s.SerialNumberPrefix_ID, s.SerialNumberRange_ID, s.Completion_Date
        EXCEPT
        SELECT x.Media_ID, x.SerialNumberPrefix_ID, x.SerialNumberRange_ID, x.Completion_Date
    )
    THEN
        UPDATE SET  x.Completion_Date = s.Completion_Date
    WHEN NOT MATCHED BY TARGET
    THEN
        INSERT (Media_ID, SerialNumberPrefix_ID, SerialNumberRange_ID, Completion_Date)
        VALUES (s.Media_ID, s.SerialNumberPrefix_ID, s.SerialNumberRange_ID, s.Completion_Date)
    WHEN NOT MATCHED BY SOURCE
    THEN
        DELETE
    OUTPUT $ACTION,
    COALESCE(inserted.Media_ID, deleted.Media_ID) Media_ID,
    COALESCE(inserted.SerialNumberPrefix_ID, deleted.SerialNumberPrefix_ID) SerialNumberPrefix_ID,
    COALESCE(inserted.SerialNumberRange_ID, deleted.SerialNumberRange_ID) SerialNumberRange_ID 
INTO @MERGE_RESULTS;

SELECT @MERGED_ROWS = @@ROWCOUNT;

SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
													,(SELECT MR.ACTIONTYPE
															,MR.Media_ID
                                                            ,MR.SerialNumberPrefix_ID
                                                            ,MR.SerialNumberRange_ID
														FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
														,WITHOUT_ARRAY_WRAPPER),'ServiceLetterCompletion Modified Rows');
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

UPDATE STATISTICS sis.ServiceLetterCompletion WITH FULLSCAN

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

END TRY

BEGIN CATCH
  DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
  DECLARE @ERROELINE INT= ERROR_LINE()

  SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
  EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;
END CATCH

END