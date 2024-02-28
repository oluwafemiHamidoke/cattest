/* ==================================================================================================================================================== 
-- Author:			Paul B. Felix
-- Create date:	2018-08-30
-- Modify Date:	20200302 Added Media_ID to [IE_Effectivity]
-- Description: Merge external table [sis_stage].[IE_Effectivity] into [sis].[IE_Effectivity]
				No updates.  All fields are part of the composite PKey.
-- Exec [sis].[IE_Effectivity_Merge]
====================================================================================================================================================== */
CREATE PROCEDURE [sis].[IE_Effectivity_Merge] ( @DEBUG BIT = 'FALSE' )
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


			MERGE [sis].[IE_Effectivity] AS tgt
			USING [sis_stage].[IE_Effectivity] AS src
			on src.IE_ID = tgt.IE_ID 
				and src.SerialNumberPrefix_ID = tgt.SerialNumberPrefix_ID 
				and src.SerialNumberRange_ID = tgt.SerialNumberRange_ID 
				and src.Media_ID = tgt.Media_ID
			WHEN NOT MATCHED BY TARGET
			THEN
				INSERT (IE_ID, SerialNumberPrefix_ID, SerialNumberRange_ID, Media_ID) 
				VALUES (src.IE_ID, src.SerialNumberPrefix_ID, src.SerialNumberRange_ID, src.Media_ID)
			WHEN NOT MATCHED BY SOURCE
			THEN DELETE
			OUTPUT $ACTION,
				COALESCE(inserted.IE_ID, deleted.IE_ID) Number
			INTO @MERGE_RESULTS;

			SELECT @MERGED_ROWS = @@ROWCOUNT;

			SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
																,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
																,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
																,(SELECT MR.ACTIONTYPE
																		,MR.Number
																	FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
																	,WITHOUT_ARRAY_WRAPPER),'IE_Effectivity Modified Rows');
			EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @MERGED_ROWS;

			Update STATISTICS sis.IEPart with fullscan

			EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;

	END;
GO

