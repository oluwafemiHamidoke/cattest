/****** Object:  StoredProcedure [sissearch2].[ServiceIEProductHierarchy_Load]    Script Date: 8/22/2022 3:32:03 PM ******/
Create  Procedure [sissearch2].[ServiceIEProductHierarchy_Load]
As

Begin

BEGIN TRY

SET NOCOUNT ON

Declare @LastINSERTDATE Datetime

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
Select distinct
	Iesystemcontrolnumber
into #DeletedRecords
from [sissearch2].[ServiceIE_ProductHierarchy]
Except 
Select distinct 
	a.IESystemControlNumber
from sis.IE a
inner join sis.IE_Effectivity b on a.IE_ID=b.IE_ID
inner join sis.SerialNumberPrefix c on b.SerialNumberPrefix_ID=c.SerialNumberPrefix_ID
inner join sis.vw_Product d on c.Serial_Number_Prefix=d.Serial_Number_Prefix
inner join sis.IE_Translation e on e.IE_ID=a.IE_ID
inner join sis.Language f on e.Language_ID=f.Language_ID and f.Language_Tag='en-US'
inner join sis.IE_InfoType_Relation g on g.IE_ID=a.IE_ID
and g.InfoType_ID not in (Select x.InfoTypeID from sissearch2.Ref_ExcludeInfoType x) 



SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records Detected';

