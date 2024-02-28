

CREATE   VIEW SISSEARCH.vw_BasicServiceIE_Origin AS
SELECT  
	e.IE_ID, 
	e.IESystemControlNumber as IESystemControlNumber, 
	'['+string_agg(i.InfoType_ID, ',')+']' as InfoTypeID
	from sis.IE e
	inner join sis.IE_InfoType_Relation i on e.IE_ID=i.IE_ID
	GROUP BY e.IE_ID, e.IESystemControlNumber
GO