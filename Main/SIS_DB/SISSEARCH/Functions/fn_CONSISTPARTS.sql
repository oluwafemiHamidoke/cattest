
CREATE   FUNCTION [SISSEARCH].[fn_CONSISTPARTS](@LASTINSERTDATE DATETIME)
	RETURNS TABLE
AS RETURN SELECT 
		b.IESYSTEMCONTROLNUMBER,
		b.IESYSTEMCONTROLNUMBER as ID,
		max(try_cast(INSERTDATE as datetime)) INSERTDATE,
		'["' + string_agg(string_escape(translate(concat(isnull(b.PARTNUMBER,''), ':', isnull(b.PARTNAME, '')), 
			char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json'), '","') + '"]' as CONSISTPART,
		'["' + string_agg([8], '","') + '"]' as [ConsistPartNames_id-ID],
		'["' + string_agg([C], '","') + '"]' as [ConsistPartNames_zh-CN],
		'["' + string_agg([F], '","') + '"]' as [ConsistPartNames_fr-FR],
		'["' + string_agg([G], '","') + '"]' as [ConsistPartNames_de-DE],
		'["' + string_agg([L], '","') + '"]' as [ConsistPartNames_it-IT],
		'["' + string_agg([P], '","') + '"]' as [ConsistPartNames_pt-BR],
		'["' + string_agg([S], '","') + '"]' as [ConsistPartNames_es-ES],
		'["' + string_agg([R], '","') + '"]' as [ConsistPartNames_ru-RU],
		'["' + string_agg([J], '","') + '"]' as [ConsistPartNames_ja-JP]
from [SISSEARCH].[fn_CONSISTPARTSORIGIN](@LASTINSERTDATE) b
INNER JOIN [SISSEARCH].[vw_TRANSLATEDPARTS] t on b.PARTNAME = t.PARTNAME
GROUP BY b.IESYSTEMCONTROLNUMBER