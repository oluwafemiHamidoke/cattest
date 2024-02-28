
-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20200806
-- Description: Merge load from SISWEB_OWNER.LNKSERIALPART
-- =============================================
CREATE PROCEDURE sis_stage.SerialNumber_Media_Relation_Load (@FORCE_LOAD BIT = 'FALSE'
														   ,@DEBUG      BIT = 'FALSE') 
AS
BEGIN
	SET XACT_ABORT,NOCOUNT ON;
	BEGIN TRY
		DECLARE @PROCNAME    VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@MERGED_ROWS BIGINT           = 0
			   ,@PROCESSID   UNIQUEIDENTIFIER = NEWID()
			   ,@LOGMESSAGE  VARCHAR(MAX);

		DECLARE @MERGE_RESULTS TABLE (ACTIONTYPE         NVARCHAR(10)
									 ,SerialNumber_ID    INT NOT NULL
									 ,Media_ID           INT NOT NULL
									 ,Arrangement_Number CHAR(8) NOT NULL);

		BEGIN TRANSACTION;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

		/* MERGE command */
		WITH SerialNumber_Media_Relation
			 AS (SELECT S.SerialNumber_ID,M.Media_ID,a.ARRANGEMENTPARTNUMBER AS Arrangement_Number
				 FROM SISWEB_OWNER.LNKSERIALPART AS a
					  JOIN sis.SerialNumber AS S ON S.SerialNumber = a.SERIALNUMBER
					  JOIN SISWEB_OWNER.LNKMEDIAARRANGEMENT AS b ON a.ARRANGEMENTPARTNUMBER = b.ARRANGEMENTNO
					  JOIN sis.Media AS M ON M.Media_Number = b.MEDIANUMBER)
			 MERGE INTO sis.SerialNumber_Media_Relation tgt
			 USING SerialNumber_Media_Relation AS src
			 ON src.SerialNumber_ID = tgt.SerialNumber_ID AND 
				src.Media_ID = tgt.Media_ID
			 WHEN MATCHED AND EXISTS
			 (
				 SELECT src.Arrangement_Number
				 EXCEPT
				 SELECT tgt.Arrangement_Number
			 )
				   THEN UPDATE SET tgt.Arrangement_Number = src.Arrangement_Number
			 WHEN NOT MATCHED BY TARGET
				   THEN
				   INSERT(SerialNumber_ID,Media_ID,Arrangement_Number)
				   VALUES (src.SerialNumber_ID,src.Media_ID,src.Arrangement_Number) 
			 --WHEN NOT MATCHED BY SOURCE
				--   THEN DELETE
			 OUTPUT $ACTION,COALESCE(inserted.SerialNumber_ID,deleted.SerialNumber_ID) SerialNumber_ID,COALESCE(inserted.Media_ID,deleted.Media_ID) Media_ID,COALESCE(inserted.
			 Arrangement_Number,deleted.Arrangement_Number) Arrangement_Number
					INTO @MERGE_RESULTS;

		/* MERGE command */
		SELECT @MERGED_ROWS = @@ROWCOUNT;

		SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
		(
			SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE')
			AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
			(
				SELECT MR.ACTIONTYPE,MR.SerialNumber_ID,MR.Media_ID,MR.Arrangement_Number
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