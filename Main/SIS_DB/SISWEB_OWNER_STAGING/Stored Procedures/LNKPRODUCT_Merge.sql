﻿
-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20191119
-- Modify Date: 20191218 - Davide: added @DEBUG parameter and [LASTMODIFIEDDATE] column
-- Modify Date: 20201120 - Davide: added UPDATE STATS see: https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/86007
-- Description: Conditional load from STAGING LNKPRODUCT
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.LNKPRODUCT_Merge (@FORCE_LOAD BIT = 'FALSE'
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
		DECLARE @MERGE_RESULTS TABLE (ACTIONTYPE           NVARCHAR(10)
									 ,ID                   INT NOT NULL
									 ,PRODUCTCODE          VARCHAR(4) NOT NULL
									 ,SEQUENCENUMBER       SMALLINT NOT NULL
									 ,SALESMODELNO         VARCHAR(21) NOT NULL
									 ,SNP                  VARCHAR(10) NOT NULL
									 ,SALESMODELSEQNO      SMALLINT NOT NULL
									 ,STATUSINDICATOR      VARCHAR(1) NOT NULL
									 ,CCRINDICATOR         VARCHAR(1) NOT NULL
									 ,FREQUENCY            VARCHAR(1) NULL
									 ,SHIPPEDDATE          DATETIME2(0) NULL
									 ,CLASSICPARTINDICATOR VARCHAR(1) NOT NULL);

		BEGIN TRANSACTION;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

		IF @FORCE_LOAD = 'FALSE'
		BEGIN
			EXEC @MODIFIED_ROWS_PERCENTAGE = [SISWEB_OWNER_STAGING].[_getModifiedRowsPercentage] @SISWEB_OWNER_TABLE='LNKPRODUCT', @SISWEB_OWNER_STAGING_TABLE = 'LNKPRODUCT'
		END;

		IF @FORCE_LOAD = 'TRUE' OR 
		   @MODIFIED_ROWS_PERCENTAGE BETWEEN 0 AND 10
		BEGIN
			SET @LOGMESSAGE = 'Executing load: ' + IIF(@FORCE_LOAD = 1,'Force Load = TRUE','Force Load = FALSE');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

			/* MERGE command */
			MERGE INTO SISWEB_OWNER.LNKPRODUCT tgt
			USING SISWEB_OWNER_STAGING.LNKPRODUCT src
			ON src.PRODUCTCODE = tgt.PRODUCTCODE AND 
			   src.SEQUENCENUMBER = tgt.SEQUENCENUMBER AND 
			   src.SALESMODELNO = tgt.SALESMODELNO AND 
			   src.SNP = tgt.SNP
			WHEN MATCHED AND EXISTS
			(
				SELECT src.SALESMODELSEQNO,src.STATUSINDICATOR,src.CCRINDICATOR,src.FREQUENCY,src.SHIPPEDDATE,src.CLASSICPARTINDICATOR
				EXCEPT
				SELECT tgt.SALESMODELSEQNO,tgt.STATUSINDICATOR,tgt.CCRINDICATOR,tgt.FREQUENCY,tgt.SHIPPEDDATE,tgt.CLASSICPARTINDICATOR
			)
				  THEN UPDATE SET tgt.SALESMODELSEQNO = src.SALESMODELSEQNO,tgt.STATUSINDICATOR = src.STATUSINDICATOR,tgt.CCRINDICATOR = src.CCRINDICATOR,tgt.FREQUENCY = src.
				  FREQUENCY,tgt.SHIPPEDDATE = src.SHIPPEDDATE,tgt.CLASSICPARTINDICATOR = src.CLASSICPARTINDICATOR,tgt.LASTMODIFIEDDATE = @SYSUTCDATETIME
			WHEN NOT MATCHED BY TARGET
				  THEN
				  INSERT(PRODUCTCODE,SEQUENCENUMBER,SALESMODELNO,SNP,SALESMODELSEQNO,STATUSINDICATOR,CCRINDICATOR,FREQUENCY,SHIPPEDDATE,CLASSICPARTINDICATOR,LASTMODIFIEDDATE)
				  VALUES (src.PRODUCTCODE,src.SEQUENCENUMBER,src.SALESMODELNO,src.SNP,src.SALESMODELSEQNO,src.STATUSINDICATOR,src.CCRINDICATOR,src.FREQUENCY,src.SHIPPEDDATE,src.
				  CLASSICPARTINDICATOR,@SYSUTCDATETIME) 
			WHEN NOT MATCHED BY SOURCE
				  THEN DELETE
			OUTPUT $ACTION,COALESCE(inserted.ID,deleted.ID) ID,COALESCE(inserted.PRODUCTCODE,deleted.PRODUCTCODE) PRODUCTCODE,COALESCE(inserted.SEQUENCENUMBER,deleted.
			SEQUENCENUMBER) SEQUENCENUMBER,COALESCE(inserted.SALESMODELNO,deleted.SALESMODELNO) SALESMODELNO,COALESCE(inserted.SNP,deleted.SNP) SNP,COALESCE(inserted.
			SALESMODELSEQNO,deleted.SALESMODELSEQNO) SALESMODELSEQNO,COALESCE(inserted.STATUSINDICATOR,deleted.STATUSINDICATOR) STATUSINDICATOR,COALESCE(inserted.CCRINDICATOR,
			deleted.CCRINDICATOR) CCRINDICATOR,COALESCE(inserted.FREQUENCY,deleted.FREQUENCY) FREQUENCY,COALESCE(inserted.SHIPPEDDATE,deleted.SHIPPEDDATE) SHIPPEDDATE,COALESCE(
			inserted.CLASSICPARTINDICATOR,deleted.CLASSICPARTINDICATOR) CLASSICPARTINDICATOR
				   INTO @MERGE_RESULTS;

			/* MERGE command */

			SELECT @MERGED_ROWS = @@ROWCOUNT;
			SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
			(
				SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE =
				'UPDATE'
				) AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
				(
					SELECT MR.ACTIONTYPE,MR.ID,MR.PRODUCTCODE,MR.SEQUENCENUMBER,MR.SALESMODELNO,MR.SNP,MR.SALESMODELSEQNO,MR.STATUSINDICATOR,MR.CCRINDICATOR,MR.FREQUENCY,MR.
					SHIPPEDDATE,MR.CLASSICPARTINDICATOR
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
		UPDATE STATISTICS SISWEB_OWNER.LNKPRODUCT WITH FULLSCAN;

								UPDATE STATISTICS SISWEB_OWNER.LNKPRODUCT WITH FULLSCAN;


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

