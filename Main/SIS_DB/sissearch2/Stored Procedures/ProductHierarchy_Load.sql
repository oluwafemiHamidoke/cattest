CREATE  Procedure [sissearch2].[ProductHierarchy_Load] 
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
Select Distinct IESystemControlNumber 
into #DeletedRecords
from  [sissearch2].[ProductHierarchy]
Except 
Select Distinct MS.IESystemControlNumber
FROM [sis_shadow].[MediaSequence] MS
inner join [sis].[IEPart] IP on IP.IEPart_ID = MS.IEPart_ID

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records Detected';

-- Delete Idenified Deleted Records in Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [sissearch2].[ProductHierarchy] 
from [sissearch2].[ProductHierarchy] a
left outer join #DeletedRecords d on a.IESystemControlNumber = d.IESystemControlNumber
where  d.IESystemControlNumber is not null or --Deleted
a.familySubFamilyCode is null or --Not full loaded
a.familySubFamilySalesModel is null or  --Not full loaded
a.familySubFamilySalesModelSNP is null --Not full loaded

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records from Target [sissearch2].[ProductHierarchy]';

--Drop Temp
Drop Table #DeletedRecords

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	
Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [sissearch2].[ProductHierarchy]
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

SELECT DISTINCT MS.IESystemControlNumber as IESystemControlNumber,
CASE	WHEN MS.LastModified_Date > MP.LastModified_Date AND MS.LastModified_Date > IE.LastModified_Date AND MS.LastModified_Date > PF.LastModified_Date
				THEN MS.LastModified_Date
		WHEN IE.LastModified_Date > MS.LastModified_Date AND IE.LastModified_Date > MP.LastModified_Date AND IE.LastModified_Date > PF.LastModified_Date
			THEN IE.LastModified_Date
		WHEN MP.LastModified_Date > MS.LastModified_Date AND MP.LastModified_Date > IE.LastModified_Date AND MP.LastModified_Date > PF.LastModified_Date 
			THEN MP.LastModified_Date
	ELSE PF.LastModified_Date END AS LastModified_Date
INTO #InsertRecords
From [sis_shadow].[MediaSequence] MS
inner join sis.MediaSection C on MS.MediaSection_ID=C.MediaSection_ID
inner join sis.Media M on C.Media_ID=M.Media_ID AND M.Source in ('A','C')
inner join sis.IEPart_Effectivity IE on MS.IEPart_ID = IE.IEPart_ID and IE.SerialNumberPrefix_Type = 'P'
inner join sis.SerialNumberPrefix MP on MP.SerialNumberPrefix_ID = IE.SerialNumberPrefix_ID
inner join [sis].[Product_Relation] pr on MP.SerialNumberPrefix_ID = pr.SerialNumberPrefix_ID  
inner join [sis].[ProductFamily] PF on PF.ProductFamily_ID = pr.ProductFamily_ID 
WHERE 	MS.LastModified_Date > @LastInsertDate 	OR
		IE.LastModified_Date > @LastInsertDate 	OR
		MP.LastModified_Date > @LastInsertDate 	OR 
		PF.LastModified_Date > @LastInsertDate

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Detected #InsertRecords';

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_IESystemControlNumber 
    ON #InsertRecords(IESystemControlNumber) INCLUDE(LastModified_Date)

--Delete Inserted records from Target 	
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete from [sissearch2].[ProductHierarchy]
where IESystemControlNumber in
 (Select IESystemControlNumber from  #InsertRecords)
 
SET @RowCount= @@RowCount   
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Inserted Records from Target [sissearch2].[ProductHierarchy]';

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin
 Drop table #RecordsToString
End

select a.IESystemControlNumber as IESystemControlNumber,
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
									isnull(p.Family_Code,'')
								,'\', '\\')
							,char(8), ' ')
						,char(9), ' ')
					,char(10), ' ')
				,char(11), ' ')
			,char(12), ' ')
		,char(13), ' ')
		,'"', '\"')
	,'/', '\/') as Family_Code,
