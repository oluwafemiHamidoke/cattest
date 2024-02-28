CREATE  Procedure [SISSEARCH].[BASICSERVICEIE_2_LOAD] 
As
/*---------------
Date: 10-04-2017
Object Description:  Loading changed data into SISSEARCH.BASICSERVICEIE_2 from base tables
Modifiy Date: 20210310 - Davide. Changed DATEUPDATED to LASTMODDIFIEDDATE, see: https://dev.azure.com/sis-cat-com/sis2-ui/_workitems/edit/9566/
Exec [SISSEARCH].[BASICSERVICEIE_2_LOAD]
Truncate table [SISSEARCH].[BASICSERVICEIE_2]
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

EXEC @SPStartLogID = SISSEARCH.WriteLog @TIME = @SPStartTime, @NAMEOFSPROC = @ProcName;

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


If Object_ID('Tempdb..#DeletedRecords') is not null
  Begin 
     Drop table #DeletedRecords
  End
Select
	[IESystemControlNumber]
into #DeletedRecords
from  [SISSEARCH].[BASICSERVICEIE_2]
Except 
Select
	a.IESYSTEMCONTROLNUMBER
From [SISWEB_OWNER].[LNKIESNP] a
inner join [SISWEB_OWNER].[LNKIEINFOTYPE] b on 
	a.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER and
	b.INFOTYPEID not in (Select [INFOTYPEID] from SISSEARCH.REF_EXCLUDEINFOTYPE) 		
inner join [SISWEB_OWNER].[LNKIETITLE] d on 
	a.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER and
	d.IELANGUAGEINDICATOR = 'E' and
	(d.GROUPTITLEINDICATOR='N' OR d.GROUPTITLEINDICATOR is NULL)

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records Detected';

-- Delete Idenified Deleted Records in Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [SISSEARCH].[BASICSERVICEIE_2] 
From [SISSEARCH].[BASICSERVICEIE_2] a
inner join #DeletedRecords d on a.[IESystemControlNumber] = d.[IESystemControlNumber]

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Records from Target [SISSEARCH].[BASICSERVICEIE_2]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	
Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [SISSEARCH].[BASICSERVICEIE_2]
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
	Select
	a.IESYSTEMCONTROLNUMBER
	into #InsertRecords
	From [SISWEB_OWNER].[LNKIESNP] a
	inner join [SISWEB_OWNER].[LNKIEINFOTYPE] b on 
		a.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER and
		b.INFOTYPEID not in (Select [INFOTYPEID] from SISSEARCH.REF_EXCLUDEINFOTYPE) 		
	left outer join [SISWEB_OWNER].[LNKIEDATE] e on 
		a.IESYSTEMCONTROLNUMBER = e.IESYSTEMCONTROLNUMBER and
		e.LANGUAGEINDICATOR = 'E'
	inner join [SISWEB_OWNER].[LNKIETITLE] d on 
		a.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER and
		d.IELANGUAGEINDICATOR = 'E' and
		(d.GROUPTITLEINDICATOR='N' OR d.GROUPTITLEINDICATOR is NULL)
	where isnull(e.LASTMODIFIEDDATE, getdate()) > @LastInsertDate
	group by a.IESYSTEMCONTROLNUMBER
	--Should be the date when the records was inserted.
	--if no insert date is found, then reprocess.

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Detected #InsertRecords',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_iesystemcontrolnumber 
    ON #InsertRecords([IESYSTEMCONTROLNUMBER])

--Delete Inserted records from Target 	
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [SISSEARCH].[BASICSERVICEIE_2] 
From [SISSEARCH].[BASICSERVICEIE_2] a
inner join #InsertRecords d on a.IESystemControlNumber = d.IESYSTEMCONTROLNUMBER

SET @RowCount= @@RowCount   
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Inserted Records from Target [SISSEARCH].[BASICSERVICEIE_2]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

--insert into [SISSEARCH].[BASICSERVICEIE_2]
--    (
--    [ID]
--    ,[BeginRange]
--    ,[EndRange]
--    ,[IESystemControlNumber]
--    ,[IETitle]
--    ,[isMedia]
--	,[InfoTypeID]
--	,[InfoType]
--    ,[DateUpdated]
--    ,[InsertDate]
--	,[PubDate]
--	)

select a.IESYSTEMCONTROLNUMBER as [ID], 
	--cast(a.BEGINNINGRANGE as varchar(10)) [BeginRange],
	--cast(a.ENDRANGE as varchar(10)) [EndRange],
	a.IESYSTEMCONTROLNUMBER,
	replace( --escape /
		replace( --escape "
			replace( --replace carriage return (ascii 13)
				replace( --replace form feed (ascii 12) 
					replace( --replace vertical tab (ascii 11)
						replace( --replace line feed (ascii 10)
							replace( --replace horizontal tab (ascii 09)
								replace( --replace backspace (ascii 08)
									replace( --escape \
										max(d.IETITLE) 
									,'\', '\\')
								,char(8), ' ')
							,char(9), ' ')
						,char(10), ' ')
					,char(11), ' ')
				,char(12), ' ')
			,char(13), ' ')
			,'"', '\"')
		,'/', '\/') as  IETitle,
	0 as [isMedia],
	cast(b.INFOTYPEID as varchar(50)) InfoTypeID,
	--'[''' + STRING_AGG(b.INFOTYPEID, '","') WITHIN GROUP (ORDER BY b.INFOTYPEID ASC)  + ''']' AS InfoTypeID, --20180912 pbf change to array; per Lu; This does not work because you can't get distinct
	max(bb.INFOTYPE) InfoType,
	max(e.[DATEUPDATED]) DateUpdated,
	max(e.LASTMODIFIEDDATE) [InsertDate], --Must be updated to insert date
	max(e.IEPUBDATE) [PubDate],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[ieTitle_id-ID],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [ieTitle_id-ID],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[ieTitle_zh-CN],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [ieTitle_zh-CN],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[ieTitle_fr-FR],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [ieTitle_fr-FR],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[ieTitle_de-DE],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [ieTitle_de-DE],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[ieTitle_it-IT],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [ieTitle_it-IT],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[ieTitle_pt-BR],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [ieTitle_pt-BR],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[ieTitle_es-ES],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [ieTitle_es-ES],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[ieTitle_ru-RU],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [ieTitle_ru-RU],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[ieTitle_ja-JP],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [ieTitle_ja-JP],

max(tr3.[PubDate_id-ID]) as [PubDate_id-ID],
max(tr3.[PubDate_zh-CN]) as [PubDate_zh-CN],
max(tr3.[PubDate_fr-FR]) as [PubDate_fr-FR],
max(tr3.[PubDate_de-DE]) as [PubDate_de-DE],
max(tr3.[PubDate_it-IT]) as [PubDate_it-IT],
max(tr3.[PubDate_pt-BR]) as [PubDate_pt-BR],
max(tr3.[PubDate_es-ES]) as [PubDate_es-ES],
max(tr3.[PubDate_ru-RU]) as [PubDate_ru-RU],
max(tr3.[PubDate_ja-JP]) as [PubDate_ja-JP],

max(tr4.[dateUpdated_id-ID]) as [dateUpdated_id-ID],
max(tr4.[dateUpdated_zh-CN]) as [dateUpdated_zh-CN],
max(tr4.[dateUpdated_fr-FR]) as [dateUpdated_fr-FR],
max(tr4.[dateUpdated_de-DE]) as [dateUpdated_de-DE],
max(tr4.[dateUpdated_it-IT]) as [dateUpdated_it-IT],
max(tr4.[dateUpdated_pt-BR]) as [dateUpdated_pt-BR],
max(tr4.[dateUpdated_es-ES]) as [dateUpdated_es-ES],
max(tr4.[dateUpdated_ru-RU]) as [dateUpdated_ru-RU],
max(tr4.[dateUpdated_ja-JP]) as [dateUpdated_ja-JP]

into #RecordsToString_C
From [SISWEB_OWNER].[LNKIESNP] a
inner join #InsertRecords i on 
	a.IESYSTEMCONTROLNUMBER = i.IESYSTEMCONTROLNUMBER --Limit to inserted records
inner join [SISWEB_OWNER].[LNKIEINFOTYPE] b on 
	a.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER and
	b.INFOTYPEID not in (Select [INFOTYPEID] from SISSEARCH.REF_EXCLUDEINFOTYPE) 	
left outer join [SISWEB_OWNER].[MASINFOTYPE] bb on
	b.INFOTYPEID = bb.INFOTYPEID and
	bb.LANGUAGEINDICATOR = 'E'
left outer join [SISWEB_OWNER].[LNKIEDATE] e on 
	a.IESYSTEMCONTROLNUMBER = e.IESYSTEMCONTROLNUMBER and
	e.LANGUAGEINDICATOR = 'E'
inner join [SISWEB_OWNER].[LNKIETITLE] d on 
	a.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER and
	d.IELANGUAGEINDICATOR = 'E' and
	(d.GROUPTITLEINDICATOR='N' OR d.GROUPTITLEINDICATOR is null)

--Get translated values
left outer join
(
Select 
IESYSTEMCONTROLNUMBER, 
[8] [ieTitle_id-ID], 
[C] [ieTitle_zh-CN], 
[F] [ieTitle_fr-FR], 
[G] [ieTitle_de-DE], 
[L] [ieTitle_it-IT], 
[P] [ieTitle_pt-BR], 
[S] [ieTitle_es-ES], 
[R] [ieTitle_ru-RU], 
[J] [ieTitle_ja-JP]
From 
(
SELECT IESYSTEMCONTROLNUMBER --Candidate key composite
      ,IELANGUAGEINDICATOR --Candidate key composite
      ,IETITLE
FROM [SISWEB_OWNER].[LNKIETITLE]
WHERE GROUPTITLEINDICATOR='N' OR GROUPTITLEINDICATOR is null
) p
Pivot
(
Max(IETITLE) 
For IELANGUAGEINDICATOR in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
) pvt
) tr on tr.IESYSTEMCONTROLNUMBER = a.IESYSTEMCONTROLNUMBER

--Get translated values
left outer join
(
Select 
IESYSTEMCONTROLNUMBER, 
[8] [PubDate_id-ID], 
[C] [PubDate_zh-CN], 
[F] [PubDate_fr-FR], 
[G] [PubDate_de-DE], 
[L] [PubDate_it-IT], 
[P] [PubDate_pt-BR], 
[S] [PubDate_es-ES], 
[R] [PubDate_ru-RU], 
[J] [PubDate_ja-JP]
From 
(
SELECT IESYSTEMCONTROLNUMBER --Candidate key composite
      ,[LANGUAGEINDICATOR] --Candidate key composite
      ,IEPUBDATE
FROM [SISWEB_OWNER].[LNKIEDATE]
) p
Pivot
(
Max(IEPUBDATE) 
For [LANGUAGEINDICATOR] in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
) pvt
) tr3 on tr3.IESYSTEMCONTROLNUMBER = a.IESYSTEMCONTROLNUMBER

--Get translated values
left outer join
(
Select 
IESYSTEMCONTROLNUMBER, 
[8] [dateUpdated_id-ID], 
[C] [dateUpdated_zh-CN], 
[F] [dateUpdated_fr-FR], 
[G] [dateUpdated_de-DE], 
[L] [dateUpdated_it-IT], 
[P] [dateUpdated_pt-BR], 
[S] [dateUpdated_es-ES], 
[R] [dateUpdated_ru-RU], 
[J] [dateUpdated_ja-JP]
From 
(
SELECT IESYSTEMCONTROLNUMBER --Candidate key composite
      ,[LANGUAGEINDICATOR] --Candidate key composite
      ,LASTMODIFIEDDATE
FROM [SISWEB_OWNER].[LNKIEDATE]
) p
Pivot
(
Max(LASTMODIFIEDDATE) 
For [LANGUAGEINDICATOR] in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
) pvt
) tr4 on tr4.IESYSTEMCONTROLNUMBER = a.IESYSTEMCONTROLNUMBER


Group by 
a.IESYSTEMCONTROLNUMBER,
--cast(a.BEGINNINGRANGE as varchar(10))
--cast(a.ENDRANGE as varchar(10)),
cast(b.INFOTYPEID as varchar(50))

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Loaded to Temp #RecordsToString_C',@DATAVALUE = @RowCount, @LOGID = @StepLogID

----Drop temp
--Drop Table #InsertRecords

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID] 
ON #RecordsToString_C ([ID] ASC)
INCLUDE (InfoTypeID)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  
	[ID], 
	--[BeginRange],
	--[EndRange],
	IESYSTEMCONTROLNUMBER,
	max(IETitle) IETitle, --Already 1:1 with grain
	max([isMedia]) [isMedia],--Already 1:1 with grain
	coalesce(f.InfoTypeIDString,'') As InfoTypeID,
	max(InfoType) InfoType,--Already 1:1 with grain
	max(DateUpdated) DateUpdated,--Already 1:1 with grain
	max([InsertDate]) [InsertDate],--Already 1:1 with grain
	max([PubDate]) PubDate,--Already 1:1 with grain

max([ieTitle_id-ID]) [ieTitle_id-ID],
max([ieTitle_zh-CN]) [ieTitle_zh-CN],
max([ieTitle_fr-FR]) [ieTitle_fr-FR],
max([ieTitle_de-DE]) [ieTitle_de-DE],
max([ieTitle_it-IT]) [ieTitle_it-IT],
max([ieTitle_pt-BR]) [ieTitle_pt-BR],
max([ieTitle_es-ES]) [ieTitle_es-ES],
max([ieTitle_ru-RU]) [ieTitle_ru-RU],
max([ieTitle_ja-JP]) [ieTitle_ja-JP],
				   
max([PubDate_id-ID]) [PubDate_id-ID],
max([PubDate_zh-CN]) [PubDate_zh-CN],
max([PubDate_fr-FR]) [PubDate_fr-FR],
max([PubDate_de-DE]) [PubDate_de-DE],
max([PubDate_it-IT]) [PubDate_it-IT],
max([PubDate_pt-BR]) [PubDate_pt-BR],
max([PubDate_es-ES]) [PubDate_es-ES],
max([PubDate_ru-RU]) [PubDate_ru-RU],
max([PubDate_ja-JP]) [PubDate_ja-JP],

max([dateUpdated_id-ID]) [dateUpdated_id-ID],
max([dateUpdated_zh-CN]) [dateUpdated_zh-CN],
max([dateUpdated_fr-FR]) [dateUpdated_fr-FR],
max([dateUpdated_de-DE]) [dateUpdated_de-DE],
max([dateUpdated_it-IT]) [dateUpdated_it-IT],
max([dateUpdated_pt-BR]) [dateUpdated_pt-BR],
max([dateUpdated_es-ES]) [dateUpdated_es-ES],
max([dateUpdated_ru-RU]) [dateUpdated_ru-RU],
max([dateUpdated_ja-JP]) [dateUpdated_ja-JP]

into  #RecordsToStringResult_C
from  #RecordsToString_C a
cross apply 
(
	SELECT  '[' + stuff
	(
		(SELECT '","' + cast(InfoTypeID as varchar(MAX))        
		FROM #RecordsToString_C as b 
		where a.ID=b.ID 
		order by b.ID
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')   
	,1,2,'') + '"'+']'     
) f (InfoTypeIDString)
Group by 
[ID],
IESYSTEMCONTROLNUMBER,
--[BeginRange],
--[EndRange],
f.InfoTypeIDString

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult_C Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Temp RecordsToStringResult_C',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Drop temp table
Drop Table #RecordsToString_C

--Add pkey to result
Alter Table #RecordsToStringResult_C Alter Column ID varchar(50) Not NULL
ALTER TABLE #RecordsToStringResult_C ADD PRIMARY KEY CLUSTERED (ID) 
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult_C'

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into [SISSEARCH].[BASICSERVICEIE_2]
(
 [ID]
--,[BeginRange]
--,[EndRange]
,[IESystemControlNumber]
,[IETitle]
,[isMedia]
,[InfoTypeID]
,[InfoType]
,[DateUpdated]
,[InsertDate]
,[PubDate],

[IETitle_id-ID],
[IETitle_zh-CN],
[IETitle_fr-FR],
[IETitle_de-DE],
[IETitle_it-IT],
[IETitle_pt-BR],
[IETitle_es-ES],
[IETitle_ru-RU],
[IETitle_ja-JP],

[PubDate_id-ID],
[PubDate_zh-CN],
[PubDate_fr-FR],
[PubDate_de-DE],
[PubDate_it-IT],
[PubDate_pt-BR],
[PubDate_es-ES],
[PubDate_ru-RU],
[PubDate_ja-JP],

[DateUpdated_id-ID],
[DateUpdated_zh-CN],
[DateUpdated_fr-FR],
[DateUpdated_de-DE],
[DateUpdated_it-IT],
[DateUpdated_pt-BR],
[DateUpdated_es-ES],
[DateUpdated_ru-RU],
[DateUpdated_ja-JP]
)
Select 
[ID], 
--[BeginRange],
--[EndRange],
IESYSTEMCONTROLNUMBER,
IETitle, --Already 1:1 with grain
[isMedia],--Already 1:1 with grain
InfoTypeID,
InfoType,--Already 1:1 with grain
DateUpdated,--Already 1:1 with grain
[InsertDate],--Already 1:1 with grain
PubDate,--Already 1:1 with grain

[ieTitle_id-ID],
[ieTitle_zh-CN],
[ieTitle_fr-FR],
[ieTitle_de-DE],
[ieTitle_it-IT],
[ieTitle_pt-BR],
[ieTitle_es-ES],
[ieTitle_ru-RU],
[ieTitle_ja-JP],

[PubDate_id-ID],
[PubDate_zh-CN],
[PubDate_fr-FR],
[PubDate_de-DE],
[PubDate_it-IT],
[PubDate_pt-BR],
[PubDate_es-ES],
[PubDate_ru-RU],
[PubDate_ja-JP],

[dateUpdated_id-ID],
[dateUpdated_zh-CN],
[dateUpdated_fr-FR],
[dateUpdated_de-DE],
[dateUpdated_it-IT],
[dateUpdated_pt-BR],
[dateUpdated_es-ES],
[dateUpdated_ru-RU],
[dateUpdated_ja-JP]

From  #RecordsToStringResult_C

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Target [SISSEARCH].[BASICSERVICEIE_2]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

/*
Array of ControlNumber
All IDs have been inserted.  Next we need to get an array of control numbers and update the controlnumber field.
*/

