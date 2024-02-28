CREATE PROCEDURE [sis].[SP_IEPL_EMP] 
(@Part_ID_List VARCHAR(MAX),@Media_Number VARCHAR(50),@SNP VARCHAR(60),@Start_Serial_Number int,@End_Serial_Number int,@Media_Origin_NonSisJ VARCHAR(2), @Media_Origin_NonEMP VARCHAR(2), @Product_Instance_Number  VARCHAR(60))

AS

BEGIN
SET NOCOUNT ON
DROP TABLE IF EXISTS #t1;
DROP TABLE IF EXISTS #t2;
DROP TABLE IF EXISTS #t3;
DROP TABLE IF EXISTS #t4;
DROP TABLE IF EXISTS #t5;



SELECT CAST(value as INT) Part_ID INTO #t5 FROM STRING_SPLIT(@Part_ID_List, ',');

SELECT DISTINCT part2_.Org_Code
	,part2_.Part_Number 
	,vwmediaseq0_.IESystemControlNumber 
	,vwmediaseq0_.Media_Number 
	,vwmediaseq0_.Serviceability_Indicator 
	,vwmediaseq0_.Arrangement_Indicator 
	,vwmediaseq0_.CCR_Indicator 
	,vwmediaseq0_.TypeChange_Indicator 
	,vwmediaseq0_.NPR_Indicator 
	,iepart1_.Base_English_Control_Number 
	,iepart1_.IE_Control_Number 
	,iepart1_.Update_Date 
	,vwmediaseq0_.Start_Serial_Number 
	,vwmediaseq0_.End_Serial_Number 
	,vwmediaseq0_.IEPart_ID
	,vwmediaseq0_.Media_ID
	,vwmediaseq0_.SerialNumberPrefix_ID
	,part2_.Part_ID 
INTO #t1
FROM #t5 p1
INNER JOIN sis.Part part2_ ON (part2_.Part_ID = p1.Part_ID)
INNER JOIN sis.IEPart iepart1_ ON (iepart1_.Part_ID = part2_.Part_ID)
INNER JOIN sis.vw_MediaSequenceFamily vwmediaseq0_ ON (vwmediaseq0_.IEPart_ID = iepart1_.IEPart_ID)
WHERE 
(vwmediaseq0_.Media_Origin			<>	@Media_Origin_NonSisJ	OR @Media_Origin_NonSisJ	IS NULL) AND 
(vwmediaseq0_.Media_Origin			<>	@Media_Origin_NonEMP	OR @Media_Origin_NonEMP		IS NULL) AND
(vwmediaseq0_.Media_Number			=	@Media_Number			OR @Media_Number			IS NULL) AND
(vwmediaseq0_.Start_Serial_Number	<=	@Start_Serial_Number	OR @Start_Serial_Number 	IS NULL) AND
(vwmediaseq0_.End_Serial_Number		>=	@End_Serial_Number		OR @End_Serial_Number   	IS NULL) 
ORDER BY vwmediaseq0_.Media_Number

select distinct ProductStructure_ID,productstr4_.IEPart_ID,productstr4_.Media_ID
into #t2
from #t1 vwmediaseq0_
INNER JOIN sis.ProductStructure_IEPart_Relation productstr4_ ON (
		vwmediaseq0_.IEPart_ID = productstr4_.IEPart_ID
		AND productstr4_.Media_ID = vwmediaseq0_.Media_ID
		)
SELECT DISTINCT ieparteffe4_.SerialNumberPrefix_Type
	,vwmediaseq0_.SerialNumberPrefix_ID
	,vwmediaseq0_.IEPart_ID
	,vwmediaseq0_.Media_ID
INTO #t3
FROM sis.IEPart_Effectivity ieparteffe4_
INNER JOIN #t1 vwmediaseq0_ ON (
		ieparteffe4_.SerialNumberPrefix_ID = vwmediaseq0_.SerialNumberPrefix_ID
		AND ieparteffe4_.IEPart_ID = vwmediaseq0_.IEPart_ID
		AND ieparteffe4_.Media_ID = vwmediaseq0_.Media_ID
		)

SELECT lnkieprodu5_.MEDIANUMBER,lnkieprodu5_.IESYSTEMCONTROLNUMBER,lnkieprodu5_.EMPPRODUCTINSTANCE_ID  
INTO #t31
FROM #t1 vwmediaseq0_
LEFT OUTER JOIN SISWEB_OWNER.LNKIEPRODUCTINSTANCE lnkieprodu5_ ON (
		lnkieprodu5_.MEDIANUMBER = vwmediaseq0_.Media_Number
		AND lnkieprodu5_.IESYSTEMCONTROLNUMBER = vwmediaseq0_.IESystemControlNumber
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
	,vwmediaseq0_.Org_Code 
	,vwmediaseq0_.Part_Number 
	,vwmediaseq0_.Update_Date 
	,vwmediaseq0_.Start_Serial_Number 
	,vwmediaseq0_.End_Serial_Number 
	,empproduct6_.SNP 
	,vwmediaseq0_.Part_ID
	,vwmediaseq0_.SerialNumberPrefix_ID
	,vwmediaseq0_.IEPart_ID
	,vwmediaseq0_.Media_ID
INTO #t4
FROM #t1 vwmediaseq0_
INNER JOIN #t31 lnkieprodu5_ ON (
		lnkieprodu5_.MEDIANUMBER = vwmediaseq0_.Media_Number
		AND lnkieprodu5_.IESYSTEMCONTROLNUMBER = vwmediaseq0_.IESystemControlNumber
		)
LEFT OUTER JOIN SISWEB_OWNER.EMPPRODUCTINSTANCE empproduct6_ ON (empproduct6_.EMPPRODUCTINSTANCE_ID = lnkieprodu5_.EMPPRODUCTINSTANCE_ID) -- EMP added + 5 seconds
WHERE(empproduct6_.NUMBER  = @Product_Instance_Number  OR @Product_Instance_Number  IS NULL )
AND (empproduct6_.SNP  = @SNP OR @SNP IS NULL )


SELECT DISTINCT IESystemControlNumber
	,Media_Number
	,Serviceability_Indicator
	,Arrangement_Indicator
	,CCR_Indicator
	,TypeChange_Indicator
	,NPR_Indicator
	,Base_English_Control_Number
	,IE_Control_Number
	,Org_Code
	,Part_Number
	,ProductStructure_ID
	,Update_Date
	,Start_Serial_Number
	,End_Serial_Number
	,SerialNumberPrefix_Type
	,SNP Serial_Number_Prefix
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