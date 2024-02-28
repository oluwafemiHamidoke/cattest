-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181002
-- Description: Merge external table [sis_stage].[Part_IEPart_Relation_Translation] into [sis].[Part_IEPart_Relation_Translation]
-- =============================================
CREATE PROCEDURE [sis].[Part_IEPart_Relation_Translation_Merge]
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

MERGE [sis].[Part_IEPart_Relation_Translation] AS x
    USING [sis_stage].[Part_IEPart_Relation_Translation] AS s
    ON (s.Language_ID = x.Language_ID and s.Part_IEPart_Relation_ID = x.Part_IEPart_Relation_ID)
    WHEN MATCHED AND EXISTS
    (
    SELECT s.Part_IEPart_Name, s.Part_IEPart_Modifier, s.Part_IEPart_Note
    EXCEPT
    SELECT x.Part_IEPart_Name, x.Part_IEPart_Modifier, x.Part_IEPart_Note
    )
    THEN
UPDATE SET x.Part_IEPart_Name = s.Part_IEPart_Name, x.Part_IEPart_Modifier = s.Part_IEPart_Modifier, x.Part_IEPart_Note=s.Part_IEPart_Note
    WHEN NOT MATCHED BY TARGET
    THEN
INSERT (Language_ID, Part_IEPart_Name, Part_IEPart_Relation_ID, Part_IEPart_Modifier, Part_IEPart_Note)
VALUES (s.Language_ID, s.Part_IEPart_Name, s.Part_IEPart_Relation_ID, s.Part_IEPart_Modifier, s.Part_IEPart_Note)
    OUTPUT $ACTION,
    COALESCE(inserted.Part_IEPart_Relation_ID, deleted.Part_IEPart_Relation_ID) Number
INTO @MERGE_RESULTS;

SELECT @MERGED_ROWS = @@ROWCOUNT;

SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
													,(SELECT MR.ACTIONTYPE
															,MR.Number
														FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
														,WITHOUT_ARRAY_WRAPPER),'Part IEPart Relation Translation Modified Rows');
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

Update STATISTICS sis.Part_IEPart_Relation_Translation with fullscan

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

END TRY

BEGIN CATCH

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
DECLARE @ERROELINE INT= ERROR_LINE()

SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

END CATCH

END
