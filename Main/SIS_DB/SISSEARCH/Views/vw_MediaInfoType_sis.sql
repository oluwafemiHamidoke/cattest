CREATE VIEW SISSEARCH.[vw_MediaInfoType_Sis] AS
SELECT 
	m.Media_ID, 
	'["'+ string_agg(cast(i.InfoType_ID as nvarchar(10)), '","') + '"]' as InformationType
FROM sis.Media m
INNER JOIN sis.Media_InfoType_Relation i on m.Media_ID=i.Media_ID
GROUP BY m.Media_ID
GO