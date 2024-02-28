
create   view [SISSEARCH].[vw_CONSISTPARTS] AS
SELECT 
	 b.IESYSTEMCONTROLNUMBER,
	 b.IESYSTEMCONTROLNUMBER as ID,
	 max(INSERTDATE) INSERTDATE,
	 '["' + string_agg(cast(string_escape(concat(isnull(b.PARTNUMBER,''), ':', isnull(b.PARTNAME, '')), 'json') as nvarchar(max)), '","') + '"]' as CONSISTPART,
	 '["' + string_agg(cast(string_escape(t.[8], 'json') as nvarchar(max)), '","') + '"]' as [ConsistPartNames_id-ID],
	 '["' + string_agg(cast(string_escape(t.[C], 'json') as nvarchar(max)), '","') + '"]' as [ConsistPartNames_zh-CN],
	 '["' + string_agg(cast(string_escape(t.[F], 'json') as nvarchar(max)), '","') + '"]' as [ConsistPartNames_fr-FR],
	 '["' + string_agg(cast(string_escape(t.[G], 'json') as nvarchar(max)), '","') + '"]' as [ConsistPartNames_de-DE],
	 '["' + string_agg(cast(string_escape(t.[L], 'json') as nvarchar(max)), '","') + '"]' as [ConsistPartNames_it-IT],
	 '["' + string_agg(cast(string_escape(t.[P], 'json') as nvarchar(max)), '","') + '"]' as [ConsistPartNames_pt-BR],
	 '["' + string_agg(cast(string_escape(t.[S], 'json') as nvarchar(max)), '","') + '"]' as [ConsistPartNames_es-ES],
	 '["' + string_agg(cast(string_escape(t.[R], 'json') as nvarchar(max)), '","') + '"]' as [ConsistPartNames_ru-RU],
	 '["' + string_agg(cast(string_escape(t.[J], 'json') as nvarchar(max)), '","') + '"]' as [ConsistPartNames_ja-JP]
from [SISSEARCH].[vw_CONSISTPARTSORIGIN] b
LEFT OUTER Join (
	select * 
	from [SISWEB_OWNER].[LNKTRANSLATEDSPN] t
	PIVOT (
		Max([TRANSLATEDPARTNAME]) 
		For [LANGUAGEINDICATOR] in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
	) pvt
) t on b.PARTNAME = t.PARTNAME
GROUP BY b.IESYSTEMCONTROLNUMBER--, t.PARTNAME
--ORDER BY b.IESYSTEMCONTROLNUMBER