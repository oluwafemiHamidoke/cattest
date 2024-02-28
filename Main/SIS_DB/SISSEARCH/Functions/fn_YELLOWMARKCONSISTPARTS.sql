﻿

CREATE   FUNCTION SISSEARCH.fn_YELLOWMARKCONSISTPARTS(@DATE DATETIME)
	RETURNS TABLE
AS
RETURN SELECT 
	IESYSTEMCONTROLNUMBER,
	IESYSTEMCONTROLNUMBER as ID,
	'["' + string_agg(YELLOWMARKCONSISTPART, '","') + '"]' as YELLOWMARKCONSISTPART,
	MAX(INSERTDATE) as INSERTDATE
FROM SISSEARCH.fn_YELLOWMARKCONSISTPARTS_ORIGIN(@DATE)
GROUP BY IESYSTEMCONTROLNUMBER