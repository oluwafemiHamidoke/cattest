-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20230410
-- Description: Merge external table [sis_stage].[CCRUpdateTypes_Translation] into [sis].[CCRUpdateTypes_Translation]
-- =============================================
CREATE PROCEDURE [sis].[CCRUpdateTypes_Translation_Merge]
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

		MERGE [sis].[CCRUpdateTypes_Translation] AS x
			USING [sis_stage].[CCRUpdateTypes_Translation] AS s
			ON (s.[CCRUpdateTypes_ID] = x.[CCRUpdateTypes_ID] and s.[Language_ID] = x.[Language_ID])
			WHEN MATCHED AND EXISTS
			(
			SELECT s.[UpdateTypeDescription]
			EXCEPT
			SELECT x.[UpdateTypeDescription]
			)
			THEN
		UPDATE SET x.[Language_ID]	= s.[Language_ID],
				   x.[UpdateTypeDescription]		= s.[UpdateTypeDescription]
			WHEN NOT MATCHED BY TARGET
			THEN
		INSERT([CCRUpdateTypes_ID],[Language_ID], [UpdateTypeDescription])
		VALUES(s.[CCRUpdateTypes_ID], s.[Language_ID], s.[UpdateTypeDescription])
			OUTPUT $ACTION,
			COALESCE(inserted.[CCRUpdateTypes_ID], deleted.[CCRUpdateTypes_ID]) Number
		INTO @MERGE_RESULTS;
	
		SELECT @MERGED_ROWS = @@ROWCOUNT;
		
		SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
				,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
				,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
				,(SELECT MR.ACTIONTYPE
					,MR.Number
					FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER),'CCRUpdateTypes_Translation Modified Rows');

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

		Update STATISTICS [sis].[CCRUpdateTypes_Translation] with fullscan

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

	END TRY

	BEGIN CATCH

		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
		DECLARE @ERROELINE INT= ERROR_LINE()

		SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

	END CATCH

END