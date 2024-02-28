
-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180424
-- Description: High level load sequence for sis schema
/*
Exec [sis_stage].Full_Load_P2
*/
-- =============================================
CREATE PROCEDURE [sis_stage].[Full_Load_P2]
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

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution started', NULL)

--Load

--Exec [sis_stage].[Language_Load]
--RAISERROR ('[Language_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[Language_Details_Load]
RAISERROR ('[Language_Details_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[Country_Load]
RAISERROR ('[Country_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[Product_Load]
RAISERROR ('[Product_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[SerialNumberRange_Load]
RAISERROR ('[SerialNumberRange_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[Part_Load]
RAISERROR ('[Part_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[Part_Translation_Load]
RAISERROR ('[Part_Translation_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[Related_Part_Relation_Load]
RAISERROR ('[Related_Part_Relation_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[IEPart_Load]
RAISERROR ('[IEPart_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[Illustration_Load]
RAISERROR ('[Illustration_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[IE_Load]
RAISERROR ('[IE_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[Media_Load]
RAISERROR ('[Media_Load]', 0, 1) WITH NOWAIT --Media, Section, Sequence & related translation and effectivity

Exec [sis_stage].[Media_ProductFamily_Effectivity_Load]
RAISERROR ('[Media_ProductFamily_Effectivity_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[IE_Effectivity_Load]
RAISERROR ('[IE_Effectivity_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[IE_ProductFamily_Effectivity_Load]
RAISERROR ('[IE_ProductFamily_Effectivity_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[IEPart_Effectivity_Load]
RAISERROR ('[IEPart_Effectivity_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[IEPart_Effective_Date_Load]
RAISERROR ('[IEPart_Effective_Date_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[Part_IEPart_Relation_Load]
RAISERROR ('[Part_IEPart_Relation_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[Part_IEPart_Relation_Translation_Load]
RAISERROR ('[Part_IEPart_Relation_Translation_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[IEPart_IEPart_Relation_Load]
RAISERROR ('[IEPart_IEPart_Relation_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[ProductStructure_Load]
RAISERROR ('[ProductStructure_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[ProductStructure_Translation_Load]
RAISERROR ('[ProductStructure_Translation_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[ProductStructure_IEPart_Relation_Load]
RAISERROR ('[ProductStructure_IEPart_Relation_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[CaptivePrime_Load]
RAISERROR ('[CaptivePrime_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[SMCS_Load]
RAISERROR ('[SMCS_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[InfoType_Load]
RAISERROR ('[InfoType_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[IE_InfoType_Relation_Load]
RAISERROR ('[IE_InfoType_Relation_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[Dealer_Load]
RAISERROR ('[Dealer_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[MarketingOrg_Load]
RAISERROR ('[MarketingOrg_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[ProductStructure_IE_Relation_Load]
RAISERROR ('[ProductStructure_IE_Relation_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[Media_InfoType_Relation_Load]
RAISERROR ('[Media_InfoType_Relation_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[ProductStructure_Effectivity_Load]
RAISERROR ('[ProductStructure_Effectivity_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[ServiceFile_Load]
RAISERROR ('[ServiceFile_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[ServiceFile_DisplayTerms_Load]
RAISERROR ('[ServiceFile_DisplayTerms_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[ServiceFile_DisplayTerms_Translation_Load]
RAISERROR ('[ServiceFile_DisplayTerms_Translation_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[Part_IE_Effectivity_Load]
RAISERROR ('[Part_IE_Effectivity_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[ServiceLetterCompletion_Load]
RAISERROR ('[ServiceLetterCompletion_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[CCRMedia_Load]
RAISERROR ('[CCRMedia_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[CCRSegments_Load]
RAISERROR ('[CCRSegments_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[CCROperations_Load]
RAISERROR ('[CCROperations_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[CCRUpdateTypes_Load]
RAISERROR ('[CCRUpdateTypes_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[CCRUpdateTypes_Translation_Load]
RAISERROR ('[CCRUpdateTypes_Translation_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[CCRGroupIE_Effectivity_Load]
RAISERROR ('[CCRGroupIE_Effectivity_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[CCRTechdocSNP_Effectivity_Load]
RAISERROR ('[CCRTechdocSNP_Effectivity_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[CCRVirtualIE_Effectivity_Load]
RAISERROR ('[CCRVirtualIE_Effectivity_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[CCRUpdatesIE_Relation_Load]
RAISERROR ('[CCRUpdatesIE_Relation_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[CCRRepairTypes_Load]
RAISERROR ('[CCRRepairTypes_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[CCRRepairTypes_Translation_Load]
RAISERROR ('[CCRRepairTypes_Translation_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[RepairDescriptions_Load]
RAISERROR ('[RepairDescriptions_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[RepairDescriptions_Translation_Load]
RAISERROR ('[RepairDescriptions_Translation_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[IELevel_Load]
RAISERROR ('[IELevel_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[IELevel_Translation_Load]
RAISERROR ('[IELevel_Translation_Load]', 0, 1) WITH NOWAIT

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
