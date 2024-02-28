-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20231013
-- Description: Merge external table [sis_stage].[IELevel] into [sis].[IELevel]
-- =============================================
CREATE PROCEDURE [sis].[IELevel_Merge]
(@DEBUG      BIT = 'FALSE')
AS
BEGIN
    SET NOCOUNT ON

	BEGIN TRY

		DECLARE @MERGED_ROWS                   INT              = 0
			   ,@LOGMESSAGE                    VARCHAR(MAX);

		DECLARE @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
		DECLARE @ProcessID uniqueidentifier = NewID()

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

		DECLARE @MERGE_RESULTS TABLE
		(ACTIONTYPE         NVARCHAR(10)
		,Number         VARCHAR(50) NOT NULL
		);

		MERGE [sis].[IELevel] AS x
			USING [sis_stage].[IELevel] AS s
			ON (s.[IELevel_ID] = x.[IELevel_ID])
			WHEN MATCHED AND EXISTS
			(
			SELECT s.[IE_ID], s.[LevelSequenceNumber], s.[LevelID], s.[ParentID]
			EXCEPT
			SELECT x.[IE_ID], x.[LevelSequenceNumber], x.[LevelID], x.[ParentID]
			)
			THEN
		UPDATE SET x.[IE_ID]	= s.[IE_ID],
				   x.[LevelSequenceNumber]	= s.[LevelSequenceNumber],
				   x.[LevelID]	= s.[LevelID],
				   x.[ParentID] = s.[ParentID]
			WHEN NOT MATCHED BY TARGET
			THEN
		INSERT([IELevel_ID],[IE_ID],[LevelSequenceNumber], [LevelID], [ParentID])
		VALUES(s.[IELevel_ID],s.[IE_ID], s.[LevelSequenceNumber], s.[LevelID], s.[ParentID])
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
					,WITHOUT_ARRAY_WRAPPER),'IELevel Modified Rows');

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

		Update STATISTICS [sis].[IELevel] with fullscan

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

	END TRY

	BEGIN CATCH

		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
		DECLARE @ERROELINE INT= ERROR_LINE()

		SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

	END CATCH

END;
