CREATE PROCEDURE [sis_stage].[UDSP_SIS2ETL_SSF_Load_FLashFileDeleteMetadata]
(
    @blobFileName [sis_stage].[UDTT_SIS2ETL_GENERIC_SINGLE_VARCHAR_COLUMN] READONLY
)
AS
BEGIN

    SET XACT_ABORT,NOCOUNT ON;

	DELETE sis_stage.ssf_Output_FlashFileDeleteMetadata

	;with cte as (
		SELECT cast('flashFile' as varchar(20)) as fileType, ServiceFile_ID as serviceFileId, ServiceFile_Name as serviceFileName
		FROM sis_stage.ServiceFile_Syn WHERE ServiceFile_Name IN (SELECT UPPER(REPLACE(REPLACE([COL1], '	',''), ' ','')) FROM @blobFileName)

		UNION ALL

		SELECT cast('productDescription' as varchar(20)) as fileType, child.Referred_ServiceFile_ID as serviceFileId, sf.ServiceFile_Name as serviceFileName FROM sis_stage.ServiceFile_Reference_Syn child
		INNER JOIN cte c
		    ON child.ServiceFile_ID= c.serviceFileId
		INNER JOIN sis_stage.ServiceFile_Syn sf
		    ON child.Referred_ServiceFile_ID= sf.ServiceFile_ID
		)
	INSERT INTO sis_stage.ssf_Output_FlashFileDeleteMetadata SELECT fileType, serviceFileId, serviceFileName  FROM cte

END
GO