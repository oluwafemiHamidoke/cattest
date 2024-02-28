-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20200108
-- Description: Test table differences and returns TRUE or FALSE (TRUE = Diff Load, FALSE = Full Load) suggesting which load is needed.
-- =============================================
CREATE PROCEDURE [SISWEB_OWNER_STAGING].[_getFullOrDiff] (@SCHEMANAME      NVARCHAR(128)
													,@TABLENAME       NVARCHAR(128)
													,@CURRENT_VERSION BIGINT
													,@DEBUG           BIT     = 'FALSE'
													,@RESULT          BIT OUTPUT) 
AS
BEGIN
	SET XACT_ABORT,NOCOUNT ON;
--	BEGIN TRY
		DECLARE @PROCESSID     UNIQUEIDENTIFIER = NEWID()
			   ,@PROCNAME      VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@FULLTABLENAME sysname          = @SCHEMANAME + '.' + @TABLENAME;

		-- Gets the latest version that was successfully loaded and the minimum valid version for that table
		DECLARE @LAST_SYNCHRONIZATION_VERSION  BIGINT        = SISWEB_OWNER_STAGING._getLastSynchVersion (@FULLTABLENAME)
			   ,@MIN_VALID_VERSION             BIGINT        = CHANGE_TRACKING_MIN_VALID_VERSION(OBJECT_ID(@FULLTABLENAME))
				--			   ,@CURRENT_VERSION               BIGINT        = CHANGE_TRACKING_CURRENT_VERSION()
			   ,@LOGMESSAGE                    VARCHAR(MAX)
			   ,@SQLCOMMAND                    NVARCHAR(MAX)
			   ,@SISWEB_OWNER_ROWCOUNT         DECIMAL(12,3) = 0
			   ,@SISWEB_OWNER_STAGING_ROWCOUNT DECIMAL(12,3) = 0
			   ,@MODIFIED_ROWS_PERCENTAGE      DECIMAL(12,4) = 0;

		IF @DEBUG = 'TRUE'
		BEGIN
			PRINT FORMATMESSAGE('@FULLTABLENAME=%s',@FULLTABLENAME);
			PRINT FORMATMESSAGE('@LAST_SYNCHRONIZATION_VERSION=%s',FORMAT(@LAST_SYNCHRONIZATION_VERSION,'G','en-us'));
			PRINT FORMATMESSAGE('@MIN_VALID_VERSION=%s',FORMAT(@MIN_VALID_VERSION,'G','en-us'));
			PRINT FORMATMESSAGE('@CURRENT_VERSION=%s',FORMAT(@CURRENT_VERSION,'G','en-us'));
		END;

		-- If the change tracking is not enabled on table logs and error -> RAISE
		IF @MIN_VALID_VERSION IS NULL
		BEGIN
			SET @LOGMESSAGE = FORMATMESSAGE('Change tracking not enabled on the table: %s',@FULLTABLENAME);
			THROW 61001,@LOGMESSAGE,1;
		END;

		-- If there is no record for the last successful load logs and error -> RAISE
		IF @LAST_SYNCHRONIZATION_VERSION IS NULL
		BEGIN
			SET @LOGMESSAGE = FORMATMESSAGE('No record found in _LAST_SYNCHRONIZATION_VERSIONS for table: %s',@FULLTABLENAME);
			THROW 61002,@LOGMESSAGE,1;
		END;

		-- If the latest version is less then the minimum valid, the version is too old we can't run diff, need to reload, logs an error -> RAISE
		IF @LAST_SYNCHRONIZATION_VERSION < @MIN_VALID_VERSION
		BEGIN
			SET @LOGMESSAGE = FORMATMESSAGE('Version %s too old. Run full load on table: %s',CAST(@LAST_SYNCHRONIZATION_VERSION AS VARCHAR(12)),@FULLTABLENAME);
			THROW 61003,@LOGMESSAGE,1;
		END;

		-- If the current version is the same as the last version that was loaded, no need to load -> returns FALSE
		IF @CURRENT_VERSION = @LAST_SYNCHRONIZATION_VERSION
		BEGIN
			SET @LOGMESSAGE = FORMATMESSAGE('Version up to date, skipping load on table: %s',@FULLTABLENAME);
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID
								   ,@LOGTYPE = 'Information'
								   ,@NAMEOFSPROC = @PROCNAME
								   ,@LOGMESSAGE = @LOGMESSAGE
								   ,@DATAVALUE = @CURRENT_VERSION;
			SET @RESULT = 'FALSE';
		END;
		ELSE 
		-- versions are different, check row counts
		BEGIN
			SET @SQLCOMMAND = N'SELECT @SISWEB_OWNER_ROWCOUNT = COUNT_BIG(*) FROM SISWEB_OWNER.' + @TABLENAME;
			EXECUTE sp_executesql @SQLCOMMAND
								 ,N'@SISWEB_OWNER_ROWCOUNT DECIMAL(12,3) OUTPUT'
								 ,@SISWEB_OWNER_ROWCOUNT = @SISWEB_OWNER_ROWCOUNT OUTPUT;
			SET @SQLCOMMAND = N'SELECT @SISWEB_OWNER_STAGING_ROWCOUNT = COUNT_BIG(*) FROM SISWEB_OWNER_STAGING.' + @TABLENAME;
			EXECUTE sp_executesql @SQLCOMMAND
								 ,N'@SISWEB_OWNER_STAGING_ROWCOUNT DECIMAL(12,3) OUTPUT'
								 ,@SISWEB_OWNER_STAGING_ROWCOUNT = @SISWEB_OWNER_STAGING_ROWCOUNT OUTPUT;
			
			IF @SISWEB_OWNER_ROWCOUNT > 0
			BEGIN
				SELECT @MODIFIED_ROWS_PERCENTAGE = (@SISWEB_OWNER_STAGING_ROWCOUNT - @SISWEB_OWNER_ROWCOUNT) / @SISWEB_OWNER_ROWCOUNT;
			END;
			ELSE
			BEGIN
				SELECT @MODIFIED_ROWS_PERCENTAGE = 100;
			END;
			

			IF @DEBUG = 'TRUE'
			BEGIN
				PRINT FORMATMESSAGE('@SISWEB_OWNER_ROWCOUNT=%s',FORMAT(@SISWEB_OWNER_ROWCOUNT,'N','en-us'));
				PRINT FORMATMESSAGE('@SISWEB_OWNER_STAGING_ROWCOUNT=%s',FORMAT(@SISWEB_OWNER_STAGING_ROWCOUNT,'N','en-us'));
				PRINT FORMATMESSAGE('@MODIFIED_ROWS_PERCENTAGE=%s',FORMAT(@MODIFIED_ROWS_PERCENTAGE,'P','en-us'));
			END;

			-- If the row count difference between SISWEB_OWNER and SISWEB_OWNER_STAGING is greater than 10%, logs an error -> returns FALSE
			IF @MODIFIED_ROWS_PERCENTAGE NOT BETWEEN-0.10 AND 0.10
			BEGIN
				SET @LOGMESSAGE = FORMATMESSAGE('Skipping load: Row difference outside range (±10%%) on table: %s',@FULLTABLENAME);
				EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID
									   ,@LOGTYPE = 'Error'
									   ,@NAMEOFSPROC = @PROCNAME
									   ,@LOGMESSAGE = @LOGMESSAGE
									   ,@DATAVALUE = @MODIFIED_ROWS_PERCENTAGE;
				SET @RESULT = 'FALSE';
			END;
				--
			ELSE
			BEGIN 
				-- It's OK to run the Diff Load
				SET @RESULT = 'TRUE';
			END;
		END;
				--
	--END TRY
	--BEGIN CATCH
	--	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
	--		   ,@ERRORLINE    INT            = ERROR_LINE()
	--		   ,@ERRORNUM     INT            = ERROR_NUMBER();

	--	--SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
	--	--EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @ERRORNUM;
	--END CATCH;
END;
GO

