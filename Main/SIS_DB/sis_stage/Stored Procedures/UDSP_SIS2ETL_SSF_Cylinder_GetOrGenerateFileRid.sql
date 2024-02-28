CREATE PROCEDURE [sis_stage].[UDSP_SIS2ETL_SSF_Cylinder_GetOrGenerateFileRid]
(
    @blobFileName [varchar](MAX)
)
AS
BEGIN

    SET XACT_ABORT,NOCOUNT ON;

    DECLARE @newFileRid TABLE (ServiceFile_Name VARCHAR(50),newFileRid INT)
	DECLARE @PROCNAME                     VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID),
            @PROCESSID                    UNIQUEIDENTIFIER = NEWID(),
            @LOGMESSAGE                   VARCHAR(MAX),
			@invalidCount                 INT,
			@invalidFiles                 VARCHAR(MAX),
			@errorMessage                 VARCHAR(MAX);


	SELECT VALUE AS [fileName] INTO #blobFiles FROM openjson(replace(@blobFileName, '\', ''))

	-- check for invalid file names
	SELECT [fileName] INTO #invalidFiles FROM #blobFiles WHERE len([fileName]) <> 25
	SELECT @invalidCount = COUNT([fileName]) FROM #invalidFiles

	if @invalidCount > 0
	BEGIN
		SELECT @invalidFiles = STRING_AGG([fileName], ', ') FROM #invalidFiles
		SELECT @errorMessage = 'Invalid files [' + @invalidFiles + ']. Expected file name length is 25'
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @errorMessage, @DATAVALUE = NULL;
	END

	SELECT [fileName] INTO #validFiles FROM #blobFiles WHERE len([fileName]) = 25

    INSERT INTO @newFileRid
    SELECT bf.[fileName] ServiceFile_Name,NEXT VALUE FOR sis_stage.ServiceFileSeq newFileRid
    FROM #validFiles bf
    LEFT JOIN  sis_stage.ServiceFile_Syn sf
    ON UPPER(bf.[fileName]) = sf.ServiceFile_Name
    WHERE sf.ServiceFile_Name IS NULL

    DELETE sis_stage.ssf_Output_SSFGetOrGenerateFileRid

    INSERT INTO sis_stage.ssf_Output_SSFGetOrGenerateFileRid ([fileName], [isExists], [fileRid])
    SELECT bf.[fileName],
        convert(bit, CASE WHEN s.ServiceFile_Name is null THEN 0 ELSE 1 END) isExists,
        COALESCE(s.ServiceFile_ID, nf.newFileRid) fileRid
    FROM #validFiles bf
        LEFT JOIN @newFileRid nf
        on nf.ServiceFile_Name = bf.[fileName]
        LEFT JOIN sis_stage.ServiceFile_Syn s
        on UPPER(bf.[fileName]) = s.ServiceFile_Name

    RETURN;
END
GO