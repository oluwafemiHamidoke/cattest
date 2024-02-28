CREATE PROCEDURE [sis].[SP_MediaAsShippedAndRelatedParts] 
(@SerialNumberPrefix_ID INT, @SerialNumberRange_ID INT )

AS

BEGIN
SET NOCOUNT ON;  
DROP TABLE IF EXISTS #t1;
DROP TABLE IF EXISTS #t2;
DROP TABLE IF EXISTS #t3;

SELECT distinct Part_ID, PartLevel
	INTO #t1 
	FROM [sis].[AsShippedPart_Level_Relation] 
	WHERE (PartLevel=0 or PartLevel=1)
    AND SerialNumberPrefix_ID=@SerialNumberPrefix_ID and SerialNumberRange_ID=@SerialNumberRange_ID; 

SELECT IEPart_ID
	INTO #t2
	FROM #t1 t1 
	JOIN [sis].[IEPart] IEP
	ON IEP.Part_ID=t1.Part_ID

SELECT Media_ID, Related_IEPart_ID
	INTO #t3
	FROM #t2 t2
	JOIN  sis.IEPart_IEPart_Relation IER
	ON t2.IEPart_ID = IER.IEPart_ID

SELECT MSSF.IESystemControlNumber
	FROM  #t3 t3
	JOIN sis.MediaSequenceSectionFamily MSSF
	ON MSSF.Media_ID=t3.Media_ID
	AND MSSF.IEPart_ID=t3.Related_IEPart_ID
	GROUP BY MSSF.IESystemControlNumber

END