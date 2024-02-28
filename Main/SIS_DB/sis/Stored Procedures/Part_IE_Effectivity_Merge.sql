/* ==================================================================================================================================================== 
Author		:	Sooraj Parameswaran
Create date	:	2022-05-20
Description	:	Merge from sis_stage.Part_IE_Effectivity to sis.Part_IE_Effectivity
====================================================================================================================================================== */

CREATE PROCEDURE [sis].[Part_IE_Effectivity_Merge] ( @DEBUG BIT = 'FALSE' )
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


			MERGE [sis].[Part_IE_Effectivity] AS tgt
			USING [sis_stage].[Part_IE_Effectivity] AS src
			on src.IE_ID = tgt.IE_ID 
				and src.Part_ID = tgt.Part_ID
				and src.Media_ID = tgt.Media_ID
				and src.SerialNumberPrefix_ID = tgt.SerialNumberPrefix_ID 
				and src.SerialNumberRange_ID = tgt.SerialNumberRange_ID 
			WHEN NOT MATCHED BY TARGET
			THEN
				INSERT (IE_ID, Part_ID, Media_ID, SerialNumberPrefix_ID, SerialNumberRange_ID ) 
				VALUES (src.IE_ID, src.Part_ID, src.Media_ID, src.SerialNumberPrefix_ID, src.SerialNumberRange_ID)
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
																	,WITHOUT_ARRAY_WRAPPER),'Part_IE_Effectivity Modified Rows');
			EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @MERGED_ROWS;

			Update STATISTICS sis.IEPart with fullscan

			EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;

	END;
GO