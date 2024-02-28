

CREATE  Procedure [SISSEARCH].[SERVICEIESNP_4_LOAD] 
As
/*---------------
Date: 20190911
Object Description:  Loading changed data into SISSEARCH.SERVICEIESNP_4 from base tables
Modifiy Date: 20210310 - Davide. Changed DATEUPDATED to LASTMODDIFIEDDATE, see: https://dev.azure.com/sis-cat-com/sis2-ui/_workitems/edit/9566/
Exec [SISSEARCH].[SERVICEIESNP_4_LOAD]
Truncate table [SISSEARCH].[SERVICEIESNP_4]
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
from  [SISSEARCH].[SERVICEIESNP_4]
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
	(d.GROUPTITLEINDICATOR='N' or d.GROUPTITLEINDICATOR is Null)

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records Detected';

-- Delete Idenified Deleted Records in Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [SISSEARCH].[SERVICEIESNP_4] 
From [SISSEARCH].[SERVICEIESNP_4] a
inner join #DeletedRecords d on a.[IESystemControlNumber] = d.[IESystemControlNumber]

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records from Target [SISSEARCH].[SERVICEIESNP_4]';

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	
Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [SISSEARCH].[SERVICEIESNP_4]
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
		(d.GROUPTITLEINDICATOR='N' or d.GROUPTITLEINDICATOR is Null)
	where isnull(e.LASTMODIFIEDDATE, getdate()) > @LastInsertDate 
	and a.TYPEINDICATOR = 'S' --Limit to Type
	group by a.IESYSTEMCONTROLNUMBER
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

Delete [SISSEARCH].[SERVICEIESNP_4] 
From [SISSEARCH].[SERVICEIESNP_4] a
inner join #InsertRecords d on a.IESystemControlNumber = d.IESYSTEMCONTROLNUMBER

SET @RowCount= @@RowCount   
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Inserted Records from Target [SISSEARCH].[SERVICEIESNP_4]';

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
Drop table #RecordsToString
End

--1:50
;with CTE as
(
select a.IESYSTEMCONTROLNUMBER as [ID], 
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
										isnull(a.SNP, '')
									,'\', '\\')
								,char(8), ' ')
							,char(9), ' ')
						,char(10), ' ')
					,char(11), ' ')
				,char(12), ' ')
			,char(13), ' ')
			,'"', '\"')
		,'/', '\/') as  SNP,
cast(a.BEGINNINGRANGE as varchar(10)) BEGINNINGRANGE,
cast(a.ENDRANGE as varchar(10)) ENDRANGE,
max(e.LASTMODIFIEDDATE) [InsertDate] --Must be updated to insert date
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
	(d.GROUPTITLEINDICATOR='N' or d.GROUPTITLEINDICATOR is Null)
Where a.TYPEINDICATOR = 'S' --Limite to Type
Group by 
a.IESYSTEMCONTROLNUMBER,
cast(a.BEGINNINGRANGE as varchar(10)),
cast(a.ENDRANGE as varchar(10)),
a.SNP
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
ON #RecordsToString ([ID], [SNP], BEGINNINGRANGE, ENDRANGE)
INCLUDE (IESYSTEMCONTROLNUMBER,[InsertDate])


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

--Create string of snp to support multi object array in json
--2:08
SELECT [ID],
[IESYSTEMCONTROLNUMBER],
ISNULL('["' + STRING_AGG(cast(SNP as varchar(max)),'","') WITHIN GROUP (ORDER BY SNP) + '"]','[]') AS [serialNumbers.serialNumberPrefixes],
BEGINNINGRANGE as [serialNumbers.beginningRange],
ENDRANGE as [serialNumbers.endRange],
max(InsertDate) [InsertDate]
Into #SNPArray
FROM #RecordsToString_Ranked --From Ranked Temp which includes ID suffix to bin into groups of 3000
GROUP BY 
ID,
IESYSTEMCONTROLNUMBER,
BEGINNINGRANGE,
ENDRANGE

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into #SNPArray: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into #SNPArray';

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into [SISSEARCH].[SERVICEIESNP_4] 
(
	[ID]
	,[IESystemControlNumber]
	,[SerialNumbers]
	,[InsertDate]
)
SELECT 
ID,
IESYSTEMCONTROLNUMBER,
(--Create json for each ID
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
IESYSTEMCONTROLNUMBER

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Target [SISSEARCH].[SERVICEIESNP_4]';

--Done
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