replace( --escape /
	replace( --escape "
		replace( --replace carriage return (ascii 13)
			replace( --replace form feed (ascii 12) 
				replace( --replace vertical tab (ascii 11)
					replace( --replace line feed (ascii 10)
						replace( --replace horizontal tab (ascii 09)
							replace( --replace backspace (ascii 08)
								replace( --escape \
									isnull(ps.Subfamily_Code,'')
								,'\', '\\')
							,char(8), ' ')
						,char(9), ' ')
					,char(10), ' ')
				,char(11), ' ')
			,char(12), ' ')
		,char(13), ' ')
		,'"', '\"')
	,'/', '\/') as Subfamily_Code,
replace( --escape /
	replace( --escape "
		replace( --replace carriage return (ascii 13)
			replace( --replace form feed (ascii 12) 
				replace( --replace vertical tab (ascii 11)
					replace( --replace line feed (ascii 10)
						replace( --replace horizontal tab (ascii 09)
							replace( --replace backspace (ascii 08)
								replace( --escape \
									isnull(sm.Sales_Model,'')
								,'\', '\\')
							,char(8), ' ')
						,char(9), ' ')
					,char(10), ' ')
				,char(11), ' ')
			,char(12), ' ')
		,char(13), ' ')
		,'"', '\"')
	,'/', '\/') as Sales_Model,
replace( --escape /
	replace( --escape "
		replace( --replace carriage return (ascii 13)
			replace( --replace form feed (ascii 12) 
				replace( --replace vertical tab (ascii 11)
					replace( --replace line feed (ascii 10)
						replace( --replace horizontal tab (ascii 09)
							replace( --replace backspace (ascii 08)
								replace( --escape \
									isnull(snp.Serial_Number_Prefix,'')
								,'\', '\\')
							,char(8), ' ')
						,char(9), ' ')
					,char(10), ' ')
				,char(11), ' ')
			,char(12), ' ')
		,char(13), ' ')
		,'"', '\"')
	,'/', '\/') as Serial_Number_Prefix,
i.LastModified_Date InsertDate
into #RecordsToString
from  [sis_shadow].[MediaSequence] a
inner join sis.MediaSection c on a.MediaSection_ID=c.MediaSection_ID
inner join sis.Media d on c.Media_ID=d.Media_ID and d.Source in ('A','C')
inner join sis.IEPart_Effectivity iep on a.IEPart_ID = iep.IEPart_ID and iep.SerialNumberPrefix_Type = 'P'
inner join sis.SerialNumberPrefix snp on snp.SerialNumberPrefix_ID = iep.SerialNumberPrefix_ID
inner join [sis].[Product_Relation] pr on snp.SerialNumberPrefix_ID = pr.SerialNumberPrefix_ID  
inner join [sis].[ProductFamily] p on p.ProductFamily_ID = pr.ProductFamily_ID  
inner join [sis].[SalesModel] sm on sm.SalesModel_ID = pr.SalesModel_ID  
inner join [sis].[ProductSubfamily] ps on pr.ProductSubfamily_ID = ps.ProductSubfamily_ID
inner join #InsertRecords i --Add filter to limit to changed records
    on i.IESystemControlNumber = a.IESystemControlNumber 

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to #RecordsToString';

Drop Table #InsertRecords

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID] 
ON #RecordsToString (ID ASC)
INCLUDE (IESystemControlNumber,Family_Code, Subfamily_Code, Sales_Model, Serial_Number_Prefix, InsertDate)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

/*
Family_Code
*/

Select  
ID, 
IESystemControlNumber,
Family_Code,
max(InsertDate) InsertDate
Into #RecordsToString_FM
From #RecordsToString 
Group by ID, IESystemControlNumber, Family_Code

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID_FM] 
ON #RecordsToString_FM (ID ASC)
INCLUDE (IESystemControlNumber, Family_Code, InsertDate)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Family_Code'

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  
    a.IESystemControlNumber,
	a.ID,
	'["' + string_agg(a.Family_Code,'","') + '"]'  As RecordsToString,
	min(a.InsertDate) InsertDate --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into #RecordsToStringResult
from #RecordsToString_FM a
Group by 
a.IESystemControlNumber,
a.ID

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Family_Code, Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Temp RecordsToStringResult Family_Code';

--Add pkey to result
Alter Table #RecordsToStringResult Alter Column ID varchar(50) Not NULL
ALTER TABLE #RecordsToStringResult ADD PRIMARY KEY CLUSTERED (ID) 
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into [sissearch2].[ProductHierarchy] (IESystemControlNumber,ID,familyCode,InsertDate)
Select IESystemControlNumber,ID,RecordsToString,InsertDate from #RecordsToStringResult

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Insert into Target Count, Family_Code: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Insert into Target, Family_Code, [sissearch2].[ProductHierarchy]';

--Drop temp
Drop table #RecordsToStringResult
Drop table #RecordsToString_FM

/*
Subfamily_Code
*/

Select  
ID, 
IESystemControlNumber, 
----Family_Code,
----Subfamily_Code,
cast(Family_Code + '_' + Subfamily_Code as varchar(MAX)) RTS,
max(InsertDate) InsertDate
Into #RecordsToString_SF
From #RecordsToString 
Group by ID, IESystemControlNumber, Family_Code, Subfamily_Code

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID_SF] 
ON #RecordsToString_SF (ID ASC)
INCLUDE (IESystemControlNumber,RTS, InsertDate)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Subfamily_Code'

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  
    a.IESystemControlNumber,
	a.ID,
	'["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
	min(a.InsertDate) InsertDate --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into #RecordsToStringResult_SF
