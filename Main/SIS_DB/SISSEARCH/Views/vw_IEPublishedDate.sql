


CREATE    VIEW [SISSEARCH].vw_IEPublishedDate AS
--
-- vw_IEPublishedDate
--
select 
	IE_ID,
	p.en as [PublishedDate_en-US],
	p.es as [PublishedDate_es-ES],
	p.fr as [PublishedDate_fr-FR],
	p.pt as [PublishedDate_pt-BR],
	p.it as [PublishedDate_it-IT],
	p.id as [PublishedDate_id-ID],
	p.zh as [PublishedDate_zh-CN],
	p.de as [PublishedDate_de-DE],
	p.jp as [PublishedDate_ja-JP],
	p.ru as [PublishedDate_ru-RU]
from (
	select e.IE_ID, l.Language_Code, tr.Published_Date
	from sis.IE e
	 inner join sis.IE_Translation tr on e.IE_ID=tr.IE_ID
	 inner join sis.Language l on tr.Language_ID=l.Language_ID
) q
Pivot (Max(q.Published_Date) For q.Language_Code in ([en],[de],[es],[fr],[jp],[ru],[id],[zh],[it],[pt])) p
GO
