
-- =============================================
-- Author:      Madhukar Bhandari
-- Create Date: 20220615
-- Description: Merge from etl_stage.SerialNumber to sis.SerialNumber
-- =============================================
CREATE PROCEDURE etl_stage.UDPS_EPS_Merge_SerialNumber (@FORCE_LOAD BIT = 'FALSE'
											,@DEBUG      BIT = 'FALSE') 
AS
BEGIN
	SET XACT_ABORT,NOCOUNT ON;
	BEGIN TRY
		DECLARE @PROCNAME    VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@MERGED_ROWS BIGINT           = 0
			   ,@PROCESSID   UNIQUEIDENTIFIER = NEWID()
			   ,@LOGMESSAGE  VARCHAR(MAX);

		DECLARE @MERGE_RESULTS TABLE (ACTIONTYPE   NVARCHAR(10)
									 ,SerialNumber CHAR(8) NOT NULL
									 ,Build_Date   DATETIME2(0));

		BEGIN TRANSACTION;
		EXEC etl_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;


		/* MERGE command */
			 MERGE INTO sis.SerialNumber tgt
			 USING etl_stage.SerialNumber AS src
			 ON src.SerialNumber = tgt.SerialNumber
			 WHEN MATCHED AND EXISTS
			 (
				 SELECT src.Build_Date
				 EXCEPT
				 SELECT tgt.Build_Date
			 )
				   THEN UPDATE SET tgt.Build_Date = src.Build_Date
			 WHEN NOT MATCHED BY TARGET
				   THEN
				   INSERT(SerialNumber,Build_Date)
				   VALUES (src.SerialNumber,src.Build_Date) 
			 --WHEN NOT MATCHED BY SOURCE
			 --   THEN DELETE     
			 OUTPUT $ACTION,COALESCE(inserted.SerialNumber,deleted.SerialNumber) SerialNumber,COALESCE(inserted.Build_Date,deleted.Build_Date) Build_Date
					INTO @MERGE_RESULTS;

		/* MERGE command */
		SELECT @MERGED_ROWS = @@ROWCOUNT;

		SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
		(
			SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE')
			AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
			(
				SELECT MR.ACTIONTYPE,MR.SerialNumber,MR.Build_Date
				FROM @MERGE_RESULTS AS MR FOR JSON AUTO
			) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
		),'Modified Rows');
		EXEC etl_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
		COMMIT;
		EXEC etl_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;
		DROP TABLE IF EXISTS #SERIALNUMBERS;
	END TRY
	BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
			   ,@ERRORLINE    INT            = ERROR_LINE()
			   ,@ERRORNUM     INT            = ERROR_NUMBER();
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
		EXEC etl_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @ERRORNUM;
	END CATCH;
END;