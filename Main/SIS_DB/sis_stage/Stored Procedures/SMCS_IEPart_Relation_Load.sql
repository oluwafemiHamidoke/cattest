
-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20200808
-- Modify Date: 20201002 https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/7717/ corrected wrong join on BASEENGCONTROLNO
-- Description: Merge load from SISWEB_OWNER.LNKSERIALPART
-- =============================================
CREATE PROCEDURE sis_stage.SMCS_IEPart_Relation_Load (@FORCE_LOAD BIT = 'FALSE'
													,@DEBUG      BIT = 'FALSE') 
AS
BEGIN
	SET XACT_ABORT,NOCOUNT ON;
	BEGIN TRY
		DECLARE @PROCNAME    VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@MERGED_ROWS BIGINT           = 0
			   ,@PROCESSID   UNIQUEIDENTIFIER = NEWID()
			   ,@LOGMESSAGE  VARCHAR(MAX);

		DECLARE @MERGE_RESULTS TABLE (ACTIONTYPE NVARCHAR(10)
									 ,SMCS_ID    INT NOT NULL
									 ,IEPart_ID  INT NOT NULL
									 ,Media_ID  INT NOT NULL);

		BEGIN TRANSACTION;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

		/* MERGE command */
		WITH SMCS_IEPart_Relation
			 AS (SELECT DISTINCT SMCS.SMCS_ID,I.IEPart_ID, M.Media_ID
                 FROM sis.IEPart AS I
                 JOIN SISWEB_OWNER.LNKMEDIAIEPART AS L ON I.Base_English_Control_Number = CASE
                 																			WHEN IETYPE = 'L' THEN CASE L.BASEENGCONTROLNO
                 																									WHEN '-' THEN L.IESYSTEMCONTROLNUMBER + '-' + L.MEDIANUMBER
                 																										ELSE L.BASEENGCONTROLNO + '-' + L.MEDIANUMBER
                 																									END
                 																							   ELSE CASE L.BASEENGCONTROLNO
                 																									WHEN '-' THEN L.IESYSTEMCONTROLNUMBER
                 																										ELSE L.BASEENGCONTROLNO
                 																									END
                 																							   END
                 JOIN SISWEB_OWNER.LNKIESMCS AS S ON S.IESYSTEMCONTROLNUMBER = L.IESYSTEMCONTROLNUMBER
                 JOIN sis_stage.SMCS AS SMCS ON S.SMCSCOMPCODE = SMCS.SMCSCOMPCODE
                 JOIN sis_stage.Media AS M ON M.Media_Number = L.MediaNumber)
			 MERGE INTO sis.SMCS_IEPart_Relation tgt
			 USING SMCS_IEPart_Relation src
			 ON src.SMCS_ID = tgt.SMCS_ID AND 
				src.IEPart_ID = tgt.IEPart_ID AND
				src.Media_ID = tgt.Media_ID
			 WHEN NOT MATCHED BY TARGET
				   THEN
				   INSERT (SMCS_ID, IEPart_ID, Media_ID, LastModified_Date)
				   VALUES (src.SMCS_ID, src.IEPart_ID, src.Media_ID, GETDATE())
			 --WHEN NOT MATCHED BY SOURCE
				--   THEN DELETE
			 OUTPUT $ACTION, COALESCE(inserted.SMCS_ID, deleted.SMCS_ID) SMCS_ID, COALESCE(inserted.IEPart_ID, deleted.IEPart_ID) IEPart_ID, COALESCE(inserted.Media_ID, deleted.Media_ID) Media_ID
					INTO @MERGE_RESULTS;

		/* MERGE command */
		SELECT @MERGED_ROWS = @@ROWCOUNT;

		SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE', (SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,
		    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated,
		    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
		    (SELECT MR.ACTIONTYPE, MR.SMCS_ID, MR.IEPart_ID, MR.Media_ID FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS Modified_Rows FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		), 'Modified Rows');
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