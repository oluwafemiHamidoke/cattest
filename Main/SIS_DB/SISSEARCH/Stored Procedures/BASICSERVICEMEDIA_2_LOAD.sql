CREATE  Procedure [SISSEARCH].[BASICSERVICEMEDIA_2_LOAD] 
As
/*---------------
Date: 10-04-2017
Object Description:  Loading changed data into SISSEARCH.BASICSERVICEMEDIA_2 from base tables
Modifiy Date: 20210311 - Davide. Changed MEDIAUPDATEDDATE to LASTMODDIFIEDDATE, see: https://dev.azure.com/sis-cat-com/sis2-ui/_workitems/edit/9566/
Exec [SISSEARCH].[BASICSERVICEMEDIA_2_LOAD]
Truncate table [SISSEARCH].[BASICSERVICEMEDIA_2]
Select top 100 * From SISSEARCH.LOG Order By LogID desc
---------------*/


Begin

BEGIN TRY

SET NOCOUNT ON

Declare @LastInsertDate Datetime

Declare @SPStartTime DATETIME,
		@StepStartTime DATETIME,
		@ProcName VARCHAR(200),
		@SPStartLogID BIGINT,
		@StepLogID BIGINT,
		@RowCount BIGINT,
		@LAPSETIME BIGINT

SET @SPStartTime= GETDATE()
SET @ProcName= OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)  

--Identify Deleted Records From Source

EXEC @SPStartLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


If Object_ID('Tempdb..#DeletedRecords') is not null
  Begin 
     Drop table #DeletedRecords
  End
Select
	[BaseEngMediaNumber]
into #DeletedRecords
from  [SISSEARCH].[BASICSERVICEMEDIA_2]
Except 
Select
	a.[BASEENGLISHMEDIANUMBER]
from [SISWEB_OWNER].[MASMEDIA] a
inner join [SISWEB_OWNER].[LNKMEDIASNP] b on  a.[BASEENGLISHMEDIANUMBER]=b.MEDIANUMBER  and b.INFOTYPEID not in (Select [INFOTYPEID] from SISSEARCH.REF_EXCLUDEINFOTYPE where [Search2_Status] = 1 and [Selective_Exclude] = 0)
--inner join [SISWEB_OWNER].[LNKMEDIAINFOTYPE] d on a.[BASEENGLISHMEDIANUMBER] = d.MEDIANUMBER and d.INFOTYPEID not in(16,17,18,19,20,21,22,33,34,58) 
where not exists(
	select 1 from SISSEARCH.REF_SELECTIVE_EXCLUDEINFOTYPE 
	where  INFOTYPEID = b.INFOTYPEID and [Excluded_Values] = a.MEDIAORIGIN
)

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Records Detected',@DATAVALUE = @RowCount, @LOGID = @StepLogID

