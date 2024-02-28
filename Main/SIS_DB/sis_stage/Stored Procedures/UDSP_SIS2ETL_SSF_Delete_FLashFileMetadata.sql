CREATE PROCEDURE [sis_stage].[UDSP_SIS2ETL_SSF_Delete_FLashFileMetadata]
(
    @flashFileMetadata [VARCHAR](MAX)
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

        SELECT * INTO #fileMetadata FROM openjson(replace(@flashFileMetadata, '\', ''))
            with (
                [fileType]          varchar(20),
                [serviceFileId]           int,
                [serviceFileName]          varchar(100)
            )

        UPDATE sf set sf.Available_Flag = 'N'
            FROM sis_stage.ServiceFile_Syn sf
            INNER JOIN #fileMetadata m
            ON sf.ServiceFile_ID = m.serviceFileId
            WHERE m.fileType = 'flashFile'

        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Available Flag updated for flashFiles in ServiceFile_Syn table',@DATAVALUE = NULL;

        DELETE FROM sis_stage.ServiceFile_Reference_Syn WHERE ServiceFile_ID in (select serviceFileId from #fileMetadata)

        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Deleted Records from ServiceFile_Reference_Syn table',@DATAVALUE = NULL;


        DELETE sf
            FROM sis_stage.ServiceFile_Syn sf
            INNER JOIN #fileMetadata m
            ON sf.ServiceFile_ID = m.serviceFileId
            WHERE m.fileType = 'productDescription'

        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Deleted ProductDescriptions from ServiceFile_Syn table',@DATAVALUE = NULL;

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