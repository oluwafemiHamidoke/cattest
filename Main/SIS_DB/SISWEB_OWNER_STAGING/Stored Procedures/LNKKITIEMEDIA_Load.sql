CREATE PROCEDURE [SISWEB_OWNER_STAGING].[LNKKITIEMEDIA_Load]
(@DEBUG BIT = 'FALSE')
-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20240215
-- Modify Date: 
-- Description:  Load data into [SISWEB_OWNER_STAGING].[LNKKITIEMEDIA]
-- =============================================
AS
BEGIN
    SET NOCOUNT ON
BEGIN TRY

DECLARE @ProcName    VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
	   ,@ProcessID   UNIQUEIDENTIFIER = NEWID()
	   ,@LOGMESSAGE  VARCHAR(MAX)
	   ,@MERGED_ROWS INT  = 0;

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

DECLARE @MERGE_RESULTS TABLE
(ACTIONTYPE         NVARCHAR(10)
,[IESYSTEMCONTROLNUMBER] nvarchar(15) 
);

BEGIN TRANSACTION;
    select IECONTROLNUMBER, [Media Number 1] AS MediaNumber 
	into #IECONTROLNUMBER_MEDIA from [KIM].[SIS_KitSalesMarketingInfo]
	where isnull([Media Number 1],'') <> '' and isnull(IECONTROLNUMBER,'')<> ''
    UNION 
    select IECONTROLNUMBER, [Media Number 2] AS MediaNumber from [KIM].[SIS_KitSalesMarketingInfo]
	where isnull([Media Number 2],'') <> '' and isnull(IECONTROLNUMBER,'')<> ''
    UNION 
    select IECONTROLNUMBER, [Media Number 3] AS MediaNumber from [KIM].[SIS_KitSalesMarketingInfo]
	where isnull([Media Number 3],'') <> '' and isnull(IECONTROLNUMBER,'')<> ''
    UNION 
    select IECONTROLNUMBER, [Media Number 4] AS MediaNumber from [KIM].[SIS_KitSalesMarketingInfo]
	where isnull([Media Number 4],'') <> '' and isnull(IECONTROLNUMBER,'')<> ''
    UNION 
    select IECONTROLNUMBER, [Media Number 5] AS MediaNumber from [KIM].[SIS_KitSalesMarketingInfo]
	where isnull([Media Number 5],'') <> '' and isnull(IECONTROLNUMBER,'')<> ''
    UNION 
    select IECONTROLNUMBER, [Media Number 6] AS MediaNumber from [KIM].[SIS_KitSalesMarketingInfo]
	where isnull([Media Number 6],'') <> '' and isnull(IECONTROLNUMBER,'')<> ''

	MERGE [SISWEB_OWNER_STAGING].LNKKITIEMEDIA AS x
	USING #IECONTROLNUMBER_MEDIA AS s
	ON (s.IECONTROLNUMBER = x.IESYSTEMCONTROLNUMBER and s.[MEDIANUMBER] = x.[MEDIANUMBER])
	WHEN NOT MATCHED BY TARGET
	THEN
		INSERT(IESYSTEMCONTROLNUMBER, [MEDIANUMBER])
		VALUES(s.IECONTROLNUMBER, s.[MEDIANUMBER])
	WHEN NOT MATCHED BY SOURCE
	THEN DELETE;
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

	SELECT @MERGED_ROWS = @@ROWCOUNT;

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