-- Delete Idenified Deleted Records in Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [sissearch2].[ServiceIE_ProductHierarchy]
From [sissearch2].[ServiceIE_ProductHierarchy] a
left outer join #DeletedRecords d on a.IESystemControlNumber = d.Iesystemcontrolnumber
WHere d.Iesystemcontrolnumber is not null or --Deleted
a.familySubFamilyCode is null or --Not full loaded
a.familySubFamilySalesModel is null or  --Not full loaded
a.familySubFamilySalesModelSNP is null --Not full loaded

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records from Target [sissearch2].[ServiceIE_ProductHierarchy]';

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	
Select  @LastINSERTDATE=coalesce(Max(InsertDate),'1900-01-01') From [sissearch2].[ServiceIE_ProductHierarchy]
--Print cast(getdate() as varchar(50)) + ' - Latest Insert Date in Target: ' + cast(@LastINSERTDATE as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
Declare @Logmessage as varchar(50) = 'Latest Insert Date in Target '+cast (@LastINSERTDATE as varchar(25))
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = @Logmessage , @LOGID = @StepLogID


--Identify Inserted records from Source
SET @StepStartTime= GETDATE()
EXEC @StepLogID =sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

 If Object_ID('Tempdb..#InsertRecords') is not null
Begin 
 Drop table #InsertRecords
End
	Select distinct 
	a.IESystemControlNumber
	into #InsertRecords
	from sis.IE a
	inner join sis.IE_Effectivity b on a.IE_ID=b.IE_ID
	inner join sis.SerialNumberPrefix c on b.SerialNumberPrefix_ID=c.SerialNumberPrefix_ID
inner join sis.vw_Product d on c.Serial_Number_Prefix=d.Serial_Number_Prefix
inner join sis.IE_Translation e on e.IE_ID=a.IE_ID
inner join sis.Language f on e.Language_ID=f.Language_ID and f.Language_Tag='en-US' 
inner join sis.IE_InfoType_Relation g on g.IE_ID=a.IE_ID
and g.InfoType_ID not in (Select x.InfoTypeID from sissearch2.Ref_ExcludeInfoType x) 
where isnull(e.LastModified_Date, getdate()) > @LastINSERTDATE 
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

Delete [sissearch2].[ServiceIE_ProductHierarchy]
From [sissearch2].[ServiceIE_ProductHierarchy] a
inner join #InsertRecords d on a.IESystemControlNumber = d.IESystemControlNumber

SET @RowCount= @@RowCount   
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Inserted Records from Target [sissearch2].[ServiceIE_ProductHierarchy]';

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
Drop table #RecordsToString
End

;with CTE as
(
select distinct 
id, 
IESystemControlNumber,
replace( --escape /
	replace( --escape "
		replace( --replace carriage return (ascii 13)
			replace( --replace form feed (ascii 12) 
				replace( --replace vertical tab (ascii 11)
					replace( --replace line feed (ascii 10)
						replace( --replace horizontal tab (ascii 09)
							replace( --replace backspace (ascii 08)
								replace( --escape \
									isnull(Family_Code,'')
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
									isnull(Subfamily_Code,'')
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
									isnull(Sales_Model,'')
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
									isnull(Serial_Number_Prefix,'')
								,'\', '\\')
							,char(8), ' ')
						,char(9), ' ')
					,char(10), ' ')
				,char(11), ' ')
			,char(12), ' ')
		,char(13), ' ')
		,'"', '\"')
	,'/', '\/') as Serial_Number_Prefix,
LastModified_Date INSERTDATE
from (
select Distinct
	a.IESystemControlNumber as id, 
	a.IESystemControlNumber,
	c.Family_Code,
	d.Subfamily_Code,
	d.Sales_Model,
	d.Serial_Number_Prefix,
	e.LastModified_Date
from 
sis.IE a
inner join #InsertRecords i on 
	a.IESystemControlNumber = i.IESystemControlNumber --Limit to inserted records
inner join sis.IE_ProductFamily_Effectivity b on a.IE_ID=b.IE_ID
	inner join sis.ProductFamily c on b.ProductFamily_ID=c.ProductFamily_ID
inner join sis.vw_Product d on c.Family_Code=d.Family_Code
inner join sis.IE_Translation e on e.IE_ID=a.IE_ID
inner join sis.Language f on e.Language_ID=f.Language_ID and f.Language_Tag='en-US' 
inner join sis.IE_InfoType_Relation g on g.IE_ID=a.IE_ID
and g.InfoType_ID not in (Select x.InfoTypeID from sissearch2.Ref_ExcludeInfoType x) 
Union
	select Distinct
	a.IESystemControlNumber as id, 
	a.IESystemControlNumber,
	d.Family_Code,
	d.Subfamily_Code,
	d.Sales_Model,
	d.Serial_Number_Prefix,
	e.LastModified_Date
from 
sis.IE a
inner join #InsertRecords i on 
a.IESystemControlNumber = i.IESystemControlNumber --Limit to inserted records
inner join sis.IE_Effectivity b on a.IE_ID=b.IE_ID
inner join sis.SerialNumberPrefix c on b.SerialNumberPrefix_ID=c.SerialNumberPrefix_ID
inner join sis.vw_Product d on c.Serial_Number_Prefix=d.Serial_Number_Prefix
inner join sis.IE_Translation e on e.IE_ID=a.IE_ID
inner join sis.Language f on e.Language_ID=f.Language_ID and f.Language_Tag='en-US' 
inner join sis.IE_InfoType_Relation g on g.IE_ID=a.IE_ID
and g.InfoType_ID not in (Select x.InfoTypeID from sissearch2.Ref_ExcludeInfoType x) 
) x
)
Select *
into #RecordsToString
From CTE;

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString';



/*
Family_Code
*/

Select  
id, 
IESystemControlNumber,
Family_Code,
max(INSERTDATE) INSERTDATE
Into #RecordsToString_FM
From #RecordsToString 
Group by id, IESystemControlNumber, Family_Code

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID_FM] 
ON #RecordsToString_FM (id ASC)
INCLUDE (IESystemControlNumber, Family_Code, INSERTDATE)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Family_Code'

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  
    a.IESystemControlNumber,
	a.id,
	'["' + string_agg(a.Family_Code,'","') + '"]'  As RecordsToString,
	min(a.INSERTDATE) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into #RecordsToStringResult
from #RecordsToString_FM a
Group by 
a.IESystemControlNumber,
a.id

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Family_Code, Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Temp RecordsToStringResult Family_Code';

--Add pkey to result
Alter Table #RecordsToStringResult Alter Column id varchar(50) Not NULL
ALTER TABLE #RecordsToStringResult ADD PRIMARY KEY CLUSTERED (id) 
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into [sissearch2].[ServiceIE_ProductHierarchy] (Iesystemcontrolnumber,ID,familyCode,InsertDate)
Select IESystemControlNumber,id,RecordsToString,INSERTDATE from #RecordsToStringResult

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Insert into Target Count, Family_Code: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Insert into Target, Family_Code, [sissearch2].[ServiceIE_ProductHierarchy]';

--Drop temp
Drop table #RecordsToStringResult
Drop table #RecordsToString_FM





/*
Subfamily_Code
*/

Select  
id, 
IESystemControlNumber, 
----Family_Code,
----Subfamily_Code,
cast(Family_Code + '_' + Subfamily_Code as varchar(MAX)) RTS,
max(INSERTDATE) INSERTDATE
Into #RecordsToString_SF
From #RecordsToString 
Group by id, IESystemControlNumber, Family_Code, Subfamily_Code

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID_SF] 
ON #RecordsToString_SF (id ASC)
INCLUDE (IESystemControlNumber,RTS, INSERTDATE)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Subfamily_Code'

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  
    a.IESystemControlNumber,
	a.id,
	'["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
	min(a.INSERTDATE) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into #RecordsToStringResult_SF
from #RecordsToString_SF a
Group by 
a.IESystemControlNumber,
a.id

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Subfamily_Code, Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Temp RecordsToStringResult Subfamily_Code';

