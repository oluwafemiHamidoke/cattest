Create  Procedure [sissearch2].[ServiceIE_Media_Load]
As

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

EXEC @SPStartLogID = sissearch2.WriteLog @TIME = @SPStartTime, @NAMEOFSPROC = @ProcName;

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#DeletedRecords') is not null
Begin
Drop table #DeletedRecords
End
Select
    [IESystemControlNumber]
into #DeletedRecords
from  [sissearch2].[ServiceIE_Media]
Except
Select
    a.IESystemControlNumber
From [sis].[IE] a
    inner join (select IE_ID from [sis].[IE_Effectivity] union select IE_ID from [sis].[IE_ProductFamily_Effectivity]) aa on
    a.IE_ID = aa.IE_ID
    inner join [sis].[IE_InfoType_Relation] b on
    a.IE_ID = b.IE_ID and
    b.InfoType_ID not in (Select x.InfoTypeID from sissearch2.Ref_ExcludeInfoType x)
    inner join  [sis].[IE_Translation] c on
    a.IE_ID = c.IE_ID
    inner join [sis].[Language] d on
    c.Language_ID=d.Language_ID and d.Language_Tag='en-US'

    SET @RowCount= @@RowCount

        SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
@LOGMESSAGE =  'Deleted Records Detected';

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [sissearch2].[ServiceIE_Media]
From [sissearch2].[ServiceIE_Media] a
inner join #DeletedRecords d on a.[IESystemControlNumber] = d.[IESystemControlNumber]

SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
@LOGMESSAGE =  'Deleted Records from Target [sissearch2].[ServiceIE_Media]';

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [sissearch2].[ServiceIE_Media]

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
Declare @Logmessage as varchar(50) = 'Latest Insert Date in Target '+cast (@LastInsertDate as varchar(25))
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = @Logmessage , @LOGID = @StepLogID


SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

 If Object_ID('Tempdb..#InsertRecords') is not null
Begin
Drop table #InsertRecords
End
Select distinct
    a.IESystemControlNumber
into #InsertRecords
From [sis].[IE] a
    inner join (select IE_ID from [sis].[IE_Effectivity] 
	union select IE_ID from [sis].[IE_ProductFamily_Effectivity]) aa on a.IE_ID = aa.IE_ID
    inner join [sis].[IE_InfoType_Relation] b on a.IE_ID = b.IE_ID and
    b.InfoType_ID not in (Select x.InfoTypeID from sissearch2.Ref_ExcludeInfoType x)
    left outer join  [sis].[IE_Translation] c on a.IE_ID = c.IE_ID
    inner join [sis].[Language] d on c.Language_ID=d.Language_ID and d.Language_Tag='en-US'
where isnull(c.LastModified_Date, getdate()) > @LastInsertDate

SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
@LOGMESSAGE =  'Inserted Records Detected #InsertRecords';

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_iesystemcontrolnumber
    ON #InsertRecords([IESystemControlNumber])

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [sissearch2].[ServiceIE_Media]
From [sissearch2].[ServiceIE_Media] a
inner join #InsertRecords d on a.IESystemControlNumber = d.IESystemControlNumber

SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
@LOGMESSAGE =  'Deleted Inserted Records from Target [sissearch2].[ServiceIE_Media]';

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin
Drop table #RecordsToString
End