select a.IESYSTEMCONTROLNUMBER as [ID], 
trim(d.IECONTROLNUMBER) ControlNumber
into #RecordsToString_CN
From [SISWEB_OWNER].[LNKIESNP] a
inner join #InsertRecords i on 
	a.IESYSTEMCONTROLNUMBER = i.IESYSTEMCONTROLNUMBER --Limit to inserted records
inner join [SISWEB_OWNER].[LNKIEINFOTYPE] b on 
	a.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER and
	b.INFOTYPEID not in (Select [INFOTYPEID] from SISSEARCH.REF_EXCLUDEINFOTYPE) 	
left outer join [SISWEB_OWNER].[MASINFOTYPE] bb on
	b.INFOTYPEID = bb.INFOTYPEID and
	bb.LANGUAGEINDICATOR = 'E'
left outer join [SISWEB_OWNER].[LNKIEDATE] e on 
	a.IESYSTEMCONTROLNUMBER = e.IESYSTEMCONTROLNUMBER and
	e.LANGUAGEINDICATOR = 'E'
inner join [SISWEB_OWNER].[LNKIETITLE] d on 
	a.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER and
	d.IELANGUAGEINDICATOR = 'E' and
	(d.GROUPTITLEINDICATOR='N' OR d.GROUPTITLEINDICATOR is null)
