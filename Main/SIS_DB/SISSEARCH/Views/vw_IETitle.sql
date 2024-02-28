
CREATE    VIEW [SISSEARCH].vw_IETitle AS
--
-- IE Title
--
select 
	IE_ID, 
	string_escape(translate(t.en, char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as [IETitle_en-US],
	string_escape(translate(t.es, char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as [IETitle_es-ES],
	string_escape(translate(t.fr, char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as [IETitle_fr-FR],
	string_escape(translate(t.pt, char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as [IETitle_pt-BR],
	string_escape(translate(t.it, char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as [IETitle_it-IT],
	string_escape(translate(t.id, char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as [IETitle_id-ID],
	string_escape(translate(t.zh, char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as [IETitle_zh-CN],
	string_escape(translate(t.de, char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as [IETitle_de-DE],
	string_escape(translate(t.jp, char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as [IETitle_ja-JP],
	string_escape(translate(t.ru, char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as [IETitle_ru-RU]
from (
	select e.IE_ID, l.Language_Code, tr.Title
	from sis.IE e
	 inner join sis.IE_Translation tr on e.IE_ID=tr.IE_ID
	 inner join sis.Language l on tr.Language_ID=l.Language_ID and l.Default_Language=1
) q
Pivot (Max(q.Title) For q.Language_Code in ([en],[de],[es],[fr],[jp],[ru],[id],[zh],[it],[pt])) t
GO