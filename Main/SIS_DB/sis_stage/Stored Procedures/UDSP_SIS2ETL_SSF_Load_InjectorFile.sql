--exec [sis_stage].[UDSP_SIS2ETL_SSF_Load_InjectorFile] '[{"fileName": "1S1027375420-01.trm", "fileSize":1761},{"fileName": "1S1027375338-02.trm", "fileSize":1761},{"fileName": "1S1027375031-01.trm", "fileSize":1761},{"fileName": "1S102737491B-01.trm", "fileSize":1761},{"fileName": "1S102737523F-01.trm", "fileSize":1761},{"fileName": "1S1027375136-01.trm", "fileSize":1761}]',55
CREATE PROCEDURE [sis_stage].[UDSP_SIS2ETL_SSF_Load_InjectorFile]
(
    @fileMetadata [VARCHAR](MAX),
	@infoTypeId INT
)
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

		DROP TABLE IF EXISTS #FILEDETAILS

		CREATE TABLE #FILEDETAILS(
			[ServiceFile_ID]	INT NULL,
			[FileName]			VARCHAR(255),
			[SerialNumber]		VARCHAR(50),
			[FileVersion]		VARCHAR(10),
			[FileSize]			INT,
			[IsNew]				BIT
		)

		DECLARE @LanguageId INT = (Select top 1 Language_ID from sis.Language where Language_Code = 'en' and Default_Language = 1)
		
        ;WITH CTE AS
		(SELECT 
		UPPER([fileName]) [FileName], 
		SUBSTRING([fileName],1,CHARINDEX('-',[fileName])-1) [SerialNumber],
		SUBSTRING([fileName],CHARINDEX('-',[fileName])+1,2) [FileVersion],
		FileSize
		FROM openjson(replace(@fileMetadata, '\', ''))
            with (
                [fileName]  varchar(20),
                [fileSize]  int
            )
		)

		INSERT INTO #FILEDETAILS
		select fsc.ServiceFile_ID, c.*,IIF(fsc.ServiceFile_ID IS NULL,1,0)  from CTE c
		left join sis.ServiceFile_SearchCriteria fsc
		on fsc.Search_Value = c.SerialNumber and Search_Type = 'SN' and InfoType_ID = @infoTypeId

		UPDATE #FILEDETAILS
		SET ServiceFile_ID = NEXT VALUE FOR sis_stage.ServiceFileSeq
		WHERE [IsNew] = 1

		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Inserting records for new files',@DATAVALUE = NULL;

		INSERT INTO [sis_stage].[ServiceFile_Syn] (ServiceFile_ID, InfoType_ID, ServiceFile_Name, Available_Flag, Mime_Type, ServiceFile_Size)
		SELECT src.ServiceFile_ID, @infoTypeId, src.[fileName], 'Y','z',src. [fileSize]
		from #FILEDETAILS src WHERE  IsNew = 1

		INSERT INTO [sis_stage].[ServiceFile_DisplayTerms_Syn]
		SELECT fd.ServiceFile_ID,DtType.type from #FILEDETAILS fd, (SELECT 'FN' type UNION SELECT 'VER' type) as DtType
		where IsNew = 1

		select * from #FILEDETAILS

		INSERT INTO [sis_stage].[ServiceFile_DisplayTerms_Translation_Syn]
		select dt.ServiceFile_DisplayTerms_ID,@LanguageId, IIF(dt.Type = 'FN','C','N'),
		IIF(dt.Type = 'FN',fd.[SerialNumber],fd.[FileVersion]),IIF(dt.Type = 'FN',fd.[SerialNumber],fd.[FileVersion])  from sis_stage.ServiceFile_DisplayTerms dt
		inner join #FILEDETAILS fd on fd.ServiceFile_ID = dt.ServiceFile_ID
		where fd.IsNew = 1

		INSERT INTO sis_stage.ServiceFile_SearchCriteria_Syn
		SELECT ServiceFile_ID,@infoTypeId,'SN',fd.SerialNumber,fd.SerialNumber, NULL,NULL,NULL 
		FROM #FILEDETAILS fd where fd.IsNew = 1
		
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Updating records for existing files',@DATAVALUE = NULL;

		----UPDATE EXISTING RECORDS---
		UPDATE sf
		SET ServiceFile_Name = fd.[fileName],
		ServiceFile_Size = fd.FileSize,
		Available_Flag = 'Y' FROM [sis_stage].[ServiceFile_Syn] sf
		inner join #FILEDETAILS fd
		on fd.ServiceFile_ID = sf.ServiceFile_ID
		Where IsNew = 0

		UPDATE dtt
		set [Value] = FileVersion,
		[Display_Value] =  FileVersion
		from [sis_stage].[ServiceFile_DisplayTerms_Translation] dtt
		inner join sis_stage.ServiceFile_DisplayTerms dt
		on dt.ServiceFile_DisplayTerms_ID = dtt.ServiceFile_DisplayTerms_ID
		inner join #FILEDETAILS fd
		on fd.ServiceFile_ID = dt.ServiceFile_ID
		where Value_Type = 'N' and fd.IsNew = 0

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
END
GO

