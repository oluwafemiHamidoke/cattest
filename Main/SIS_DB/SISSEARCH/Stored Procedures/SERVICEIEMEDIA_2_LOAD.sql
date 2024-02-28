CREATE  Procedure [SISSEARCH].[SERVICEIEMEDIA_2_LOAD] 
As
/*---------------
Date: 20180504
Object Description:  Loading changed data into SISSEARCH.SERVICEIEMEDIA_2 from base tables
Modifiy Date: 20210310 - Davide. Changed DATEUPDATED to LASTMODDIFIEDDATE, see: https://dev.azure.com/sis-cat-com/sis2-ui/_workitems/edit/9566/
Exec [SISSEARCH].[SERVICEIEMEDIA_2_LOAD]
Truncate table [SISSEARCH].[SERVICEIEMEDIA_2]
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
from  [SISSEARCH].[SERVICEIEMEDIA_2]
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
	(d.GROUPTITLEINDICATOR='N' OR d.GROUPTITLEINDICATOR is Null)

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records Detected';

-- Delete Idenified Deleted Records in Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [SISSEARCH].[SERVICEIEMEDIA_2] 
From [SISSEARCH].[SERVICEIEMEDIA_2] a
inner join #DeletedRecords d on a.[IESystemControlNumber] = d.[IESystemControlNumber]

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records from Target [SISSEARCH].[SERVICEIEMEDIA_2]';

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	
Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [SISSEARCH].[SERVICEIEMEDIA_2]
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
	--Should be the date when the records was inserted.
	--if no insert date is found, then reprocess.

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Detected #InsertRecords';

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_iesystemcontrolnumber 
    ON #InsertRecords([IESYSTEMCONTROLNUMBER])

--Delete Inserted records from Target 	
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [SISSEARCH].[SERVICEIEMEDIA_2] 
From [SISSEARCH].[SERVICEIEMEDIA_2] a
inner join #InsertRecords d on a.IESystemControlNumber = d.IESYSTEMCONTROLNUMBER

SET @RowCount= @@RowCount   
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Inserted Records from Target [SISSEARCH].[SERVICEIEMEDIA_2]';

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
Drop table #RecordsToString
End

;with CTE as
(
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
										isnull(a.MEDIANUMBER, '')
									,'\', '\\')
								,char(8), ' ')
							,char(9), ' ')
						,char(10), ' ')
					,char(11), ' ')
				,char(12), ' ')
			,char(13), ' ')
			,'"', '\"')
		,'/', '\/') as  MEDIANUMBER,
	max(e.LASTMODIFIEDDATE) [InsertDate], --Must be updated to insert date

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

From [SISWEB_OWNER].[LNKIESNP] a
inner join #InsertRecords i on 
	a.IESYSTEMCONTROLNUMBER = i.IESYSTEMCONTROLNUMBER --Limit to inserted records
inner join [SISWEB_OWNER].[LNKIEINFOTYPE] b on 
	a.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER and
	b.INFOTYPEID not in (Select [INFOTYPEID] from SISSEARCH.REF_EXCLUDEINFOTYPE) 		
left outer join [SISWEB_OWNER].[LNKIEDATE] e on 
	a.IESYSTEMCONTROLNUMBER = e.IESYSTEMCONTROLNUMBER and
	e.LANGUAGEINDICATOR = 'E'
inner join [SISWEB_OWNER].[LNKIETITLE] d on 
	a.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER and
	d.IELANGUAGEINDICATOR = 'E' and
	(d.GROUPTITLEINDICATOR='N' OR GROUPTITLEINDICATOR is NULL)
Left outer join [SISWEB_OWNER].[MASMEDIA] m on --Join to get BaseEnglishMediaNumber.  Required in next join.
	m.MEDIANUMBER = a.MEDIANUMBER
--Get translated values
left outer join
(
Select 
BASEENGLISHMEDIANUMBER, 
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
SELECT m.BASEENGLISHMEDIANUMBER
      ,m.[LANGUAGEINDICATOR]
      ,m.[MEDIANUMBER]
FROM [SISWEB_OWNER].[MASMEDIA] m

) p
Pivot
(
Max([MEDIANUMBER]) 
For [LANGUAGEINDICATOR] in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
) pvt
) tr on tr.BASEENGLISHMEDIANUMBER = m.BASEENGLISHMEDIANUMBER
Group by 
a.IESYSTEMCONTROLNUMBER,
--cast(a.BEGINNINGRANGE as varchar(10)),
--cast(a.ENDRANGE as varchar(10)),
a.MEDIANUMBER
)
Select *
into #RecordsToString
From CTE;

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString';

--NCI
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID] 
ON #RecordsToString ([ID] ASC)
INCLUDE (IESYSTEMCONTROLNUMBER,MEDIANUMBER,[InsertDate])
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


--Insert into [SISSEARCH].[SERVICEIEMEDIA_2] 
--(
--	[ID]
--	--,[BeginRange]
--	--,[EndRange]
--	,[IESystemControlNumber]
--	,MediaNumber
--	,[InsertDate]
--)
--Select
--	a.ID,
--	--a.BeginRange,
--	--a.EndRange,
--	a.IESYSTEMCONTROLNUMBER,
--	coalesce(f.MEDIANUMBERString,'') As MEDIANUMBER,
--	min(a.InsertDate) InsertDate --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
--from  #RecordsToString a
--cross apply 
--(
--	SELECT  '[' + stuff
--	(
--		(SELECT '","'+ cast(MEDIANUMBER as varchar(MAX))        
--		FROM #RecordsToString as b 
--		where a.ID=b.ID
--		order by b.ID
--		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')   
--	,1,2,'') + '"'+']'     
--) f (MEDIANUMBERString)
--Group by 
--a.ID,
----a.BeginRange,
----a.EndRange,
--a.IESYSTEMCONTROLNUMBER,
--f.MEDIANUMBERString



--Change from xmlpath to string_agg method
--Drop table #RecordsToStringResult_C
Insert into [SISSEARCH].[SERVICEIEMEDIA_2] 
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
	a.IESYSTEMCONTROLNUMBER,
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
a.IESYSTEMCONTROLNUMBER



SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Target [SISSEARCH].[SERVICEIEMEDIA_2]';

SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
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