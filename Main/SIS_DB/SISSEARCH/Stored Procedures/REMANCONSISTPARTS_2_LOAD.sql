CREATE  Procedure [SISSEARCH].[REMANCONSISTPARTS_2_LOAD] 
As
/*---------------
Date: 10-04-2017
Object Description:  Loading changed data into SISSEARCH.REMANCONSISTPARTS_2 from base tables
Exec [SISSEARCH].[REMANCONSISTPARTS_2_LOAD]
Truncate table [SISSEARCH].[REMANCONSISTPARTS_2]
---------------*/

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

EXEC @SPStartLogID = SISSEARCH.WriteLog @TIME = @SPStartTime, @NAMEOFSPROC = @ProcName;

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#DeletedRecords') is not null
  Begin 
     Drop table #DeletedRecords
  End
Select IESYSTEMCONTROLNUMBER 
into #DeletedRecords
from  [SISSEARCH].[REMANCONSISTPARTS_2]
Except 
Select IESYSTEMCONTROLNUMBER
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] 

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records Detected';

-- Delete Idenified Deleted Records in Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete from 
[SISSEARCH].[REMANCONSISTPARTS_2] 
where  IESYSTEMCONTROLNUMBER  in (Select IESYSTEMCONTROLNUMBER From #DeletedRecords)

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records from Target [SISSEARCH].[REMANCONSISTPARTS_2] ';

--Drop Temp
Drop Table #DeletedRecords

--Get Maximum insert date from Target	
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  @LASTINSERTDATE=coalesce(Max(INSERTDATE),'1900-01-01') From [SISSEARCH].[REMANCONSISTPARTS_2]

--Print cast(getdate() as varchar(50)) + ' - Latest Insert Date in Target: ' + cast(@LASTINSERTDATE as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
Declare @Logmessage as varchar(50) = 'Latest Insert Date in Target '+cast (@LASTINSERTDATE as varchar(25))
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = @Logmessage , @LOGID = @StepLogID


--Identify Inserted records from Source
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

 If Object_ID('Tempdb..#InsertRecords') is not null
Begin 
 Drop table #InsertRecords
End
  Select IESYSTEMCONTROLNUMBER
  into #InsertRecords
  from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] 
  where LASTMODIFIEDDATE > @LASTINSERTDATE

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Detected into #InsertRecords';

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_IESYSTEMCONTROLNUMBER 
    ON #InsertRecords(IESYSTEMCONTROLNUMBER)

--Delete Inserted records from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
 	
Delete from [SISSEARCH].[REMANCONSISTPARTS_2]
where IESYSTEMCONTROLNUMBER in
 (Select IESYSTEMCONTROLNUMBER from  #InsertRecords)
 
SET @RowCount= @@RowCount  
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Inserted Records from Target [SISSEARCH].[REMANCONSISTPARTS_2]';

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
	Drop table #RecordsToString
End

;with CTE_REMANCONSISTPART as
(
--LnkMediaPart 3,139,335
--LnkMediaPart + LNKPARTSIESNP 10,122,059
--LnkMediaPart + LNKPARTSIESNP distinct 9,190,684
--LnkMediaPart + LNKPARTSIESNP + MasMedia distinct 2,838,301
--LnkMediaPart + LNKPARTSIESNP + MasMedia + LNKCONSISTLIST distinct 2,838,188 (Some IE's are not found in LNKCONSISTLIST)
--LnkMediaPart + LNKPARTSIESNP + MasMedia + LNKCONSISTLIST 63,473,062 (Loads into temp in 2min 54sec)
select 
    b.IESYSTEMCONTROLNUMBER,
	b.IESYSTEMCONTROLNUMBER as ID,	
	replace( --escape /
		replace( --escape "
			replace( --replace carriage return (ascii 13)
				replace( --replace form feed (ascii 12) 
					replace( --replace vertical tab (ascii 11)
						replace( --replace line feed (ascii 10)
							replace( --replace horizontal tab (ascii 09)
								replace( --replace backspace (ascii 08)
									replace( --escape \
										isnull(k.PARTNUMBER,'')+':'+isnull(k.RELATEDPARTNUMBER,'')+':'+isnull(k.RELATEDPARTNAME, '')
									,'\', '\\')
								,char(8), ' ')
							,char(9), ' ')
						,char(10), ' ')
					,char(11), ' ')
				,char(12), ' ')
			,char(13), ' ')
			,'"', '\"')
		,'/', '\/') as REMANCONSISTPART,
   b.LASTMODIFIEDDATE INSERTDATE
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] b With(NolocK)--3M
--inner join	[SISWEB_OWNER].LNKPARTSIESNP a With(Nolock) --10M
--	on a.IESYSTEMCONTROLNUMBER=b.IESYSTEMCONTROLNUMBER and a.MEDIANUMBER=b.MEDIANUMBER
inner join [SISWEB_OWNER].[MASMEDIA] e with(Nolock)
	on e.MEDIANUMBER=b.MEDIANUMBER and e.[MEDIASOURCE]='A'  --Authoring 
inner join #InsertRecords c --Add filter to limit to changed records
	on c.IESYSTEMCONTROLNUMBER=b.IESYSTEMCONTROLNUMBER
inner join [SISWEB_OWNER_SHADOW].LNKCONSISTLIST d With(Nolock) --56M
	on b.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER
inner join [sis].[vw_RelatedPartsNoKits] k
	on k.PARTNUMBER = d.PARTNUMBER and k.TYPEINDICATOR = 'R'
--Where a.SNPType = 'P'
)
Select * 
into #RecordsToString
From CTE_REMANCONSISTPART;

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to #RecordsToString';

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID] 
ON #RecordsToString ([ID] ASC)
INCLUDE ([IESYSTEMCONTROLNUMBER],[REMANCONSISTPART],[INSERTDATE])
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

--29 Minutes to Get to this Point

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  
    a.IESYSTEMCONTROLNUMBER,
	a.ID,
	coalesce(f.REMANCONSISTPARTString,'') As REMANCONSISTPART,
	min(a.INSERTDATE) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into  #RecordsToStringResult
from  #RecordsToString a
cross apply 
(
	SELECT  '[' + stuff
	(
		(SELECT '","' + cast(REMANCONSISTPART as varchar(MAX))        
		FROM #RecordsToString as b 
		where a.ID=b.ID 
		order by b.ID
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')   
	,1,2,'') + '"'+']'     
) f (REMANCONSISTPARTString)
Group by 
a.IESYSTEMCONTROLNUMBER,
a.ID,
f.REMANCONSISTPARTString

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
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

Insert into [SISSEARCH].[REMANCONSISTPARTS_2] (IESYSTEMCONTROLNUMBER,ID,REMANCONSISTPART,INSERTDATE)
Select IESYSTEMCONTROLNUMBER,ID,REMANCONSISTPART,INSERTDATE from #RecordsToStringResult

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Insert into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Insert into Target [SISSEARCH].[REMANCONSISTPARTS_2]';

--Drop temp
Drop table #RecordsToStringResult


/*
----------------------------------------------------------
Conversion
----------------------------------------------------------
*/

--Print cast(getdate() as varchar(50)) + ' - Conversion Start'

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

;with CTE_REMANCONSISTPART as
(
select
    b.IESYSTEMCONTROLNUMBER,
	b.IESYSTEMCONTROLNUMBER as ID,	
	replace( --escape /
		replace( --escape "
			replace( --escape carriage return (ascii 13)
				replace( --escape form feed (ascii 12) 
					replace( --escape vertical tab (ascii 11)
						replace( --escape line feed (ascii 10)
							replace( --escape horizontal tab (ascii 09)
								replace( --escape backspace (ascii 08)
									replace( --escape \
										isnull(k.PARTNUMBER,'')+':'+isnull(k.RELATEDPARTNUMBER,'')+':'+isnull(k.RELATEDPARTNAME, '')
									,'\', '\\')
								,char(8), ' ')
							,char(9), ' ')
						,char(10), ' ')
					,char(11), ' ')
				,char(12), ' ')
			,char(13), ' ')
			,'"', '\"')
		,'/', '\/') as REMANCONSISTPART,
   b.LASTMODIFIEDDATE INSERTDATE
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] b With(NolocK)--3M
--inner join	[SISWEB_OWNER].LNKPARTSIESNP a With(Nolock) --10M
--	on a.IESYSTEMCONTROLNUMBER=b.IESYSTEMCONTROLNUMBER and a.MEDIANUMBER=b.MEDIANUMBER
inner join [SISWEB_OWNER].[MASMEDIA] e with(Nolock)
	on e.MEDIANUMBER=b.MEDIANUMBER and e.[MEDIASOURCE] ='C'  --Conversion
inner join #InsertRecords c --Add filter to limit to changed records
	on c.IESYSTEMCONTROLNUMBER=b.IESYSTEMCONTROLNUMBER
inner join [SISWEB_OWNER_SHADOW].LNKCONSISTLIST d With(Nolock) --56M
	on d.IESYSTEMCONTROLNUMBER  = b.BASEENGCONTROLNO-- Conversion records relate to LNKCONSISTLIST on baseengcontrolno instead of iesystemcontrolnumber
inner join [sis].[vw_RelatedPartsNoKits] k
	on k.PARTNUMBER = d.PARTNUMBER and k.TYPEINDICATOR = 'R'
--where a.SNPType = 'P'
)
Select * 
into #RecordsToString_C
From CTE_REMANCONSISTPART;

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString_C';

--Drop temp
Drop Table #InsertRecords

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID] 
ON #RecordsToString_C ([ID] ASC)
INCLUDE ([IESYSTEMCONTROLNUMBER],[REMANCONSISTPART],[INSERTDATE])
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  
    a.IESYSTEMCONTROLNUMBER,
	a.ID,
	coalesce(f.REMANCONSISTPARTString,'') As REMANCONSISTPART,
	min(a.INSERTDATE) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into  #RecordsToStringResult_C
from  #RecordsToString_C a
cross apply 
(
	SELECT  '[' + stuff
	(
		(SELECT '","' + cast(REMANCONSISTPART as varchar(MAX))        
		FROM #RecordsToString_C as b 
		where a.ID=b.ID 
		order by b.ID
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')   
	,1,2,'') + '"'+']'     
) f (REMANCONSISTPARTString)
Group by 
a.IESYSTEMCONTROLNUMBER,
a.ID,
f.REMANCONSISTPARTString

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult_C Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Temp RecordsToStringResult_C';

--Drop temp table
Drop Table #RecordsToString_C

--Add pkey to result
Alter Table #RecordsToStringResult_C Alter Column ID varchar(50) Not NULL
ALTER TABLE #RecordsToStringResult_C ADD PRIMARY KEY CLUSTERED (ID) 
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult_C'

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into [SISSEARCH].[REMANCONSISTPARTS_2] (IESYSTEMCONTROLNUMBER,ID,REMANCONSISTPART,INSERTDATE)
Select IESYSTEMCONTROLNUMBER,ID,REMANCONSISTPART,INSERTDATE from #RecordsToStringResult_C

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Insert into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Insert into Target [SISSEARCH].[REMANCONSISTPARTS_2]';

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