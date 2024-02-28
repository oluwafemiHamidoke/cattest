Create  Procedure [sissearch2].[Basic_ServiceIE_Load] As
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

EXEC @SPStartLogID = sissearch2.WriteLog @TIME = @SPStartTime, @NAMEOFSPROC = @ProcName;
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#DeletedRecords') is not null
  Begin
     Drop table #DeletedRecords
  End

Select IESystemControlNumber
into #DeletedRecords
From [sissearch2].[Basic_ServiceIE]
Except
Select IE.IESystemControlNumber
From [sis].[IE] IE
inner join [sis].[IE_Translation] IET ON IET.IE_ID = IE.IE_ID
inner join [sis].[Language] L on L.Language_ID = IET.Language_ID and L.Language_Tag='en-US'
inner join [sis].[IE_InfoType_Relation] IIR ON IIR.IE_ID = IE.IE_ID AND IIR.InfoType_ID NOT IN (Select InfoTypeID from sissearch2.Ref_ExcludeInfoType)
inner join
	(select IE_ID from [sis].[IE_Effectivity]
	 union
	 select IE_ID from [sis].[IE_ProductFamily_Effectivity]) x ON x.IE_ID = IE.IE_ID

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, @LOGMESSAGE =  'Deleted Records Detected';

-- Delete Idenified Deleted Records in Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete From [sissearch2].[Basic_ServiceIE]
Where IESystemControlNumber IN (Select IESystemControlNumber From #DeletedRecords)

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Records from Target [sissearch2].[Basic_ServiceIE]', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select @LastInsertDate = coalesce(Max(InsertDate),'1900-01-01') From [sissearch2].[Basic_ServiceIE]
--Print cast(getdate() as varchar(50)) + ' - Latest Insert Date in Target: ' + cast(@LastInsertDate as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
Declare @Logmessage as varchar(50) = 'Latest Insert Date in Target '+cast (@LastInsertDate as varchar(25))
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = @Logmessage , @LOGID = @StepLogID

--Identify Inserted records from Source
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#InsertRecords') is not null
Begin
    Drop table #InsertRecords
End

Select IE.IESystemControlNumber
into #InsertRecords
From [sis].[IE] IE
inner join [sis].[IE_Translation] IET ON IET.IE_ID = IE.IE_ID
inner join [sis].[Language] L on L.Language_ID = IET.Language_ID and L.Language_Tag='en-US'
inner join [sis].[IE_InfoType_Relation] IIR ON IIR.IE_ID = IE.IE_ID AND IIR.InfoType_ID NOT IN (Select InfoTypeID from sissearch2.Ref_ExcludeInfoType)
inner join
	(select IE_ID from [sis].[IE_Effectivity]
	 union
	 select IE_ID from [sis].[IE_ProductFamily_Effectivity]) x ON x.IE_ID = IE.IE_ID
where isnull(IET.LastModified_Date, getdate()) > @LastInsertDate

SET @RowCount = @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Detected #InsertRecords', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_IESystemControlNumber ON #InsertRecords([IESystemControlNumber])

--Delete Inserted records from Target
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete From [sissearch2].[Basic_ServiceIE]
Where IESystemControlNumber IN (Select IESystemControlNumber From #InsertRecords)

SET @RowCount = @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Inserted Records from Target [sissearch2].[Basic_ServiceIE]', @DATAVALUE = @RowCount, @LOGID = @StepLogID

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
  Begin
     Drop table #RecordsToString
  End;

select IE.IESystemControlNumber as [ID],
	IE.IESystemControlNumber,
	replace( --escape /
		replace( --escape "
			replace( --replace carriage return (ascii 13)
				replace( --replace form feed (ascii 12)
					replace( --replace vertical tab (ascii 11)
						replace( --replace line feed (ascii 10)
							replace( --replace horizontal tab (ascii 09)
								replace( --replace backspace (ascii 08)
									replace( --escape \
										max(IET.Title)
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
	cast(IInfoR.InfoType_ID as varchar(50)) InfoTypeID,
	max(IET.[Date_Updated]) DateUpdated,
	max(IET.LastModified_Date) [InsertDate], --Must be updated to insert date
	max(IET.Published_Date) [PubDate],

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

Into #RecordsToString
From [sis].[IE] IE
inner join #InsertRecords IR on IR.IESystemControlNumber = IE.IESystemControlNumber
inner join [sis].[IE_Translation] IET ON IET.IE_ID = IE.IE_ID
inner join [sis].[Language] L on L.Language_ID = IET.Language_ID and L.Language_Tag ='en-US'
inner join [sis].[IE_InfoType_Relation] IInfoR ON IInfoR.IE_ID = IE.IE_ID AND IInfoR.InfoType_ID NOT IN (Select InfoTypeID from sissearch2.Ref_ExcludeInfoType)
inner join
	(select IE_ID from [sis].[IE_Effectivity]
	 union
	 select IE_ID from [sis].[IE_ProductFamily_Effectivity]) x ON x.IE_ID = IE.IE_ID

--Get translated values
left outer join
    (
    Select
    IESystemControlNumber,
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
        SELECT IE.IESystemControlNumber, --Candidate key composite
        L.Legacy_Language_Indicator as IELANGUAGEINDICATOR, --Candidate key composite
        IET.Title as IETITLE
        FROM [sis].[IE] IE
	    inner join [sis].[IE_Translation] IET on IET.IE_ID = IE.IE_ID
        inner join [sis].[Language] L on L.Language_ID = IET.Language_ID
    ) p
    Pivot
    (
        Max(IETITLE)
        For IELANGUAGEINDICATOR in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
    ) pvt
    ) tr on tr.IESystemControlNumber = IE.IESystemControlNumber

--Get translated values
left outer join
    (
    Select
    IESystemControlNumber,
    [8] [PubDate_id-ID],
    [C] [PubDate_zh-CN],
    [F] [PubDate_fr-FR],
    [G] [PubDate_de-DE],
    [L] [PubDate_it-IT],
    [P] [PubDate_pt-BR],
    [S] [PubDate_es-ES],
    [R] [PubDate_ru-RU],
    [J] [PubDate_ja-JP]
    From (
		SELECT IE.IESystemControlNumber, --Candidate key composite
		L.Legacy_Language_Indicator as LANGUAGEINDICATOR, --Candidate key composite
		IET.Published_Date as IEPUBDATE
        FROM [sis].[IE] IE
	    inner join [sis].[IE_Translation] IET on IET.IE_ID = IE.IE_ID
        inner join [sis].[Language] L on L.Language_ID = IET.Language_ID
	) p
	Pivot
	(
		Max(IEPUBDATE)
		For [LANGUAGEINDICATOR] in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
	) pvt
    ) tr3 on tr3.IESystemControlNumber = IE.IESystemControlNumber

--Get translated values
left outer join
    (
    Select
    IESystemControlNumber,
    [8] [dateUpdated_id-ID],
    [C] [dateUpdated_zh-CN],
    [F] [dateUpdated_fr-FR],
    [G] [dateUpdated_de-DE],
    [L] [dateUpdated_it-IT],
    [P] [dateUpdated_pt-BR],
    [S] [dateUpdated_es-ES],
    [R] [dateUpdated_ru-RU],
    [J] [dateUpdated_ja-JP]
    From (
		SELECT IE.IESystemControlNumber --Candidate key composite
        ,L.Legacy_Language_Indicator as LANGUAGEINDICATOR --Candidate key composite
        ,IET.Date_Updated as UpdatedDate
        FROM [sis].[IE] IE
	    inner join [sis].[IE_Translation] IET on IET.IE_ID = IE.IE_ID
        inner join [sis].[Language] L on L.Language_ID = IET.Language_ID
	) p
	Pivot
	(
		Max(UpdatedDate)
		For [LANGUAGEINDICATOR] in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
	) pvt
    ) tr4 on tr4.IESystemControlNumber = IE.IESystemControlNumber
Group by
    IE.IESystemControlNumber,
    cast(IInfoR.InfoType_ID as varchar(50))

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Loaded to Temp #RecordsToString', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID]
ON #RecordsToString ([ID] ASC)
INCLUDE (InfoTypeID)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToStringResult') is not null
  Begin
     Drop table #RecordsToStringResult
  End;

Select
    [ID],
    IESystemControlNumber,
    max(IETitle) IETitle, --Already 1:1 with grain
    max([isMedia]) [isMedia],--Already 1:1 with grain
    coalesce(f.InfoTypeIDString,'') As InfoTypeID,
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

into #RecordsToStringResult
From #RecordsToString a
CROSS apply
	(
		SELECT '[' + stuff (
			(
				SELECT  '","' + cast(InfoTypeID AS varchar(max))
				FROM	#RecordsToString AS b
                WHERE    a.Id = b.Id
                ORDER BY b.Id
				FOR xml path(''), type).value('.', 'varchar(max)') ,1,2,''
			) + '"'+']'
	) f (InfoTypeIDString)
Group By a.Id, a.IESystemControlNumber, f.InfoTypeIDString

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult_C Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Temp RecordsToStringResult', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--Add pkey to result
Alter Table #RecordsToStringResult Alter Column ID varchar(50) Not NULL
ALTER TABLE #RecordsToStringResult ADD PRIMARY KEY CLUSTERED (ID)

--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into [sissearch2].[Basic_ServiceIE]
(
    [ID]
    ,[IESystemControlNumber]
    ,[IETitle]
    ,[isMedia]
    ,[InfoTypeID]
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
    IESystemControlNumber,
    IETitle, --Already 1:1 with grain
    [isMedia],--Already 1:1 with grain
    InfoTypeID,
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
From  #RecordsToStringResult

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Target [sissearch2].[Basic_ServiceIE]', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--Array of ControlNumber
--All IDs have been inserted. Next we need to get an array of control numbers and update the ControlNumber field.

If Object_ID('Tempdb..#RecordsToString_CN') is not null
  Begin
     Drop table #RecordsToString_CN
  End;

Select IE.IESystemControlNumber as [ID],
    trim(IET.IEControlNumber) ControlNumber
into #RecordsToString_CN
From [sis].[IE] IE
inner join #InsertRecords IR on IR.IESystemControlNumber = IE.IESystemControlNumber
inner join [sis].[IE_Translation] IET ON IET.IE_ID = IE.IE_ID
inner join [sis].[Language] L on L.Language_ID = IET.Language_ID and L.Language_Tag ='en-US'
inner join [sis].[IE_InfoType_Relation] IInfoR ON IInfoR.IE_ID = IE.IE_ID AND IInfoR.InfoType_ID NOT IN (Select InfoTypeID from sissearch2.Ref_ExcludeInfoType)
inner join
	(select IE_ID from [sis].[IE_Effectivity]
	 union
	 select IE_ID from [sis].[IE_ProductFamily_Effectivity]) x ON x.IE_ID = IE.IE_ID
Group by IE.IESystemControlNumber, IET.IEControlNumber

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count (ControlNumber): ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Loaded to Temp #RecordsToString_CN (ControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID]
ON #RecordsToString_CN ([ID] ASC)
INCLUDE (ControlNumber)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp (ControlNumber)'

--Records to String
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToStringResult_CN') is not null
  Begin
     Drop table #RecordsToStringResult_CN
  End;

Select [ID],
    coalesce(f.ControlNumberString,'') As [ControlNumber]
into #RecordsToStringResult_CN
From #RecordsToString_CN a
CROSS apply
	(
		SELECT '[' + stuff (
			(
				SELECT  '","' + cast(ControlNumber AS varchar(max))
				FROM	#RecordsToString_CN AS b
                WHERE    a.Id = b.Id
                ORDER BY b.Id, cast(ControlNumber as varchar(MAX))
				FOR xml path(''), type).value('.', 'varchar(max)') ,1,2,''
			) + '"'+']'
	) f (ControlNumberString)
Group By [ID], f.ControlNumberString

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult_C Count (ControlNumber): ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Temp RecordsToStringResult_CN (ControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--Add pkey to result
Alter Table #RecordsToStringResult_CN Alter Column ID varchar(50) Not NULL
ALTER TABLE #RecordsToStringResult_CN ADD PRIMARY KEY CLUSTERED (ID)
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult_CN (ControlNumber)'

--Insert result into target
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

--All IDs have been inserted already.  Update with ControlNumber Array.
Update BS
Set BS.ControlNumber = nullif(nullif(R.ControlNumber, ''), '[""]')
From [sissearch2].[Basic_ServiceIE] BS
Inner join #RecordsToStringResult_CN R on BS.ID = R.ID

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Updated Target Count (ControlNumber): ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated Target [sissearch2].[Basic_ServiceIE] (ControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--Array of GraphicControlNumber
--All IDs have been inserted. Next we need to get an array of GraphicControlNumbers and update the GraphicControlNumber field.

If Object_ID('Tempdb..#RecordsToString_GCN') is not null
  Begin
     Drop table #RecordsToString_GCN
  End;

Select IE.IESystemControlNumber as [ID],
	I.Graphic_Control_Number as GraphicControlNumber
into #RecordsToString_GCN
From [sis].[IE] IE
inner join #InsertRecords IR on IR.IESystemControlNumber = IE.IESystemControlNumber
inner join [sis].[IE_Translation] IET ON IET.IE_ID = IE.IE_ID
inner join [sis].[Language] L on L.Language_ID = IET.Language_ID and L.Language_Tag ='en-US'
inner join [sis].[IE_InfoType_Relation] IInfoR ON IInfoR.IE_ID = IE.IE_ID AND IInfoR.InfoType_ID NOT IN (Select InfoTypeID from sissearch2.Ref_ExcludeInfoType)
inner join
	(select IE_ID from [sis].[IE_Effectivity]
	 union
	 select IE_ID from [sis].[IE_ProductFamily_Effectivity]) x ON x.IE_ID = IE.IE_ID
inner join sis.IE_Illustration_Relation IIR ON IIR.IE_ID = IE.IE_ID
inner join sis.Illustration I ON I.Illustration_ID = IIR.Illustration_ID
Group by IE.IESystemControlNumber, I.Graphic_Control_Number

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count (GraphicControlNumber): ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Loaded to Temp #RecordsToString_GCN (GraphicControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID]
ON #RecordsToString_GCN ([ID] ASC)
INCLUDE (GraphicControlNumber)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp (GraphicControlNumber)'

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
                WHERE    a.Id = b.Id
                ORDER BY b.Id, cast(GraphicControlNumber as varchar(MAX))
				FOR xml path(''), type).value('.', 'varchar(max)') ,1,2,''
			) + '"'+']'
	) f (GraphicControlNumberString)
Group By [ID], f.GraphicControlNumberString

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult_GCN Count (GraphicControlNumber): ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Temp RecordsToStringResult_GCN (GraphicControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--Add pkey to result
Alter Table #RecordsToStringResult_GCN Alter Column ID varchar(50) Not NULL
ALTER TABLE #RecordsToStringResult_GCN ADD PRIMARY KEY CLUSTERED (ID)
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult_GCN (GraphicControlNumber)'

--Insert result into target
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

--All IDs have been inserted already.  Update with ControlNumber Array.
Update BS
Set BS.GraphicControlNumber = nullif(nullif(R.GraphicControlNumber, ''), '[""]')
From [sissearch2].[Basic_ServiceIE] BS
Inner join #RecordsToStringResult_GCN R on BS.ID = R.ID

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Updated Target Count (GraphicControlNumber): ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated Target [sissearch2].[Basic_ServiceIE] (GraphicControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

/*
End All
*/

--Drop temp table
Drop Table #DeletedRecords
Drop Table #InsertRecords
Drop Table #RecordsToString
Drop Table #RecordsToStringResult
Drop Table #RecordsToString_CN
Drop Table #RecordsToStringResult_CN
Drop Table #RecordsToString_GCN
Drop Table #RecordsToStringResult_GCN

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LOGID = @SPStartLogID, @DATAVALUE = @RowCount

DELETE FROM sissearch2.LOG WHERE DATEDIFF(DD, LogDateTime, GetDate())>30 and NameofSproc= @ProcName

END TRY

BEGIN CATCH
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT= ERROR_LINE()

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC sissearch2.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error

END CATCH

End