from #RecordsToString_SF a
Group by 
a.IESystemControlNumber,
a.ID

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Subfamily_Code, Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Temp RecordsToStringResult Subfamily_Code';

--Add pkey to result
Alter Table  #RecordsToStringResult_SF Alter Column ID varchar(50) Not NULL
ALTER TABLE  #RecordsToStringResult_SF ADD PRIMARY KEY CLUSTERED (ID) 
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Update x
set familySubFamilyCode = y.RecordsToString
From [sissearch2].[ProductHierarchy]  x
inner join  #RecordsToStringResult_SF y on x.ID = y.ID

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Update Target Count, Subfamily_Code: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Update Target, Subfamily_Code, [sissearch2].[ProductHierarchy]';

--Drop temp
Drop table  #RecordsToStringResult_SF
Drop table #RecordsToString_SF

Declare @LoopCount int = 0
Declare @BatchInsertCount int = 0
Declare @BatchProcessCount int = 0
Declare @BatchCount int = 100000 --Each loop will process this number of IDs
Declare @UpdateCount int = 0

/*
Sales_Model
*/

Select  
ID, 
IESystemControlNumber, 
--Family_Code,
--Subfamily_Code,
--Sales_Model,
cast(Family_Code + '_' + Subfamily_Code + '_' + Sales_Model as varchar(MAX)) RTS,
max(InsertDate) InsertDate
Into #RecordsToString_SM
From #RecordsToString 
Group by ID, IESystemControlNumber, Family_Code, Subfamily_Code, Sales_Model

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID_SM] 
ON #RecordsToString_SM (ID ASC)
INCLUDE (IESystemControlNumber,RTS, InsertDate)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Sales_Model'

Create table #RecordsToStringResult_SM
(
IESystemControlNumber varchar(50) not null,
ID varchar(50) not null,
RecordsToString varchar(max) null,
InsertDate datetime not null
)

--Add pkey to result
Alter Table  #RecordsToStringResult_SM Alter Column ID varchar(50) Not NULL
ALTER TABLE  #RecordsToStringResult_SM ADD PRIMARY KEY CLUSTERED (ID) 
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