--Add pkey to result
Alter Table  #RecordsToStringResult_SF Alter Column id varchar(50) Not NULL
ALTER TABLE  #RecordsToStringResult_SF ADD PRIMARY KEY CLUSTERED (id) 
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Update x
set familySubFamilyCode = y.RecordsToString
From [sissearch2].[ServiceIE_ProductHierarchy]  x
inner join  #RecordsToStringResult_SF y on x.ID = y.id

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Update Target Count, Subfamily_Code: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Update Target, Subfamily_Code, [sissearch2].[ServiceIE_ProductHierarchy]';

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
id, 
IESystemControlNumber, 
cast(Family_Code + '_' + Subfamily_Code + '_' + Sales_Model as varchar(MAX)) RTS,
max(INSERTDATE) INSERTDATE
Into #RecordsToString_SM
From #RecordsToString 
Group by id, IESystemControlNumber, Family_Code, Subfamily_Code, Sales_Model

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID_SM] 
ON #RecordsToString_SM (id ASC)
INCLUDE (IESystemControlNumber,RTS, INSERTDATE)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Sales_Model'

Create table #RecordsToStringResult_SM
(
IESystemControlNumber varchar(50) not null,
id varchar(50) not null,
RecordsToString varchar(max) null,
INSERTDATE datetime not null
)

--Add pkey to result
Alter Table  #RecordsToStringResult_SM Alter Column id varchar(50) Not NULL
ALTER TABLE  #RecordsToStringResult_SM ADD PRIMARY KEY CLUSTERED (id) 
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

While (Select count(*) from #RecordsToString_SM) > 0
Begin

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into #RecordsToStringResult_SM
Select  
    a.IESystemControlNumber,
	a.id,
	'["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
	min(a.INSERTDATE) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from (Select top (@BatchCount) With Ties * From #RecordsToString_SM order by id) a
Group by 
a.IESystemControlNumber,
a.id


Set @BatchInsertCount = @@ROWCOUNT
SET @RowCount= @RowCount + @BatchInsertCount
Set @LoopCount = @LoopCount + 1

--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Sales_Model, Count: ' + Cast(@BatchInsertCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @BatchInsertCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Temp RecordsToStringResult Sales_Model';

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Update x
set familySubFamilySalesModel = y.RecordsToString
From [sissearch2].[ServiceIE_ProductHierarchy]  x
inner join  #RecordsToStringResult_SM y on x.ID = y.id

SET @UpdateCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Update Target Count, Sales_Model: ' + Cast(@UpdateCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @UpdateCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Update Target, Sales_Model, [sissearch2].[ServiceIE_ProductHierarchy]';

Delete a
From #RecordsToString_SM a
inner join (Select Distinct id From (Select top (@BatchCount) with Ties id From #RecordsToString_SM order by id) x ) b on a.id = b.id

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
id, 
IESystemControlNumber, 
cast(Family_Code + '_' + Subfamily_Code + '_' + Sales_Model + '_' + Serial_Number_Prefix as varchar(MAX)) RTS,
max(INSERTDATE) INSERTDATE
Into #RecordsToString_SNP
From #RecordsToString 
Group by id, IESystemControlNumber, Family_Code, Subfamily_Code, Sales_Model, Serial_Number_Prefix

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID_SNP] 
ON #RecordsToString_SNP (id ASC)
INCLUDE (IESystemControlNumber, RTS, INSERTDATE)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Sales_Model'

Create table #RecordsToStringResult_SNP
(
IESystemControlNumber varchar(50) not null,
id varchar(50) not null,
RecordsToString varchar(max) null,
INSERTDATE datetime not null
)

--Add pkey to result
Alter Table  #RecordsToStringResult_SNP Alter Column id varchar(50) Not NULL
ALTER TABLE  #RecordsToStringResult_SNP ADD PRIMARY KEY CLUSTERED (id) 
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

While (Select count(*) from #RecordsToString_SNP) > 0
Begin

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into #RecordsToStringResult_SNP
Select  
    a.IESystemControlNumber,
	a.id,
	'["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
	min(a.INSERTDATE) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from (Select top (@BatchCount) With Ties * From #RecordsToString_SNP order by id) a
Group by 
a.IESystemControlNumber,
a.id

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
From [sissearch2].[ServiceIE_ProductHierarchy]  x
inner join  #RecordsToStringResult_SNP y on x.ID = y.id

SET @UpdateCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Update Target Count, Serial_Number_Prefix: ' + Cast(@UpdateCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @UpdateCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Update Target, Serial_Number_Prefix, [sissearch2].[ServiceIE_ProductHierarchy]';

Delete a
From #RecordsToString_SNP a
inner join (Select Distinct id From (Select top (@BatchCount) with Ties id From #RecordsToString_SNP order by id) x ) b on a.id = b.id

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


SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LOGID = @SPStartLogID

DELETE FROM sissearch2.LOG WHERE DATEDIFF(DD, LogDateTime, GetDate())>30 and NameofSproc= @ProcName

END TRY

BEGIN CATCH 
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT= ERROR_LINE()

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC sissearch2.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error
END CATCH


End