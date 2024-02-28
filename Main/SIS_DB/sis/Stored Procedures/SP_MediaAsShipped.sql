CREATE PROCEDURE [sis].[SP_MediaAsShipped] 
(@SerialNumberPrefix_ID INT, @SerialNumberRange_ID INT )

AS

BEGIN

DROP TABLE IF EXISTS #t1;
DROP TABLE IF EXISTS #t2;

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

SELECT MS.IESystemControlNumber
	FROM #t2 t2
	JOIN sis.[MediaSequence] MS
	ON
	MS.IEPart_ID=t2.IEPart_ID
	GROUP BY MS.IESystemControlNumber

END


