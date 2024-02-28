-- =============================================
-- Author:      Mahendra Kundare + Kuldeep Singh
-- Create Date: 20210205
-- Modify Date: 
-- Description: Merge SISWEB_OWNER_STAGING.LNKCCRTECHDOCSNP to SISWEB_OWNER.LNKCCRTECHDOCSNP
-- =============================================	
CREATE PROCEDURE SISWEB_OWNER_STAGING.LNKCCRTECHDOCSNP_Merge
    (@FORCE_LOAD BIT = 'FALSE'
    ,@DEBUG      BIT = 'FALSE')
AS
BEGIN
    SET XACT_ABORT,NOCOUNT ON;
    BEGIN TRY
        DECLARE @MODIFIED_ROWS_PERCENTAGE      DECIMAL(12,4)    = 0
               ,@RELOADED_ROWS                 INT              = 0
               ,@PROCNAME                      VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
               ,@PROCESSID                     UNIQUEIDENTIFIER = NEWID()
               ,@LOGMESSAGE                    VARCHAR(MAX);

        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

        BEGIN TRANSACTION;

        IF @FORCE_LOAD = 'FALSE'
        BEGIN

            EXEC @MODIFIED_ROWS_PERCENTAGE = [SISWEB_OWNER_STAGING].[_getModifiedRowsPercentage] @SISWEB_OWNER_TABLE='LNKCCRTECHDOCSNP', @SISWEB_OWNER_STAGING_TABLE = 'LNKCCRTECHDOCSNP'

        END;

        IF
           @FORCE_LOAD = 1
           OR @MODIFIED_ROWS_PERCENTAGE BETWEEN 0 AND 10
        BEGIN
            SET @LOGMESSAGE = 'Executing load: ' + IIF(@FORCE_LOAD = 1,'Force Load = TRUE','Force Load = FALSE');
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

            TRUNCATE TABLE SISWEB_OWNER.LNKCCRTECHDOCSNP;
            
            INSERT INTO SISWEB_OWNER.LNKCCRTECHDOCSNP (UPDATERID,SNP,BEGINNINGRANGE,ENDRANGE,LASTMODIFIEDDATE)
            SELECT UPDATERID,SNP,BEGINNINGRANGE,ENDRANGE,LASTMODIFIEDDATE
            from SISWEB_OWNER_STAGING.LNKCCRTECHDOCSNP;

            SELECT @RELOADED_ROWS = @@ROWCOUNT;
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Reloaded Rows',@DATAVALUE = @RELOADED_ROWS;
        END;
        ELSE
        BEGIN
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Skipping load: Row difference outside range (±10%)',@DATAVALUE = NULL;
        END;
        COMMIT;

        						UPDATE STATISTICS SISWEB_OWNER.LNKCCRTECHDOCSNP WITH FULLSCAN;

        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;
    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
               ,@ERRORLINE    INT            = ERROR_LINE();

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SET @LOGMESSAGE = 'LINE ' + CAST(@ERRORLINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE;
        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;
    END CATCH;
END;
GO
