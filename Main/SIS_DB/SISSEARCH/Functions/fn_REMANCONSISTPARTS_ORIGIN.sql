﻿CREATE   FUNCTION [SISSEARCH].[fn_REMANCONSISTPARTS_ORIGIN](@DATE DATETIME)
	RETURNS TABLE
AS
RETURN SELECT
	b.IESYSTEMCONTROLNUMBER,
	isnull(k.PARTNUMBER,'')+':'+isnull(k.RELATEDPARTNUMBER,'')+':'+isnull(k.RELATEDPARTNAME, '') as REMANCONSISTPART,
	b.LASTMODIFIEDDATE INSERTDATE
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] b With(NolocK)--3M
inner join [SISWEB_OWNER].[MASMEDIA] e with(Nolock)
	on e.MEDIANUMBER=b.MEDIANUMBER and e.[MEDIASOURCE]='A'  --Authoring 
inner join [SISWEB_OWNER_SHADOW].LNKCONSISTLIST d With(Nolock) --56M
	on b.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER
inner join [sis].[vw_RelatedPartsNoKits] k
	on k.PARTNUMBER = d.PARTNUMBER and k.TYPEINDICATOR = 'R'
WHERE b.LASTMODIFIEDDATE > @DATE 
UNION ALL SELECT
    b.IESYSTEMCONTROLNUMBER,
	isnull(k.PARTNUMBER,'')+':'+isnull(k.RELATEDPARTNUMBER,'')+':'+isnull(k.RELATEDPARTNAME, '') as REMANCONSISTPART,
   b.LASTMODIFIEDDATE INSERTDATE
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] b With(NolocK)
inner join [SISWEB_OWNER].[MASMEDIA] e with(Nolock)
	on e.MEDIANUMBER=b.MEDIANUMBER and e.[MEDIASOURCE] ='C'  --Conversion
inner join [SISWEB_OWNER_SHADOW].LNKCONSISTLIST d With(Nolock) --56M
	on d.IESYSTEMCONTROLNUMBER  = b.BASEENGCONTROLNO-- Conversion records relate to LNKCONSISTLIST on baseengcontrolno instead of iesystemcontrolnumber
inner join [sis].[vw_RelatedPartsNoKits] k
	on k.PARTNUMBER = d.PARTNUMBER and k.TYPEINDICATOR = 'R'
WHERE b.LASTMODIFIEDDATE > @DATE