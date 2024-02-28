/* ==================================================================================================================================================== 
Author:			Paul B. Felix (+Davide Moraschi)
Create date:	2018-10-02
Modify date:	2019-08-28 Copied from [sis].[SMCS_Merge] and renamed
Modify date:	2020-03-16 Removed natural Key InfoTypeID

-- Description: Merge external table [sis_stage].[InfoType_Diff] into [sis].[InfoType]
====================================================================================================================================================== */
CREATE PROCEDURE [sis].[InfoType_Merge] (@DEBUG      BIT = 'FALSE')
AS
	BEGIN
		SET NOCOUNT ON;

		BEGIN TRY

			DECLARE @ProcName		VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
			DECLARE @ProcessID		UNIQUEIDENTIFIER = NewID(),
					@MERGED_ROWS    INT = 0,
					@LOGMESSAGE    VARCHAR(MAX);

			Declare @MERGE_RESULTS TABLE (
				ACTIONTYPE      NVARCHAR(10) ,
				InfoType_ID   	INT NOT NULL
			);

			EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

			MERGE [sis].[InfoType] AS tgt
			USING [sis_stage].[InfoType] AS src
			ON (src.InfoType_ID = tgt.InfoType_ID)
			WHEN MATCHED AND EXISTS
			(
				SELECT src.Is_Structured
				EXCEPT
				SELECT tgt.Is_Structured
			)
			THEN
				UPDATE SET tgt.Is_Structured = src.Is_Structured
			WHEN NOT MATCHED BY TARGET
			THEN
				INSERT(InfoType_ID, Is_Structured)
				VALUES(src.InfoType_ID, src.Is_Structured)
			WHEN NOT MATCHED BY SOURCE
			THEN DELETE
			OUTPUT $ACTION,
				COALESCE(inserted.InfoType_ID, deleted.InfoType_ID) Number
			INTO @MERGE_RESULTS;

			SELECT @MERGED_ROWS = @@ROWCOUNT;

			SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
																,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
																,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
																,(SELECT MR.ACTIONTYPE
																		,MR.InfoType_ID
																	FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
																	,WITHOUT_ARRAY_WRAPPER),'InfoType Modified Rows');
			EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @MERGED_ROWS;

            Update STATISTICS sis.InfoType with fullscan 

			EXEC sis.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;
		END TRY
		BEGIN CATCH
			DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
			DECLARE @ERROELINE INT= ERROR_LINE()
			SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
			
			EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;
		END CATCH;
	END;
GO

