
CREATE   FUNCTION [SISSEARCH].[fn_PRODUCTSTRUCTURE](@DATE DATETIME)
	RETURNS TABLE
AS RETURN select 
	IESYSTEMCONTROLNUMBER,
	IESYSTEMCONTROLNUMBER as id,
	'[' + string_agg(PSID,',')+']' as psid,
	'["' + string_agg(SYSTEM,'","')+'"]' as system,
	max([InsertDate]) as [InsertDate]
from (	
	select
		IESYSTEMCONTROLNUMBER,
		'"' + string_agg(PSID,'","')+'"' as PSID,
		SYSTEM,
		max([InsertDate]) as [InsertDate]
	from SISSEARCH.fn_PRODUCTSTRUCTURE_ORIGIN(@DATE)
	group by IESYSTEMCONTROLNUMBER, SYSTEM
) r
group by IESYSTEMCONTROLNUMBER