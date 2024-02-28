Create  Procedure [sissearch2].[ServiceIESNP_Load] 
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

--Identify Deleted Records From Source

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
from  [sissearch2].[ServiceIE_SNP]
Except 
Select
	a.IESystemControlNumber
From [sis].[IE] a
	inner join (select IE_ID from [sis].[IE_Effectivity]
		union select IE_ID from [sis].[IE_ProductFamily_Effectivity]) g on a.IE_ID=g.IE_ID
	inner join [sis].[IE_InfoType_Relation] b on a.IE_ID=b.IE_ID
	and b.InfoType_ID not in (Select x.InfoTypeID from sissearch2.Ref_ExcludeInfoType x) 
	inner join [sis].[IE_Translation] e on a.IE_ID=e.IE_ID
	inner join [sis].[Language] f on e.Language_ID=f.Language_ID and f.Language_Tag='en-US'

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records Detected';

-- Delete Idenified Deleted Records in Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [sissearch2].[ServiceIE_SNP] 
From [sissearch2].[ServiceIE_SNP] a
inner join #DeletedRecords d on a.[IESystemControlNumber] = d.[IESystemControlNumber]

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records from Target [sissearch2].[ServiceIE_SNP]';

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	
Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [sissearch2].[ServiceIE_SNP]
--Print cast(getdate() as varchar(50)) + ' - Latest Insert Date in Target: ' + cast(@LastInsertDate as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
Declare @Logmessage as varchar(50) = 'Latest Insert Date in Target '+cast (@LastInsertDate as varchar(25))
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = @Logmessage , @LOGID = @StepLogID


--Identify Inserted records from Source
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

 If Object_ID('Tempdb..#InsertRecords') is not null
Begin 
 Drop table #InsertRecords
End
	Select a.IESystemControlNumber
	into #InsertRecords
	From [sis].[IE] a
	inner join [sis].[IE_Effectivity] g on a.IE_ID=g.IE_ID
	inner join [sis].[IE_InfoType_Relation] b on a.IE_ID=b.IE_ID
	and b.InfoType_ID not in (Select x.InfoTypeID from sissearch2.Ref_ExcludeInfoType x) 
	left outer join [sis].[IE_Translation] e on a.IE_ID=e.IE_ID
	inner join [sis].[Language] f on e.Language_ID=f.Language_ID and f.Language_Tag='en-US'
	where isnull(e.LastModified_Date, getdate()) > @LastInsertDate
	group by a.IESystemControlNumber
	--Should be the date when the records was inserted.
	--if no insert date is found, then reprocess.

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Detected #InsertRecords';

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_iesystemcontrolnumber 
    ON #InsertRecords([IESystemControlNumber])

--Delete Inserted records from Target 	
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [sissearch2].[ServiceIE_SNP]
From [sissearch2].[ServiceIE_SNP] a
inner join #InsertRecords d on a.IESystemControlNumber = d.IESystemControlNumber

SET @RowCount= @@RowCount   
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Inserted Records from Target [sissearch2].[ServiceIE_SNP]';

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
Drop table #RecordsToString
End

--1:50
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
										isnull(h.Serial_Number_Prefix, '')
									,'\', '\\')
								,char(8), ' ')
							,char(9), ' ')
						,char(10), ' ')
					,char(11), ' ')
				,char(12), ' ')
			,char(13), ' ')
			,'"', '\"')
		,'/', '\/') as  SNP,
cast(j.Start_Serial_Number as varchar(10)) BEGINNINGRANGE,
cast(j.End_Serial_Number as varchar(10)) ENDRANGE,
max(e.LASTMODIFIED_DATE) [InsertDate] --Must be updated to insert date
From [sis].[IE] a
inner join #InsertRecords i on 
	a.IESystemControlNumber = i.IESystemControlNumber --Limit to inserted records
	inner join [sis].[IE_Effectivity] g on a.IE_ID=g.IE_ID
	inner join [sis].[SerialNumberPrefix] h on g.SerialNumberPrefix_ID=h.SerialNumberPrefix_ID
	inner join [sis].[SerialNumberRange] j on g.SerialNumberRange_ID = j.SerialNumberRange_ID
--	where a.iesystemcontrolnumber='i02288520'
	inner join [sis].[IE_InfoType_Relation] b on a.IE_ID=b.IE_ID
and b.InfoType_ID not in (Select x.InfoTypeID from sissearch2.Ref_ExcludeInfoType x) 
left outer join [sis].[IE_Translation] e on a.IE_ID=e.IE_ID
inner join [sis].[Language] f on e.Language_ID=f.Language_ID and f.Language_Tag='en-US'
Group by 
a.IESystemControlNumber,
cast(j.Start_Serial_Number as varchar(10)),
cast(j.End_Serial_Number as varchar(10)),
h.Serial_Number_Prefix
)
Select *
into #RecordsToString
From CTE;

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString';

--NCI
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID] 
ON #RecordsToString ([ID], [SNP], BEGINNINGRANGE, ENDRANGE)
INCLUDE (IESystemControlNumber,[InsertDate])


/*
This section is adding a suffix to the ID to ensure that we do not have over 3000 begin/end range combinations
for the same ID.  The first group of 3000 has no ID suffix.  The second group of 3000 has _1 suffix. Then _2, etc...
*/

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select
case 
	when RowRank < 3000 then x.ID
	else x.ID + '_' + cast(RowRank / 3000 as varchar(50))
end ID, --First 3000 records get no suffix.  Subsequent 3000 get suffixed with _1.
x.IESystemControlNumber, 
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
	IESystemControlNumber, 
	BEGINNINGRANGE,
	ENDRANGE,
	Row_Number() Over (Partition By IESystemControlNumber Order BY cast(BEGINNINGRANGE as bigint)) - 1 RowRank --Change to zero base
	From #RecordsToString
	--Where IESYSTEMCONTROLNUMBER = 'REBE50770001' --Example of IE with over 3000 Begin/End combinations - REBE50770001
	Group by ID, IESystemControlNumber, BEGINNINGRANGE, ENDRANGE
) x
--Get the SNP & InsertDate
Inner Join #RecordsToString r on 
	x.IESystemControlNumber = r.IESystemControlNumber and 
	x.BEGINNINGRANGE = r.BEGINNINGRANGE and
	x.ENDRANGE = r.ENDRANGE
	
SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to #RecordsToString_Ranked Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString_Ranked';

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

--Create string of snp to support multi object array in json
--2:08
SELECT [ID],
[IESystemControlNumber],
ISNULL('["' + STRING_AGG(cast(SNP as varchar(max)),'","') WITHIN GROUP (ORDER BY SNP) + '"]','[]') AS [serialNumbers.serialNumberPrefixes],
BEGINNINGRANGE as [serialNumbers.beginningRange],
ENDRANGE as [serialNumbers.endRange],
max(InsertDate) [InsertDate]
Into #SNPArray
FROM #RecordsToString_Ranked --From Ranked Temp which includes ID suffix to bin into groups of 3000
GROUP BY 
ID,
IESystemControlNumber,
BEGINNINGRANGE,
ENDRANGE

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into #SNPArray: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into #SNPArray';

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into [sissearch2].[ServiceIE_SNP]
(
	[ID]
	,[IESystemControlNumber]
	,[SerialNumbers]
	,[InsertDate]
)
SELECT 
ID,
IESystemControlNumber,
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
IESystemControlNumber

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Target [sissearch2].[ServiceIE_SNP]';

--Done
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