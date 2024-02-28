

CREATE   VIEW [SISSEARCH].[vw_MASMEDIANUMBER] AS
Select * FROM (
	SELECT BASEENGLISHMEDIANUMBER --Candidate key composite
			,[LANGUAGEINDICATOR] --Candidate key composite
			,MEDIANUMBER
	FROM [SISWEB_OWNER].[MASMEDIA]
) p
Pivot
(
	Max(MEDIANUMBER) 
	For [LANGUAGEINDICATOR] in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
) pvt