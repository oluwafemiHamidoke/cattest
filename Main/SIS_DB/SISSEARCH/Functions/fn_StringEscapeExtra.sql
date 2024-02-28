

-- string_escape(translate(@t, char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json')

CREATE   FUNCTION [SISSEARCH].fn_StringEscapeExtra(@t nvarchar(max))
RETURNS nvarchar(max)
AS BEGIN
	RETURN string_escape(translate(@t, char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json')
END