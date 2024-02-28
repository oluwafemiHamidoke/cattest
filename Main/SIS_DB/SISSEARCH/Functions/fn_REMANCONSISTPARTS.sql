﻿
CREATE   FUNCTION SISSEARCH.fn_REMANCONSISTPARTS(@DATE DATETIME)
	RETURNS TABLE
AS
RETURN SELECT 
	IESYSTEMCONTROLNUMBER,
	IESYSTEMCONTROLNUMBER as ID,
	'["' + string_agg(string_escape(translate(REMANCONSISTPART,
		char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json'), '","') + '"]' as REMANCONSISTPART,
	MAX(INSERTDATE) as INSERTDATE
FROM SISSEARCH.fn_REMANCONSISTPARTS_ORIGIN(@DATE)
GROUP BY IESYSTEMCONTROLNUMBER