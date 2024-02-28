CREATE VIEW SISSEARCH.[vw_ConsolidatedMedia] AS
SELECT DISTINCT
	m.Media_Number as ID,
	m.Media_Number as BaseEngMediaNumber,
	p.[PublishedDate_en-US] as INSERTDATE,
	'["'+m.Media_Number+'"]' as MediaNumber,
	t.[MediaTitle_en-US] as [MediaTitle_en-US],
	coalesce(t.[MediaTitle_es-ES], '') as [MediaTitle_es-ES],
	coalesce(t.[MediaTitle_fr-FR], '') as [MediaTitle_fr-FR],
	coalesce(t.[MediaTitle_pt-BR], '') as [MediaTitle_pt-BR],
	coalesce(t.[MediaTitle_it-IT], '') as [MediaTitle_it-IT],
	coalesce(t.[MediaTitle_id-ID], '') as [MediaTitle_id-ID],
	coalesce(t.[MediaTitle_zh-CN], '') as [MediaTitle_zh-CN],
	coalesce(t.[MediaTitle_de-DE], '') as [MediaTitle_de-DE],
	coalesce(t.[MediaTitle_ja-JP], '') as [MediaTitle_ja-JP],
	coalesce(t.[MediaTitle_ru-RU], '') as [MediaTitle_ru-RU],
	1 as isMedia,
	i.InformationType,
	s.SerialNumbers,
	NULL as ProductCode,
	u.[UpdatedDate_en-US] as UpdatedDate,
	p.[PublishedDate_en-US] as PubDate,
	r.RestrictionCode as RestrictionCode,
	m.PIPPS_Number as PIPPSPNumber,
	f.Family_Code as familyCode,
	f.Subfamily_Code as familySubFamilyCode,
	f.Sales_Model as familySubFamilySalesModel,
	f.Serial_Number_Prefix as familySubFamilySalesModelSNP,
	n.[MediaNumber_es-ES],
	n.[MediaNumber_zh-CN],
	n.[MediaNumber_fr-FR],
	n.[MediaNumber_it-IT],
	n.[MediaNumber_de-DE],
	n.[MediaNumber_pt-BR],
	n.[MediaNumber_id-ID],
	n.[MediaNumber_ja-JP],
	n.[MediaNumber_ru-RU],
	p.[PublishedDate_es-ES] as [PubDate_es-ES],
	p.[PublishedDate_zh-CN] as [PubDate_zh-CN],
	p.[PublishedDate_fr-FR] as [PubDate_fr-FR],
	p.[PublishedDate_it-IT] as [PubDate_it-IT],
	p.[PublishedDate_de-DE] as [PubDate_de-DE],
	p.[PublishedDate_pt-BR] as [PubDate_pt-BR],
	p.[PublishedDate_id-ID] as [PubDate_id-ID],
	p.[PublishedDate_ja-JP] as [PubDate_ja-JP],
	p.[PublishedDate_ru-RU] as [PubDate_ru-RU],
	u.[UpdatedDate_es-ES],
	u.[UpdatedDate_zh-CN],
	u.[UpdatedDate_fr-FR],
	u.[UpdatedDate_it-IT],
	u.[UpdatedDate_de-DE],
	u.[UpdatedDate_pt-BR],
	u.[UpdatedDate_id-ID],
	u.[UpdatedDate_ja-JP],
	u.[UpdatedDate_ru-RU]
FROM sis.Media m
LEFT JOIN SISSEARCH.[vw_MediaInfoType_Sis] i ON m.Media_ID=i.Media_ID
LEFT JOIN SISSEARCH.[vw_MediaTitle] t ON m.Media_ID=t.Media_ID
LEFT JOIN SISSEARCH.[vw_MediaPublishedDate] p ON m.Media_ID=p.Media_ID
LEFT JOIN SISSEARCH.[vw_MediaUpdatedDate] u ON m.Media_ID=u.Media_ID
LEFT JOIN SISSEARCH.[vw_MediaNumber] n ON m.Media_ID=n.Media_ID
LEFT JOIN SISSEARCH.[vw_MediaSerialNumber] s ON m.Media_ID=s.Media_ID
LEFT JOIN SISSEARCH.[vw_MediaFamily] f ON m.Media_ID=f.Media_ID
LEFT JOIN SISSEARCH.[vw_MediaRestrictionCode] r ON m.Media_ID=r.Media_ID
GO