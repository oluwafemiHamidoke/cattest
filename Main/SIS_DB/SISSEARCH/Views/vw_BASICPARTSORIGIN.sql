
CREATE   VIEW [SISSEARCH].[vw_BASICPARTSORIGIN]
AS SELECT DISTINCT
	row_number() over (Partition by cast(a.IESYSTEMCONTROLNUMBER as VARCHAR) order by isnull(d.DATEUPDATED, '1900-01-01') desc, b.LASTMODIFIEDDATE desc) RowRank,
	cast(a.IESYSTEMCONTROLNUMBER as VARCHAR) As ID,
	a.IESYSTEMCONTROLNUMBER as Iesystemcontrolnumber, 
	'[''5'']' As InformationType  , --InformationType not in source. pbf 20180313 add brackets and quote.
	coalesce('["' + string_escape(translate(b.MEDIANUMBER,
		char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') + '"]', '') as medianumber, 
	cast(isnull(d.DATEUPDATED, '1900-01-01') as datetime2) as ieupdatedate, 
	string_escape(translate(isnull(b.IEPARTNUMBER, '')+':'+isnull(b.IEPARTNAME, ''), 
		char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') as iepart,
	coalesce('["' + string_escape(translate(b.MEDIANUMBER,
		char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json') + '"]', '') as PARTSMANUALMEDIANUMBER,
	Replace(
			Replace(
				Replace(
					Replace(
						Replace(
							Replace(
								Replace(
									Replace(
										Replace(
											Replace(
												Replace(
													Replace(
														Replace(
															Replace(
																b.IECAPTION 
															,'<I>',' ')
														,'</I>',' ')
													,'<BR>',' ')
												,'<TABLE BORDER=0>' ,' ')
											,'<TR>',' ')
										,'<TD COLSPAN=3 ALIGN=CENTER>',' ')
									,'</TABLE>',' ')
								,'<B>',' ')
							,'</B>',' ')
						,'<TD>',' ')
					,'</TD>',' ')
				,'<TR>',' ')
			,'</TR>',' ')
		,'@@@@@',' ') As IECAPTION
	,cast(b.LASTMODIFIEDDATE as datetime) InsertDate
	,cast(d.IEPUBDATE as datetime) as [PubDate]
	,case when len(trim(b.IECONTROLNUMBER)) = 0 then null else
		 	coalesce('["'+string_escape(translate(b.IECONTROLNUMBER,
				char(8)+char(9)+char(10)+char(11)+char(12)+char(13), '      '),'json')+'"]', '') 
		end as ControlNumber, 

	coalesce(tr.[8], '') as [iePartName_id-ID],
	coalesce(tr.[C], '') as [iePartName_zh-CN],
	coalesce(tr.[F], '') as [iePartName_fr-FR],
	coalesce(tr.[G], '') as [iePartName_de-DE],
	coalesce(tr.[L], '') as [iePartName_it-IT],
	coalesce(tr.[P], '') as [iePartName_pt-BR],
	coalesce(tr.[S], '') as [iePartName_es-ES],
	coalesce(tr.[R], '') as [iePartName_ru-RU],
	coalesce(tr.[J], '') as [iePartName_ja-JP]
from [SISWEB_OWNER_SHADOW].LNKPARTSIESNP a	--10M
inner join [SISWEB_OWNER_SHADOW].LNKMEDIAIEPART b  --3M
	on  a.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER
left outer join [SISWEB_OWNER].LNKIEDATE d --4M
	on a.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER and d.LANGUAGEINDICATOR='E'
inner join [SISWEB_OWNER].[MASMEDIA] e   --90K
		on e.MEDIANUMBER=b.MEDIANUMBER

--Get translated values
left outer join [SISSEARCH].[vw_TRANSLATEDPARTS] tr on tr.PARTNAME = b.IEPARTNAME
where 1=1
	and e.MEDIASOURCE in ('A' , 'C')
	and a.SNPTYPE = 'P'