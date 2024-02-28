CREATE VIEW SISSEARCH.[vw_MediaTitle] AS
--
-- Media Title
--
select 
	Media_ID,
	max(t.en) as [MediaTitle_en-US],
	max(t.es) as [MediaTitle_es-ES],
	max(t.fr) as [MediaTitle_fr-FR],
	max(t.pt) as [MediaTitle_pt-BR],
	max(t.it) as [MediaTitle_it-IT],
	max(t.id) as [MediaTitle_id-ID],
	max(t.zh) as [MediaTitle_zh-CN],
	max(t.de) as [MediaTitle_de-DE],
	max(t.jp) as [MediaTitle_ja-JP],
	max(t.ru) as [MediaTitle_ru-RU]
from (
	select m.Media_ID, l.Language_Code, tr.Title
	from sis.Media m
	 inner join sis.Media_Translation tr on m.Media_ID=tr.Media_ID
	 inner join sis.Language l on tr.Language_ID=l.Language_ID and l.Default_Language=1
) q
Pivot (Max(q.Title) For q.Language_Code in ([en],[de],[es],[fr],[jp],[ru],[id],[zh],[it],[pt])) t 
group by Media_ID

GO