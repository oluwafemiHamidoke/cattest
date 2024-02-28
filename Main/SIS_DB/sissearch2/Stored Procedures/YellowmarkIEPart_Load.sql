
CREATE  Procedure [sissearch2].[YellowmarkIEPart_Load] 
As

Begin

BEGIN TRY

SET NOCOUNT ON

Declare @LASTINSERTDATE Datetime 

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
from  [sissearch2].[YellowmarkIEPart]
Except 
Select IESystemControlNumber
from [sis_shadow].[MediaSequence]
--[SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] 

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records Detected';

-- Delete Idenified Deleted Records in Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete from 
[sissearch2].[YellowmarkIEPart]
where  IESystemControlNumber  in (Select IESystemControlNumber From #DeletedRecords)

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records from Target [sissearch2].[YellowmarkIEPart] ';

--Drop Temp
Drop Table #DeletedRecords

--Get Maximum insert date from Target	
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  @LASTINSERTDATE=coalesce(Max(INSERTDATE),'1900-01-01') From  [sissearch2].[YellowmarkIEPart]

--Print cast(getdate() as varchar(50)) + ' - Latest Insert Date in Target: ' + cast(@LASTINSERTDATE as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
Declare @Logmessage as varchar(50) = 'Latest Insert Date in Target '+cast (@LASTINSERTDATE as varchar(25))
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = @Logmessage , @LOGID = @StepLogID


--Identify Inserted records from Source
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#InsertRecords') is not null
Begin 
 Drop table #InsertRecords
End

SELECT DISTINCT MS.IESystemControlNumber,
CASE	WHEN MS.LastModified_Date > IP.LastModified_Date THEN MS.LastModified_Date
ELSE IP.LastModified_Date END AS LastModified_Date	
INTO #InsertRecords
FROM [sis_shadow].[MediaSequence] MS
INNER JOIN [sis].[IEPart] IP ON IP.IEPart_ID = MS.IEPart_ID
WHERE MS.LastModified_Date > @LASTINSERTDATE OR IP.LastModified_Date > @LASTINSERTDATE

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Detected into #InsertRecords';

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_IESYSTEMCONTROLNUMBER 
    ON #InsertRecords(IESystemControlNumber) INCLUDE(LastModified_Date)

--Delete Inserted records from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
 	
Delete from [sissearch2].[YellowmarkIEPart]
where IESystemControlNumber in
 (Select IESystemControlNumber from  #InsertRecords)
 
SET @RowCount= @@RowCount  
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Inserted Records from Target [sissearch2].[YellowmarkIEPart]';

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
	Drop table #RecordsToString
End

;with CTE_YELLOWMARKIEPART as
(
select 
    a.IESystemControlNumber,
	a.IESystemControlNumber as ID,	
	replace( --escape /
		replace( --escape "
			replace( --replace carriage return (ascii 13)
				replace( --replace form feed (ascii 12) 
					replace( --replace vertical tab (ascii 11)
						replace( --replace line feed (ascii 10)
							replace( --replace horizontal tab (ascii 09)
								replace( --replace backspace (ascii 08)
									replace( --escape \
										isnull(b.Part_Number,'')+':'+isnull(e.Related_Part_Number,'')+':'+isnull(e.Related_Part_Name, '')
									,'\', '\\')
								,char(8), ' ')
							,char(9), ' ')
						,char(10), ' ')
					,char(11), ' ')
				,char(12), ' ')
			,char(13), ' ')
			,'"', '\"')
		,'/', '\/') as YELLOWMARKIEPART,
   g.LastModified_Date INSERTDATE
from  [sis_shadow].[MediaSequence] a With(NolocK)
inner join sis.IEPart f on a.IEPart_ID = f.IEPart_ID
inner join sis.Part b on b.Part_ID=f.Part_ID and Org_Code='CAT'
inner join sis.MediaSection c on a.MediaSection_ID=c.MediaSection_ID
inner join sis.Media d on c.Media_ID=d.Media_ID and d.Source in ('A','C')
inner join #InsertRecords g --Add filter to limit to changed records
	on g.IESystemControlNumber=a.IESystemControlNumber
inner join sis.vw_RelatedPartsNoKits_2 e on b.Part_Number=e.Part_Number 
and e.Type_Indicator in ('CL','Y') and e.Language_Tag='en-US'
)
Select * 
into #RecordsToString
From CTE_YELLOWMARKIEPART;

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to #RecordsToString';

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID] 
ON #RecordsToString ([ID] ASC)
INCLUDE ([IESystemControlNumber],[YELLOWMARKIEPART],[INSERTDATE])
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

--29 Minutes to Get to this Point

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  
    a.IESystemControlNumber,
	a.ID,
	coalesce(f.YELLOWMARKIEPARTString,'') As YELLOWMARKIEPART,
	min(a.INSERTDATE) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into  #RecordsToStringResult
from  #RecordsToString a
cross apply 
(
	SELECT  '[' + stuff
	(
		(SELECT '","' + cast(YELLOWMARKIEPART as varchar(MAX))        
		FROM #RecordsToString as b 
		where a.ID=b.ID 
		order by b.ID
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')   
	,1,2,'') + '"'+']'     
) f (YELLOWMARKIEPARTString)
Group by 
a.IESystemControlNumber,
a.ID,
f.YELLOWMARKIEPARTString

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Temp RecordsToStringResult';

--Drop temp table
Drop Table #RecordsToString

--Add pkey to result
Alter Table #RecordsToStringResult Alter Column ID varchar(50) Not NULL
ALTER TABLE #RecordsToStringResult ADD PRIMARY KEY CLUSTERED (ID) 
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into [sissearch2].[YellowmarkIEPart] (IESystemControlNumber,ID,YELLOWMARKIEPART,INSERTDATE)
Select IESystemControlNumber,ID,YELLOWMARKIEPART,INSERTDATE from #RecordsToStringResult

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Insert into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Insert into Target [sissearch2].[YellowmarkIEPart]';

--Drop temp
Drop table #RecordsToStringResult

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