-- Delete Idenified Deleted Records in Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [SISSEARCH].[BASICSERVICEMEDIA_2] 
From [SISSEARCH].[BASICSERVICEMEDIA_2] a
inner join #DeletedRecords d on a.[BaseEngMediaNumber] = d.[BaseEngMediaNumber]

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Records from Target [SISSEARCH].[BASICSERVICEMEDIA_2]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	
Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [SISSEARCH].[BASICSERVICEMEDIA_2]
--Print cast(getdate() as varchar(50)) + ' - Latest Insert Date in Target: ' + cast(@LastInsertDate as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
Declare @Logmessage as varchar(50) = 'Latest Insert Date in Target '+cast (@LastInsertDate as varchar(25))
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = @Logmessage , @LOGID = @StepLogID


--Identify Inserted records from Source
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

 If Object_ID('Tempdb..#InsertRecords') is not null
Begin 
 Drop table #InsertRecords
End
	Select Distinct
		a.[BASEENGLISHMEDIANUMBER]
	into #InsertRecords
	from [SISWEB_OWNER].[MASMEDIA] a
	inner join [SISWEB_OWNER].[LNKMEDIASNP] b on  a.[BASEENGLISHMEDIANUMBER]=b.MEDIANUMBER  and b.INFOTYPEID not in (Select [INFOTYPEID] from SISSEARCH.REF_EXCLUDEINFOTYPE where [Search2_Status] = 1 and [Selective_Exclude] = 0)
	where a.LASTMODIFIEDDATE > @LastInsertDate --Update the reference date.  Should be the date when the records was inserted.
	and not exists(
	select 1 from SISSEARCH.REF_SELECTIVE_EXCLUDEINFOTYPE 
	where INFOTYPEID = b.INFOTYPEID and [Excluded_Values] = a.MEDIAORIGIN
)
SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Detected #InsertRecords',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_iesystemcontrolnumber 
    ON #InsertRecords([BASEENGLISHMEDIANUMBER])

--Delete Inserted records from Target 	
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [SISSEARCH].[BASICSERVICEMEDIA_2] 
From [SISSEARCH].[BASICSERVICEMEDIA_2] a
inner join #InsertRecords d on a.[BaseEngMediaNumber] = d.[BASEENGLISHMEDIANUMBER]

SET @RowCount= @@RowCount   
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Inserted Records from Target [SISSEARCH].[BASICSERVICEMEDIA_2]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

insert into [SISSEARCH].[BASICSERVICEMEDIA_2]
       (
       [ID]
      --,[BeginRange]
      --,[EndRange]
	  ,[BaseEngMediaNumber]
      ,[MediaNumber]
      ,[MediaTitle_en-US]
	  ,[MediaTitle_in-ID]
	  ,[MediaTitle_zh-CN]
	  ,[MediaTitle_fr-FR]
	  ,[MediaTitle_de-DE]
	  ,[MediaTitle_it-IT]
	  ,[MediaTitle_pt-BR]
      ,[MediaTitle_es-ES]
	  ,[MediaTitle_ru-RU]
	  ,[MediaTitle_ja-JP]
      ,[InsertDate]
	  ,[isMedia]
	  ,[UpdatedDate]
	  ,[PubDate]
	  ,[PIPPSPNumber]

	  ,[MediaNumber_id-ID]
	  ,[MediaNumber_zh-CN]
	  ,[MediaNumber_fr-FR]
	  ,[MediaNumber_de-DE]
	  ,[MediaNumber_it-IT]
	  ,[MediaNumber_pt-BR]
      ,[MediaNumber_es-ES]
	  ,[MediaNumber_ru-RU]
	  ,[MediaNumber_ja-JP]

	  ,[PubDate_id-ID]
	  ,[PubDate_zh-CN]
	  ,[PubDate_fr-FR]
	  ,[PubDate_de-DE]
	  ,[PubDate_it-IT]
	  ,[PubDate_pt-BR]
      ,[PubDate_es-ES]
	  ,[PubDate_ru-RU]
	  ,[PubDate_ja-JP]

	  ,[UpdatedDate_id-ID]
	  ,[UpdatedDate_zh-CN]
	  ,[UpdatedDate_fr-FR]
	  ,[UpdatedDate_de-DE]
	  ,[UpdatedDate_it-IT]
	  ,[UpdatedDate_pt-BR]
      ,[UpdatedDate_es-ES]
	  ,[UpdatedDate_ru-RU]
	  ,[UpdatedDate_ja-JP]
	  ,[mediaOrigin]
	  )
select a.BASEENGLISHMEDIANUMBER as [ID], 
	--cast(b.BEGINNINGRANGE as varchar(10)) [BeginRange],
	--cast(b.ENDRANGE as varchar(10)) [EndRange],
	a.BASEENGLISHMEDIANUMBER,
		'["' + replace( --escape /
			replace( --escape "
				replace( --replace carriage return (ascii 13)
					replace( --replace form feed (ascii 12) 
						replace( --replace vertical tab (ascii 11)
							replace( --replace line feed (ascii 10)
								replace( --replace horizontal tab (ascii 09)
									replace( --replace backspace (ascii 08)
										replace( --escape \
											max(a.MEDIANUMBER) --This is the language specific version of the media number
										,'\', '\\')
									,char(8), ' ')
								,char(9), ' ')
							,char(10), ' ')
						,char(11), ' ')
					,char(12), ' ')
				,char(13), ' ')
				,'"', '\"')
			,'/', '\/')  + '"]' as  MEDIANUMBER,
		replace( --escape /
			replace( --escape "
				replace( --replace carriage return (ascii 13)
					replace( --replace form feed (ascii 12) 
						replace( --replace vertical tab (ascii 11)
							replace( --replace line feed (ascii 10)
								replace( --replace horizontal tab (ascii 09)
									replace( --replace backspace (ascii 08)
										replace( --escape \
											max(a.MEDIATITLE) --Limited to English temporarily per Lu
										,'\', '\\')
									,char(8), ' ')
								,char(9), ' ')
							,char(10), ' ')
						,char(11), ' ')
					,char(12), ' ')
				,char(13), ' ')
				,'"', '\"')
			,'/', '\/') as  MEDIATITLE,

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[MediaTitle_id-ID],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaTitle_id-ID],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[MediaTitle_zh-CN],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaTitle_zh-CN],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[MediaTitle_fr-FR],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaTitle_fr-FR],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[MediaTitle_de-DE],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaTitle_de-DE],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[MediaTitle_it-IT],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaTitle_it-IT],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[MediaTitle_pt-BR],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaTitle_pt-BR],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[MediaTitle_es-ES],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaTitle_es-ES],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[MediaTitle_ru-RU],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaTitle_ru-RU],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[MediaTitle_ja-JP],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaTitle_ja-JP],

		min(a.LASTMODIFIEDDATE) [InsertDate], --Must be updated to insert date
		1 as [isMedia], 
		max(a.MEDIAUPDATEDDATE) as UpdatedDate,
		max(tr3.PUBDATE) as PubDate, 
		max(a.[PIPPSPNUMBER]) PIPPSPNumber,

