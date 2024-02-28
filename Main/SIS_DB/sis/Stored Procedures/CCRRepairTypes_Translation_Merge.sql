-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20230410
-- Description: Merge table [sis_stage].[CCRRepairTypes_Translation] into [sis].[CCRRepairTypes_Translation]
-- =============================================
CREATE PROCEDURE [sis].[CCRRepairTypes_Translation_Merge]
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

		MERGE [sis].[CCRRepairTypes_Translation] AS x
			USING [sis_stage].[CCRRepairTypes_Translation] AS s
			ON (s.[CCRRepairTypes_ID] = x.[CCRRepairTypes_ID] and s.Language_ID = x.Language_ID)
			WHEN MATCHED AND EXISTS
			(
			SELECT s.[RepairType], s.[RepairTypeDescription]
			EXCEPT
			SELECT x.[RepairType], x.[RepairTypeDescription]
			)
			THEN
		UPDATE SET x.Language_ID	= s.Language_ID,
				   x.[RepairType]	= s.[RepairType],
				   x.[RepairTypeDescription]	= s.[RepairTypeDescription]
			WHEN NOT MATCHED BY TARGET
			THEN
		INSERT([CCRRepairTypes_ID],Language_ID, [RepairType] ,[RepairTypeDescription])
		VALUES(s.[CCRRepairTypes_ID], s.Language_ID, s.[RepairType], s.[RepairTypeDescription])
		WHEN NOT MATCHED BY SOURCE
			THEN
			DELETE
			OUTPUT $ACTION,
			COALESCE(inserted.[CCRRepairTypes_ID], deleted.[CCRRepairTypes_ID]) Number
		INTO @MERGE_RESULTS;
	
		SELECT @MERGED_ROWS = @@ROWCOUNT;
		
		SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
				,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
				,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
				,(SELECT MR.ACTIONTYPE
					,MR.Number
					FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER),'CCRRepairTypes_Translation Modified Rows');

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

		Update STATISTICS [sis].[CCRRepairTypes_Translation] with fullscan

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

	END TRY

	BEGIN CATCH

		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
		DECLARE @ERROELINE INT= ERROR_LINE()

		SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

	END CATCH

END