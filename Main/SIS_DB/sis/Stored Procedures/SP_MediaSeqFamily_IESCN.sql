CREATE PROCEDURE [sis].[SP_MediaSeqFamily_IESCN] (
@Language_ID INT,@IESystemControlNumber_List VARCHAR(MAX)
)

AS

BEGIN


SELECT value IESystemControlNumber INTO #IESCN FROM STRING_SPLIT(@IESystemControlNumber_List, ',');

SELECT DISTINCT vwmediaseq0_.IESystemControlNumber 
	,vwmediaseq0_.Media_Number					
	,vwmediaseq0_.Arrangement_Indicator 
	,iepart1_.Base_English_Control_Number 
	,mediaseque3_.Caption 
	,iepart1_.IE_Control_Number 
	,mediaseque3_.Modifier 
	,parttransl4_.Part_Name 
	,part2_.Part_Number 
	,iepart1_.Update_Date 
	,vwmediaseq0_.NPR_Indicator 
	,part2_.Org_Code 
	,vwmediaseq0_.Serviceability_Indicator 
	,vwmediaseq0_.TypeChange_Indicator 
	,vwmediaseq0_.CCR_Indicator 
	,vwmediaseq0_.Serial_Number_Prefix 
	,vwmediaseq0_.Start_Serial_Number 
	,vwmediaseq0_.End_Serial_Number 
	,iepart1_.Publish_Date 
	,part2_.Part_ID 
	,iepart1_.PartName_for_NULL_PartNum 
FROM sis.vw_MediaSequenceFamily vwmediaseq0_
INNER JOIN sis.IEPart iepart1_ ON (iepart1_.IEPart_ID = vwmediaseq0_.IEPart_ID)
INNER JOIN sis.Part part2_ ON (part2_.Part_ID = iepart1_.Part_ID)
INNER JOIN sis.MediaSequence_Translation mediaseque3_ ON (mediaseque3_.MediaSequence_ID = vwmediaseq0_.MediaSequence_ID)
INNER JOIN sis.Part_Translation parttransl4_ ON (
		parttransl4_.Part_ID = part2_.Part_ID
		AND parttransl4_.Language_ID = @Language_ID
		)
INNER JOIN #IESCN ON vwmediaseq0_.IESystemControlNumber = #IESCN.IESystemControlNumber

END
GO