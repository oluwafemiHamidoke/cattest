-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180424
-- Description: High level load sequence for sis schema
/*
Exec [sis_stage].Full_Load_P1
*/
-- =============================================
CREATE PROCEDURE [sis_stage].[Full_Load_P1]
--(
    -- Add the parameters for the stored procedure here
    --<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>,
    --<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
--)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

BEGIN TRY

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
		@ProcessID uniqueidentifier = NewID()

Delete from sis_stage.[Log] where [LogDateTime]< DATEADD(month, -6, getdate()) --Delete logs older than 6 months old
Delete from sis.[Log] where [LogDateTime]< DATEADD(month, -6, getdate()) --Delete logs older than 6 months old
Delete from SISSEARCH.LOG where [LogDateTime]< DATEADD(month, -6, getdate()) --Delete logs older than 6 months old
Delete from admin.[Log] where [LogDateTime]< DATEADD(month, -6, getdate()) --Delete logs older than 6 months old

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Deleted Logs Records 6 Months or Older', @@RowCount)

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution started', NULL)

Truncate table sis_stage.AsShippedEngine
Truncate table sis_stage.AsShippedPart
Truncate table sis_stage.AsShippedPart_Effectivity
Truncate table sis_stage.AsShippedPart_Level_Relation
Truncate table sis_stage.CaptivePrime
Truncate table sis_stage.IEPart_Effective_Date
Truncate table sis_stage.IEPart
Truncate table sis_stage.IEPart_Effectivity
Truncate table sis_stage.IEPart_Illustration_Relation
Truncate table sis_stage.IE_Illustration_Relation
Truncate table sis_stage.IE_InfoType_Relation
Truncate table sis_stage.Illustration_File
Truncate table sis_stage.Illustration
Truncate table [sis_stage].[IELevel]
Truncate table [sis_stage].[IELevel_Translation]
--Truncate table sis_stage.Language
Truncate table sis_stage.Language_Details
Truncate table sis_stage.Part_IE_Effectivity
Truncate table sis_stage.Media_InfoType_Relation
Truncate table sis_stage.Media_Effectivity
Truncate table sis_stage.Media_Translation
Truncate table sis_stage.Media
Truncate table sis_stage.Part
Truncate table sis_stage.Part_AsShippedEngine_Relation
Truncate table sis_stage.Part_AsShippedPart_Relation
Truncate table sis_stage.Part_IEPart_Relation
Truncate table sis_stage.Part_IEPart_Relation_Translation
Truncate table sis_stage.Part_Translation
Truncate table sis_stage.[MediaSection_Translation]
Truncate table sis_stage.[MediaSection]
Truncate table sis_stage.[MediaSequence_Effectivity]
Truncate table sis_stage.[MediaSequence_Translation]
Truncate table sis_stage.[MediaSequence]
Truncate table sis_stage.Product_Relation
Truncate table sis_stage.IE_ProductFamily_Effectivity
Truncate table sis_stage.Media_ProductFamily_Effectivity
Truncate table sis_stage.ProductFamily_Translation
Truncate table sis_stage.ProductFamily
Truncate table sis_stage.ProductStructure_Effectivity
Truncate table sis_stage.ProductStructure_IEPart_Relation
Truncate table sis_stage.ProductStructure_IE_Relation
Truncate table sis_stage.ProductStructure_Translation
Truncate table sis_stage.ProductStructure
Truncate table sis_stage.ProductSubfamily
Truncate table sis_stage.ProductSubfamily_Translation
Truncate table sis_stage.Related_Part_Relation
Truncate table sis_stage.SalesModel
Truncate table sis_stage.SerializedComponent_Effectivity
Truncate table sis_stage.TroubleshootingInfo
Truncate table sis_stage.TroubleshootingIllustrationDetails
Truncate table sis_stage.MIDCodeDetails
Truncate table sis_stage.FMICodeDetails
Truncate table sis_stage.CIDCodeDetails
Truncate table sis_stage.SerialNumberPrefix
Truncate table sis_stage.SerialNumberRange
Truncate table sis_stage.Supersession_Part_Relation
Truncate table sis_stage.SupersessionChain
Truncate table sis_stage.SupersessionChain_Part_Relation
Truncate table sis_stage.SMCS_IE_Relation
Truncate table sis_stage.SMCS_Translation
Truncate table sis_stage.SMCS
Truncate table sis_stage.InfoType_Translation
Truncate table sis_stage.InfoType
Truncate table sis_stage.IE_Translation
Truncate table sis_stage.IE_Dealer_Relation
Truncate table sis_stage.Dealer
Truncate table sis_stage.IE_MarketingOrg_Relation
Truncate table sis_stage.MarketingOrg
Truncate table sis_stage.IE_Effectivity
Truncate table sis_stage.IE
Truncate table sis_stage.ServiceFile;
Truncate table sis_stage.ServiceFile_DisplayTerms;
Truncate table sis_stage.ServiceFile_DisplayTerms_Translation;
truncate table sis_stage.TroubleshootingInfoIERelation
truncate table sis_stage.TroubleshootingInfo2
truncate table sis_stage.TroubleshootingConfigurationInfoIERelation
truncate table sis_stage.TroubleshootingConfigurationInfo
truncate table sis_stage.ConfigurationInfo
Truncate table sis_stage.IE_Illustration_Relation_Diff --sis.IE_Illustration_Relation_Merge, sis_stage.IE_Load
Truncate table sis_stage.IE_InfoType_Relation_Diff --sis.IE_InfoType_Relation_Merge, [sis_stage].[IE_InfoType_Relation_Load]
Truncate table sis_stage.ProductStructure_IEPart_Relation_Diff -- sis_stage.ProductStructure_IEPart_Relation_Load
Truncate table sis_stage.ProductStructure_IE_Relation_Diff -- sis.ProductStructure_IE_Relation_Merge, sis_stage.ProductStructure_IE_Relation_Load
Truncate table sis_stage.SMCS_IE_Relation_Diff -- [sis_stage].[SMCS_Load], sis.SMCS_IE_Relation_Merge
Truncate table sis_stage.SMCS_Translation_Diff -- sis.SMCS_Translation_Merge, [sis_stage].[SMCS_Load]
Truncate table sis_stage.SMCS_Diff -- sis.SMCS_Merge, [sis_stage].[SMCS_Load]
Truncate table sis_stage.InfoType_Translation_Diff -- [sis_stage].[InfoType_Load], sis.InfoType_Translation_Merge
Truncate table sis_stage.IE_Translation_Diff -- sis.IE_Translation_Merge, sis_stage.IE_Load
Truncate table sis_stage.IE_Dealer_Relation_Diff -- sis.IE_Dealer_Relation_Merge, sis_stage.Dealer_Load
Truncate table sis_stage.Dealer_Diff -- sis.Dealer_Merge, sis_stage.Dealer_Load
Truncate table sis_stage.IE_MarketingOrg_Relation_Diff -- sis.IE_MarketingOrg_Relation_Merge, sis_stage.MarketingOrg_Load
Truncate table sis_stage.MarketingOrg_Diff -- sis.MarketingOrg_Merge, sis_stage.MarketingOrg_Load
Truncate table sis_stage.IE_Diff -- [sis].[IE_Merge], sis_stage.IE_Load
Truncate table sis_stage.ServiceFile_DisplayTerms_Translation_Diff; -- [sis_stage].[ServiceFile_DisplayTerms_Translation_Load]
Truncate table sis_stage.IEPart_Effective_Date_Diff; --sis.IEPart_Effective_Date_Merge, [sis_stage].[IEPart_Effective_Date_Load]
Truncate table sis_stage.IEPart_IEPart_Relation -- sis.IEPart_IEPart_Relation_Merge, [sis_stage].[IEPart_IEPart_Relation_Load]
TRUNCATE TABLE sis_stage.ServiceLetterCompletion --sis_stage.ServiceLetterCompletion_Merge, sis_stage.ServiceLetterCompletion_Load 
truncate table [sis_stage].CCRUpdatesIE_Relation
truncate table [sis_stage].CCRVirtualIE_Effectivity
truncate table [sis_stage].CCRTechdocSNP_Effectivity
truncate table [sis_stage].CCRGroupIE_Effectivity
truncate table [sis_stage].CCRUpdateTypes_Translation
truncate table [sis_stage].CCRUpdateTypes
truncate table [sis_stage].CCROperations
truncate table [sis_stage].CCRSegments
truncate table [sis_stage].CCRMedia
truncate table [sis_stage].[CCRRepairTypes_Translation]
truncate table [sis_stage].[CCRRepairTypes]
truncate table [sis_stage].[RepairDescriptions_Translation]
truncate table [sis_stage].[RepairDescriptions]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution completed', NULL)

END TRY

BEGIN CATCH

	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
			@ERROELINE INT= ERROR_LINE(),
			@ErrorSeverity INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()

	Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
	Values (@ProcessID, GETDATE(), 'Error', @ProcName, 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE, NULL)

    RAISERROR (@ERRORMESSAGE, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );

END CATCH

END
