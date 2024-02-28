



/* ==================================================================================================================================================== 
-- Author:			Paul B. Felix
-- Create date:	20191114
-- Description: Merge external table [sis_stage].[Media_ProductFamily_Effectivity] into [sis].[Media_ProductFamily_Effectivity]
				No updates.  All fMedialds are part of the composite PKey.
-- Exec [sis].[Media_ProductFamily_Effectivity_Merge]
====================================================================================================================================================== */
CREATE PROCEDURE [sis].[Media_ProductFamily_Effectivity_Merge] ( @DEBUG BIT = 'FALSE' )
AS
	BEGIN
		SET NOCOUNT ON;

		--BEGIN TRY

			Declare @ProcName       VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
					, @ProcessID    uniqueidentifier = NewID()
					, @MERGED_ROWS  INT              = 0
					, @LOGMESSAGE   VARCHAR(MAX);

			Declare @MERGE_RESULTS TABLE (
				ACTIONTYPE      NVARCHAR(10)
				, Number        VARCHAR(50)     NOT NULL
			);


			EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;


			MERGE [sis].[Media_ProductFamily_Effectivity] AS tgt
			USING [sis_stage].[Media_ProductFamily_Effectivity] AS src
			ON src.Media_ID = tgt.Media_ID and src.ProductFamily_ID = tgt.ProductFamily_ID
			WHEN NOT MATCHED BY TARGET
			THEN
				INSERT (Media_ID, ProductFamily_ID, LastModified_Date)
				VALUES (src.Media_ID, src.ProductFamily_ID, GETDATE())
			WHEN NOT MATCHED BY SOURCE
			THEN DELETE
			OUTPUT $ACTION,
				COALESCE(inserted.Media_ID, deleted.Media_ID) Number
			INTO @MERGE_RESULTS;

			SELECT @MERGED_ROWS = @@ROWCOUNT;

			SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
																,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
																,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
																,(SELECT MR.ACTIONTYPE
																		,MR.Number
																	FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
																	,WITHOUT_ARRAY_WRAPPER),'Media_ProductFamily_Effectivity Modified Rows');
			EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @MERGED_ROWS;

			Update STATISTICS sis.IEPart with fullscan

			EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;
	END;