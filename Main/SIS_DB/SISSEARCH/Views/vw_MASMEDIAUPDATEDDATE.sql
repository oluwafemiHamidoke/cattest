

CREATE   VIEW [SISSEARCH].[vw_MASMEDIAUPDATEDDATE] AS
Select * From (
	SELECT BASEENGLISHMEDIANUMBER --Candidate key composite
		  ,[LANGUAGEINDICATOR] --Candidate key composite
		  ,MEDIAUPDATEDDATE
	FROM [SISWEB_OWNER].[MASMEDIA]
) p
Pivot
(
Max(MEDIAUPDATEDDATE) 
For [LANGUAGEINDICATOR] in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
) pvt