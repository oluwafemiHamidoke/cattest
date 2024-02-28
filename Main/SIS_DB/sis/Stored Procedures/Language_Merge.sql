-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181002
-- Modify Date: 20190606 Davide - Removed countru column from language table
-- Description: Merge external table [sis_stage].[Language] into [sis].[Language]
-- Exec [sis].[Language_Merge]
-- =============================================
CREATE PROCEDURE [sis].[Language_Merge] ( @DEBUG BIT = 'FALSE' )
AS
BEGIN
    SET NOCOUNT ON

BEGIN TRY

Declare @ProcName       VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
        , @ProcessID    uniqueidentifier = NewID()
        , @MERGED_ROWS  INT              = 0
        , @LOGMESSAGE   VARCHAR(MAX);

Declare @MERGE_RESULTS TABLE (
    ACTIONTYPE      NVARCHAR(10)
    , Number        VARCHAR(50)     NOT NULL
);

EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

MERGE [sis].[Language] AS tgt
USING [sis_stage].[Language] AS src
on src.Language_Tag = tgt.Language_Tag
WHEN MATCHED AND EXISTS
(
    SELECT src.Language_ID, src.Language, src.[Language_Code], src.[Legacy_Language_Indicator], src.[Default_Language], src.LastModifiedDate, src.Lang
    EXCEPT
    SELECT tgt.Language_ID, tgt.Language, tgt.[Language_Code], tgt.[Legacy_Language_Indicator], tgt.[Default_Language], tgt.LastModifiedDate, tgt.Lang
)
THEN
    UPDATE Set
         tgt.Language_ID = src.Language_ID
        ,tgt.Language = src.Language
        ,tgt.[Language_Code]=src.[Language_Code]
        ,tgt.[Language_Tag]=src.[Language_Tag]
        ,tgt.[Legacy_Language_Indicator]=src.[Legacy_Language_Indicator]
        ,tgt.[Default_Language]=src.[Default_Language]
        ,tgt.LastModifiedDate = src.LastModifiedDate
        ,tgt.Lang = src.Lang
WHEN NOT MATCHED BY TARGET
THEN
    INSERT (Language_ID, [Language], [Language_Code], [Language_Tag],[Legacy_Language_Indicator],[Default_Language], [LastModifiedDate], [Lang])
    VALUES (src.Language_ID, src.[Language], src.[Language_Code], src.[Language_Tag], src.[Legacy_Language_Indicator], src.[Default_Language], src.[LastModifiedDate], src.[Lang])
OUTPUT $ACTION,
COALESCE(inserted.Language_Tag, deleted.Language_Tag) Number
INTO @MERGE_RESULTS;

SELECT @MERGED_ROWS = @@ROWCOUNT;

SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
													,(SELECT MR.ACTIONTYPE
															,MR.Number
														FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
														,WITHOUT_ARRAY_WRAPPER),'Language Modified Rows');
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

Update STATISTICS sis.Language with fullscan

EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;

END TRY

BEGIN CATCH

    DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
    DECLARE @ERRORLINE INT= ERROR_LINE();

	SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
	EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;

END CATCH

END
