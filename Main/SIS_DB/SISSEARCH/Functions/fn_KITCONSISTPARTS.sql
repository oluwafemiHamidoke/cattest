﻿

CREATE   FUNCTION SISSEARCH.fn_KITCONSISTPARTS(@DATE DATETIME)
	RETURNS TABLE
AS
RETURN SELECT 
	IESYSTEMCONTROLNUMBER,
	IESYSTEMCONTROLNUMBER as ID,
	'["' + string_agg(KITCONSISTPART, '","') + '"]' as KITCONSISTPART,
	MAX(INSERTDATE) as INSERTDATE
FROM SISSEARCH.fn_KITCONSISTPARTS_ORIGIN(@DATE)
GROUP BY IESYSTEMCONTROLNUMBER