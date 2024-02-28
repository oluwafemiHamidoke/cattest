CREATE  Procedure [SISSEARCH].[MEDIAINFOTYPE_2_LOAD] 
As
/*---------------
Date: 10-10-2017
Object Description:  Loading changed data into SISSEARCH.MEDIAINFOTYPE_2 from base tables
Modifiy Date: 20210311 - Davide. Changed MEDIAUPDATEDDATE to LASTMODDIFIEDDATE, see: https://dev.azure.com/sis-cat-com/sis2-ui/_workitems/edit/9566/
Exec [SISSEARCH].[MEDIAINFOTYPE_2_LOAD]
Truncate table [SISSEARCH].[MEDIAINFOTYPE_2]
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
	[BaseEngMediaNumber]
into #DeletedRecords
from  [SISSEARCH].[MEDIAINFOTYPE_2]
Except 
Select
	a.[BASEENGLISHMEDIANUMBER]
from [SISWEB_OWNER].[MASMEDIA] a
--inner join [SISWEB_OWNER].[LNKMEDIASNP] b on  a.[BASEENGLISHMEDIANUMBER]=b.MEDIANUMBER and b.INFOTYPEID not in(16,17,18,19,20,21,22,33,34,58) 
inner join [SISWEB_OWNER].[LNKMEDIASNP] b on  a.[BASEENGLISHMEDIANUMBER]=b.MEDIANUMBER and b.INFOTYPEID not in (SELECT [InfoTypeID] FROM [SISSEARCH].[REF_EXCLUDEINFOTYPE] where [Media] = 1 and [Search2_Status] = 1 and [Selective_Exclude] = 0) 
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

Delete [SISSEARCH].[MEDIAINFOTYPE_2] 
From [SISSEARCH].[MEDIAINFOTYPE_2] a
inner join #DeletedRecords d on a.[BaseEngMediaNumber] = d.[BaseEngMediaNumber]

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records from Target [SISSEARCH].[MEDIAINFOTYPE_2]';

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	
Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [SISSEARCH].[MEDIAINFOTYPE_2]
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
	--inner join [SISWEB_OWNER].[LNKMEDIASNP] b on  a.[BASEENGLISHMEDIANUMBER]=b.MEDIANUMBER and b.INFOTYPEID not in(16,17,18,19,20,21,22,33,34,58) 
	inner join [SISWEB_OWNER].[LNKMEDIASNP] b on  a.[BASEENGLISHMEDIANUMBER]=b.MEDIANUMBER and b.INFOTYPEID not in (SELECT [InfoTypeID] FROM [SISSEARCH].[REF_EXCLUDEINFOTYPE] where [Media] = 1 and [Search2_Status] = 1 and [Selective_Exclude] = 0)  
	where a.LASTMODIFIEDDATE > @LastInsertDate --Update the reference date.  Should be the date when the records was inserted.
	and not exists(
		select 1 from SISSEARCH.REF_SELECTIVE_EXCLUDEINFOTYPE 
	where INFOTYPEID = b.INFOTYPEID and [Excluded_Values] = a.MEDIAORIGIN
	)
	group by a.[BASEENGLISHMEDIANUMBER]

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

Delete [SISSEARCH].[MEDIAINFOTYPE_2] 
From [SISSEARCH].[MEDIAINFOTYPE_2] a
inner join #InsertRecords d on a.[BaseEngMediaNumber] = d.[BASEENGLISHMEDIANUMBER]

SET @RowCount= @@RowCount   
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Inserted Records from Target [SISSEARCH].[MEDIAINFOTYPE_2]';

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
Drop table #RecordsToString
End

select a.BASEENGLISHMEDIANUMBER as [ID], 
	a.BASEENGLISHMEDIANUMBER,
	b.INFOTYPEID,
	min(a.LASTMODIFIEDDATE) [InsertDate] --Must be updated to insert date
into #RecordsToString
From [SISWEB_OWNER].[MASMEDIA] a
--inner join [SISWEB_OWNER].[LNKMEDIASNP] b on  a.[BASEENGLISHMEDIANUMBER]=b.MEDIANUMBER and b.INFOTYPEID not in(16,17,18,19,20,21,22,33,34,58) 
inner join [SISWEB_OWNER].[LNKMEDIASNP] b on  a.[BASEENGLISHMEDIANUMBER]=b.MEDIANUMBER and b.INFOTYPEID not in (SELECT [InfoTypeID] FROM [SISSEARCH].[REF_EXCLUDEINFOTYPE] where [Media] = 1 and [Search2_Status] = 1 and [Selective_Exclude] = 0) 
--inner join [SISWEB_OWNER].[MASLANGUAGE] l on l.LANGUAGEINDICATOR = a.LANGUAGEINDICATOR
inner join #InsertRecords i on i.BASEENGLISHMEDIANUMBER = a.BASEENGLISHMEDIANUMBER
Where a.LANGUAGEINDICATOR = 'E' --Limit to english
and not exists(
		select 1 from SISSEARCH.REF_SELECTIVE_EXCLUDEINFOTYPE 
	where INFOTYPEID = b.INFOTYPEID and [Excluded_Values] = a.MEDIAORIGIN
	)
Group by 
	a.BASEENGLISHMEDIANUMBER,
	b.INFOTYPEID
	--cast(b.BEGINNINGRANGE as varchar(10)),
	--cast(b.ENDRANGE as varchar(10))

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString';

--NCI
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID] 
ON #RecordsToString ([ID] ASC)
INCLUDE (BASEENGLISHMEDIANUMBER,INFOTYPEID,[InsertDate])
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

--3 Minutes To Get tothis point
--Records to String
--16 Minutes to run below script (9,190,684)

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


Insert into [SISSEARCH].[MEDIAINFOTYPE_2] ([BaseEngMediaNumber],ID,[InformationType],InsertDate)
Select  
    a.BASEENGLISHMEDIANUMBER,
	a.ID,
	coalesce(f.InfoTypeString,'') As InformationType,
	min(a.InsertDate) InsertDate --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from  #RecordsToString a
cross apply 
(
	SELECT  '[' + stuff
	(
		(SELECT '","'+ cast(INFOTYPEID as varchar(MAX))        
		FROM #RecordsToString as b 
		where a.ID=b.ID 
		order by b.ID
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')   
	,1,2,'') + '"'+']'     
) f (InfoTypeString)
Group by 
a.BASEENGLISHMEDIANUMBER,
a.ID,
f.InfoTypeString

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Target [SISSEARCH].[MEDIAINFOTYPE_2]';

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