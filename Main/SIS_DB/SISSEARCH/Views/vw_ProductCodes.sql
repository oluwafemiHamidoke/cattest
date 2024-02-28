CREATE   VIEW SISSEARCH.vw_ProductCodes AS
select
	e.IE_ID, '["'+string_agg(cast(sp.Serial_Number_Prefix as varchar(max)), '","')+'"]' ProductCodes
from sis.IE e
		inner join sis.IE_Effectivity ef on ef.IE_ID=e.IE_ID
		inner join sis.SerialNumberPrefix sp on ef.SerialNumberPrefix_ID=sp.SerialNumberPrefix_ID
GROUP BY e.IE_ID