'["' + 
max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr2.[mediaNumber_id-ID],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) + '"]'as [mediaNumber_id-ID],

'["' + 
max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr2.[mediaNumber_zh-CN],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) + '"]' as [mediaNumber_zh-CN],

'["' + 
max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr2.[mediaNumber_fr-FR],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) + '"]' as [mediaNumber_fr-FR],

'["' + 
max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr2.[mediaNumber_de-DE],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) + '"]' as [mediaNumber_de-DE],

'["' + 
max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr2.[mediaNumber_it-IT],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) + '"]' as [mediaNumber_it-IT],

'["' + 
max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr2.[mediaNumber_pt-BR],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) + '"]' as [mediaNumber_pt-BR],

'["' + 
max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr2.[mediaNumber_es-ES],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) + '"]' as [mediaNumber_es-ES],

'["' + 
max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr2.[mediaNumber_ru-RU],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) + '"]' as [mediaNumber_ru-RU],

'["' + 
max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr2.[mediaNumber_ja-JP],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) + '"]' as [mediaNumber_ja-JP],

max(tr3.[pubdate_id-ID]) as [pubdate_id-ID],
max(tr3.[pubdate_zh-CN]) as [pubdate_zh-CN],
max(tr3.[pubdate_fr-FR]) as [pubdate_fr-FR],
max(tr3.[pubdate_de-DE]) as [pubdate_de-DE],
max(tr3.[pubdate_it-IT]) as [pubdate_it-IT],
max(tr3.[pubdate_pt-BR]) as [pubdate_pt-BR],
max(tr3.[pubdate_es-ES]) as [pubdate_es-ES],
max(tr3.[pubdate_ru-RU]) as [pubdate_ru-RU],
max(tr3.[pubdate_ja-JP]) as [pubdate_ja-JP],

max(tr4.[updateddate_id-ID]) as [updateddate_id-ID],
max(tr4.[updateddate_zh-CN]) as [updateddate_zh-CN],
max(tr4.[updateddate_fr-FR]) as [updateddate_fr-FR],
max(tr4.[updateddate_de-DE]) as [updateddate_de-DE],
max(tr4.[updateddate_it-IT]) as [updateddate_it-IT],
max(tr4.[updateddate_pt-BR]) as [updateddate_pt-BR],
max(tr4.[updateddate_es-ES]) as [updateddate_es-ES],
max(tr4.[updateddate_ru-RU]) as [updateddate_ru-RU],
max(tr4.[updateddate_ja-JP]) as [updateddate_ja-JP],

max(a.MEDIAORIGIN)

	From [SISWEB_OWNER].[MASMEDIA] a
	inner join [SISWEB_OWNER].[LNKMEDIASNP] b 
		on  a.BASEENGLISHMEDIANUMBER=b.MEDIANUMBER  
		and b.INFOTYPEID not in (Select [INFOTYPEID] from SISSEARCH.REF_EXCLUDEINFOTYPE where [Search2_Status] = 1 and [Selective_Exclude] = 0)
	--inner join [SISWEB_OWNER].[MASLANGUAGE] l on l.LANGUAGEINDICATOR = a.LANGUAGEINDICATOR
	inner join #InsertRecords i on i.BASEENGLISHMEDIANUMBER = a.BASEENGLISHMEDIANUMBER --limit to updated records
