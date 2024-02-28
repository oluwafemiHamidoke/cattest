﻿-- =============================================
-- Author:      Kuldeep Singh + Mahendra Kundare
-- Create Date: 20210204
-- Modify Date: 
-- Description: Conditional load from STAGING MASCCRSEGMENTS
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.MASCCRSEGMENTS_Merge    
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
            EXEC @MODIFIED_ROWS_PERCENTAGE = [SISWEB_OWNER_STAGING].[_getModifiedRowsPercentage] @SISWEB_OWNER_TABLE='MASCCRSEGMENTS', @SISWEB_OWNER_STAGING_TABLE = 'MASCCRSEGMENTS'
        END;

        IF
           @FORCE_LOAD = 1
           OR @MODIFIED_ROWS_PERCENTAGE BETWEEN 0 AND 10
        BEGIN
            SET @LOGMESSAGE = 'Executing load: ' + IIF(@FORCE_LOAD = 1,'Force Load = TRUE','Force Load = FALSE');
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

            TRUNCATE TABLE SISWEB_OWNER.MASCCRSEGMENTS;
            
            INSERT INTO SISWEB_OWNER.MASCCRSEGMENTS ([SEGMENTRID],[CCRMEDIARID],[SEGMENT],[COMPONENTCODE],[JOBCODE],[MODIFIERCODE],[HOURS],[LASTMODIFIEDDATE])
            SELECT [SEGMENTRID],[CCRMEDIARID],[SEGMENT],[COMPONENTCODE],[JOBCODE],[MODIFIERCODE],[HOURS],[LASTMODIFIEDDATE]
            from SISWEB_OWNER_STAGING.MASCCRSEGMENTS;

            SELECT @RELOADED_ROWS = @@ROWCOUNT;
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Reloaded Rows',@DATAVALUE = @RELOADED_ROWS;
        END;
        ELSE
        BEGIN
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Skipping load: Row difference outside range (±10%)',@DATAVALUE = NULL;
        END;
        COMMIT;

        						UPDATE STATISTICS SISWEB_OWNER.MASCCRSEGMENTS WITH FULLSCAN;

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

