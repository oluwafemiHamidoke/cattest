-- SELECT * FROM SISSEARCH.MEDIAPRODUCTHIERARCHY_2


--
-- Media SNP View
--

CREATE   VIEW [SISSEARCH].[vw_MEDIASNP] AS
-- 
-- 3. By MEDIANUMBER, build a JSON array with SerialNumber JSON objects
--
SELECT 
	MEDIANUMBER as ID,
	MEDIANUMBER as BaseEnglishMediaNumber,
	'[' + string_agg(SerialNumbers, '","') + ']' SerialNumbers
FROM (
	-- 
	-- 2. By MEDIANUMBER and unique (beginRange and endRange), get MEDIANUMBER, serialNumbers JSON object
	--
	SELECT
		a.[BASEENGLISHMEDIANUMBER] as MEDIANUMBER,
		(
			-- 
			-- 1. Compute SerialNumbers by returning a JSON object like:
			--			{"serialNumberPrefixes":["XYZ", "XYZ"], "beginRange":1, "endRange":9999}
			--		Where:
			--		- serialNumberPrefixes - JSON Array resulting from SNP aggregation. See GROUP BY section below
			--		- beginRange
			--		- endRange
			-- 
			SELECT DISTINCT
				JSON_QUERY('["'+string_agg(cast(SNP as varchar(max)), '","')+'"]') serialNumberPrefixes,
				BEGINNINGRANGE beginRange,
				ENDRANGE endRange
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		) SerialNumbers
	FROM  [SISWEB_OWNER].[MASMEDIA] a
	inner join [SISWEB_OWNER].[LNKMEDIASNP] b on a.[BASEENGLISHMEDIANUMBER]=b.MEDIANUMBER and b.INFOTYPEID not in (
		Select [INFOTYPEID] from SISSEARCH.REF_EXCLUDEINFOTYPE where Search2_Status = 1 and [Selective_Exclude] = 0
	)
	Where a.LANGUAGEINDICATOR = 'E' --Limit to english
		and b.TYPEINDICATOR = 'S' --SNP
		and not exists(
		select 1 from SISSEARCH.REF_SELECTIVE_EXCLUDEINFOTYPE 
	where INFOTYPEID = b.INFOTYPEID and [Excluded_Values] = a.MEDIAORIGIN
	)
	--
	-- Grouping by MEDIANUMBER, BEGINNINGRANGE and ENDRANGE, aggregates automatically with
	-- unique SNP values.
	--
	GROUP BY a.[BASEENGLISHMEDIANUMBER], BEGINNINGRANGE, ENDRANGE
) AS SNPsByMediaNumberAndRanges
GROUP BY MEDIANUMBER