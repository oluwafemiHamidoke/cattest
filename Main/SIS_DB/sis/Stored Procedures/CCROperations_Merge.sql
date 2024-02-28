-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20230410
-- Description: Merge external table [sis_stage].[CCROperations] into [sis].[CCROperations]
-- =============================================
CREATE PROCEDURE [sis].[CCROperations_Merge]
(@DEBUG      BIT = 'FALSE')
AS
BEGIN
    SET NOCOUNT ON

	BEGIN TRY

		DECLARE @MERGED_ROWS                   INT              = 0
			   ,@LOGMESSAGE                    VARCHAR(MAX);

		Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
		Declare @ProcessID uniqueidentifier = NewID()

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

		DECLARE @MERGE_RESULTS TABLE
		(ACTIONTYPE         NVARCHAR(10)
		,Number         VARCHAR(50) NOT NULL
		);

		MERGE [sis].[CCROperations] AS x
			USING [sis_stage].[CCROperations] AS s
			ON (s.[Operation_ID] = x.[Operation_ID])
			WHEN MATCHED AND EXISTS
			(
			SELECT s.[Segment_ID], s.[Operation], s.[OperationNumber], s.[ComponentCode], s.[JobCode], s.[ModifierCode], s.[LastModifiedDate]
			EXCEPT
			SELECT x.[Segment_ID], x.[Operation], x.[OperationNumber], x.[ComponentCode] , x.[JobCode], x.[ModifierCode], x.[LastModifiedDate]
			)
			THEN
		UPDATE SET x.[Segment_ID]		= s.[Segment_ID],
				   x.[Operation]		= s.[Operation],
				   x.[OperationNumber]	= s.[OperationNumber],
				   x.[ComponentCode]	= s.[ComponentCode],
				   x.[JobCode]			= s.[JobCode],
				   x.[ModifierCode]		= s.[ModifierCode],
				   x.[LastModifiedDate]	= s.[LastModifiedDate]
			WHEN NOT MATCHED BY TARGET
			THEN
		INSERT([Operation_ID], [Segment_ID], [Operation], [OperationNumber], [ComponentCode], [JobCode], [ModifierCode], [LastModifiedDate])
		VALUES([Operation_ID], s.[Segment_ID], s.[Operation], s.[OperationNumber], s.[ComponentCode], s.[JobCode], s.[ModifierCode], s.[LastModifiedDate])
			OUTPUT $ACTION,
			COALESCE(inserted.[Operation_ID], deleted.[Operation_ID]) Number
		INTO @MERGE_RESULTS;
	
		SELECT @MERGED_ROWS = @@ROWCOUNT;
		
		SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
				,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
				,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
				,(SELECT MR.ACTIONTYPE
					,MR.Number
					FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER),'CCROperations Modified Rows');

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

		Update STATISTICS [sis].[CCROperations] with fullscan

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

	END TRY

	BEGIN CATCH

		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
		DECLARE @ERROELINE INT= ERROR_LINE()

		SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

	END CATCH

END