CREATE PROCEDURE [sis_stage].[UDSP_SIS2ETL_SSF_Delete_CylinderFileMetadata]
(
    @blobFileName [sis_stage].[UDTT_SIS2ETL_GENERIC_SINGLE_VARCHAR_COLUMN] READONLY
)
AS
BEGIN

    SET XACT_ABORT,NOCOUNT ON;
	DECLARE @N_DATA_TYPE                  VARCHAR(1) = 'N',
			@INFOTYPE_ID                  INT = 60;

	UPDATE sf SET sf.Available_Flag=@N_DATA_TYPE
	from sis_stage.ServiceFile_Syn sf WHERE sf.ServiceFile_Name IN (SELECT UPPER([COL1]) FROM @blobFileName) AND sf.InfoType_ID=@INFOTYPE_ID


END
GO