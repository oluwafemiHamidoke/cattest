CREATE VIEW SISSEARCH.[vw_MediaSerialNumber] AS
--
--
-- Serial Numbers
--
select 
	x.Media_ID,
	'[' + string_agg(x.SerialNumbers, ',') + ']' as SerialNumbers
from (
	select
		m.Media_ID,
		(
			SELECT 
				JSON_QUERY('["'+string_agg(cast(sp.Serial_Number_Prefix as varchar(max)), '","')+'"]') serialNumberPrefixes,
				sr.Start_Serial_Number beginRange,
				sr.End_Serial_Number endRange
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		) SerialNumbers
		--sp.Serial_Number_Prefix,
		--sr.Start_Serial_Number,
		--sr.End_Serial_Number
	from sis.Media m
		inner join sis.Media_Effectivity e on e.Media_ID=m.Media_ID
		inner join sis.SerialNumberPrefix sp on e.SerialNumberPrefix_ID=sp.SerialNumberPrefix_ID
		inner join sis.SerialNumberRange sr on e.SerialNumberRange_ID=sr.SerialNumberRange_ID
	--WHERE m.Media_Number IN ('AEXQ1229','GEBJ0066')
	GROUP BY
		m.Media_ID,
		sr.Start_Serial_Number,
		sr.End_Serial_Number
) x
GROUP BY x.Media_ID
GO