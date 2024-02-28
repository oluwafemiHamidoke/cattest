




CREATE  Procedure [SISSEARCH].[SMCS_2_LOAD] 
As
/*---------------
Date: 10-04-2017
Object Description:  Loading changed data into SISSEARCH.SMCS_2 from base tables
Exec [SISSEARCH].[SMCS_2_LOAD]
Truncate table [SISSEARCH].[SMCS_2]
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

Select Iesystemcontrolnumber 
into #DeletedRecords
from  [SISSEARCH].[SMCS_2]
Except 
Select IESYSTEMCONTROLNUMBER
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] 

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE = 'Deleted Records Detected';

-- Delete Idenified Deleted Records in Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete from 
[SISSEARCH].[SMCS_2] 
where  Iesystemcontrolnumber  in (Select Iesystemcontrolnumber From #DeletedRecords)

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records from Target [SISSEARCH].[SMCS_2]' ;

--Get Maximum insert date from Target	

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [SISSEARCH].[SMCS_2]
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
Select IESYSTEMCONTROLNUMBER
into #InsertRecords
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] 
where LASTMODIFIEDDATE > @LastInsertDate

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Detected #InsertRecords';

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_iesystemcontrolnumber 
    ON #InsertRecords(IESYSTEMCONTROLNUMBER)

--Delete Inserted records from Target 	
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete from [SISSEARCH].[SMCS_2]
where Iesystemcontrolnumber in
 (Select IESYSTEMCONTROLNUMBER from  #InsertRecords) 
 
SET @RowCount= @@RowCount  
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE = 'Deleted Inserted Records from Target [SISSEARCH].[SMCS_2]';
--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
Drop table #RecordsToString
End

;With CTE_SMCS_2 as
(
--lnkPartsiesnp Distinct 9,248,860 (2Min)
--lnkPartsiesnp + LNKMEDIAIEPART Distinct 9,190,684 (2Min)
--lnkPartsiesnp + LNKMEDIAIEPART + lnkiesmcs Distinct 16,708,514 (4.5 Min)
--lnkPartsiesnp + LNKMEDIAIEPART + lnkiesmcs + MASMEDIA Distinct  with Filters 16,708,514 (4.5 MIn)
--Load into ,Load into Temp and Create Index Took 5 in
--Total 40 Minutes
select distinct  a.IESYSTEMCONTROLNUMBER,
	a.IESYSTEMCONTROLNUMBER as id, 
	b.SMCSCOMPCODE as smcs,
	c.LASTMODIFIEDDATE [InsertDate]
FROM 	[SISWEB_OWNER_SHADOW].LNKPARTSIESNP a With(Nolock) --10M
inner join [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] c With(NolocK) --3M
 on a.IESYSTEMCONTROLNUMBER=c.IESYSTEMCONTROLNUMBER  
inner join #InsertRecords d --Add filter to limit to changed records
 on c.IESYSTEMCONTROLNUMBER=d.IESYSTEMCONTROLNUMBER 
inner join [SISWEB_OWNER].LNKIESMCS as b With(Nolock) --5.5M
 on a.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER
inner join [SISWEB_OWNER].[MASMEDIA]  e With(Nolock) --90K
 on e.MEDIANUMBER=c.MEDIANUMBER
where  e.MEDIASOURCE in ('A', 'C')
and a.SNPTYPE = 'P'
)
Select IESYSTEMCONTROLNUMBER,
 id,
 replace( --escape /
		replace( --escape "
			replace( --escape carriage return (ascii 13)
				replace( --escape form feed (ascii 12) 
					replace( --escape vertical tab (ascii 11)
						replace( --escape line feed (ascii 10)
							replace( --escape horizontal tab (ascii 09)
								replace( --escape backspace (ascii 08)
									replace( --escape \
										isnull(smcs,'')
									,'\', '\\')
								,char(8), ' ')
							,char(9), ' ')
						,char(10), ' ')
					,char(11), ' ')
				,char(12), ' ')
			,char(13), ' ')
			,'"', '\"')
		,'/', '\/') as smcs,
 InsertDate
into #RecordsToString
From CTE_SMCS_2;

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString';

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID] 
ON #RecordsToString ([id] ASC)
INCLUDE ([IESYSTEMCONTROLNUMBER],[smcs],[InsertDate])
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

--Records to String
--Below Script Ran 27 Min
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


Insert into [SISSEARCH].[SMCS_2] (Iesystemcontrolnumber,ID, smcs, InsertDate)
Select  
    a.IESYSTEMCONTROLNUMBER,
	a.id,
	coalesce(f.SMCSString,'') As SMCS,
	min(a.InsertDate) InsertDate --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from  #RecordsToString a
cross apply 
(
	SELECT  '[' + stuff
	(
		(SELECT '","' + cast(smcs as varchar(MAX))        
		FROM #RecordsToString as b 
		where a.id=b.id 
		order by b.id
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')   
	,1,2,'') + '"'+']'     
) f (SMCSString)
Group by 
a.IESYSTEMCONTROLNUMBER,
a.id,
f.SMCSString

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE = 'Inserted into Target [SISSEARCH].[SMCS_2]';

SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LOGID = @SPStartLogID,@DATAVALUE = @RowCount

DELETE FROM SISSEARCH.LOG WHERE DATEDIFF(DD, LogDateTime, GetDate())>30 and NameofSproc=@ProcName

END TRY

BEGIN CATCH 
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT= ERROR_LINE()

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC SISSEARCH.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error
END CATCH


End