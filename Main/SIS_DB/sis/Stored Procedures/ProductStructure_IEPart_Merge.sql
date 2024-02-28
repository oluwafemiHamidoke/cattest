-- =============================================
-- Create Date: 11052022
-- Description: Load ProductStructure_IEPart_Relation & ProductStructure Table data into ProductStructure_IEPart
-- =============================================
CREATE PROCEDURE  [sis].[ProductStructure_IEPart_Merge]
AS
BEGIN
	SET XACT_ABORT
		,NOCOUNT ON;

BEGIN TRY
		DECLARE @AFFECTED_ROWS INT = 0
			,@LOGMESSAGE VARCHAR(MAX)
			,@ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			,@ProcessID UNIQUEIDENTIFIER = NEWID()
			,@DEFAULT_ORGCODE VARCHAR(12) = SISWEB_OWNER_STAGING._getDefaultORGCODE();

		EXEC sis.WriteLog @PROCESSID = @ProcessID
			,@LOGTYPE = 'Information'
			,@NAMEOFSPROC = @ProcName
			,@LOGMESSAGE = 'Execution started'
			,@DATAVALUE = NULL;

		BEGIN TRANSACTION;

			EXEC sis.WriteLog @PROCESSID = @ProcessID
				,@LOGTYPE = 'Information'
				,@NAMEOFSPROC = @ProcName
				,@LOGMESSAGE = 'Begin Merge'
				,@DATAVALUE = @AFFECTED_ROWS;

			MERGE sis.ProductStructure_IEPart AS TARGET
			USING (SELECT 
					 psiep.ProductStructure_ID
					,psiep.IEPart_ID
					,psiep.Media_ID
					,ps.Parentage
					,ps.ParentProductStructure_ID
					FROM sis.ProductStructure ps
						INNER JOIN sis.ProductStructure_IEPart_Relation psiep ON (ps.ProductStructure_ID=psiep.ProductStructure_ID)
						group by 
					 psiep.ProductStructure_ID
					,psiep.IEPart_ID
					,psiep.Media_ID
					,ps.Parentage
					,ps.ParentProductStructure_ID
					) AS SOURCE
			ON (
					TARGET.[IEPart_ID] 		 			= SOURCE.[IEPart_ID] 		 		  AND
					TARGET.[Media_ID] 		 			= SOURCE.[Media_ID] 		 		  AND
					TARGET.[ProductStructure_ID] 		= SOURCE.[ProductStructure_ID]	      AND
					TARGET.[ParentProductStructure_ID] 	= SOURCE.[ParentProductStructure_ID] 	  
				)
			WHEN MATCHED AND 
					(
					TARGET.Parentage              <> SOURCE.Parentage 
					)
						THEN
							UPDATE
							SET TARGET.Parentage              = SOURCE.Parentage 
			WHEN NOT MATCHED BY TARGET
						THEN
							INSERT (
								ProductStructure_ID
								,IEPart_ID
								,Media_ID
								,Parentage
								,ParentProductStructure_ID
								)
							VALUES (
								SOURCE.ProductStructure_ID
								,SOURCE.IEPart_ID
								,SOURCE.Media_ID
								,SOURCE.Parentage
								,SOURCE.ParentProductStructure_ID
								)
					WHEN NOT MATCHED BY SOURCE
						THEN
							DELETE;
			EXEC sis.WriteLog @PROCESSID = @ProcessID
				,@LOGTYPE = 'Information'
				,@NAMEOFSPROC = @ProcName
				,@LOGMESSAGE = 'Merge Completed'
				,@DATAVALUE = @AFFECTED_ROWS;


		COMMIT;

		WAITFOR DELAY '00:00:01'

		EXEC sis.WriteLog @PROCESSID = @ProcessID
			,@LOGTYPE = 'Information'
			,@NAMEOFSPROC = @ProcName
			,@LOGMESSAGE = 'Execution Completed'
			,@DATAVALUE = NULL;
END TRY

BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
			,@ERRORLINE INT = ERROR_LINE();

		SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s', CAST(@ERRORLINE AS VARCHAR(10)), CAST(@ERRORMESSAGE AS VARCHAR(4000)));

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		EXEC sis.WriteLog @PROCESSID = @ProcessID
			,@LOGTYPE = 'Error'
			,@NAMEOFSPROC = @ProcName
			,@LOGMESSAGE = @LOGMESSAGE
			,@DATAVALUE = NULL;

		RAISERROR (
				@LOGMESSAGE
				,17
				,1
				)
		WITH NOWAIT;
END CATCH
END
GO