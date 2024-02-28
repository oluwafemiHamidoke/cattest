

CREATE    VIEW [SISSEARCH].vw_IEMediaNumbers AS
--
-- IE Media Numbers
--

select 
	IE_ID, 
	'["'+t.en+'"]' as [MediaNumbers_en-US],
	'["'+t.es+'"]' as [MediaNumbers_es-ES],
	'["'+t.fr+'"]' as [MediaNumbers_fr-FR],
	'["'+t.pt+'"]' as [MediaNumbers_pt-BR],
	'["'+t.it+'"]' as [MediaNumbers_it-IT],
	'["'+t.id+'"]' as [MediaNumbers_id-ID],
	'["'+t.zh+'"]' as [MediaNumbers_zh-CN],
	'["'+t.de+'"]' as [MediaNumbers_de-DE],
	'["'+t.jp+'"]' as [MediaNumbers_ja-JP],
	'["'+t.ru+'"]' as [MediaNumbers_ru-RU]
from (
	select ef.IE_ID,l.Language_Code, t.Media_Number from sis.IE_Effectivity ef
		inner join sis.Media m on ef.Media_ID=m.Media_ID
		inner join sis.Media_Translation t on t.Media_ID=m.Media_ID
		inner join sis.Language l on l.Language_ID=t.Language_ID and l.Default_Language=1
) q
Pivot (Max(q.Media_Number) For q.Language_Code in ([en],[de],[es],[fr],[jp],[ru],[id],[zh],[it],[pt])) t
GO