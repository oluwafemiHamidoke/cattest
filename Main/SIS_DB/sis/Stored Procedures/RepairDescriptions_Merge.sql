-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20230426
-- Description: Merge table [sis_stage].[RepairDescriptions] into [sis].[RepairDescriptions]
-- =============================================
CREATE PROCEDURE [sis].[RepairDescriptions_Merge]
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

	MERGE [sis].[RepairDescriptions] AS x
			USING [sis_stage].[RepairDescriptions] AS s
			ON (s.[RepairCode] = x.[RepairCode] AND s.[RepairType] = x.[RepairType] )
			WHEN MATCHED AND EXISTS
			(
			SELECT s.[RepairDescriptions_ID]
			EXCEPT
			SELECT x.[RepairDescriptions_ID]
			)
			THEN
		UPDATE SET x.[RepairDescriptions_ID]	= s.[RepairDescriptions_ID]				 
			WHEN NOT MATCHED BY TARGET
			THEN
		INSERT([RepairDescriptions_ID],[RepairCode], [RepairType])
		VALUES(s.[RepairDescriptions_ID], s.[RepairCode], s.[RepairType])
			OUTPUT $ACTION,
			COALESCE(inserted.[RepairDescriptions_ID], deleted.[RepairDescriptions_ID]) Number
		INTO @MERGE_RESULTS;
	
		SELECT @MERGED_ROWS = @@ROWCOUNT;
		
		SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
				,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
				,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
				,(SELECT MR.ACTIONTYPE
					,MR.Number
					FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER),'CCRRepairTypes Modified Rows');

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

		Update STATISTICS [sis].[RepairDescriptions] with fullscan

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

	END TRY

	BEGIN CATCH

		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
		DECLARE @ERROELINE INT= ERROR_LINE()

		SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

	END CATCH

END