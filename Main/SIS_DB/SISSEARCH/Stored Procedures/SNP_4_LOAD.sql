




CREATE  Procedure [SISSEARCH].[SNP_4_LOAD] 
As
/*---------------
Date: 10-10-2019
Object Description:  Loading changed data into SISSEARCH.SNP_4 from base tables
Exec [SISSEARCH].[SNP_4_LOAD]
Truncate table [SISSEARCH].[SNP_4]
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
from  [SISSEARCH].[SNP_4]
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
[SISSEARCH].[SNP_4] 
where  Iesystemcontrolnumber  in (Select Iesystemcontrolnumber From #DeletedRecords)

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records from Target [SISSEARCH].[SNP_4]';
--Get Maximum insert date from Target	

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [SISSEARCH].[SNP_4]
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
@LOGMESSAGE = 'Inserted Records Detected #InsertRecords';

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_iesystemcontrolnumber 
    ON #InsertRecords(IESYSTEMCONTROLNUMBER)

--Delete Inserted records from Target 	
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete from [SISSEARCH].[SNP_4]
where Iesystemcontrolnumber in
 (Select IESYSTEMCONTROLNUMBER from  #InsertRecords)  

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Inserted Records from Target [SISSEARCH].[SNP_4]';

--Stage R2S Set

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
Drop table #RecordsToString
End

;with CTE_SNP_4 as
(
Select distinct
a.IESYSTEMCONTROLNUMBER,
a.IESYSTEMCONTROLNUMBER as ID, 
a.SNP,
c.LASTMODIFIEDDATE InsertDate,
cast(a.BEGINNINGRANGE as varchar(10)) BEGINNINGRANGE,
cast(a.ENDRANGE as varchar(10)) ENDRANGE
FROM 	[SISWEB_OWNER_SHADOW].LNKPARTSIESNP a With(Nolock) --10M
inner join [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] c With(NolocK) --3M
 on a.IESYSTEMCONTROLNUMBER =c.IESYSTEMCONTROLNUMBER  
inner join #InsertRecords d --Add filter to limit to changed records
 on c.IESYSTEMCONTROLNUMBER=d.IESYSTEMCONTROLNUMBER
inner join [SISWEB_OWNER].[MASMEDIA] b With(NolocK) --90K
 on b.MEDIANUMBER = c.MEDIANUMBER
where b.MEDIASOURCE in ('A', 'C')
)
Select IESYSTEMCONTROLNUMBER,
  ID,
  	replace( --escape /
		replace( --escape "
			replace( --escape carriage return (ascii 13)
				replace( --escape form feed (ascii 12) 
					replace( --escape vertical tab (ascii 11)
						replace( --escape line feed (ascii 10)
							replace( --escape horizontal tab (ascii 09)
								replace( --escape backspace (ascii 08)
									replace( --escape \
										isnull(SNP,'')
									,'\', '\\')
								,char(8), ' ')
							,char(9), ' ')
						,char(10), ' ')
					,char(11), ' ')
				,char(12), ' ')
			,char(13), ' ')
			,'"', '\"')
		,'/', '\/') as SNP,
InsertDate,
cast(BEGINNINGRANGE as varchar(10)) BEGINNINGRANGE,
cast(ENDRANGE as varchar(10)) ENDRANGE
into #RecordsToString
From CTE_SNP_4;

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString';

--NCI
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID] 
ON #RecordsToString ([ID], [SNP], BEGINNINGRANGE, ENDRANGE)
INCLUDE (IESYSTEMCONTROLNUMBER,[InsertDate])
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'






/*
This section is adding a suffix to the ID to ensure that we do not have over 3000 begin/end range combinations
for the same ID.  The first group of 3000 has no ID suffix.  The second group of 3000 has _1 suffix. Then _2, etc...
*/

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select
case 
	when RowRank < 3000 then x.ID
	else x.ID + '_' + cast(RowRank / 3000 as varchar(50))
end ID, --First 3000 records get no suffix.  Subsequent 3000 get suffixed with _1.
x.IESYSTEMCONTROLNUMBER, 
r.SNP,
x.BEGINNINGRANGE,
x.ENDRANGE,
r.InsertDate,
x.RowRank
Into #RecordsToString_Ranked
From 
(
	--Get
	Select 
	ID,
	IESYSTEMCONTROLNUMBER, 
	BEGINNINGRANGE,
	ENDRANGE,
	Row_Number() Over (Partition By IESYSTEMCONTROLNUMBER Order BY cast(BEGINNINGRANGE as bigint)) - 1 RowRank --Change to zero base
	From #RecordsToString
	--Where IESYSTEMCONTROLNUMBER = 'REBE50770001' --Example of IE with over 3000 Begin/End combinations - REBE50770001
	Group by ID, IESYSTEMCONTROLNUMBER, BEGINNINGRANGE, ENDRANGE
) x
--Get the SNP & InsertDate
Inner Join #RecordsToString r on 
	x.IESYSTEMCONTROLNUMBER = r.IESYSTEMCONTROLNUMBER and 
	x.BEGINNINGRANGE = r.BEGINNINGRANGE and
	x.ENDRANGE = r.ENDRANGE
	
SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to #RecordsToString_Ranked Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString_Ranked';



SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

SELECT [ID],
IESYSTEMCONTROLNUMBER,
ISNULL('["' + STRING_AGG(cast(SNP as varchar(max)),'","') WITHIN GROUP (ORDER BY SNP) + '"]','[]') AS [serialNumbers.serialNumberPrefixes],
BEGINNINGRANGE as [serialNumbers.beginningRange],
ENDRANGE as [serialNumbers.endRange],
max(InsertDate) [InsertDate]
Into #SNPArray
FROM #RecordsToString_Ranked
GROUP BY 
ID,
IESYSTEMCONTROLNUMBER,
BEGINNINGRANGE,
ENDRANGE

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to #SNPArray: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to Temp SNPArray';


--3 Minutes To Get tothis point
--Records to String
--16 Minutes to run below script (9,190,684)

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into [SISSEARCH].[SNP_4] (ID, Iesystemcontrolnumber,SerialNumbers,InsertDate)
SELECT ID,
IESYSTEMCONTROLNUMBER,
(
	Select 
	JSON_Query(b.[serialNumbers.serialNumberPrefixes]) [serialNumberPrefixes], --JSON_Query function ensures that quotes are not escaped
	cast(b.[serialNumbers.beginningRange] as int) [beginRange],
	cast(b.[serialNumbers.endRange] as int) [endRange]
	From #SNPArray b
	where a.ID = b.ID
	For JSON Path
) SerialNumbers,
max(InsertDate) InsertDate
FROM #SNPArray a
--where ID = 'i06912346'
GROUP BY 
ID,
IESYSTEMCONTROLNUMBER

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target [SISSEARCH].[SNP_4] Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Target [SISSEARCH].[SNP_4]';

--Finish

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