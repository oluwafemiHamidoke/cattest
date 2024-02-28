﻿
-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20200512
-- Description: Sync back data from SISWEB_OWNER to SHADOW LNKIEPSID
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.LNKIEPSID_Refresh_SHADOW_Table (@DEBUG BIT = 'FALSE') 
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET XACT_ABORT,NOCOUNT ON;
	BEGIN TRY

		DECLARE @MERGED_ROWS BIGINT           = 0
			   ,@PROCNAME    VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@PROCESSID   UNIQUEIDENTIFIER = NEWID()
			   ,@LOGMESSAGE  VARCHAR(MAX);

		DECLARE @MERGE_RESULTS TABLE (ACTIONTYPE            NVARCHAR(10)
									 ,MEDIANUMBER           VARCHAR(8) NOT NULL
									 ,IESYSTEMCONTROLNUMBER VARCHAR(12) NOT NULL
									 ,PSID                  VARCHAR(8) NOT NULL);

		BEGIN TRANSACTION;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

		/* MERGE command */
		MERGE INTO SISWEB_OWNER_SHADOW.LNKIEPSID tgt
		USING SISWEB_OWNER.LNKIEPSID src
		ON src.MEDIANUMBER = tgt.MEDIANUMBER AND 
		   src.IESYSTEMCONTROLNUMBER = tgt.IESYSTEMCONTROLNUMBER AND 
		   src.PSID = tgt.PSID

		/* can't happen */
		--WHEN MATCHED AND EXISTS(SELECT src.*
		--						EXCEPT
		--						SELECT tgt.*)
		--  THEN UPDATE SET tgt.ATTACHMENTTYPE = src.ATTACHMENTTYPE,tgt.LASTMODIFIEDDATE = @SYSUTCDATETIME
		WHEN NOT MATCHED BY TARGET
			  THEN
			  INSERT(MEDIANUMBER,IESYSTEMCONTROLNUMBER,PSID,LASTMODIFIEDDATE)
			  VALUES (src.MEDIANUMBER,src.IESYSTEMCONTROLNUMBER,src.PSID,src.LASTMODIFIEDDATE) 
		WHEN NOT MATCHED BY SOURCE
			  THEN DELETE
		OUTPUT $ACTION,COALESCE(inserted.MEDIANUMBER,deleted.MEDIANUMBER) MEDIANUMBER,COALESCE(inserted.IESYSTEMCONTROLNUMBER,deleted.IESYSTEMCONTROLNUMBER) IESYSTEMCONTROLNUMBER,
		COALESCE(inserted.PSID,deleted.PSID) PSID
			   INTO @MERGE_RESULTS;

		/* MERGE command */

		SELECT @MERGED_ROWS = @@ROWCOUNT;

		SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
		(
			SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE')
			AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
			(
				SELECT MR.ACTIONTYPE,MR.MEDIANUMBER,MR.IESYSTEMCONTROLNUMBER,MR.PSID
				FROM @MERGE_RESULTS AS MR FOR JSON AUTO
			) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
		),'Modified Rows');
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

		COMMIT;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;
	END TRY
	BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
			   ,@ERRORLINE    INT            = ERROR_LINE()
			   ,@ERRORNUM     INT            = ERROR_NUMBER();
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @ERRORNUM;
	END CATCH;
END;