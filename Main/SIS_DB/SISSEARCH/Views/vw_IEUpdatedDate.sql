


CREATE    VIEW [SISSEARCH].vw_IEUpdatedDate AS
--
-- IE Updated Date
--
select 
	IE_ID,
	convert(date, max(u.en)) as [UpdatedDate_en-US],
	convert(date, max(u.es)) as [UpdatedDate_es-ES],
	convert(date, max(u.fr)) as [UpdatedDate_fr-FR],
	convert(date, max(u.pt)) as [UpdatedDate_pt-BR],
	convert(date, max(u.it)) as [UpdatedDate_it-IT],
	convert(date, max(u.id)) as [UpdatedDate_id-ID],
	convert(date, max(u.zh)) as [UpdatedDate_zh-CN],
	convert(date, max(u.de)) as [UpdatedDate_de-DE],
	convert(date, max(u.jp)) as [UpdatedDate_ja-JP],
	convert(date, max(u.ru)) as [UpdatedDate_ru-RU]
from (
	select e.IE_ID, l.Language_Code, tr.Published_Date
	from sis.IE e
	 inner join sis.IE_Translation tr on e.IE_ID=tr.IE_ID
	 inner join sis.Language l on tr.Language_ID=l.Language_ID and l.Default_Language=1
) q
Pivot (Max(q.Published_Date) For q.Language_Code in ([en],[de],[es],[fr],[jp],[ru],[id],[zh],[it],[pt])) u
group by IE_ID
GO