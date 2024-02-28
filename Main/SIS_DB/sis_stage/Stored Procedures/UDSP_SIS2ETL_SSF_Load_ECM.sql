-- =============================================
-- Author:      Obieda Ananbeh
-- Create Date: 05182023
-- Description: Process ECM file
-- =============================================

--EXEC [sis_stage].[UDSP_SIS2ETL_SSF_Load_ECM2]'{"fileName":"1GZ06035_ENGINE-PRIMARY_2010021622025.XML","fileRid":59353093,"isExists":false,"fileSize":33615}';

CREATE PROCEDURE [sis_stage].[UDSP_SIS2ETL_SSF_Load_ECM] (@ecmFileMetadata [varchar](MAX))
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET XACT_ABORT,NOCOUNT ON;
	BEGIN TRY

    DECLARE @PROCNAME                     VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID),
            @PROCESSID                    UNIQUEIDENTIFIER = NEWID(),
            @LOGMESSAGE                   VARCHAR(MAX),
			@FN_TYPE                      VARCHAR(2) = 'FN',
			@SN_TYPE                      VARCHAR(2) = 'SN',
			@C_TYPE                       VARCHAR(1) = 'C',
			@MIME_TYPE                    VARCHAR(1) = 'z',
			@Y_FLAG                       VARCHAR(1) = 'Y',
			@LANGUAGE_ID                  INT = 38,
			@INFOTYPE_ID                  INT = 61;

    EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

	BEGIN TRANSACTION;

		SELECT * INTO #fileMetadata FROM openjson(replace(@ecmFileMetadata, '\', ''))
		with (
			[fileName]          varchar(100),
			[fileRid]           int,
			[isExists]          bit,
			[fileSize]          bigint
		)

		SELECT * INTO #updateRecords FROM #fileMetadata WHERE [isExists] = 1
		

		UPDATE dtt SET dtt.Display_Value= ftd.[fileName]
		FROM [sis_stage].[ServiceFile_DisplayTerms_Translation_Syn] dtt
		INNER JOIN [sis_stage].[ServiceFile_DisplayTerms_Syn] dt
			ON (dt.ServiceFile_DisplayTerms_ID = dtt.ServiceFile_DisplayTerms_ID)
		INNER JOIN #updateRecords ftd
			ON (ftd.[fileRid] = dt.ServiceFile_ID)
		WHERE dt.ServiceFile_ID = ftd.fileRid AND dtt.Value=@FN_TYPE AND dtt.Value_Type=@C_TYPE;


		UPDATE sf SET sf.ServiceFile_Name = ftd.[fileName], sf.Available_Flag=@Y_FLAG, sf.ServiceFile_Size=ftd.[fileSize]
		FROM [sis_stage].[ServiceFile_Syn] sf
		INNER JOIN #updateRecords ftd
			ON ftd.[fileRid] = sf.ServiceFile_ID

		SELECT * INTO #insertRecords FROM #fileMetadata WHERE [isExists] = 0


		INSERT INTO sis_stage.ServiceFile_Syn(ServiceFile_ID, InfoType_ID, ServiceFile_Name, Available_Flag, Mime_Type, ServiceFile_Size, Updated_Date, Created_Date, Insert_Date)
		SELECT [fileRid], @INFOTYPE_ID, [fileName], @Y_FLAG, @MIME_TYPE, [fileSize], GETDATE(), GETDATE(), GETDATE() from #insertRecords

	

		INSERT INTO sis_stage.ServiceFile_SearchCriteria_Syn(ServiceFile_ID, InfoType_ID, Search_Type, [Value], Search_Value)
		SELECT [fileRid], @INFOTYPE_ID, @SN_TYPE, SUBSTRING([fileName], 1, CHARINDEX('_', [fileName]) - 1), SUBSTRING([fileName], 1, CHARINDEX('_', [fileName]) - 1) from #insertRecords
		

		INSERT INTO [sis_stage].[ServiceFile_DisplayTerms_Syn](ServiceFile_ID, [Type])
		SELECT [fileRid], @FN_TYPE from #insertRecords


		INSERT INTO [sis_stage].[ServiceFile_DisplayTerms_Translation_Syn](ServiceFile_DisplayTerms_ID, Language_ID, Value_Type, [Value], Display_Value)
		SELECT ServiceFile_DisplayTerms_ID, @LANGUAGE_ID, @C_TYPE, ir.[fileName], ir.[fileName] FROM #insertRecords ir
		INNER JOIN [sis_stage].[ServiceFile_DisplayTerms_Syn] [sdt]
		ON (ir.[fileRid] = [sdt].ServiceFile_ID AND [sdt].[Type]=@FN_TYPE)

		COMMIT;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

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


