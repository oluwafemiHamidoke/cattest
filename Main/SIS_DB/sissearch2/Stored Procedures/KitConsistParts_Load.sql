CREATE  Procedure [sissearch2].[KitConsistParts_Load] 
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
Select IESYSTEMCONTROLNUMBER 
into #DeletedRecords
from  [sissearch2].[KitConsistParts]
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
[sissearch2].[KitConsistParts] 
where  IESYSTEMCONTROLNUMBER  in (Select IESYSTEMCONTROLNUMBER From #DeletedRecords)

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records from Target [sissearch2].[KitConsistParts] ';

--Drop Temp
Drop Table #DeletedRecords

--Get Maximum insert date from Target	
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  @LASTINSERTDATE=coalesce(Max(INSERTDATE),'1900-01-01') From [sissearch2].[KitConsistParts]

--Print cast(getdate() as varchar(50)) + ' - Latest Insert Date in Target: ' + cast(@LASTINSERTDATE as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
Declare @Logmessage as varchar(50) = 'Latest Insert Date in Target '+cast (@LASTINSERTDATE as varchar(25))
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = @Logmessage , @LOGID = @StepLogID


--Identify Inserted records from Source
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

--Identify Inserted records from Source
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#InsertRecords') is not null
Begin 
 Drop table #InsertRecords
End

SELECT DISTINCT MS.IESystemControlNumber,
CASE	WHEN MS.LastModified_Date > PIR.LastModified_Date THEN MS.LastModified_Date
ELSE PIR.LastModified_Date END AS LastModified_Date	
INTO #InsertRecords
FROM [sis_shadow].[MediaSequence] MS
INNER JOIN [sis].[Part_IEPart_Relation] PIR ON PIR.IEPart_ID = MS.IEPart_ID
WHERE MS.LastModified_Date > @LASTINSERTDATE OR PIR.LastModified_Date > @LASTINSERTDATE

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Detected into #InsertRecords';

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_IESYSTEMCONTROLNUMBER 
    ON #InsertRecords(IESYSTEMCONTROLNUMBER) INCLUDE(LastModified_Date)

--Delete Inserted records from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
 	
Delete from [sissearch2].[KitConsistParts]
where IESYSTEMCONTROLNUMBER in
 (Select IESYSTEMCONTROLNUMBER from  #InsertRecords)
 
SET @RowCount= @@RowCount  
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Inserted Records from Target [sissearch2].[KitConsistParts]';

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
	Drop table #RecordsToString
End

;with CTE_KITCONSISTPART as
(
select 
    a.IESYSTEMCONTROLNUMBER as IESYSTEMCONTROLNUMBER,
	a.IESYSTEMCONTROLNUMBER as ID,	
	replace( --escape /
		replace( --escape "
			replace( --replace carriage return (ascii 13)
				replace( --replace form feed (ascii 12) 
					replace( --replace vertical tab (ascii 11)
						replace( --replace line feed (ascii 10)
							replace( --replace horizontal tab (ascii 09)
								replace( --replace backspace (ascii 08)
									replace( --escape \
										--isnull(k.PARTNUMBER,'')+':'+isnull(k.KITPARTNUMBER,'')+':'+isnull(k.KITPARTNAME, '')
										isnull(d.Part_Number ,'')+':'+isnull(i.Number,'')+':'+isnull(i.[Name], '')
									,'\', '\\')
								,char(8), ' ')
							,char(9), ' ')
						,char(10), ' ')
					,char(11), ' ')
				,char(12), ' ')
			,char(13), ' ')
			,'"', '\"')
		,'/', '\/') as KITCONSISTPART,
   g.LastModified_Date INSERTDATE
from [sis_shadow].[MediaSequence] a With(NolocK)
--inner join sis.IEPart b on a.IEPart_ID=b.IEPart_ID
inner join sis.Part_IEPart_Relation c on c.IEPart_ID=a.IEPart_ID
inner join sis.Part d on c.Part_ID=d.Part_ID
inner join sis.MediaSection e on e.MediaSection_ID=a.MediaSection_ID
inner join sis.Media f on f.Media_ID=e.Media_ID and f.Source in ('A','C')
inner join #InsertRecords g --Add filter to limit to changed records
	on g.IESYSTEMCONTROLNUMBER=a.IESYSTEMCONTROLNUMBER
inner join sis.Kit_ParentPart_Relation h on d.Part_ID=h.ParentPart_ID
inner join sis.Kit i on i.Kit_ID=h.Kit_ID
where d.Part_Number<>''
)
Select * 
into #RecordsToString
From CTE_KITCONSISTPART;

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to #RecordsToString';

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID] 
ON #RecordsToString ([ID] ASC)
INCLUDE ([IESYSTEMCONTROLNUMBER],[KITCONSISTPART],[INSERTDATE])
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

--29 Minutes to Get to this Point

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  
    a.IESYSTEMCONTROLNUMBER,
	a.ID,
	coalesce(f.KITCONSISTPARTString,'') As KITCONSISTPART,
	min(a.INSERTDATE) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into  #RecordsToStringResult
from  #RecordsToString a
cross apply 
(
	SELECT  '[' + stuff
	(
		(SELECT '","' + cast(KITCONSISTPART as varchar(MAX))        
		FROM #RecordsToString as b 
		where a.ID=b.ID 
		order by b.ID
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')   
	,1,2,'') + '"'+']'     
) f (KITCONSISTPARTString)
Group by 
a.IESYSTEMCONTROLNUMBER,
a.ID,
f.KITCONSISTPARTString

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
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into [sissearch2].[KitConsistParts] (IESYSTEMCONTROLNUMBER,ID,KITCONSISTPART,INSERTDATE)
Select IESYSTEMCONTROLNUMBER,ID,KITCONSISTPART,INSERTDATE from #RecordsToStringResult

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Insert into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Insert into Target [sissearch2].[KitConsistParts]';

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
