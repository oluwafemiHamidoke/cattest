CREATE VIEW SISSEARCH.[vw_MediaPublishedDate] AS
select 
	Media_ID,
	max(p.en) as [PublishedDate_en-US],
	max(p.es) as [PublishedDate_es-ES],
	max(p.fr) as [PublishedDate_fr-FR],
	max(p.pt) as [PublishedDate_pt-BR],
	max(p.it) as [PublishedDate_it-IT],
	max(p.id) as [PublishedDate_id-ID],
	max(p.zh) as [PublishedDate_zh-CN],
	max(p.de) as [PublishedDate_de-DE],
	max(p.jp) as [PublishedDate_ja-JP],
	max(p.ru) as [PublishedDate_ru-RU]
from (
	select m.Media_ID, l.Language_Code, tr.Published_Date --, tr.Media_Number
	from sis.Media m
	 inner join sis.Media_Translation tr on m.Media_ID=tr.Media_ID
	 inner join sis.Language l on tr.Language_ID=l.Language_ID and l.Default_Language=1
) q
Pivot (Max(q.Published_Date) For q.Language_Code in ([en],[de],[es],[fr],[jp],[ru],[id],[zh],[it],[pt])) p  
group by Media_ID
GO