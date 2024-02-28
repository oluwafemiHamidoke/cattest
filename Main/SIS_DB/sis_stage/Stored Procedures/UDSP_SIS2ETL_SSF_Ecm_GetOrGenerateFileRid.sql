-- =============================================
-- Author:      Obieda Ananbeh
-- Create Date: 05182023
-- Description: Get Or Generate File ID 
-- =============================================

CREATE PROCEDURE [sis_stage].[UDSP_SIS2ETL_SSF_Ecm_GetOrGenerateFileRid]
(
    @blobFileName [varchar](MAX) --Input parameter to receive file names
)
AS
BEGIN

    SET XACT_ABORT,NOCOUNT ON;
    DECLARE @newFileRid TABLE (ServiceFile_Name VARCHAR(50),newFileRid INT)
    SELECT VALUE AS [fileName] INTO #blobFiles FROM openjson(replace(@blobFileName, '\', ''))

    SELECT [fileName] INTO #validFiles FROM #blobFiles 

    --Generate new file ID for files not existing in the sis_stage.ServiceFile_Syn 
    INSERT INTO @newFileRid
    SELECT bf.[fileName] ServiceFile_Name,NEXT VALUE FOR sis_stage.ServiceFileSeq newFileRid
    FROM #validFiles bf
    LEFT JOIN  sis_stage.ServiceFile_Syn sf
    ON UPPER(bf.[fileName]) = sf.ServiceFile_Name
    WHERE sf.ServiceFile_Name IS NULL

    --Delete all records from sis_stage.ssf_Output_SSF_EcmGetOrGenerateFileRid
    TRUNCATE TABLE sis_stage.ssf_Output_SSF_EcmGetOrGenerateFileRid
    
    --Insert into sis_stage.ssf_Output_SSF_EcmGetOrGenerateFileRid table the file name, whether it exists or not, and the file ID
    INSERT INTO sis_stage.ssf_Output_SSF_EcmGetOrGenerateFileRid ([fileName], [isExists], [fileRid])
    SELECT bf.[fileName],
        convert(bit, CASE WHEN s.ServiceFile_Name is null THEN 0 ELSE 1 END) isExists, --If ServiceFile_Name is null, it means the file does not exist
        COALESCE(s.ServiceFile_ID, nf.newFileRid) fileRid --If ServiceFile_ID is null, use the new file ID generated
    FROM #validFiles bf
        LEFT JOIN @newFileRid nf
        on nf.ServiceFile_Name = bf.[fileName]
        LEFT JOIN sis_stage.ServiceFile_Syn s
        on UPPER(bf.[fileName]) = s.ServiceFile_Name

    RETURN;
END
GO

