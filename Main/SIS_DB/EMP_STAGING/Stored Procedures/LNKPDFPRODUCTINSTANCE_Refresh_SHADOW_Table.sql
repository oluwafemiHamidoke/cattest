﻿CREATE PROCEDURE EMP_STAGING.LNKPDFPRODUCTINSTANCE_Refresh_SHADOW_Table (@DEBUG BIT = 'FALSE')
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET XACT_ABORT,NOCOUNT ON;
	BEGIN TRY

		DECLARE @MERGED_ROWS BIGINT           = 0
			   ,@PROCNAME    VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@PROCESSID   UNIQUEIDENTIFIER = NEWID()
			   ,@LOGMESSAGE  VARCHAR(MAX);

		DECLARE @MERGE_RESULTS TABLE ([ACTIONTYPE]            NVARCHAR(10),
		                              [PARTSPDF_ID]           INT    NOT NULL,
                                      [EMPPRODUCTINSTANCE_ID] INT    NOT NULL);

		BEGIN TRANSACTION;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

		/* MERGE command */
		MERGE INTO SISWEB_OWNER_SHADOW.LNKPDFPRODUCTINSTANCE tgt
		USING SISWEB_OWNER.LNKPDFPRODUCTINSTANCE src
		ON src.PARTSPDF_ID                  = tgt.PARTSPDF_ID AND
           src.EMPPRODUCTINSTANCE_ID        = tgt.EMPPRODUCTINSTANCE_ID
            WHEN NOT MATCHED BY TARGET
            THEN
            INSERT(PARTSPDF_ID, EMPPRODUCTINSTANCE_ID)
            VALUES (src.PARTSPDF_ID,src.EMPPRODUCTINSTANCE_ID)
            WHEN NOT MATCHED BY SOURCE
            THEN DELETE
        OUTPUT $ACTION,COALESCE(inserted.PARTSPDF_ID,deleted.PARTSPDF_ID) PARTSPDF_ID,
                       COALESCE(inserted.EMPPRODUCTINSTANCE_ID,deleted.EMPPRODUCTINSTANCE_ID) EMPPRODUCTINSTANCE_ID
		INTO @MERGE_RESULTS;

		/* MERGE command */
		SELECT @MERGED_ROWS = @@ROWCOUNT;
		SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
		(
			SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE')
			AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
			(
                SELECT MR.ACTIONTYPE,MR.PARTSPDF_ID,MR.EMPPRODUCTINSTANCE_ID
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