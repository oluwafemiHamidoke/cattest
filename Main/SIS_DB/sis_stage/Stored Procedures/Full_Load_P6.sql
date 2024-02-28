
-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180627
-- Description: Execute remote sprocs to merge _Diff into Live tables
/*
Exec [sis_stage].Full_Load_P6
*/
-- =============================================
CREATE PROCEDURE [sis_stage].[Full_Load_P6]

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

BEGIN TRY

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
		@ProcessID uniqueidentifier = NewID()

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution started', NULL)

--EXEC [sis].[Language_Merge]
--Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
--Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Language_Merge completed', NULL)

EXEC [sis].[Language_Details_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Language_Details_Merge completed', NULL)

EXEC [sis].[SerialNumberPrefix_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'SerialNumberPrefix_Merge completed', NULL)

EXEC [sis].[SalesModel_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'SalesModel_Merge completed', NULL)

EXEC [sis].[ProductSubfamily_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ProductSubfamily_Merge completed', NULL)

EXEC [sis].[ProductFamily_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ProductFamily_Merge completed', NULL)

EXEC [sis].[Product_Relation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Product_Relation_Merge completed', NULL)

EXEC [sis].[ProductSubfamily_Translation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ProductSubfamily_Translation_Merge completed', NULL)

EXEC [sis].[ProductFamily_Translation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ProductFamily_Translation_Merge completed', NULL)

EXEC [sis].[SerialNumberRange_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'SerialNumberRange_Merge completed', NULL)

EXEC [sis].[Part_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Part_Merge completed', NULL)

EXEC [sis].[Part_Translation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Part_Translation_Merge completed', NULL)

EXEC [sis].[Related_Part_Relation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Related_Part_Relation_Merge completed', NULL)

DECLARE @TableToLoad VARCHAR(500) = (
		SELECT sis.fn_get_table_from_synonym('sis_shadow', 'MediaSequence')
		)
DECLARE @new_Schema VARCHAR(500) = (
		SELECT LEFT(@TableToLoad, CHARINDEX('.', @TableToLoad) - 1)
		)
DECLARE @old_schema VARCHAR(500) = (
		SELECT CASE @new_Schema
				WHEN 'sis'
					THEN 'sis_shadow'
				WHEN 'sis_shadow'
					THEN 'sis'
				END
		)
DECLARE @sql_Swap_ForeignKeys NVARCHAR(500) =  'EXEC  [sis].[Swap_ForeignKeys] ''' + @old_schema + ''',''MediaSequence_Base'',''' + @new_Schema + ''',''MediaSequence_Base'''

EXECUTE sp_executesql @sql_Swap_ForeignKeys

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Swap_ForeignKeys  completed', NULL)

DECLARE @sql_Swap_ForeignKeys_Parent NVARCHAR(500) =  'EXEC  [sis].[Swap_ForeignKeys_Parent] ''' + @old_schema + ''',''MediaSequence_Base'',''' + @new_Schema + ''',''MediaSequence_Base'''

EXECUTE sp_executesql @sql_Swap_ForeignKeys_Parent

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Swap_ForeignKeysParent  completed', NULL)

EXEC [sis].[IEPart_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'IEPart_Merge completed', NULL)

EXEC [sis].[Media_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Media_Merge completed', NULL)

EXEC [sis].[IEPart_IEPart_Relation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'IEPart_IEPart_Relation_Merge completed', NULL)

EXEC [sis].[Media_Translation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Media_Translation_Merge completed', NULL)

EXEC [sis].[Media_Effectivity_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Media_Effectivity_Merge completed', NULL)

EXEC [sis].[Media_ProductFamily_Effectivity_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Media_ProductFamily_Effectivity_Merge completed', NULL)

EXEC [sis].[MediaSection_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'MediaSection_Merge completed', NULL)

EXEC [sis].[MediaSection_Translation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'MediaSection_Translation_Merge completed', NULL)

EXEC [sis].[IE_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'IE_Merge completed', NULL)

EXEC [sis].[MediaSequence_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'MediaSequence_Merge completed', NULL)

EXEC [sis].[MediaSequence_Translation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'MediaSequence_Translation_Merge completed', NULL)

EXEC [sis].[MediaSequence_Effectivity_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'MediaSequence_Effectivity_Merge completed', NULL)

EXEC [sis].[MediaSequenceSectionFamily_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'MediaSequenceSectionFamily_Merge completed', NULL)

EXEC [sis].[IEPart_Effectivity_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'IEPart_Effectivity_Merge completed', NULL)

EXEC [sis].[IEPart_Effective_Date_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'IEPart_Effective_Date_Merge completed', NULL)

EXEC [sis].[Part_IEPart_Relation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Part_IEPart_Relation_Merge completed', NULL)

EXEC [sis].[Part_IEPart_Relation_Translation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Part_IEPart_Relation_Translation_Merge completed', NULL)

EXEC [sis].[ProductStructure_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ProductStructure_Merge completed', NULL)

EXEC [sis].[ProductStructure_Translation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ProductStructure_Translation_Merge completed', NULL)

EXEC [sis].[ProductStructure_IEPart_Relation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ProductStructure_IEPart_Relation_Merge completed', NULL)

EXEC [sis].[Illustration_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Illustration_Merge completed', NULL)

EXEC [sis].[Illustration_File_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Illustration_File_Merge completed', NULL)

EXEC [sis].[IEPart_Illustration_Relation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'IEPart_Illustration_Relation_Merge completed', NULL)

EXEC [sis].[CaptivePrime_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'CaptivePrime_Merge completed', NULL)

EXEC [sis].[Supersession_Part_Relation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Supersession_Part_Relation_Merge completed', NULL)

EXEC [sis].[SupersessionChain_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'SupersessionChain_Merge completed', NULL)

EXEC [sis].[SupersessionChain_Part_Relation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'SupersessionChain_Part_Relation_Merge completed', NULL)

/*EXEC [sis].[AsShippedEngine_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'AsShippedEngine_Merge completed', NULL)

EXEC [sis].[AsShippedPart_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'AsShippedPart_Merge completed', NULL)

EXEC [sis].[Part_AsShippedEngine_Relation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Part_AsShippedEngine_Relation_Merge completed', NULL)

EXEC [sis].[AsShippedPart_Level_Relation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'AsShippedPart_Level_Relation_Merge completed', NULL)

EXEC [sis].[Part_AsShippedPart_Relation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Part_AsShippedPart_Relation_Merge completed', NULL)

EXEC [sis].[AsShippedPart_Effectivity_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'AsShippedPart_Effectivity_Merge completed', NULL)

EXEC [sis].[SerializedComponent_Effectivity_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'SerializedComponent_Effectivity_Merge completed', NULL)
*/
EXEC [sis].[SMCS_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'SMCS_Merge completed', NULL)

EXEC [sis].[SMCS_Translation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'SMCS_Translation_Merge completed', NULL)

EXEC [sis].[IE_Translation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'IE_Translation_Merge completed', NULL)

EXEC [sis].[IE_Effectivity_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'IE_Effectivity_Merge completed', NULL)

EXEC [sis].[IE_ProductFamily_Effectivity_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'IE_ProductFamily_Effectivity_Merge completed', NULL)

EXEC [sis].[SMCS_IE_Relation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'SMCS_IE_Relation_Merge completed', NULL)

EXEC [sis].[IE_Illustration_Relation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'IE_Illustration_Relation_Merge completed', NULL)

EXEC [sis].[ProductStructure_IE_Relation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ProductStructure_IE_Relation_Merge completed', NULL)

EXEC [sis].[InfoType_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'InfoType_Merge completed', NULL)

EXEC [sis].[InfoType_Translation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'InfoType_Translation_Merge completed', NULL)

EXEC [sis].[IE_InfoType_Relation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'IE_InfoType_Relation_Merge completed', NULL)

EXEC [sis].[Media_InfoType_Relation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Media_InfoType_Relation_Merge completed', NULL)

EXEC [sis].[Dealer_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Dealer_Merge completed', NULL)

EXEC [sis].[IE_Dealer_Relation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'IE_Dealer_Relation_Merge completed', NULL)

EXEC [sis].[MarketingOrg_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'MarketingOrg_Merge completed', NULL)

EXEC [sis].[IE_MarketingOrg_Relation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'IE_MarketingOrg_Relation_Merge completed', NULL)

EXEC [sis].[ProductStructure_Effectivity_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ProductStructure_Effectivity_Merge completed', NULL)

EXEC [sis].[KIM_data_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.KIM_Data_Merge completed', NULL)

---- New tables
EXEC sis_stage.SMCS_IEPart_Relation_Load
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.SMCS_IEPart_Relation_Load completed', NULL)

EXEC sis_stage.SerialNumber_Load
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.SerialNumber_Load completed', NULL)

EXEC sis_stage.SerialNumber_Media_Relation_Load
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.SerialNumber_Media_Relation_Load completed', NULL)

EXEC sis_stage.CaptivePrime_Serial_Load 
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'sis.CaptivePrime_Serial_Load completed', NULL)

EXEC [sis].[ServiceFile_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ServiceFile_Merge completed', NULL)

EXEC [sis].[ServiceFile_CPI_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ServiceFile_CPI_Merge completed', NULL)

---- Service Software File tables
EXEC [sis].[ServiceFile_DisplayTerms_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ServiceFile_DisplayTerms_Merge completed', NULL)

EXEC [sis].[ServiceFile_DisplayTerms_Translation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ServiceFile_DisplayTerms_Translation_Merge completed', NULL)

EXEC [sis].[FlashApplication_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'FlashApplication_Merge completed', NULL)

EXEC [sis].[ServiceFile_Reference_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ServiceFile_Reference_Merge completed', NULL)

EXEC [sis].[ServiceFile_ReplacementHierarchy_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ServiceFile_ReplacementHierarchy_Merge completed', NULL)

EXEC [sis].[ServiceFile_SearchCriteria_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ServiceFile_SearchCriteria_Merge completed', NULL)

EXEC [sis].[Part_IE_Effectivity_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Part_IE_Effectivity_Merge completed', NULL)

EXEC [sis].[CDS_data_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[CDS_data_Merge] completed', NULL)

EXEC [sis].[ServiceSoftware_Effectivity_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ServiceSoftware_Effectivity_Merge completed', NULL)

EXEC [sis].[ServiceSoftware_Effectivity_Suffix_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ServiceSoftware_Effectivity_Suffix_Merge completed', NULL)

--Hard Delete previously soft deleted records
EXEC [sis].[Hard_Delete]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Hard_Delete completed', NULL)

EXEC [sis].[CCRPartsProductStructure_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'CCRPartsProductStructure_Merge completed', NULL)

EXEC [sis].[NprInfo_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'NprInfo_Merge completed', NULL)

EXEC [sis].[NprInfoRecType23_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'NprInfoRecType23_Merge completed', NULL)

EXEC [sis].[NprInfoRecType456_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'NprInfoRecType456_Merge completed', NULL)

EXEC [sis].[MediaSequenceFamily_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[MediaSequenceFamily_Merge] completed', NULL)

EXEC [sis].[PartsWithRelatedParts_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[PartsWithRelatedParts_Merge] completed', NULL)

EXEC [sis].[IEPart_SNP_TopLevel_Load]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[IEPart_SNP_TopLevel_Load] completed', NULL)

EXEC [sis].[ServiceLetterCompletion_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[ServiceLetterCompletion_Merge] completed', NULL)

EXEC [sis].[ProductStructure_IEPart_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[ProductStructure_IEPart_Merge] completed', NULL)

EXEC [sis].[CCRMedia_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[CCRMedia_Merge] completed', NULL)

EXEC [sis].[CCRSegments_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[CCRSegments_Merge] completed', NULL)

EXEC [sis].[CCROperations_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[CCROperations_Merge] completed', NULL)

EXEC [sis].[CCRUpdateTypes_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[CCRUpdateTypes_Merge] completed', NULL)

EXEC [sis].[CCRUpdateTypes_Translation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[CCRUpdateTypes_Translation_Merge] completed', NULL)

EXEC [sis].[CCRGroupIE_Effectivity_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[CCRGroupIE_Effectivity_Merge] completed', NULL)

EXEC [sis].[CCRTechdocSNP_Effectivity_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[CCRTechdocSNP_Effectivity_Merge] completed', NULL)

EXEC [sis].[CCRVirtualIE_Effectivity_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[CCRVirtualIE_Effectivity_Merge] completed', NULL)

EXEC [sis].[CCRUpdatesIE_Relation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[CCRUpdatesIE_Relation_Merge] completed', NULL)

EXEC [sis].[CCRRepairTypes_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[CCRRepairTypes_Merge] completed', NULL)

EXEC [sis].[CCRRepairTypes_Translation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[CCRRepairTypes_Translation_Merge] completed', NULL)

EXEC [sis].[RepairDescriptions_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[RepairDescriptions_Merge] completed', NULL)

EXEC [sis].[RepairDescriptions_Translation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[RepairDescriptions_Translation_Merge] completed', NULL)

EXEC [sis].[IELevel_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[[IELevel_Merge]] completed', NULL)

EXEC [sis].[IELevel_Translation_Merge]
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'EXEC [sis].[IELevel_Translation_Merge] completed', NULL)


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