;with CTE as
          (
              select a.IESystemControlNumber as [ID],
     a.IESystemControlNumber,
     replace( --escape /
     replace( --escape "
     replace( --replace carriage return (ascii 13)
     replace( --replace form feed (ascii 12)
     replace( --replace vertical tab (ascii 11)
     replace( --replace line feed (ascii 10)
     replace( --replace horizontal tab (ascii 09)
     replace( --replace backspace (ascii 08)
     replace( --escape \
     isnull(m.MEDIA_NUMBER, '')
         ,'\', '\\')
         ,char(8), ' ')
         ,char(9), ' ')
         ,char(10), ' ')
         ,char(11), ' ')
         ,char(12), ' ')
         ,char(13), ' ')
         ,'"', '\"')
         ,'/', '\/') as  MEDIANUMBER,
     max(c.LastModified_Date) [InsertDate], --Must be updated to insert date

     max(replace(replace(replace(replace(replace(replace(replace(replace(replace(tr.[MediaNumbers_id-ID]
         ,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaNumbers_id-ID],

     max(replace(replace(replace(replace(replace(replace(replace(replace(replace(tr.[MediaNumbers_zh-CN]
         ,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaNumbers_zh-CN],

     max(replace(replace(replace(replace(replace(replace(replace(replace(replace(tr.[MediaNumbers_fr-FR]
         ,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaNumbers_fr-FR],

     max(replace(replace(replace(replace(replace(replace(replace(replace(replace(tr.[MediaNumbers_de-DE]
         ,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaNumbers_de-DE],

     max(replace(replace(replace(replace(replace(replace(replace(replace(replace(tr.[MediaNumbers_it-IT]
         ,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaNumbers_it-IT],

     max(replace(replace(replace(replace(replace(replace(replace(replace(replace(tr.[MediaNumbers_pt-BR]
         ,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaNumbers_pt-BR],

     max(replace(replace(replace(replace(replace(replace(replace(replace(replace(tr.[MediaNumbers_es-ES]
         ,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaNumbers_es-ES],

     max(replace(replace(replace(replace(replace(replace(replace(replace(replace(tr.[MediaNumbers_ru-RU]
         ,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaNumbers_ru-RU],

     max(replace(replace(replace(replace(replace(replace(replace(replace(replace(tr.[MediaNumbers_ja-JP]
         ,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaNumbers_ja-JP]

 From [sis].[IE] a
     inner join #InsertRecords i on
     a.IESystemControlNumber = i.IESystemControlNumber --Limit to inserted records
     inner join (select IE_ID,Media_ID from [sis].[IE_Effectivity] union select IE_ID,Media_ID from [sis].[IE_ProductFamily_Effectivity]) aa on
     a.IE_ID = aa.IE_ID
     inner join [sis].[IE_InfoType_Relation] b on
     a.IE_ID = b.IE_ID and
     b.InfoType_ID not in (Select x.InfoTypeID from sissearch2.Ref_ExcludeInfoType x)
     left outer join [sis].[IE_Translation] c on
     a.IE_ID = c.IE_ID
     inner join [sis].[Language] d on
     c.Language_ID=d.Language_ID and d.Language_Tag='en-US'
     Left outer join [sis].[Media] m on --Join to get BaseEnglishMediaNumber.  Required in next join.
     aa.Media_ID = m.Media_ID
--Get translated values
     left outer join
     (
     Select
     Media_Number,
    [8] [MediaNumbers_id-ID], 
    [C] [MediaNumbers_zh-CN], 
    [F] [MediaNumbers_fr-FR], 
    [G] [MediaNumbers_de-DE], 
    [L] [MediaNumbers_it-IT], 
    [P] [MediaNumbers_pt-BR], 
    [S] [MediaNumbers_es-ES], 
    [R] [MediaNumbers_ru-RU], 
    [J] [MediaNumbers_ja-JP]    
     From
     (
     select M.Media_Number,L.Legacy_Language_Indicator,MT.Media_Number as medianumber 
	 from sis.Media M 
	 inner join sis.Media_Translation MT ON M.Media_ID=MT.Media_ID
     inner JOIN [sis].[Language] L ON MT.Language_ID=L.Language_ID
     ) p
     Pivot
     (
     Max(medianumber)
     For  [Legacy_Language_Indicator] in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
     ) pvt
     ) tr on tr.Media_Number = m.Media_Number
 Group by
     a.IESystemControlNumber,
     m.MEDIA_NUMBER
     )
Select *
into #RecordsToString
From CTE;

SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString';

--NCI
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID]
ON #RecordsToString ([ID] ASC)
INCLUDE (IESystemControlNumber,MEDIANUMBER,[InsertDate])
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


--Change from xmlpath to string_agg method
--Drop table #RecordsToStringResult_C
Insert into [sissearch2].[ServiceIE_Media]
(
    [ID]
    ,[IESystemControlNumber]
    ,[MediaNumber]
    ,[MediaNumbers_id-ID]
    ,[MediaNumbers_zh-CN]
    ,[MediaNumbers_fr-FR]
    ,[MediaNumbers_de-DE]
    ,[MediaNumbers_it-IT]
    ,[MediaNumbers_pt-BR]
    ,[MediaNumbers_es-ES]
    ,[MediaNumbers_ja-JP]
    ,[MediaNumbers_ru-RU]
    ,[InsertDate]
)
SELECT
    a.ID,
    a.IESystemControlNumber,
    COALESCE('["' + STRING_AGG(CAST(MEDIANUMBER AS VARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY MEDIANUMBER) + '"]','') AS MEDIANUMBER,
    COALESCE('["' + STRING_AGG(CAST([MediaNumbers_id-ID] AS VARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY MEDIANUMBER) + '"]','') AS [MediaNumbers_id-ID],
COALESCE('["' + STRING_AGG(CAST([MediaNumbers_zh-CN] AS VARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY MEDIANUMBER) + '"]','') AS [MediaNumbers_zh-CN],
COALESCE('["' + STRING_AGG(CAST([MediaNumbers_fr-FR] AS VARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY MEDIANUMBER) + '"]','') AS [MediaNumbers_fr-FR],
COALESCE('["' + STRING_AGG(CAST([MediaNumbers_de-DE] AS VARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY MEDIANUMBER) + '"]','') AS [MediaNumbers_de-DE],
COALESCE('["' + STRING_AGG(CAST([MediaNumbers_it-IT] AS VARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY MEDIANUMBER) + '"]','') AS [MediaNumbers_it-IT],
COALESCE('["' + STRING_AGG(CAST([MediaNumbers_pt-BR] AS VARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY MEDIANUMBER) + '"]','') AS [MediaNumbers_pt-BR],
COALESCE('["' + STRING_AGG(CAST([MediaNumbers_es-ES] AS VARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY MEDIANUMBER) + '"]','') AS [MediaNumbers_es-ES],
COALESCE('["' + STRING_AGG(CAST([MediaNumbers_ja-JP] AS VARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY MEDIANUMBER) + '"]','') AS [MediaNumbers_ja-JP],
COALESCE('["' + STRING_AGG(CAST([MediaNumbers_ru-RU] AS VARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY MEDIANUMBER) + '"]','') AS [MediaNumbers_ru-RU],
min(a.InsertDate) InsertDate --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
FROM #RecordsToString a
Group by
    a.ID,
    a.IESystemControlNumber

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
@LOGMESSAGE =  'Inserted into Target [sissearch2].[ServiceIE_Media]';

SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LOGID = @SPStartLogID,@DATAVALUE = @RowCount

DELETE FROM sissearch2.LOG WHERE DATEDIFF(DD, LogDateTime, GetDate())>30 and NameofSproc= @ProcName

END TRY

BEGIN CATCH
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT= ERROR_LINE()

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC sissearch2.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error
END CATCH


End