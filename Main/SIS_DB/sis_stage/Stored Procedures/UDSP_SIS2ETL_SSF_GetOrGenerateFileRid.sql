CREATE PROCEDURE [sis_stage].[UDSP_SIS2ETL_SSF_GetOrGenerateFileRid]
(
    @blobFileName [varchar](MAX)
)
AS
BEGIN

    SET XACT_ABORT,NOCOUNT ON;

    DECLARE @newFileRid TABLE (ServiceFile_Name VARCHAR(50),newFileRid INT)
    DECLARE @productDescriptionFileRid TABLE (ServiceFile_Name VARCHAR(50),productDescriptionFileRid INT)
    DECLARE @cssFileRid TABLE (ServiceFile_Name VARCHAR(50),cssFileRid INT)
    DECLARE @logoFileRid TABLE (ServiceFile_Name VARCHAR(50),logoFileRid INT)

	select value as [fileName] into #blobFiles from openjson(replace(@blobFileName, '\', ''))

    INSERT INTO @newFileRid
    SELECT bf.[fileName] ServiceFile_Name,NEXT VALUE FOR sis_stage.ServiceFileSeq newFileRid
    FROM #blobFiles bf
    LEFT JOIN  sis_stage.ServiceFile_Syn sf
    ON UPPER(REPLACE(bf.[fileName], '-', '')) = sf.ServiceFile_Name
    WHERE sf.ServiceFile_Name IS NULL

    INSERT INTO @productDescriptionFileRid
    SELECT bf.[fileName] ServiceFile_Name,NEXT VALUE FOR sis_stage.ServiceFileSeq productDescriptionFileRid
    FROM #blobFiles bf

    INSERT INTO @cssFileRid
    SELECT bf.[fileName] ServiceFile_Name,NEXT VALUE FOR sis_stage.ServiceFileSeq cssFileRid FROM #blobFiles bf

    INSERT INTO @logoFileRid
    SELECT bf.[fileName] ServiceFile_Name,NEXT VALUE FOR sis_stage.ServiceFileSeq logoFileRid
    FROM #blobFiles bf

    DELETE sis_stage.ssf_Output_SSFGetOrGenerateFileRid

    INSERT INTO sis_stage.ssf_Output_SSFGetOrGenerateFileRid ([fileName], [isExists], [fileRid], [productDescriptionFileRid], [cssFileRid] , [logoFileRid])
    SELECT bf.[fileName],
        convert(bit, CASE WHEN s.ServiceFile_Name is null THEN 0 ELSE 1 END) isExists,
        COALESCE(s.ServiceFile_ID, nf.newFileRid) fileRid,
        pd.productDescriptionFileRid,
        css.cssFileRid,
        logo.logoFileRid
    FROM #blobFiles bf
        INNER JOIN @productDescriptionFileRid pd
        on pd.ServiceFile_Name = bf.[fileName]
        INNER JOIN @cssFileRid css
        on css.ServiceFile_Name = bf.[fileName]
        INNER JOIN @logoFileRid logo
        on logo.ServiceFile_Name = bf.[fileName]
        LEFT JOIN @newFileRid nf
        on nf.ServiceFile_Name = bf.[fileName]
        LEFT JOIN sis_stage.ServiceFile_Syn s
        on UPPER(REPLACE(bf.[fileName], '-', '')) = s.ServiceFile_Name

    RETURN;
END
GO