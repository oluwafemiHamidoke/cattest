CREATE VIEW SISSEARCH.[vw_MediaUpdatedDate] AS
select 
	Media_ID,
	max(u.en) as [UpdatedDate_en-US],
	max(u.es) as [UpdatedDate_es-ES],
	max(u.fr) as [UpdatedDate_fr-FR],
	max(u.pt) as [UpdatedDate_pt-BR],
	max(u.it) as [UpdatedDate_it-IT],
	max(u.id) as [UpdatedDate_id-ID],
	max(u.zh) as [UpdatedDate_zh-CN],
	max(u.de) as [UpdatedDate_de-DE],
	max(u.jp) as [UpdatedDate_ja-JP],
	max(u.ru) as [UpdatedDate_ru-RU]
from (
	select m.Media_ID, l.Language_Code, tr.Updated_Date-- , tr.Published_Date, tr.Media_Number
	from sis.Media m
	 inner join sis.Media_Translation tr on m.Media_ID=tr.Media_ID
	 inner join sis.Language l on tr.Language_ID=l.Language_ID and l.Default_Language=1
) q
Pivot (Max(q.Updated_Date) For q.Language_Code in ([en],[de],[es],[fr],[jp],[ru],[id],[zh],[it],[pt])) u  
group by Media_ID
GO