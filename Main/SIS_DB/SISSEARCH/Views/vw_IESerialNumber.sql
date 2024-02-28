CREATE   VIEW SISSEARCH.vw_IESerialNumber AS
--
--
-- Serial Numbers
--
select 
	x.IE_ID,
	'[' + string_agg(x.SerialNumbers, ',') + ']' as SerialNumbers
from (
	select
		IE_ID,
		(
			SELECT 
				JSON_QUERY('["'+string_agg(cast(Serial_Number_Prefix as varchar(max)), '","')+'"]') serialNumberPrefixes,
				Start_Serial_Number beginRange,
				End_Serial_Number endRange
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		) SerialNumbers
	from ( 
		select DISTINCT m.IE_ID, IESystemControlNumber,Serial_Number_Prefix, Start_Serial_Number, End_Serial_Number 
		from sis.IE m
			inner join sis.IE_Effectivity e on e.IE_ID=m.IE_ID
			inner join sis.SerialNumberPrefix sp on e.SerialNumberPrefix_ID=sp.SerialNumberPrefix_ID
			inner join sis.SerialNumberRange sr on e.SerialNumberRange_ID=sr.SerialNumberRange_ID
	) y
	GROUP BY
		IE_ID,
		Start_Serial_Number,
		End_Serial_Number
) x
GROUP BY x.IE_ID
GO