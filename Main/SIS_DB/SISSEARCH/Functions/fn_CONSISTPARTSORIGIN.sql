﻿
CREATE   FUNCTION [SISSEARCH].[fn_CONSISTPARTSORIGIN] (@LASTINSERTDATE DATETIME)
	RETURNS TABLE
AS RETURN SELECT 
	b.IESYSTEMCONTROLNUMBER,
	b.IESYSTEMCONTROLNUMBER as ID,
	d.PARTNUMBER,
	d.PARTNAME,
	b.LASTMODIFIEDDATE INSERTDATE
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] b With(NolocK)
inner join [SISWEB_OWNER].[MASMEDIA] e with(Nolock)
	on e.MEDIANUMBER=b.MEDIANUMBER and e.[MEDIASOURCE]='A'  
inner join [SISWEB_OWNER_SHADOW].LNKCONSISTLIST d With(Nolock) 
	on b.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER
WHERE b.LASTMODIFIEDDATE > @LASTINSERTDATE
-- Use UNION or UNION ALL depending if you want duplicated parts or not --
-- UNION  --  Using UNION will not include duplicated parts
UNION ALL --  Using UNION ALL will include duplicated parts
SELECT
	b.IESYSTEMCONTROLNUMBER,
	b.IESYSTEMCONTROLNUMBER as id,	
	d.PARTNUMBER,
	d.PARTNAME,
	b.LASTMODIFIEDDATE INSERTDATE
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] b With(NolocK)
inner join [SISWEB_OWNER].[MASMEDIA] e with(Nolock)
	on e.MEDIANUMBER=b.MEDIANUMBER and e.[MEDIASOURCE] ='C'
inner join [SISWEB_OWNER_SHADOW].LNKCONSISTLIST d With(Nolock)
	on d.IESYSTEMCONTROLNUMBER  = b.BASEENGCONTROLNO
WHERE b.LASTMODIFIEDDATE > @LASTINSERTDATE