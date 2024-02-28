
CREATE   VIEW [SISSEARCH].[vw_BASEMEDIA] AS
SELECT 
	a.BASEENGLISHMEDIANUMBER as [ID], 
	a.BASEENGLISHMEDIANUMBER,
	'["' + string_escape(max(a.MEDIANUMBER), 'json')  + '"]' as  MEDIANUMBER,
	string_escape(max(a.MEDIATITLE), 'json') as  MEDIATITLE,

	max(string_escape(isnull(titleQuery.[8],''), 'json')) as  [MediaTitle_id-ID],
	max(string_escape(isnull(titleQuery.[C],''), 'json')) as  [MediaTitle_zh-CN],
	max(string_escape(isnull(titleQuery.[F],''), 'json')) as  [MediaTitle_fr-FR],
	max(string_escape(isnull(titleQuery.[G],''), 'json')) as  [MediaTitle_de-DE],
	max(string_escape(isnull(titleQuery.[L],''), 'json')) as  [MediaTitle_it-IT],
	max(string_escape(isnull(titleQuery.[P],''), 'json')) as  [MediaTitle_pt-BR],
	max(string_escape(isnull(titleQuery.[S],''), 'json')) as  [MediaTitle_es-ES],
	max(string_escape(isnull(titleQuery.[R],''), 'json')) as  [MediaTitle_ru-RU],
	max(string_escape(isnull(titleQuery.[J],''), 'json')) as  [MediaTitle_ja-JP],

	min(a.[MEDIAUPDATEDDATE]) [InsertDate], --Must be updated to insert date
	1 as [isMedia], 
	max(a.MEDIAUPDATEDDATE) as UpdatedDate,
	max(publishedDateQuery.PUBDATE) as PubDate, 
	max(a.[PIPPSPNUMBER]) PIPPSPNumber,

	'["' + max(string_escape(isnull(mediaNumberQuery.[8],''), 'json'))  + '"]' as  [mediaNumber_id-ID],
	'["' + max(string_escape(isnull(mediaNumberQuery.[C],''), 'json'))  + '"]' as  [mediaNumber_zh-CN],
	'["' + max(string_escape(isnull(mediaNumberQuery.[F],''), 'json'))  + '"]' as  [mediaNumber_fr-FR],
	'["' + max(string_escape(isnull(mediaNumberQuery.[G],''), 'json'))  + '"]' as  [mediaNumber_de-DE],
	'["' + max(string_escape(isnull(mediaNumberQuery.[L],''), 'json'))  + '"]' as  [mediaNumber_it-IT],
	'["' + max(string_escape(isnull(mediaNumberQuery.[P],''), 'json'))  + '"]' as  [mediaNumber_pt-BR],
	'["' + max(string_escape(isnull(mediaNumberQuery.[S],''), 'json'))  + '"]' as  [mediaNumber_es-ES],
	'["' + max(string_escape(isnull(mediaNumberQuery.[R],''), 'json'))  + '"]' as  [mediaNumber_ru-RU],
	'["' + max(string_escape(isnull(mediaNumberQuery.[J],''), 'json'))  + '"]' as  [mediaNumber_ja-JP],

	max(publishedDateQuery.[8]) as [pubdate_id-ID],
	max(publishedDateQuery.[C]) as [pubdate_zh-CN],
	max(publishedDateQuery.[F]) as [pubdate_fr-FR],
	max(publishedDateQuery.[G]) as [pubdate_de-DE],
	max(publishedDateQuery.[L]) as [pubdate_it-IT],
	max(publishedDateQuery.[P]) as [pubdate_pt-BR],
	max(publishedDateQuery.[S]) as [pubdate_es-ES],
	max(publishedDateQuery.[R]) as [pubdate_ru-RU],
	max(publishedDateQuery.[J]) as [pubdate_ja-JP],

	max(updateDateQuery.[8]) as [updateddate_id-ID],
	max(updateDateQuery.[C]) as [updateddate_zh-CN],
	max(updateDateQuery.[F]) as [updateddate_fr-FR],
	max(updateDateQuery.[G]) as [updateddate_de-DE],
	max(updateDateQuery.[L]) as [updateddate_it-IT],
	max(updateDateQuery.[P]) as [updateddate_pt-BR],
	max(updateDateQuery.[S]) as [updateddate_es-ES],
	max(updateDateQuery.[R]) as [updateddate_ru-RU],
	max(updateDateQuery.[J]) as [updateddate_ja-JP]

From [SISWEB_OWNER].[MASMEDIA] a
inner join [SISWEB_OWNER].[LNKMEDIASNP] b on 
	a.BASEENGLISHMEDIANUMBER=b.MEDIANUMBER and 
	b.INFOTYPEID not in (
		Select [INFOTYPEID] from SISSEARCH.REF_EXCLUDEINFOTYPE where [Search2_Status] = 1  and [Selective_Exclude] = 0
	)
--Get translated values
left outer join [SISSEARCH].[vw_MASMEDIATITLE] titleQuery on titleQuery.BASEENGLISHMEDIANUMBER = a.BASEENGLISHMEDIANUMBER
left outer join [SISSEARCH].[vw_MASMEDIANUMBER] mediaNumberQuery on mediaNumberQuery.BASEENGLISHMEDIANUMBER = a.BASEENGLISHMEDIANUMBER
--Get computed dates
left outer join [SISSEARCH].[vw_MASMEDIAPUBLISHEDDATE] publishedDateQuery on publishedDateQuery.BASEENGLISHMEDIANUMBER = a.BASEENGLISHMEDIANUMBER
left outer join [SISSEARCH].[vw_MASMEDIAUPDATEDDATE] updateDateQuery on updateDateQuery.BASEENGLISHMEDIANUMBER = a.BASEENGLISHMEDIANUMBER
Where a.LANGUAGEINDICATOR = 'E' --This is the base.  Pivot provides other languages.
and not exists(
		select 1 from SISSEARCH.REF_SELECTIVE_EXCLUDEINFOTYPE 
	where INFOTYPEID = b.INFOTYPEID and [Excluded_Values] = a.MEDIAORIGIN
	)
Group by a.BASEENGLISHMEDIANUMBER