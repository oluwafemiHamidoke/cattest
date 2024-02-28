

CREATE   VIEW [SISSEARCH].[vw_MASMEDIAPUBLISHEDDATE] AS
SELECT 
	pvt.BASEENGLISHMEDIANUMBER, 
	q.E PUBDATE, -- if PUBDATE is incorrect, change it to pvt.E
	IIF(pvt.[8] IS NULL, NULL, q.[8]) [8],
	IIF(pvt.[C] IS NULL, NULL, q.[C]) [C],
	IIF(pvt.[F] IS NULL, NULL, q.[F]) [F],
	IIF(pvt.[G] IS NULL, NULL, q.[G]) [G],
	IIF(pvt.[L] IS NULL, NULL, q.[L]) [L],
	IIF(pvt.[P] IS NULL, NULL, q.[P]) [P],
	IIF(pvt.[S] IS NULL, NULL, q.[S]) [S],
	IIF(pvt.[R] IS NULL, NULL, q.[R]) [R],
	IIF(pvt.[J] IS NULL, NULL, q.[J]) [J]
FROM 
(
	SELECT BASEENGLISHMEDIANUMBER
			,[LANGUAGEINDICATOR]
			,PUBLISHEDDATE
	FROM [SISWEB_OWNER].[MASMEDIA]
) p
PIVOT(MAX(PUBLISHEDDATE) FOR [LANGUAGEINDICATOR] IN ([E], [8], [C], [F], [G], [L], [P], [S], [R], [J])) pvt
-- !5744 - **outer** join PIVOTTED MASSMEDIA with PIVOTTED LNKMEDIAIE&LNKIEDATE in order to 
--         obtain a full recordset
--FULL OUTER JOIN (
INNER JOIN (
	--
	-- !5744 - 4. Relate IESYSTEMCONTROLNUMBER with MEDIANUMBER->BASEENGLISHMEDIANUMBER
	--
	SELECT MEDIANUMBER AS BASEENGLISHMEDIANUMBER, 
		MAX(E) AS E, 
		MAX([8]) AS [8],
		MAX(C) AS C,
		MAX(F) AS F,
		MAX(G) AS G, 
		MAX(L) AS L, 
		MAX(P) AS P,
		MAX(S) AS S, 
		MAX(R) AS R,
		MAX(J) AS J
	FROM (
		--
		-- !5744 - 3. When IE has no language, detault to E date 
		--
		SELECT 
			IESYSTEMCONTROLNUMBER,
			E,
			ISNULL([8], E) [8],
			ISNULL([C], E) [C],
			ISNULL([F], E) [F],
			ISNULL([G], E) [G],
			ISNULL([L], E) [L],
			ISNULL([P], E) [P],
			ISNULL([S], E) [S],
			ISNULL([R], E) [R],
			ISNULL([J], E) [J]
		FROM (
			--
			-- !5744 - 1. Get dates for each language in the language set 
			--
			SELECT IESYSTEMCONTROLNUMBER, LANGUAGEINDICATOR, DATEUPDATED AS DATE
				FROM [SISWEB_OWNER].[LNKIEDATE]
				WHERE LANGUAGEINDICATOR IN ('E', '8', 'C', 'F', 'G', 'L', 'P', 'S', 'R', 'J')
		) AS src
		--
		-- !5744 - 2. Pivot the table
		--
		PIVOT (MAX([DATE]) FOR LANGUAGEINDICATOR in ([E], [8], [C], [F], [G], [L], [P], [S], [R], [J])) AS s 
	) AS p
	INNER JOIN [SISWEB_OWNER].[LNKMEDIAIE] b ON b.IESYSTEMCONTROLNUMBER = p.IESYSTEMCONTROLNUMBER
	GROUP BY MEDIANUMBER
) q ON q.BASEENGLISHMEDIANUMBER = pvt.BASEENGLISHMEDIANUMBER