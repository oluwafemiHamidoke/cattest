create PROCEDURE [SISWEB_OWNER_STAGING].[LNKKITIEMEDIA_Merge]
-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20240215
-- Modify Date: 
-- Description:  Load data into [SISWEB_OWNER].[LNKKITIEMEDIA]
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

BEGIN TRANSACTION;

   	MERGE [SISWEB_OWNER].LNKKITIEMEDIA AS x
	USING [SISWEB_OWNER_STAGING].LNKKITIEMEDIA AS s
	ON (s.IESYSTEMCONTROLNUMBER =  x.IESYSTEMCONTROLNUMBER and s.[MEDIANUMBER] = x.[MEDIANUMBER])
			WHEN NOT MATCHED BY TARGET
			THEN
			INSERT(IESYSTEMCONTROLNUMBER, [MEDIANUMBER])
			VALUES(s.IESYSTEMCONTROLNUMBER, s.[MEDIANUMBER])
	WHEN NOT MATCHED BY SOURCE
		THEN DELETE;

SELECT @MERGED_ROWS = @@ROWCOUNT;

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

Update STATISTICS [SISWEB_OWNER].LNKKITIEMEDIA with fullscan

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

COMMIT;

END TRY

BEGIN CATCH

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
       ,@ERRORLINE    INT            = ERROR_LINE()
       ,@ERRORNUM     INT            = ERROR_NUMBER();

SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @ERRORNUM;

	    IF @@TRANCOUNT > 0
            BEGIN
                ROLLBACK TRANSACTION;
                THROW;
            END

END CATCH

END