--Get translated values
left outer join
(
Select 
BASEENGLISHMEDIANUMBER, 
[8] [MediaTitle_id-ID], 
[C] [MediaTitle_zh-CN], 
[F] [MediaTitle_fr-FR], 
[G] [MediaTitle_de-DE], 
[L] [MediaTitle_it-IT], 
[P] [MediaTitle_pt-BR], 
[S] [MediaTitle_es-ES], 
[R] [MediaTitle_ru-RU], 
[J] [MediaTitle_ja-JP]
From 
(
SELECT BASEENGLISHMEDIANUMBER --Candidate key composite
      ,[LANGUAGEINDICATOR] --Candidate key composite
      ,MEDIATITLE
FROM [SISWEB_OWNER].[MASMEDIA]
) p
Pivot
(
Max(MEDIATITLE) 
For [LANGUAGEINDICATOR] in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
) pvt
) tr on tr.BASEENGLISHMEDIANUMBER = a.BASEENGLISHMEDIANUMBER

--Get translated values
left outer join
(
Select 
BASEENGLISHMEDIANUMBER, 
[8] [mediaNumber_id-ID], 
[C] [mediaNumber_zh-CN], 
[F] [mediaNumber_fr-FR], 
[G] [mediaNumber_de-DE], 
[L] [mediaNumber_it-IT], 
[P] [mediaNumber_pt-BR], 
[S] [mediaNumber_es-ES], 
[R] [mediaNumber_ru-RU], 
[J] [mediaNumber_ja-JP]
From 
(
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
) tr2 on tr2.BASEENGLISHMEDIANUMBER = a.BASEENGLISHMEDIANUMBER

--Get translated values
left outer join
(
	SELECT 
		pvt.BASEENGLISHMEDIANUMBER, 
		pvt.E PUBDATE, -- if PUBDATE is incorrect, change it to pvt.E
		pvt.[8] [pubdate_id-ID],
		pvt.[C] [pubdate_zh-CN],
		pvt.[F] [pubdate_fr-FR],
		pvt.[G] [pubdate_de-DE],
		pvt.[L] [pubdate_it-IT],
		pvt.[P] [pubdate_pt-BR],
		pvt.[S] [pubdate_es-ES],
		pvt.[R] [pubdate_ru-RU],
		pvt.[J] [pubdate_ja-JP]
	FROM 
	(
		SELECT BASEENGLISHMEDIANUMBER
			  ,[LANGUAGEINDICATOR]
			  ,PUBLISHEDDATE
		FROM [SISWEB_OWNER].[MASMEDIA]
	) p
	PIVOT(MAX(PUBLISHEDDATE) FOR [LANGUAGEINDICATOR] IN ([E], [8], [C], [F], [G], [L], [P], [S], [R], [J])) pvt	
) tr3 on tr3.BASEENGLISHMEDIANUMBER = a.BASEENGLISHMEDIANUMBER

--Get translated values
left outer join
(
Select 
BASEENGLISHMEDIANUMBER, 
[8] [updateddate_id-ID], 
[C] [updateddate_zh-CN], 
[F] [updateddate_fr-FR], 
[G] [updateddate_de-DE], 
[L] [updateddate_it-IT], 
[P] [updateddate_pt-BR], 
[S] [updateddate_es-ES], 
[R] [updateddate_ru-RU], 
[J] [updateddate_ja-JP]
From 
(
SELECT BASEENGLISHMEDIANUMBER --Candidate key composite
      ,[LANGUAGEINDICATOR] --Candidate key composite
      ,LASTMODIFIEDDATE
FROM [SISWEB_OWNER].[MASMEDIA]
) p
Pivot
(
Max(LASTMODIFIEDDATE) 
For [LANGUAGEINDICATOR] in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
) pvt
) tr4 on tr4.BASEENGLISHMEDIANUMBER = a.BASEENGLISHMEDIANUMBER

	Where a.LANGUAGEINDICATOR = 'E' --This is the base.  Pivot provides other languages.
	and not exists(
		select 1 from SISSEARCH.REF_SELECTIVE_EXCLUDEINFOTYPE 
	where INFOTYPEID = b.INFOTYPEID and [Excluded_Values] = a.MEDIAORIGIN
	)
	Group by 
	a.BASEENGLISHMEDIANUMBER
	--cast(b.BEGINNINGRANGE as varchar(10)),
	--cast(b.ENDRANGE as varchar(10))

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Target [SISSEARCH].[BASICSERVICEMEDIA_2]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LOGID = @SPStartLogID,@DATAVALUE = @RowCount

DELETE FROM SISSEARCH.LOG WHERE DATEDIFF(DD, LogDateTime, GetDate())>30 and NameofSproc= @ProcName

END TRY

BEGIN CATCH 
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT= ERROR_LINE()

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC SISSEARCH.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error
END CATCH

End