Group by 
a.IESYSTEMCONTROLNUMBER,
d.IECONTROLNUMBER

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count (ControlNumber): ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Loaded to Temp #RecordsToString_CN (ControlNumber)',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Drop temp
--Drop Table #InsertRecords

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID] 
ON #RecordsToString_CN ([ID] ASC)
INCLUDE (ControlNumber)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp (ControlNumber)'

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  
	[ID], 
	coalesce(f.ControlNumberString,'') As [ControlNumber]
into  #RecordsToStringResult_CN
from  #RecordsToString_CN a
cross apply 
(
	SELECT  '[' + stuff
	(
		(SELECT '","' + cast(ControlNumber as varchar(MAX))        
		FROM #RecordsToString_CN as b 
		where a.ID=b.ID 
		order by b.ID, cast(ControlNumber as varchar(MAX))
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')   
	,1,2,'') + '"'+']'     
) f (ControlNumberString)
Group by 
[ID],
f.ControlNumberString

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult_C Count (ControlNumber): ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Temp RecordsToStringResult_C (ControlNumber)',@DATAVALUE = @RowCount, @LOGID = @StepLogID
	
--Drop temp table
Drop Table #RecordsToString_CN

--Add pkey to result
Alter Table #RecordsToStringResult_CN Alter Column ID varchar(50) Not NULL
ALTER TABLE #RecordsToStringResult_CN ADD PRIMARY KEY CLUSTERED (ID) 
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult_C (ControlNumber)'

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

--All IDs have been inserted already.  Update with ControlNumber Array.
Update bs
Set bs.ControlNumber = nullif(nullif(r.ControlNumber, ''), '[""]')
From [SISSEARCH].[BASICSERVICEIE_2] bs
Inner join #RecordsToStringResult_CN r on bs.ID = r.ID

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Updated Target Count (ControlNumber): ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated Target [SISSEARCH].[BASICSERVICEIE_2] (ControlNumber)',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Array of GraphicControlNumber
--All IDs have been inserted. Next we need to get an array of GraphicControlNumbers and update the GraphicControlNumber field.

If Object_ID('Tempdb..#RecordsToString_GCN') is not null
  Begin
     Drop table #RecordsToString_GCN
  End;

Select IE.IESYSTEMCONTROLNUMBER as [ID],
	c.GRAPHICCONTROLNUMBER GraphicControlNumber
into #RecordsToString_GCN
From [SISWEB_OWNER].[LNKIESNP] IE
inner join #InsertRecords IR on IR.IESystemControlNumber = IE.IESYSTEMCONTROLNUMBER
inner join [SISWEB_OWNER].[LNKIEINFOTYPE] b on 
	IE.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER and
	b.INFOTYPEID not in (Select [INFOTYPEID] from SISSEARCH.REF_EXCLUDEINFOTYPE) 
inner join SISWEB_OWNER_SHADOW.LNKIEIMAGE c on IE.IESYSTEMCONTROLNUMBER= c.IESYSTEMCONTROLNUMBER
Group by IE.IESYSTEMCONTROLNUMBER, c.GRAPHICCONTROLNUMBER

SET @RowCount = @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Loaded to Temp #RecordsToString_GCN (GraphicControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID]
ON #RecordsToString_GCN ([ID] ASC)
INCLUDE (GraphicControlNumber)

--Records to String
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToStringResult_GCN') is not null
  Begin
     Drop table #RecordsToStringResult_GCN
  End;

Select [ID],
    coalesce(f.GraphicControlNumberString,'') As [GraphicControlNumber]
into #RecordsToStringResult_GCN
From #RecordsToString_GCN a
CROSS apply
	(
		SELECT '[' + stuff (
			(
				SELECT  '","' + cast(GraphicControlNumber AS varchar(max))
				FROM	#RecordsToString_GCN AS b
                WHERE    a.ID = b.ID
                ORDER BY b.ID, cast(GraphicControlNumber as varchar(MAX))
				FOR xml path(''), type).value('.', 'varchar(max)') ,1,2,''
			) + '"'+']'
	) f (GraphicControlNumberString)
Group By [ID], f.GraphicControlNumberString

SET @RowCount = @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Temp RecordsToStringResult_GCN (GraphicControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--Add pkey to result
Alter Table #RecordsToStringResult_GCN Alter Column ID varchar(50) Not NULL
ALTER TABLE #RecordsToStringResult_GCN ADD PRIMARY KEY CLUSTERED (ID)

--Insert result into target
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

--All IDs have been inserted already.  Update with ControlNumber Array.
Update BS
Set BS.GraphicControlNumber = nullif(nullif(R.GraphicControlNumber, ''), '[""]')
From [SISSEARCH].[BASICSERVICEIE_2] BS
Inner join #RecordsToStringResult_GCN R on BS.ID = R.ID

SET @RowCount = @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated Target [SISSEARCH].[BASICSERVICEIE_2] (GraphicControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

/*
End All
*/

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
