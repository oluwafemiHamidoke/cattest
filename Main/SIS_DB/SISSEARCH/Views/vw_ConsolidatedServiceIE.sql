

CREATE   VIEW SISSEARCH.vw_ConsolidatedServiceIE AS
select
	convert(varchar(50),e.IESystemControlNumber) as ID,
	convert(varchar(15),e.IESystemControlNumber) as IESystemControlNumber,
	e.InfoTypeID as InfoType,
	m.MediaNumbers  as MediaNumbers,
	convert(date, u.[UpdatedDate_en-US]) as UpdatedDate,
	s.SerialNumbers,
	sm.SMCSCodes,
	pr.ProductStructureSystemIDs,
	t.[IETitle_en-US] as [Title_en],
	0 as isMedia,
	pc.ProductCodes,
	coalesce(p.[PublishedDate_en-US], '') as PubDate,
	r.RestrictionCode,
	cn.ControlNumber,
	f.Family_Code as familyCode,
	f.Subfamily_Code as familySubFamilyCode,
	f.Sales_Model as familySubFamilySalesModel,
	f.Serial_Number_Prefix as  familySubFamilySalesModelSNP,
	coalesce(t.[IETitle_es-ES], '') as [Title_es-ES],
	coalesce(t.[IETitle_fr-FR], '') as [Title_fr-FR],
	coalesce(t.[IETitle_pt-BR], '') as [Title_pt-BR],
	coalesce(t.[IETitle_it-IT], '') as [Title_it-IT],
	coalesce(t.[IETitle_id-ID], '') as [Title_id-ID],
	coalesce(t.[IETitle_zh-CN], '') as [Title_zh-CN],
	coalesce(t.[IETitle_de-DE], '') as [Title_de-DE],
	coalesce(t.[IETitle_ja-JP], '') as [Title_ja-JP],
	coalesce(t.[IETitle_ru-RU], '') as [Title_ru-RU],
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
	u.[UpdatedDate_ru-RU],
	mn.[MediaNumbers_es-ES],
	mn.[MediaNumbers_zh-CN],
	mn.[MediaNumbers_fr-FR],
	mn.[MediaNumbers_it-IT],
	mn.[MediaNumbers_de-DE],
	mn.[MediaNumbers_pt-BR],
	mn.[MediaNumbers_id-ID],
	mn.[MediaNumbers_ja-JP],
	mn.[MediaNumbers_ru-RU]
from [SISSEARCH].[vw_BasicServiceIE_Origin] e
left join [SISSEARCH].vw_IEControlNumber cn on cn.IE_ID=e.IE_ID
left join [SISSEARCH].[vw_IETitle] t on t.IE_ID=e.IE_ID
left join [SISSEARCH].[vw_IEUpdatedDate] u on u.IE_ID=e.IE_ID
left join [SISSEARCH].[vw_IEPublishedDate] p on p.IE_ID=e.IE_ID
left join SISSEARCH.[vw_IESerialNumber] s ON s.IE_ID=e.IE_ID
left join SISSEARCH.[vw_IEFamily] f ON f.IE_ID=e.IE_ID
left join SISSEARCH.[vw_IEMedia] m ON m.IE_ID=e.IE_ID
left join SISSEARCH.[vw_IESMCS] sm on sm.IE_ID=e.IE_ID
left join SISSEARCH.[vw_IEProductStructure] pr on pr.IE_ID=e.IE_ID
left join SISSEARCH.[vw_IERestrictionCode] r on r.IE_ID=e.IE_ID
left join SISSEARCH.[vw_IEProductCodes] pc on pc.IE_ID=e.IE_ID
left join SISSEARCH.[vw_IEMediaNumbers] mn on mn.IE_ID=e.IE_ID
GO
