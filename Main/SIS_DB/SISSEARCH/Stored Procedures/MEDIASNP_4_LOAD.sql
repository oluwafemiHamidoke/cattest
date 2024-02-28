





CREATE  Procedure [SISSEARCH].[MEDIASNP_4_LOAD] 
As
/*---------------
Date: 10-10-2017
Object Description:  Loading changed data into SISSEARCH.MEDIASNP_4 from base tables
Modifiy Date: 20210311 - Davide. Changed MEDIAUPDATEDDATE to LASTMODDIFIEDDATE, see: https://dev.azure.com/sis-cat-com/sis2-ui/_workitems/edit/9566/
Exec [SISSEARCH].[MEDIASNP_4_LOAD]
Truncate table [SISSEARCH].[MEDIASNP_4]
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
Select [BaseEngMediaNumber]
into #DeletedRecords
from  [SISSEARCH].[MEDIASNP_4]
Except 
Select a.[BASEENGLISHMEDIANUMBER]
from [SISWEB_OWNER].[MASMEDIA] a
--inner join [SISWEB_OWNER].[LNKMEDIASNP] b on  a.[BASEENGLISHMEDIANUMBER]=b.MEDIANUMBER and b.INFOTYPEID not in(16,17,18,19,20,21,22,33,34,58) 
inner join [SISWEB_OWNER].[LNKMEDIASNP] b on  a.[BASEENGLISHMEDIANUMBER]=b.MEDIANUMBER  and b.INFOTYPEID not in (Select [INFOTYPEID] from SISSEARCH.REF_EXCLUDEINFOTYPE where Search2_Status = 1 and [Selective_Exclude] = 0)
where not exists(
		select 1 from SISSEARCH.REF_SELECTIVE_EXCLUDEINFOTYPE 
	where INFOTYPEID = b.INFOTYPEID and [Excluded_Values] = a.MEDIAORIGIN
	)
SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records Detected';

-- Delete Idenified Deleted Records in Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [SISSEARCH].[MEDIASNP_4] 
From [SISSEARCH].[MEDIASNP_4] a
inner join #DeletedRecords d on a.[BaseEngMediaNumber] = d.[BaseEngMediaNumber]

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records from Target [SISSEARCH].[MEDIASNP_4]';

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	
Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [SISSEARCH].[MEDIASNP_4]
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
		a.[BASEENGLISHMEDIANUMBER]
	into #InsertRecords
	from [SISWEB_OWNER].[MASMEDIA] a
	--inner join [SISWEB_OWNER].[LNKMEDIASNP] b on  a.[BASEENGLISHMEDIANUMBER]=b.MEDIANUMBER  and b.INFOTYPEID not in(16,17,18,19,20,21,22,33,34,58) 
	inner join [SISWEB_OWNER].[LNKMEDIASNP] b on  a.[BASEENGLISHMEDIANUMBER]=b.MEDIANUMBER  and b.INFOTYPEID not in (Select [INFOTYPEID] from SISSEARCH.REF_EXCLUDEINFOTYPE where Search2_Status = 1 and [Selective_Exclude] = 0)
	where a.LASTMODIFIEDDATE > @LastInsertDate --Update the reference date.  Should be the date when the records was inserted.
	and not exists(
		select 1 from SISSEARCH.REF_SELECTIVE_EXCLUDEINFOTYPE 
	where INFOTYPEID = b.INFOTYPEID and [Excluded_Values] = a.MEDIAORIGIN
	)
	Group by a.[BASEENGLISHMEDIANUMBER]
SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Detected #InsertRecords';

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_iesystemcontrolnumber 
    ON #InsertRecords([BASEENGLISHMEDIANUMBER])

--Delete Inserted records from Target 	
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [SISSEARCH].[MEDIASNP_4] 
From [SISSEARCH].[MEDIASNP_4] a
inner join #InsertRecords d on a.[BaseEngMediaNumber] = d.[BASEENGLISHMEDIANUMBER]

SET @RowCount= @@RowCount   
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Inserted Records from Target [SISSEARCH].[MEDIASNP_4]';

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
Drop table #RecordsToString
End

select 
a.BASEENGLISHMEDIANUMBER as [ID], 
a.BASEENGLISHMEDIANUMBER,
b.SNP,
min(a.LASTMODIFIEDDATE) [InsertDate], --Must be updated to insert date
cast(b.BEGINNINGRANGE as varchar(10)) BEGINNINGRANGE,
cast(b.ENDRANGE as varchar(10)) ENDRANGE
into #RecordsToString
From [SISWEB_OWNER].[MASMEDIA] a
inner join [SISWEB_OWNER].[LNKMEDIASNP] b on  a.[BASEENGLISHMEDIANUMBER]=b.MEDIANUMBER  and b.INFOTYPEID not in (Select [INFOTYPEID] from SISSEARCH.REF_EXCLUDEINFOTYPE where Search2_Status = 1 and [Selective_Exclude] = 0)
inner join #InsertRecords i on i.BASEENGLISHMEDIANUMBER = a.BASEENGLISHMEDIANUMBER
Where a.LANGUAGEINDICATOR = 'E' --Limit to english
and b.TYPEINDICATOR = 'S' --SNP
and not exists(
		select 1 from SISSEARCH.REF_SELECTIVE_EXCLUDEINFOTYPE 
	where INFOTYPEID = b.INFOTYPEID and [Excluded_Values] = a.MEDIAORIGIN
	)
Group by 
	a.BASEENGLISHMEDIANUMBER,
	b.SNP,
	cast(b.BEGINNINGRANGE as varchar(10)),
	cast(b.ENDRANGE as varchar(10))


SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to #RecordsToString: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to #RecordsToString';

--NCI
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID] 
ON #RecordsToString ([ID], [SNP], BEGINNINGRANGE, ENDRANGE)
INCLUDE (BASEENGLISHMEDIANUMBER,[InsertDate])
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
x.BASEENGLISHMEDIANUMBER, 
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
	BASEENGLISHMEDIANUMBER, 
	BEGINNINGRANGE,
	ENDRANGE,
	Row_Number() Over (Partition By BASEENGLISHMEDIANUMBER Order BY cast(BEGINNINGRANGE as bigint)) - 1 RowRank --Change to zero base
	From #RecordsToString
	--Where IESYSTEMCONTROLNUMBER = 'REBE50770001' --Example of IE with over 3000 Begin/End combinations - REBE50770001
	Group by ID, BASEENGLISHMEDIANUMBER, BEGINNINGRANGE, ENDRANGE
) x
--Get the SNP & InsertDate
Inner Join #RecordsToString r on 
	x.BASEENGLISHMEDIANUMBER = r.BASEENGLISHMEDIANUMBER and 
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
BASEENGLISHMEDIANUMBER,
ISNULL('["' + STRING_AGG(cast(SNP as varchar(max)),'","') WITHIN GROUP (ORDER BY SNP) + '"]','[]') AS [serialNumbers.serialNumberPrefixes],
BEGINNINGRANGE as [serialNumbers.beginningRange],
ENDRANGE as [serialNumbers.endRange],
max(InsertDate) [InsertDate]
Into #SNPArray
FROM #RecordsToString_Ranked
GROUP BY 
ID,
BASEENGLISHMEDIANUMBER,
BEGINNINGRANGE,
ENDRANGE

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to #SNPArray: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to #SNPArray';

Insert into [SISSEARCH].[MEDIASNP_4] ([BaseEngMediaNumber],[ID],[SerialNumbers],InsertDate)
SELECT 
BASEENGLISHMEDIANUMBER,
ID,
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
GROUP BY 
ID,
BASEENGLISHMEDIANUMBER

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to [SISSEARCH].[MEDIASNP_4]: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Target [SISSEARCH].[MEDIASNP_4]';

--Complete

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