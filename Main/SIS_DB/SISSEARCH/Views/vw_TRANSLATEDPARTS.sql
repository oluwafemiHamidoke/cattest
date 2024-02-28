CREATE VIEW [SISSEARCH].[vw_TRANSLATEDPARTS] 
AS SELECT 
	PARTNAME, -- LASTMODIFIEDDATE, 
	string_escape(translate([8], char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as [8], 
	string_escape(translate([C], char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as [C], 
	string_escape(translate([F], char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as [F], 
	string_escape(translate([G], char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as [G], 
	string_escape(translate([L], char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as [L], 
	string_escape(translate([P], char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as [P], 
	string_escape(translate([S], char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as [S], 
	string_escape(translate([R], char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as [R], 
	string_escape(translate([J], char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as [J]
from [SISWEB_OWNER].[LNKTRANSLATEDSPN] t
PIVOT (
	Max([TRANSLATEDPARTNAME]) 
	For [LANGUAGEINDICATOR] in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
) pvt;