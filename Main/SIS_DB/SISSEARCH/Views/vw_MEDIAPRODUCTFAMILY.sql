﻿
--
-- Media Product Family View
--

CREATE   VIEW [SISSEARCH].[vw_MEDIAPRODUCTFAMILY] AS
SELECT
	MEDIANUMBER + '_' + cast(BEGINNINGRANGE as varchar(10)) + '_' + cast(ENDRANGE as varchar(10)) as [ID],
	MEDIANUMBER as BaseEnglishMediaNumber,
	'["' + string_agg(cast(SNP as varchar(max)), '","') + '"]' ProductCode
FROM (
	SELECT DISTINCT MEDIANUMBER, BEGINNINGRANGE, ENDRANGE, SNP
	FROM [SISWEB_OWNER].[LNKMEDIASNP] new
	WHERE
		TYPEINDICATOR = 'P'
		AND INFOTYPEID NOT IN (
			SELECT [INFOTYPEID] FROM SISSEARCH.REF_EXCLUDEINFOTYPE WHERE Search2_Status = 1
		)
) AS x
GROUP BY MEDIANUMBER, BEGINNINGRANGE, ENDRANGE