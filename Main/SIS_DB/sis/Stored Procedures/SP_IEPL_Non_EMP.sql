CREATE PROCEDURE [sis].[SP_IEPL_Non_EMP] 
(@Part_ID_List VARCHAR(MAX),@Media_Number VARCHAR(50),@Serial_Number_Prefix VARCHAR(3),@Start_Serial_Number int,@End_Serial_Number int,@Media_Origin_NonSisJ VARCHAR(2), @Media_Origin_NonEMP VARCHAR(2))

AS

BEGIN
SET NOCOUNT ON
DROP TABLE IF EXISTS #t1;
DROP TABLE IF EXISTS #t2;
DROP TABLE IF EXISTS #t3;
DROP TABLE IF EXISTS #t4;


SELECT CAST(value as INT) Part_ID INTO #t4 FROM STRING_SPLIT(@Part_ID_List, ',');

SELECT DISTINCT vwmediaseq0_.IESystemControlNumber 
	,vwmediaseq0_.Media_Number 
	,vwmediaseq0_.Serviceability_Indicator 
	,vwmediaseq0_.Arrangement_Indicator 
	,vwmediaseq0_.CCR_Indicator 
	,vwmediaseq0_.TypeChange_Indicator 
	,vwmediaseq0_.NPR_Indicator 
	,iepart1_.Base_English_Control_Number 
	,iepart1_.IE_Control_Number 
	,part2_.Org_Code 
	,part2_.Part_Number 
	,iepart1_.Update_Date
	,vwmediaseq0_.Start_Serial_Number 
	,vwmediaseq0_.End_Serial_Number 
	,vwmediaseq0_.Serial_Number_Prefix 
	,part2_.Part_ID
	,vwmediaseq0_.IEPart_ID
	,vwmediaseq0_.Media_ID
	,vwmediaseq0_.SerialNumberPrefix_ID
INTO #t1
FROM #t4 p1
INNER JOIN sis.Part part2_ ON (part2_.Part_ID = p1.Part_ID)
INNER JOIN sis.IEPart iepart1_ ON (iepart1_.Part_ID = part2_.Part_ID)
INNER JOIN sis.vw_MediaSequenceFamily vwmediaseq0_ ON (vwmediaseq0_.IEPart_ID = iepart1_.IEPart_ID)
WHERE 
 (vwmediaseq0_.Serial_Number_Prefix =	@Serial_Number_Prefix OR @Serial_Number_Prefix 	IS NULL) AND
 (vwmediaseq0_.Start_Serial_Number <=	@Start_Serial_Number  OR @Start_Serial_Number 	IS NULL) AND
 (vwmediaseq0_.End_Serial_Number >=		@End_Serial_Number    OR @End_Serial_Number   	IS NULL) AND
 (vwmediaseq0_.Media_Origin <>			@Media_Origin_NonSisJ		  OR @Media_Origin_NonSisJ		 	IS NULL) AND
 (vwmediaseq0_.Media_Origin <>			@Media_Origin_NonEMP		  OR @Media_Origin_NonEMP		 	IS NULL) AND
 (vwmediaseq0_.Media_Number =			@Media_Number		  OR @Media_Number		 	IS NULL)


select distinct ProductStructure_ID,productstr3_.IEPart_ID,productstr3_.Media_ID
into #t2
from #t1 vwmediaseq0_
INNER JOIN sis.ProductStructure_IEPart_Relation productstr3_ ON (
		vwmediaseq0_.IEPart_ID = productstr3_.IEPart_ID
		AND productstr3_.Media_ID = vwmediaseq0_.Media_ID
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


SELECT  
	 IESystemControlNumber 
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
	,Serial_Number_Prefix 
	,Part_ID 
FROM #t1 t1
INNER JOIN #t3 t3 ON (
		t1.SerialNumberPrefix_ID = t3.SerialNumberPrefix_ID
		AND t1.IEPart_ID = t3.IEPart_ID
		AND t1.Media_ID = t3.Media_ID
		)
INNER JOIN #t2 productstr4_ ON (
		t1.IEPart_ID = productstr4_.IEPart_ID
		AND productstr4_.Media_ID = t1.Media_ID
		)


END
GO