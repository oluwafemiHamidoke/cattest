
CREATE   FUNCTION [SISSEARCH].[fn_PRODUCTHIERARCHY_ORIGIN](@DATE DATETIME)
	RETURNS TABLE
AS
RETURN SELECT DISTINCT
	a.IESYSTEMCONTROLNUMBER,
	isnull(b.Family_Code,'') Family_Code,
	isnull(b.Subfamily_Code,'') Subfamily_Code,
	isnull(b.Sales_Model,'') Sales_Model,
	isnull(b.Serial_Number_Prefix,'') Serial_Number_Prefix,
	c.LASTMODIFIEDDATE INSERTDATE
from SISWEB_OWNER_SHADOW.LNKPARTSIESNP a
inner join sis.vw_Product b on a.SNP=b.Serial_Number_Prefix 
inner join SISWEB_OWNER_SHADOW.LNKMEDIAIEPART c on 
	a.IESYSTEMCONTROLNUMBER = c.IESYSTEMCONTROLNUMBER AND c.LASTMODIFIEDDATE > @DATE 
inner join [SISWEB_OWNER].[MASMEDIA] d on d.MEDIANUMBER=c.MEDIANUMBER and d.MEDIASOURCE in ('A','C')
where a.SNPTYPE='P'