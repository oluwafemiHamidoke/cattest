-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20230418
-- Description: Merge external table [sis_stage].[CCRUpdatesIE_Relation] into [sis].[CCRUpdatesIE_Relation]
-- =============================================
CREATE PROCEDURE [sis].[CCRUpdatesIE_Relation_Merge]
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

		MERGE [sis].[CCRUpdatesIE_Relation] AS x
			USING [sis_stage].[CCRUpdatesIE_Relation] AS s
			ON (s.[Update_ID] = x.[Update_ID])
			WHEN MATCHED AND EXISTS
			(
			SELECT s.[Operation_ID], s.[UpdateTypeIndicator], s.[IE_ID]
			EXCEPT
			SELECT x.[Operation_ID], x.[UpdateTypeIndicator], x.[IE_ID] 
			)
			THEN
		UPDATE SET x.[Operation_ID]			= s.[Operation_ID],
				   x.[UpdateTypeIndicator]	= s.[UpdateTypeIndicator],
				   x.[IE_ID]				= s.[IE_ID]
				 
			WHEN NOT MATCHED BY TARGET
			THEN
		INSERT([Update_ID], [Operation_ID], [UpdateTypeIndicator], [IE_ID] )
		VALUES(S.[Update_ID], s.[Operation_ID], s.[UpdateTypeIndicator], s.[IE_ID] )
			OUTPUT $ACTION,
			COALESCE(inserted.[Update_ID], deleted.[Update_ID]) Number
		INTO @MERGE_RESULTS;
	
		SELECT @MERGED_ROWS = @@ROWCOUNT;
		
		SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
				,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
				,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
				,(SELECT MR.ACTIONTYPE
					,MR.Number
					FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER),'CCRUpdatesIE_Relation Modified Rows');

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

		Update STATISTICS [sis].[CCRUpdatesIE_Relation] with fullscan

		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

	END TRY

	BEGIN CATCH

		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
		DECLARE @ERROELINE INT= ERROR_LINE()

		SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
		EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

	END CATCH

END