While (Select count(*) from #RecordsToString_SM) > 0
Begin

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into #RecordsToStringResult_SM
Select  
    a.IESystemControlNumber,
	a.ID,
	'["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
	min(a.InsertDate) InsertDate --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from (Select top (@BatchCount) With Ties * From #RecordsToString_SM order by ID) a
Group by 
a.IESystemControlNumber,
a.ID


Set @BatchInsertCount = @@ROWCOUNT
SET @RowCount= @RowCount + @BatchInsertCount
Set @LoopCount = @LoopCount + 1

--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Sales_Model, Count: ' + Cast(@BatchInsertCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @BatchInsertCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Temp RecordsToStringResult Sales_Model';

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Update x
set familySubFamilySalesModel = y.RecordsToString
From [sissearch2].[ProductHierarchy]  x
inner join  #RecordsToStringResult_SM y on x.ID = y.ID

SET @UpdateCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Update Target Count, Sales_Model: ' + Cast(@UpdateCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @UpdateCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Update Target, Sales_Model, [sissearch2].[ProductHierarchy]';

Delete a
From #RecordsToString_SM a
inner join (Select Distinct ID From (Select top (@BatchCount) with Ties ID From #RecordsToString_SM order by ID) x ) b on a.ID = b.ID

Set @BatchProcessCount = @@ROWCOUNT
--Print cast(getdate() as varchar(50)) + ' - Total Update Count: ' + Cast(@RowCount as varchar(50)) + ' | Loop Count: ' + Cast(@LoopCount as varchar(50)) + ' | Batch Update Count: ' + Cast(@BatchInsertCount as varchar(50)) + ' | Batch Rows Processed: ' + Cast(@BatchProcessCount as varchar(50))

Truncate table #RecordsToStringResult_SM

End --End of records to string loop

--Drop temp
Drop table  #RecordsToStringResult_SM
Drop table #RecordsToString_SM


/*
SNP
*/

Select  
ID, 
IESystemControlNumber, 
--Family_Code,
--Subfamily_Code,
--Sales_Model,
--Serial_Number_Prefix,
cast(Family_Code + '_' + Subfamily_Code + '_' + Sales_Model + '_' + Serial_Number_Prefix as varchar(MAX)) RTS,
max(InsertDate) InsertDate
Into #RecordsToString_SNP
From #RecordsToString 
Group by ID, IESystemControlNumber, Family_Code, Subfamily_Code, Sales_Model, Serial_Number_Prefix

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID_SNP] 
ON #RecordsToString_SNP (ID ASC)
INCLUDE (IESystemControlNumber, RTS, InsertDate)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Sales_Model'

Create table #RecordsToStringResult_SNP
(
IESystemControlNumber varchar(50) not null,
ID varchar(50) not null,
RecordsToString varchar(max) null,
InsertDate datetime not null
)

--Add pkey to result
Alter Table  #RecordsToStringResult_SNP Alter Column ID varchar(50) Not NULL
ALTER TABLE  #RecordsToStringResult_SNP ADD PRIMARY KEY CLUSTERED (ID) 
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

While (Select count(*) from #RecordsToString_SNP) > 0
Begin

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into #RecordsToStringResult_SNP
Select  
    a.IESystemControlNumber,
	a.ID,
	'["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
	min(a.InsertDate) InsertDate --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from (Select top (@BatchCount) With Ties * From #RecordsToString_SNP order by ID) a
Group by 
a.IESystemControlNumber,
a.ID

Set @BatchInsertCount = @@ROWCOUNT
SET @RowCount= @RowCount + @BatchInsertCount
Set @LoopCount = @LoopCount + 1

--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Serial_Number_Prefix, Count: ' + Cast(@BatchInsertCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @BatchInsertCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Temp RecordsToStringResult Serial_Number_Prefix';

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Update x
set familySubFamilySalesModelSNP = y.RecordsToString
From [sissearch2].[ProductHierarchy]  x
inner join  #RecordsToStringResult_SNP y on x.ID = y.ID

SET @UpdateCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Update Target Count, Serial_Number_Prefix: ' + Cast(@UpdateCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @UpdateCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Update Target, Serial_Number_Prefix, [sissearch2].[ProductHierarchy]';

Delete a
From #RecordsToString_SNP a
inner join (Select Distinct ID From (Select top (@BatchCount) with Ties ID From #RecordsToString_SNP order by ID) x ) b on a.ID = b.ID

Set @BatchProcessCount = @@ROWCOUNT
--Print cast(getdate() as varchar(50)) + ' - Total Update Count: ' + Cast(@RowCount as varchar(50)) + ' | Loop Count: ' + Cast(@LoopCount as varchar(50)) + ' | Batch Update Count: ' + Cast(@BatchInsertCount as varchar(50)) + ' | Batch Rows Processed: ' + Cast(@BatchProcessCount as varchar(50))

Truncate table #RecordsToStringResult_SNP

End --End of records to string loop

--Drop temp
Drop table  #RecordsToStringResult_SNP
Drop table #RecordsToString_SNP

/*
Finish
*/

DELETE FROM sissearch2.LOG WHERE DATEDIFF(DD, LogDateTime, GetDate())>30 and NameofSproc= @ProcName

SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LOGID = @SPStartLogID

END TRY

BEGIN CATCH 
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT= ERROR_LINE()

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC sissearch2.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error
END CATCH

End
