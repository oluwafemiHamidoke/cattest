-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20231013
-- Description: Merge table [sis_stage].[IELevel_Translation] into [sis].[IELevel_Translation]
-- =============================================
CREATE PROCEDURE [sis].[IELevel_Translation_Merge]
(@DEBUG      BIT = 'FALSE')
AS
BEGIN
      SET NOCOUNT ON

	BEGIN TRY

		DECLARE @MERGED_ROWS                   INT              = 0
			,@LOGMESSAGE                   VARCHAR(MAX);

		DECLARE @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
		DECLARE @ProcessID uniqueidentifier = NewID()

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

		DECLARE @MERGE_RESULTS TABLE
		(ACTIONTYPE         NVARCHAR(10)
		,Number         VARCHAR(50) NOT NULL
		);

		MERGE [sis].[IELevel_Translation] AS x
		USING [sis_stage].[IELevel_Translation] AS s
			ON (s.[IELevel_ID] = x.[IELevel_ID] and x.Language_ID	= s.Language_ID)
			WHEN MATCHED AND EXISTS
			(
				SELECT s.[Description], s.Language_ID
				EXCEPT
				SELECT x.[Description], x.Language_ID
			)
			THEN
				UPDATE SET    x.[Description]	= s.[Description]
			WHEN NOT MATCHED BY TARGET
			THEN
				INSERT([IELevel_ID],Language_ID, [Description] )
				VALUES(s.[IELevel_ID], s.Language_ID, s.[Description])
			WHEN NOT MATCHED BY SOURCE
			THEN
				DELETE
			OUTPUT $ACTION,
			COALESCE(inserted.[IELevel_ID], deleted.[IELevel_ID]) Number
		INTO @MERGE_RESULTS;
	
		SELECT @MERGED_ROWS = @@ROWCOUNT;
		
		SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
				,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
				,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
				,(SELECT MR.ACTIONTYPE
					,MR.Number
				 FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
				   ,WITHOUT_ARRAY_WRAPPER),'IELevel_Translation Modified Rows');

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

		Update STATISTICS [sis].[IELevel_Translation] with fullscan

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

	END TRY

	BEGIN CATCH

		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
		DECLARE @ERROELINE INT= ERROR_LINE()

		SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

	END CATCH

END;
