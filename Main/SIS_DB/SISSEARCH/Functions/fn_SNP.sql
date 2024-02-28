
CREATE   FUNCTION SISSEARCH.fn_SNP(@DATE DATETIME)
	RETURNS TABLE
AS
RETURN SELECT
	IESYSTEMCONTROLNUMBER as ID,
	IESYSTEMCONTROLNUMBER,
	'[' + string_agg(r.SerialNumbers, ',') + ']' as SerialNumbers,
	MAX(InsertDate) InsertDate
FROM (
	SELECT 
		IESYSTEMCONTROLNUMBER,
		(
			SELECT
				JSON_QUERY('["'+string_agg(cast(SNP as varchar(max)), '","')+'"]') serialNumberPrefixes,
				cast(BEGINNINGRANGE as int) beginRange,
				cast(ENDRANGE as int) endRange
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		) SerialNumbers,
		MAX(InsertDate) InsertDate
	FROM SISSEARCH.fn_SNP_ORIGIN('')
	GROUP BY IESYSTEMCONTROLNUMBER, BEGINNINGRANGE, ENDRANGE
) r
GROUP BY IESYSTEMCONTROLNUMBER