
-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181002
-- Description: Merge external table [sis_stage].[IEPart_Effectivity] into [sis].[IEPart_Effectivity]
-- Modified By: Kishor Padmanabhan
-- Modified Date: 20220912
-- Modified Reason: Included Media_ID in IEPart_Effiectivity table
-- Associated User Story: 22637
-- =============================================
CREATE PROCEDURE [sis].[IEPart_Effectivity_Merge]
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

MERGE [sis].[IEPart_Effectivity] AS x
USING [sis_stage].[IEPart_Effectivity] AS s
    on (s.IEPart_ID = x.IEPart_ID and s.SerialNumberPrefix_ID = x.SerialNumberPrefix_ID and s.SerialNumberRange_ID = x.SerialNumberRange_ID and s.Media_ID = x.Media_ID)
    WHEN NOT MATCHED THEN
    INSERT(IEPart_ID, SerialNumberPrefix_ID, SerialNumberRange_ID,SerialNumberPrefix_Type, Media_ID, LastModified_Date)
    VALUES(s.IEPart_ID, s.SerialNumberPrefix_ID, s.SerialNumberRange_ID, s.SerialNumberPrefix_Type, s.Media_ID, GETDATE())
OUTPUT $ACTION,
    COALESCE(inserted.IEPart_ID, deleted.IEPart_ID) Number
    INTO @MERGE_RESULTS;
SELECT @MERGED_ROWS = @@ROWCOUNT;
    SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
        ,(SELECT MR.ACTIONTYPE
            ,MR.Number
            FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
            ,WITHOUT_ARRAY_WRAPPER),'IE Part Effectivity Modified Rows');
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

Update STATISTICS sis.IEPart_Effectivity with fullscan

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

END TRY

BEGIN CATCH

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
DECLARE @ERROELINE INT= ERROR_LINE()

SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

END CATCH

END
