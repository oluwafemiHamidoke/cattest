-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20230410
-- Description: Merge external table [sis_stage].[CCRSegments] into [sis].[CCRSegments]
-- =============================================
CREATE PROCEDURE [sis].[CCRSegments_Merge]
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

		MERGE [sis].[CCRSegments] AS x
			USING [sis_stage].[CCRSegments] AS s
			ON (s.[Segment_ID] = x.[Segment_ID])
			WHEN MATCHED AND EXISTS
			(
			SELECT s.[CCRMedia_ID], s.[Segment], s.[ComponentCode], s.[JobCode],  s.[ModifierCode], s.[Hours], s.[LastModifiedDate]
			EXCEPT
			SELECT x.[CCRMedia_ID], x.[Segment], x.[ComponentCode], x.[JobCode] , x.[ModifierCode], s.[Hours], x.[LastModifiedDate]
			)
			THEN
		UPDATE SET x.[CCRMedia_ID]		= s.[CCRMedia_ID],
				   x.[Segment]			= s.[Segment],
				   x.[ComponentCode]	= s.[ComponentCode],
				   x.[JobCode]			= s.[JobCode],
				   x.[ModifierCode]		= s.[ModifierCode],
				   x.[Hours]			= s.[Hours],
				   x.[LastModifiedDate]	= s.[LastModifiedDate]
			WHEN NOT MATCHED BY TARGET
			THEN
		INSERT([Segment_ID], [CCRMedia_ID], [Segment], [ComponentCode], [JobCode],  [ModifierCode], [Hours], [LastModifiedDate])
		VALUES(s.[Segment_ID], s.[CCRMedia_ID], s.[Segment], s.[ComponentCode], s.[JobCode],  s.[ModifierCode], s.[Hours], s.[LastModifiedDate])
			OUTPUT $ACTION,
			COALESCE(inserted.[Segment_ID], deleted.[Segment_ID]) Number
		INTO @MERGE_RESULTS;
	
		SELECT @MERGED_ROWS = @@ROWCOUNT;
		
		SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
				,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
				,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
				,(SELECT MR.ACTIONTYPE
					,MR.Number
					FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER),'CCRSegments Modified Rows');

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

		Update STATISTICS [sis].[CCRSegments] with fullscan

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

	END TRY

	BEGIN CATCH

		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
		DECLARE @ERROELINE INT= ERROR_LINE()

		SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

	END CATCH

END