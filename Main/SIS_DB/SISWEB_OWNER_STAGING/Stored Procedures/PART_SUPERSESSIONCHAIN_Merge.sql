CREATE PROCEDURE [SISWEB_OWNER_STAGING].[PART_SUPERSESSIONCHAIN_Merge]
(@DEBUG      BIT = 'FALSE')
AS
BEGIN
      SET NOCOUNT ON

	BEGIN TRY

		DECLARE @MERGED_ROWS                   INT              = 0
				,@LOGMESSAGE                   VARCHAR(MAX);

		DECLARE @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
		DECLARE @ProcessID uniqueidentifier = NewID()

		EXEC sis_stage.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

		DECLARE @MERGE_RESULTS TABLE
		(ACTIONTYPE         NVARCHAR(10)
		,Number         VARCHAR(100) NOT NULL
		);

		MERGE [SISWEB_OWNER].[PART_SUPERSESSIONCHAIN] AS x
		USING [SISWEB_OWNER_STAGING].[PART_SUPERSESSIONCHAIN] AS s
			ON (s.[PART_SUPERSESSIONCHAIN_ID] = x.[PART_SUPERSESSIONCHAIN_ID])
			WHEN MATCHED AND EXISTS
			(
				SELECT s.[PARTNUMBER],s.[CHAIN]
				EXCEPT
				SELECT x.[PARTNUMBER],x.[CHAIN]
			)
			THEN
				UPDATE SET	x.[PARTNUMBER]	= s.[PARTNUMBER],
							x.[CHAIN]	= s.[CHAIN]	
			WHEN NOT MATCHED BY TARGET
			THEN
				INSERT([PART_SUPERSESSIONCHAIN_ID],[PARTNUMBER],[CHAIN])
				VALUES(s.[PART_SUPERSESSIONCHAIN_ID], s.[PARTNUMBER], s.[CHAIN])
			WHEN NOT MATCHED BY SOURCE
			THEN
				DELETE
			OUTPUT $ACTION,
			COALESCE(inserted.[PART_SUPERSESSIONCHAIN_ID], deleted.[PART_SUPERSESSIONCHAIN_ID]) Number
		INTO @MERGE_RESULTS;
	
		SELECT @MERGED_ROWS = @@ROWCOUNT;
		
		SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
				,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
				,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
				,(SELECT MR.ACTIONTYPE
					,MR.Number
				 FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
				   ,WITHOUT_ARRAY_WRAPPER),'[SISWEB_OWNER].[PART_SUPERSESSIONCHAIN] Modified Rows');

		EXEC sis_stage.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

		UPDATE STATISTICS [SISWEB_OWNER].[PART_SUPERSESSIONCHAIN] WITH FULLSCAN

		EXEC sis_stage.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Merge and Update Stats completed for  [SISWEB_OWNER].[PART_SUPERSESSIONCHAIN]',@DATAVALUE = NULL;


		EXEC sis_stage.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

	END TRY

	BEGIN CATCH

		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
		DECLARE @ERROELINE INT= ERROR_LINE()

		SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
		EXEC sis_stage.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

	END CATCH

END;
