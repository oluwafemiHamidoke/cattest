CREATE PROCEDURE [sis].[Kit_Media_Relation_Merge]
(@DEBUG BIT = 'FALSE')
AS
BEGIN
    SET NOCOUNT ON

BEGIN TRY

DECLARE @ProcName    VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
	   ,@ProcessID   UNIQUEIDENTIFIER = NEWID()
	   ,@LOGMESSAGE  VARCHAR(MAX)
	   ,@MERGED_ROWS INT  = 0;

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

DECLARE @MERGE_RESULTS TABLE
(ACTIONTYPE         NVARCHAR(10)
,kitId         int
);

BEGIN TRANSACTION;

select distinct kit.Kit_ID, media.Media_ID into #kit_media FROM (
    select KITNUMBER, [Media Number 1] AS MediaNumber from [KIM].[SIS_KitSalesMarketingInfo]
    UNION ALL
    select KITNUMBER, [Media Number 2] AS MediaNumber from [KIM].[SIS_KitSalesMarketingInfo]
    UNION ALL
    select KITNUMBER, [Media Number 3] AS MediaNumber from [KIM].[SIS_KitSalesMarketingInfo]
    UNION ALL
    select KITNUMBER, [Media Number 4] AS MediaNumber from [KIM].[SIS_KitSalesMarketingInfo]
    UNION ALL
    select KITNUMBER, [Media Number 5] AS MediaNumber from [KIM].[SIS_KitSalesMarketingInfo]
    UNION ALL
    select KITNUMBER, [Media Number 6] AS MediaNumber from [KIM].[SIS_KitSalesMarketingInfo]
) km INNER JOIN sis.Kit kit ON km.KITNUMBER = kit.Number
INNER JOIN sis.Media media ON km.MediaNumber = media.Media_Number and km.KITNUMBER is not NULL and km.MediaNumber is not NULL


MERGE [sis].[Kit_Media_Relation] AS x
USING #kit_media AS s
ON (s.Kit_ID = x.Kit_ID and s.Media_ID = x.Media_ID)
  WHEN MATCHED AND EXISTS
    (
        SELECT s.Kit_ID, s.Media_ID
        EXCEPT
        SELECT x.Kit_ID, x.Media_ID
    )
THEN
        UPDATE SET Kit_ID = s.Kit_ID, Media_ID = s.Media_ID
		WHEN NOT MATCHED BY TARGET
THEN
        INSERT(Kit_ID, Media_ID)
        VALUES(s.Kit_ID, s.Media_ID)
WHEN NOT MATCHED BY SOURCE
    THEN DELETE
OUTPUT $ACTION,
    COALESCE(inserted.Kit_ID, deleted.Kit_ID) kitId
INTO @MERGE_RESULTS;

SELECT @MERGED_ROWS = @@ROWCOUNT;


SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
    ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
    ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
    ,(SELECT MR.ACTIONTYPE
        ,MR.kitId
        FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
        ,WITHOUT_ARRAY_WRAPPER),'Kit_Media_Relation Modified Rows');
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

Update STATISTICS sis.Kit_Media_Relation with fullscan

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

DROP TABLE #kit_media

COMMIT;

END TRY

BEGIN CATCH

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
       ,@ERRORLINE    INT            = ERROR_LINE()
       ,@ERRORNUM     INT            = ERROR_NUMBER();

SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @ERRORNUM;

	    IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRANSACTION;
                THROW;
            END

END CATCH

END
GO