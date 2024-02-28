-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20230410
-- Description: Merge external table [sis_stage].[CCRMedia] into [sis].[CCRMedia]
-- =============================================
CREATE PROCEDURE [sis].[CCRMedia_Merge]
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

		MERGE [sis].[CCRMedia] AS x
			USING [sis_stage].[CCRMedia] AS s
			ON (s.[CCRMedia_ID] = x.[CCRMedia_ID])
			WHEN MATCHED AND EXISTS
			(
			SELECT s.[SerialNumberPrefix_ID], s.[RepairTypeIndicator], s.[SerialNumberRange_ID], s.[LastModifiedDate]
			EXCEPT
			SELECT x.[SerialNumberPrefix_ID], x.[RepairTypeIndicator], x.[SerialNumberRange_ID], x.[LastModifiedDate]
			)
			THEN
		UPDATE SET x.[SerialNumberPrefix_ID]	= s.[SerialNumberPrefix_ID],
				   x.[RepairTypeIndicator]	= s.[RepairTypeIndicator],
				   x.[SerialNumberRange_ID]	= s.[SerialNumberRange_ID],
				   x.[LastModifiedDate]		= s.[LastModifiedDate]
			WHEN NOT MATCHED BY TARGET
			THEN
		INSERT([CCRMedia_ID],[SerialNumberPrefix_ID], [RepairTypeIndicator], [SerialNumberRange_ID], [LastModifiedDate])
		VALUES(s.[CCRMedia_ID], s.[SerialNumberPrefix_ID], s.[RepairTypeIndicator], s.[SerialNumberRange_ID], s.[LastModifiedDate])
			OUTPUT $ACTION,
			COALESCE(inserted.[CCRMedia_ID], deleted.[CCRMedia_ID]) Number
		INTO @MERGE_RESULTS;
	
		SELECT @MERGED_ROWS = @@ROWCOUNT;
		
		SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
				,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
				,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
				,(SELECT MR.ACTIONTYPE
					,MR.Number
					FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER),'CCRMedia Modified Rows');

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

		Update STATISTICS [sis].[CCRMedia] with fullscan

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

	END TRY

	BEGIN CATCH

		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
		DECLARE @ERROELINE INT= ERROR_LINE()

		SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

	END CATCH

END