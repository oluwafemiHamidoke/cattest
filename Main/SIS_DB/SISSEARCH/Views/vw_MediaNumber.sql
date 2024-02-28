CREATE VIEW SISSEARCH.[vw_MediaNumber] AS
select 
	Media_ID,
	max(m.en) as [MediaNumber_en-US],
	max(m.es) as [MediaNumber_es-ES],
	max(m.fr) as [MediaNumber_fr-FR],
	max(m.pt) as [MediaNumber_pt-BR],
	max(m.it) as [MediaNumber_it-IT],
	max(m.id) as [MediaNumber_id-ID],
	max(m.zh) as [MediaNumber_zh-CN],
	max(m.de) as [MediaNumber_de-DE],
	max(m.jp) as [MediaNumber_ja-JP],
	max(m.ru) as [MediaNumber_ru-RU]
from (
	select m.Media_ID, l.Language_Code, tr.Media_Number
	from sis.Media m
	 inner join sis.Media_Translation tr on m.Media_ID=tr.Media_ID
	 inner join sis.Language l on tr.Language_ID=l.Language_ID and l.Default_Language=1
) q
Pivot (Max(q.Media_Number) For q.Language_Code in ([en],[de],[es],[fr],[jp],[ru],[id],[zh],[it],[pt])) m  
group by Media_ID
GO
