CREATE PROCEDURE [sis_stage].[UDSP_SIS2ETL_SSF_Load_FlashFileMetadata] (@flashFileMetadata [varchar](MAX))
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET XACT_ABORT,NOCOUNT ON;
	BEGIN TRY

        DECLARE @PROCNAME                     VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID),
                @PROCESSID                    UNIQUEIDENTIFIER = NEWID(),
                @LOGMESSAGE                   VARCHAR(MAX);

        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

	BEGIN TRANSACTION;

		SELECT * INTO #fileMetadata FROM openjson(replace(@flashFileMetadata, '\', ''))
		with (
			[fileType]          varchar(20),
			[fileName]          varchar(100),
			[language]          varchar(6),
			[isExists]          bit,
			[fileRid]           int,
			[parentFileRid]  int,
			[mimeType]          varchar(1),
			[fileSize]          bigint
		)

		SELECT fileRid into #deleteRecords FROM #fileMetadata WHERE fileType = 'flashFile' AND isExists = 1

		DELETE FROM sis_stage.ServiceFile_ReplacementHierarchy_Syn
			WHERE ServiceFile_ID IN (SELECT fileRid FROM #deleteRecords) or
			Replacing_ServiceFile_ID IN (SELECT fileRid FROM #deleteRecords)

		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Record deleted from ServiceFile_ReplacementHierarchy_Syn table',@DATAVALUE = NULL;

		DELETE FROM sis_stage.ServiceFile_SearchCriteria_Syn
			WHERE ServiceFile_ID  IN (SELECT fileRid FROM #deleteRecords)

		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Record deleted from ServiceFile_SearchCriteria_Syn table',@DATAVALUE = NULL;

		DELETE dtt
			FROM sis_stage.[ServiceFile_DisplayTerms_Translation_Syn] dtt
			INNER JOIN sis_stage.[ServiceFile_DisplayTerms_Syn] dt
			ON dtt.ServiceFile_DisplayTerms_ID = dt.ServiceFile_DisplayTerms_ID
			WHERE dt.ServiceFile_ID IN (SELECT fileRid FROM #deleteRecords)

		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Record deleted from ServiceFile_DisplayTerms_Translation_Syn table',@DATAVALUE = NULL;

		DELETE FROM sis_stage.[ServiceFile_DisplayTerms_Syn] WHERE ServiceFile_ID IN (SELECT fileRid FROM #deleteRecords)

		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Record deleted from ServiceFile_DisplayTerms_Syn table',@DATAVALUE = NULL;

		;with cte as (
					SELECT ServiceFile_ID FROM sis_stage.ServiceFile_Reference_Syn  WHERE ServiceFile_ID  IN (SELECT fileRid FROM #deleteRecords)
					UNION ALL
					SELECT child.Referred_ServiceFile_ID FROM sis_stage.ServiceFile_Reference_Syn child
					INNER JOIN cte c
					ON child.ServiceFile_ID= c.ServiceFile_ID
					)
		select * into #deleteFileId from cte

		DELETE from sis_stage.ServiceFile_Reference_Syn where ServiceFile_ID in (select ServiceFile_ID from #deleteFileId union SELECT fileRid FROM #deleteRecords)
		DELETE FROM sis_stage.ServiceFile_Syn where ServiceFile_ID in (select ServiceFile_ID from #deleteFileId  union SELECT fileRid FROM #deleteRecords)

		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Record deleted from ServiceFile_Syn & ServiceFile_Reference_Syn table',@DATAVALUE = NULL;

		INSERT INTO [sis_stage].[ServiceFile_Syn] ([ServiceFile_ID],[InfoType_ID],[ServiceFile_Name],[Available_Flag],[Mime_Type],[ServiceFile_Size],[Updated_Date],[Created_Date],[Insert_Date])
			SELECT [fileRid], 41, [fileName],'Y',[mimeType],[fileSize] ,GETDATE(),GETDATE(),GETDATE()
			FROM #fileMetadata

		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Record inserted into ServiceFile_Syn table',@DATAVALUE = NULL;

		INSERT INTO sis_stage.ServiceFile_Reference_Syn ([ServiceFile_ID], [Referred_ServiceFile_ID], [Language_ID])
			SELECT fm.parentFileRid, fm.fileRid, l.Language_ID FROM #fileMetadata fm
			INNER JOIN [sis].[Language] l
			ON fm.[language] = l.Legacy_Language_Indicator and [Default_Language] = 1
			WHERE fm.parentFileRid is not null

		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Record inserted into ServiceFile_Reference_Syn table',@DATAVALUE = NULL;

		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

		COMMIT;

	END TRY
	BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
			   ,@ERRORLINE    INT            = ERROR_LINE()
			   ,@ERRORNUM     INT            = ERROR_NUMBER();
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @ERRORNUM;
		THROW 70000,@LOGMESSAGE,1;
	END CATCH;
END;
GO