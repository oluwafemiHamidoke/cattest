CREATE PROC [sis].[SP_AsShippedEngine]   @Serial_Number_Prefix VARCHAR(12)
	,@Start_Serial_Number INT
	,@End_Serial_Number int 
	,@Language_ID int  AS Declare @prefixID INT = (SELECT SerialNumberPrefix_ID FROM sis.SerialNumberPrefix WHERE Serial_Number_Prefix = @Serial_Number_Prefix)

DECLARE @rangeID INT = (
		SELECT SerialNumberRange_ID
		FROM sis.SerialNumberRange
		WHERE Start_Serial_Number = @Start_Serial_Number     
			AND End_Serial_Number = @End_Serial_Number
		)  

SELECT shippedEngine.AsShippedEngine_ID
	,shippedEngine.Sequence_Number AS Sequence_Number
	,shippedEngine.Assembly AS Assembly
	,    shippedEngine.Change_Level_Number AS Change_Level_Number
	,shippedEngine.Indentation AS Indentation
	,shippedEngine.Less_Indicator AS Less_Indicator
	,    shippedEngine.Part_ID AS Part_ID
	,shippedEngine.Quantity AS Quantity
INTO #t1
FROM sis.AsShippedEngine shippedEngine    WHERE shippedEngine.SerialNumberPrefix_ID = @prefixID    
	AND shippedEngine.SerialNumberRange_ID = @rangeID     

SELECT pasr.Sequence_Number AS Sequence_Number
	,pasr.Assembly AS Assembly
	,    pasr.Change_Level_Number AS Change_Level_Number
	,pasr.Indentation AS Indentation
	,pasr.Less_Indicator AS Less_Indicator
	,    pasr.Part_ID AS Part_ID
	,    shippedEngine.Quantity AS Quantity    
INTO #t2    
FROM #t1 shippedEngine    
INNER JOIN [sis].[Part_AsShippedEngine_Relation] pasr ON pasr.AsShippedEngine_ID = shippedEngine.AsShippedEngine_ID     

SELECT Sequence_Number
	,Assembly
	,Change_Level_Number
	,Indentation
	,Less_Indicator
	,Part_ID
	,Quantity    
INTO #t3    
FROM #t1    

UNION ALL -- may want to try with UNION also
	
	   
SELECT Sequence_Number
	,Assembly
	,Change_Level_Number
	,Indentation
	,Less_Indicator
	,Part_ID
	,Quantity    
FROM #t2 
SELECT C.Sequence_Number
	,C.Assembly
	,C.Change_Level_Number
	,C.Indentation
	,C.Less_Indicator
	,C.Part_ID
	,part.Part_Number
	,C.Quantity
	,  pt.Part_Name
	,pt.Language_ID
	,@Serial_Number_Prefix Serial_Number_Prefix
	,@Start_Serial_Number Start_Serial_Number
	,@End_Serial_Number End_Serial_Number
FROM #t3 C    
INNER JOIN sis.Part part ON C.Part_ID = part.Part_ID    
LEFT JOIN sis.Part_Translation pt ON part.Part_ID = pt.Part_ID
WHERE Language_ID = @Language_ID
	OR Language_ID IS NULL
GROUP BY C.Sequence_Number
	,C.Assembly
	,C.Change_Level_Number
	,C.Indentation
	,C.Less_Indicator
	,C.Part_ID
	,part.Part_Number
	,C.Quantity
	,  pt.Part_Name
	,pt.Language_ID 

DROP TABLE #t1

DROP TABLE #t2

DROP TABLE #t3
GO
