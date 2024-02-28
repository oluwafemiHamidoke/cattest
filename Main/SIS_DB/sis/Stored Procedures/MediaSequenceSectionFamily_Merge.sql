-- =============================================
-- Create Date: 20230426
-- Description: Merge  table [sis].[MediaSequenceSectionFamily] from Tables [sis].[MediaSequence] and [sis].[MediaSection] 
-- =============================================
CREATE PROCEDURE [sis].[MediaSequenceSectionFamily_Merge] (@DEBUG      BIT = 'FALSE')
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

MERGE [sis].[MediaSequenceSectionFamily] AS x
    USING 
	(
	select MES.Media_ID, MS.IEPart_ID,MS.MediaSection_ID,MS.IESystemControlNumber
	from [sis].[MediaSequence] MS
    JOIN [sis].[MediaSection] MES
    ON MS.MediaSection_ID=MES.MediaSection_ID
	) AS s
    ON 
	(   s.Media_ID= x.Media_ID
	and s.IEPart_ID = x.IEPart_ID
	and s.MediaSection_ID= x.MediaSection_ID
	and ISNULL(s.IESystemControlNumber,999999999) = ISNULL(x.IESystemControlNumber,999999999)
	)
    WHEN NOT MATCHED BY TARGET
    THEN
INSERT (Media_ID, IEPart_ID, MediaSection_ID, IESystemControlNumber)
VALUES (s.Media_ID, s.IEPart_ID, s.MediaSection_ID, s.IESystemControlNumber)
WHEN NOT MATCHED BY SOURCE
    THEN DELETE 
    OUTPUT $ACTION,
    COALESCE(inserted.Media_ID, deleted.Media_ID) Number
INTO @MERGE_RESULTS;

SELECT @MERGED_ROWS = @@ROWCOUNT;

SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
													,(SELECT MR.ACTIONTYPE
															,MR.Number
														FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
														,WITHOUT_ARRAY_WRAPPER),'MediaSequenceSectionFamily Modified Rows');
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

Update STATISTICS sis.MediaSequenceSectionFamily with fullscan

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

END TRY

BEGIN CATCH

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
DECLARE @ERROELINE INT= ERROR_LINE()

SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

END CATCH

END