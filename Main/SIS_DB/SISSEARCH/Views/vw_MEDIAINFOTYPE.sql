
--
-- Media InfoType View
--

CREATE   VIEW [SISSEARCH].[vw_MEDIAINFOTYPE] AS
SELECT
	ID, BASEENGLISHMEDIANUMBER, '["' + INFOTYPEID + '"]' as InformationType
FROM (
	select
		a.BASEENGLISHMEDIANUMBER + '_' + cast(b.BEGINNINGRANGE as varchar(10)) + '_' + cast(b.ENDRANGE as varchar(10)) as [ID],
		a.BASEENGLISHMEDIANUMBER,
		string_agg(cast(b.INFOTYPEID as varchar(max)) , '","') AS INFOTYPEID,
		b.BEGINNINGRANGE,
		b.ENDRANGE
	From [SISWEB_OWNER].[MASMEDIA] a
	inner join [SISWEB_OWNER].[LNKMEDIASNP] b on 
		a.[BASEENGLISHMEDIANUMBER]=b.MEDIANUMBER and b.INFOTYPEID not in (
			SELECT [InfoTypeID] FROM [SISSEARCH].[REF_EXCLUDEINFOTYPE] where [Media] = 1 and [Selective_Exclude] = 0
		) 
	Where a.LANGUAGEINDICATOR = 'E' --Limit to english
	and not exists(
		select 1 from SISSEARCH.REF_SELECTIVE_EXCLUDEINFOTYPE 
	where INFOTYPEID = b.INFOTYPEID and [Excluded_Values] = a.MEDIAORIGIN
	)
	GROUP BY a.BASEENGLISHMEDIANUMBER,
		b.BEGINNINGRANGE,
		b.ENDRANGE

) as m