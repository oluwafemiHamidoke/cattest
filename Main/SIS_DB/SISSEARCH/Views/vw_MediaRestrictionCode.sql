CREATE VIEW SISSEARCH.vw_MediaRestrictionCode AS
SELECT
	m.Media_ID,
	'[·'+string_agg(c.OrgCode, '","')+'"]' as RestrictionCode
FROM sis.Media m
INNER JOIN sis.Media_InfoType_Relation i on m.Media_ID=i.Media_ID
inner join [sis].[ServiceLetter_RestrictionCodes] c on i.InfoType_ID=c.[InfoTypeID]
GROUP BY m.Media_ID
GO
