CREATE PROCEDURE [sis].[SP_IEPL_PartWhereUsed_EMP] (
@Part_ID_List VARCHAR(8000),@Language_Tag VARCHAR(50),@Media_Origin_NonSisJ VARCHAR(2),@Media_Number VARCHAR(50)
)

AS

BEGIN

DROP TABLE IF EXISTS #t1;
DROP TABLE IF EXISTS #t2;
DROP TABLE IF EXISTS #t3;
DROP TABLE IF EXISTS #t4;
DROP TABLE IF EXISTS #t5;

SELECT CAST(value as INT) Part_ID INTO #t5 FROM STRING_SPLIT(@Part_ID_List, ',');

SELECT DISTINCT part3_.Org_Code
	,part3_.Part_Number
	,part3_.Part_ID
	,parttransl5_.Part_Name
	,iepart2_.Update_Date
	,iepart2_.Base_English_Control_Number
	,iepart2_.IE_Control_Number
	,vwmediaseq0_.IESystemControlNumber
	,vwmediaseq0_.Media_Number
	,vwmediaseq0_.Serviceability_Indicator
	,vwmediaseq0_.Arrangement_Indicator
	,vwmediaseq0_.CCR_Indicator
	,vwmediaseq0_.TypeChange_Indicator
	,vwmediaseq0_.NPR_Indicator
	,vwmediaseq0_.Start_Serial_Number
	,vwmediaseq0_.End_Serial_Number
	,vwmediaseq0_.MediaSequence_ID
	,vwmediaseq0_.Serial_Number_Prefix
	,vwmediaseq0_.IEPart_ID
	,vwmediaseq0_.Media_ID
	,vwmediaseq0_.SerialNumberPrefix_ID
	,mediaseque1_.Caption
	,mediaseque1_.Modifier
INTO #t1
FROM #t5 p1
INNER JOIN sis.Part part3_ ON (part3_.Part_ID = p1.Part_ID)
INNER JOIN sis.IEPart iepart2_ ON (iepart2_.Part_ID = part3_.Part_ID)
INNER JOIN sis.Part_Translation parttransl5_ ON (part3_.Part_ID = parttransl5_.Part_ID)
INNER JOIN sis.LANGUAGE language6_ ON (language6_.Language_ID = parttransl5_.Language_ID)
INNER JOIN sis.MediaSequenceFamily vwmediaseq0_ ON (vwmediaseq0_.IEPart_ID = iepart2_.IEPart_ID)
INNER JOIN sis.MediaSequence_Translation mediaseque1_ ON (mediaseque1_.MediaSequence_ID = vwmediaseq0_.MediaSequence_ID) -- +4 seconds
WHERE language6_.Language_Tag = @Language_Tag
	AND (vwmediaseq0_.Media_Origin <> @Media_Origin_NonSisJ OR @Media_Origin_NonSisJ IS NULL)
	AND (vwmediaseq0_.Media_Number = @Media_Number OR @Media_Number IS NULL)


select distinct ProductStructure_ID,productstr4_.IEPart_ID,productstr4_.Media_ID
into #t2
from #t1 vwmediaseq0_
INNER JOIN sis.ProductStructure_IEPart_Relation productstr4_ ON (
		vwmediaseq0_.IEPart_ID = productstr4_.IEPart_ID
		AND productstr4_.Media_ID = vwmediaseq0_.Media_ID
		)

SELECT DISTINCT ieparteffe7_.SerialNumberPrefix_Type
	,vwmediaseq0_.SerialNumberPrefix_ID
	,vwmediaseq0_.IEPart_ID
	,vwmediaseq0_.Media_ID
INTO #t3
FROM sis.IEPart_Effectivity ieparteffe7_
INNER JOIN #t1 vwmediaseq0_ ON (
		ieparteffe7_.SerialNumberPrefix_ID = vwmediaseq0_.SerialNumberPrefix_ID
		AND ieparteffe7_.IEPart_ID = vwmediaseq0_.IEPart_ID
		AND ieparteffe7_.Media_ID = vwmediaseq0_.Media_ID
		)




SELECT DISTINCT vwmediaseq0_.IESystemControlNumber
	,vwmediaseq0_.Media_Number
	,vwmediaseq0_.Serviceability_Indicator
	,vwmediaseq0_.Arrangement_Indicator
	,vwmediaseq0_.CCR_Indicator
	,vwmediaseq0_.TypeChange_Indicator
	,vwmediaseq0_.NPR_Indicator
	,vwmediaseq0_.Base_English_Control_Number
	,vwmediaseq0_.IE_Control_Number
	,vwmediaseq0_.Caption
	,vwmediaseq0_.Org_Code
	,vwmediaseq0_.Part_Number
	,vwmediaseq0_.Part_Name
	,vwmediaseq0_.Update_Date
	,vwmediaseq0_.Start_Serial_Number
	,vwmediaseq0_.End_Serial_Number
	,coalesce(empproduct9_.SNP, vwmediaseq0_.Serial_Number_Prefix) Serial_Number_Prefix
	,empproduct9_.NUMBER
	,vwmediaseq0_.Modifier
	,vwmediaseq0_.Part_ID
	,vwmediaseq0_.SerialNumberPrefix_ID
	,vwmediaseq0_.IEPart_ID
	,vwmediaseq0_.Media_ID
INTO #t4
FROM #t1 vwmediaseq0_
LEFT OUTER JOIN sis.IEPart_Effectivity ieparteffe7_  ON (
		ieparteffe7_.SerialNumberPrefix_ID = vwmediaseq0_.SerialNumberPrefix_ID
		AND ieparteffe7_.IEPart_ID = vwmediaseq0_.IEPart_ID
		AND ieparteffe7_.Media_ID = vwmediaseq0_.Media_ID
		)
LEFT OUTER JOIN SISWEB_OWNER.LNKIEPRODUCTINSTANCE lnkieprodu8_ ON (
		lnkieprodu8_.MEDIANUMBER = vwmediaseq0_.Media_Number
		AND lnkieprodu8_.IESYSTEMCONTROLNUMBER = vwmediaseq0_.IESystemControlNumber
		)
LEFT OUTER JOIN SISWEB_OWNER.EMPPRODUCTINSTANCE empproduct9_ ON (empproduct9_.EMPPRODUCTINSTANCE_ID = lnkieprodu8_.EMPPRODUCTINSTANCE_ID) -- EMP added + 5 seconds


SELECT DISTINCT 
	IESystemControlNumber
	,Media_Number
	,Serviceability_Indicator
	,Arrangement_Indicator
	,CCR_Indicator
	,TypeChange_Indicator
	,NPR_Indicator
	,Base_English_Control_Number
	,IE_Control_Number
	,Caption
	,Org_Code
	,Part_Number
	,ProductStructure_ID
	,Part_Name
	,Update_Date
	,Start_Serial_Number
	,End_Serial_Number
	,SerialNumberPrefix_Type
	,Serial_Number_Prefix
	,NUMBER Product_Instance_Number
	,Modifier
	,Part_ID
FROM #t3 t3
INNER JOIN #t4 t4 ON (
		t4.SerialNumberPrefix_ID = t3.SerialNumberPrefix_ID
		AND t4.IEPart_ID = t3.IEPart_ID
		AND t4.Media_ID = t3.Media_ID
		)
INNER JOIN #t2 productstr4_ ON (
		t4.IEPart_ID = productstr4_.IEPart_ID
		AND productstr4_.Media_ID = t4.Media_ID
		)




END
GO