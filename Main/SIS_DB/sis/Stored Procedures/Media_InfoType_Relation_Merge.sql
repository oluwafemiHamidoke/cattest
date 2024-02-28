


/* ==================================================================================================================================================== 
-- Author:	Paul B. Felix
-- Create date:	2018-08-30
-- Description: Merge external table [sis_stage].[Media_InfoType_Relation_Merge] into [sis].[Media_InfoType_Relation_Merge]
--				No update is done; All fields are part of composite key.
-- Exec [sis].[Media_InfoType_Relation_Merge]
====================================================================================================================================================== */
CREATE PROCEDURE [sis].[Media_InfoType_Relation_Merge] ( @DEBUG BIT = 'FALSE' )
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


			MERGE [sis].[Media_InfoType_Relation] AS tgt
			USING [sis_stage].[Media_InfoType_Relation] AS src
			on src.Media_ID = tgt.Media_ID and src.InfoType_ID = tgt.InfoType_ID
			WHEN NOT MATCHED BY TARGET
			THEN
				INSERT (Media_ID, InfoType_ID)
				VALUES (src.Media_ID, src.InfoType_ID)
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
																	,WITHOUT_ARRAY_WRAPPER),'Media_InfoType_Relation Modified Rows');
			EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @MERGED_ROWS;

			Update STATISTICS sis.IEPart with fullscan

			EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;

	END;