﻿
CREATE   FUNCTION [SISSEARCH].[fn_KITIEPART_ORIGIN2](@DATE DATETIME)
	RETURNS TABLE
AS
RETURN SELECT 
    b.IESYSTEMCONTROLNUMBER,
	string_escape(translate(isnull(k.PARTNUMBER,'')+':'+isnull(k.KITPARTNUMBER,'')+':'+isnull(k.KITPARTNAME, ''),
		char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as KITIEPART,
	b.LASTMODIFIEDDATE INSERTDATE
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] b With(NolocK)
inner join [SISWEB_OWNER].[MASMEDIA] e with(Nolock)
	on e.MEDIANUMBER=b.MEDIANUMBER and e.[MEDIASOURCE] IN ('A', 'C')  --Authoring 
inner join [SISWEB_OWNER].[MV_KITDATA] k
	on k.PARTNUMBER = b.IEPARTNUMBER
WHERE b.LASTMODIFIEDDATE > @DATE