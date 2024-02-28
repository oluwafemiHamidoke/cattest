
create   view [SISSEARCH].[vw_C] AS
SELECT 
	 b.IESYSTEMCONTROLNUMBER,
	 b.IESYSTEMCONTROLNUMBER as ID,
	 '["' + string_agg(cast(concat(d.PARTNUMBER,':',d.PARTNAME) as varchar(max)), '","') + '"]' as CONSISTPART,
	 '["' + string_agg(cast(t.[8] as varchar(max)), '","') + '"]' as a,
	 '["' + string_agg(cast(t.[C] as varchar(max)), '","') + '"]' as b,
	 '["' + string_agg(cast(t.[F] as varchar(max)), '","') + '"]' as c,
	 '["' + string_agg(cast(t.[G] as varchar(max)), '","') + '"]' as d,
	 '["' + string_agg(cast(t.[L] as varchar(max)), '","') + '"]' as e,
	 '["' + string_agg(cast(t.[P] as varchar(max)), '","') + '"]' as f,
	 '["' + string_agg(cast(t.[S] as varchar(max)), '","') + '"]' as g,
	 '["' + string_agg(cast(t.[R] as varchar(max)), '","') + '"]' as h,
	 '["' + string_agg(cast(t.[J] as varchar(max)), '","') + '"]' as i
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] b With(NolocK)--3M
inner join [SISWEB_OWNER].[MASMEDIA] e with(Nolock)
	on e.MEDIANUMBER=b.MEDIANUMBER and e.[MEDIASOURCE]='A'  --Authoring 
inner join [SISWEB_OWNER_SHADOW].LNKCONSISTLIST d With(Nolock) --56M
	on b.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER
Inner Join (
	select * 
	from [SISWEB_OWNER].[LNKTRANSLATEDSPN] t
	PIVOT (
		Max([TRANSLATEDPARTNAME]) 
		For [LANGUAGEINDICATOR] in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
	) pvt
) t on d.PARTNAME = t.PARTNAME
GROUP BY b.IESYSTEMCONTROLNUMBER--, t.PARTNAME
--ORDER BY b.IESYSTEMCONTROLNUMBER