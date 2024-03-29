﻿-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20191119
-- Modify Date: 20191218 - Davide: added @DEBUG parameter and [LASTMODIFIEDDATE] column
-- Description: Conditional load from STAGING MV_KITDATA
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.MV_KITDATA_Merge
	(@FORCE_LOAD BIT = 'FALSE'
	,@DEBUG      BIT = 'FALSE') 
AS
BEGIN
	SET XACT_ABORT,NOCOUNT ON;
	BEGIN TRY
		DECLARE @MODIFIED_ROWS_PERCENTAGE      DECIMAL(12,4)    = 0
			   ,@MERGED_ROWS                   INT              = 0
			   ,@PROCNAME                      VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@PROCESSID                     UNIQUEIDENTIFIER = NEWID()
			   ,@LOGMESSAGE                    VARCHAR(MAX)
			   ,@SYSUTCDATETIME                DATETIME2(6)     = SYSUTCDATETIME();
		DECLARE @MERGE_RESULTS TABLE
			(ACTIONTYPE    NVARCHAR(10)
			,PARTNUMBER    VARCHAR(20) NOT NULL
			,KITPARTNUMBER VARCHAR(20) NOT NULL
			,KITPARTNAME   VARCHAR(200) NOT NULL);

		BEGIN TRANSACTION;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

		IF @FORCE_LOAD = 'FALSE'
		BEGIN
            EXEC @MODIFIED_ROWS_PERCENTAGE = [SISWEB_OWNER_STAGING].[_getModifiedRowsPercentage] @SISWEB_OWNER_TABLE='MV_KITDATA', @SISWEB_OWNER_STAGING_TABLE = 'MV_KITDATA'
		END;

		IF
		   @FORCE_LOAD = 1
		   OR @MODIFIED_ROWS_PERCENTAGE BETWEEN 0 AND 10
		BEGIN
			SET @LOGMESSAGE = 'Executing load: ' + IIF(@FORCE_LOAD = 1,'Force Load = TRUE','Force Load = FALSE');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

			/* MERGE command */
			MERGE INTO SISWEB_OWNER.MV_KITDATA tgt
			USING SISWEB_OWNER_STAGING.MV_KITDATA src
			ON
			   src.PARTNUMBER = tgt.PARTNUMBER
			   AND src.KITPARTNUMBER = tgt.KITPARTNUMBER
				WHEN MATCHED AND EXISTS(SELECT src.KITPARTNAME
										EXCEPT
										SELECT tgt.KITPARTNAME)
				  THEN UPDATE SET tgt.KITPARTNAME = src.KITPARTNAME,tgt.LASTMODIFIEDDATE = @SYSUTCDATETIME
				WHEN NOT MATCHED BY TARGET
				  THEN
				  INSERT(PARTNUMBER
						,KITPARTNUMBER
						,KITPARTNAME
						,LASTMODIFIEDDATE)
				  VALUES
				(src.PARTNUMBER
				,src.KITPARTNUMBER
				,src.KITPARTNAME
				,@SYSUTCDATETIME
				) 
				WHEN NOT MATCHED BY SOURCE
				  THEN DELETE
			OUTPUT $ACTION
				  ,COALESCE(inserted.PARTNUMBER,deleted.PARTNUMBER) PARTNUMBER
				  ,COALESCE(inserted.KITPARTNUMBER,deleted.KITPARTNUMBER) KITPARTNUMBER
				  ,COALESCE(inserted.KITPARTNAME,deleted.KITPARTNAME) KITPARTNAME
				   INTO @MERGE_RESULTS;
			/* MERGE command */

			SELECT @MERGED_ROWS = @@ROWCOUNT;
			SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
														,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
														,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
														,(SELECT MR.ACTIONTYPE
																,MR.PARTNUMBER
																,MR.KITPARTNUMBER
																,MR.KITPARTNAME FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS            Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER),'Modified Rows');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
		END;
		ELSE
		BEGIN
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Skipping load: Row difference outside range (±10%)',@DATAVALUE = NULL;
		END;
		COMMIT;

						UPDATE STATISTICS SISWEB_OWNER.MV_KITDATA WITH FULLSCAN;

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

