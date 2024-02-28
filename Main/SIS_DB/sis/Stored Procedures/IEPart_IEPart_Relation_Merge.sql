CREATE PROCEDURE sis.IEPart_IEPart_Relation_Merge (@DEBUG      BIT = 'FALSE')
AS
	BEGIN
		SET NOCOUNT ON;

		BEGIN TRY

			DECLARE @ProcName 		VARCHAR(200) 		= OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID),
					@ProcessID 		UNIQUEIDENTIFIER 	= NewID(),
					@MERGED_ROWS  	INT              	= 0,
					@LOGMESSAGE   	VARCHAR(MAX);

			Declare @MERGE_RESULTS TABLE (
				ACTIONTYPE      	NVARCHAR(10),
				IEPart_ID        	int NOT NULL,
				Related_IEPart_ID	int NOT NULL,
			    Media_ID            int NOT NULL
			);
			
			EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

			MERGE sis.IEPart_IEPart_Relation tgt
			USING sis_stage.IEPart_IEPart_Relation src
			ON src.IEPart_ID = tgt.IEPart_ID and src.Related_IEPart_ID = tgt.Related_IEPart_ID and src.Media_ID=tgt.Media_ID
			WHEN NOT MATCHED THEN
				INSERT (IEPart_ID, Related_IEPart_ID, Media_ID)
				VALUES (src.IEPart_ID, src.Related_IEPart_ID, src.Media_ID)
			WHEN NOT MATCHED BY SOURCE
				THEN DELETE
			OUTPUT $ACTION,
				COALESCE(inserted.IEPart_ID, deleted.IEPart_ID) IEPart_ID, 
				COALESCE(inserted.Related_IEPart_ID, deleted.Related_IEPart_ID) Related_IEPart_ID,
				COALESCE(inserted.Media_ID, deleted.Media_ID) Media_ID
			INTO @MERGE_RESULTS;

			SELECT @MERGED_ROWS = @@ROWCOUNT;

			SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
																,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
																,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
																,(SELECT MR.ACTIONTYPE
																		,MR.IEPart_ID
																		,MR.Related_IEPart_ID
																	FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
																	,WITHOUT_ARRAY_WRAPPER),'IEPart_IEPart_Relation Modified Rows');
			EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @MERGED_ROWS;

		    Update STATISTICS sis.IEPart_IEPart_Relation with fullscan 

			EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;
		END TRY
		BEGIN CATCH
			DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
			DECLARE @ERROELINE INT= ERROR_LINE()

			SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
			EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = NULL;
		END CATCH;
	END;
GO

