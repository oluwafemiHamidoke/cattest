﻿
-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20191119
-- Modify Date: 20191218 - Davide: added @DEBUG parameter and [LASTMODIFIEDDATE] column
-- Modify Date: 20201120 - Davide: added UPDATE STATS see: https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/86007
-- Description: Conditional load from STAGING MASPRODUCTSTRUCTURE
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.MASPRODUCTSTRUCTURE_Merge (@FORCE_LOAD BIT = 'FALSE'
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
		DECLARE @MERGE_RESULTS TABLE (ACTIONTYPE                  NVARCHAR(10)
									 ,PRODUCTSTRUCTUREID          CHAR(8) NOT NULL
									 ,LANGUAGEINDICATOR           VARCHAR(2) NOT NULL
									 ,PARENTPRODUCTSTRUCTUREID    CHAR(8) NOT NULL
									 ,PRODUCTSTRUCTUREDESCRIPTION NVARCHAR(192) NOT NULL
									 ,PARENTAGE                   NUMERIC(1,0) NOT NULL
									 ,MISCSPNINDICATOR            CHAR(1) NOT NULL);

		BEGIN TRANSACTION;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

		IF @FORCE_LOAD = 'FALSE'
		BEGIN
            EXEC @MODIFIED_ROWS_PERCENTAGE = [SISWEB_OWNER_STAGING].[_getModifiedRowsPercentage] @SISWEB_OWNER_TABLE='MASPRODUCTSTRUCTURE', @SISWEB_OWNER_STAGING_TABLE = 'MASPRODUCTSTRUCTURE'
		END;

		IF @FORCE_LOAD = 'TRUE' OR 
		   @MODIFIED_ROWS_PERCENTAGE BETWEEN 0 AND 10
		BEGIN
			SET @LOGMESSAGE = 'Executing load: ' + IIF(@FORCE_LOAD = 1,'Force Load = TRUE','Force Load = FALSE');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

			/* MERGE command */
			MERGE INTO SISWEB_OWNER.MASPRODUCTSTRUCTURE tgt
			USING SISWEB_OWNER_STAGING.MASPRODUCTSTRUCTURE src
			ON src.PRODUCTSTRUCTUREID = tgt.PRODUCTSTRUCTUREID AND 
			   src.LANGUAGEINDICATOR = tgt.LANGUAGEINDICATOR AND 
			   src.PARENTPRODUCTSTRUCTUREID = tgt.PARENTPRODUCTSTRUCTUREID
			WHEN MATCHED AND EXISTS
			(
				SELECT src.PRODUCTSTRUCTUREDESCRIPTION,src.PARENTAGE,src.MISCSPNINDICATOR
				EXCEPT
				SELECT tgt.PRODUCTSTRUCTUREDESCRIPTION,tgt.PARENTAGE,tgt.MISCSPNINDICATOR
			)
				  THEN UPDATE SET tgt.PRODUCTSTRUCTUREDESCRIPTION = src.PRODUCTSTRUCTUREDESCRIPTION,tgt.PARENTAGE = src.PARENTAGE,tgt.MISCSPNINDICATOR = src.MISCSPNINDICATOR,tgt.
				  LASTMODIFIEDDATE = @SYSUTCDATETIME
			WHEN NOT MATCHED BY TARGET
				  THEN
				  INSERT(PRODUCTSTRUCTUREID,LANGUAGEINDICATOR,PARENTPRODUCTSTRUCTUREID,PRODUCTSTRUCTUREDESCRIPTION,PARENTAGE,MISCSPNINDICATOR,LASTMODIFIEDDATE)
				  VALUES (src.PRODUCTSTRUCTUREID,src.LANGUAGEINDICATOR,src.PARENTPRODUCTSTRUCTUREID,src.PRODUCTSTRUCTUREDESCRIPTION,src.PARENTAGE,src.MISCSPNINDICATOR,
				  @SYSUTCDATETIME) 
			WHEN NOT MATCHED BY SOURCE
				  THEN DELETE
			OUTPUT $ACTION,COALESCE(inserted.PRODUCTSTRUCTUREID,deleted.PRODUCTSTRUCTUREID) PRODUCTSTRUCTUREID,COALESCE(inserted.LANGUAGEINDICATOR,deleted.LANGUAGEINDICATOR)
			LANGUAGEINDICATOR,COALESCE(inserted.PARENTPRODUCTSTRUCTUREID,deleted.PARENTPRODUCTSTRUCTUREID) PARENTPRODUCTSTRUCTUREID,COALESCE(inserted.PRODUCTSTRUCTUREDESCRIPTION,
			deleted.PRODUCTSTRUCTUREDESCRIPTION) PRODUCTSTRUCTUREDESCRIPTION,COALESCE(inserted.PARENTAGE,deleted.PARENTAGE) PARENTAGE,COALESCE(inserted.MISCSPNINDICATOR,deleted.
			MISCSPNINDICATOR) MISCSPNINDICATOR
				   INTO @MERGE_RESULTS;

			/* MERGE command */

			SELECT @MERGED_ROWS = @@ROWCOUNT;
			SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
			(
				SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE =
				'UPDATE'
				) AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
				(
					SELECT MR.ACTIONTYPE,MR.PRODUCTSTRUCTUREID,MR.LANGUAGEINDICATOR,MR.PARENTPRODUCTSTRUCTUREID,MR.PRODUCTSTRUCTUREDESCRIPTION,MR.PARENTAGE,MR.MISCSPNINDICATOR
					FROM @MERGE_RESULTS AS MR FOR JSON AUTO
				) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
			),'Modified Rows');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
		END;
		ELSE
		BEGIN
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Skipping load: Row difference outside range (±10%)',
			@DATAVALUE = NULL;
		END;
		COMMIT;

		/* STATS command */
		SET @LOGMESSAGE = 'Updating Statistics';
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;
		UPDATE STATISTICS SISWEB_OWNER.MASPRODUCTSTRUCTURE WITH FULLSCAN;

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
