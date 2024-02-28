CREATE  Procedure [sissearch2].[Media_ProductHierarchy_Load] 
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
 
--IDentify Deleted Records From Source

EXEC @SPStartLogID = sissearch2.WriteLog @TIME = @SPStartTime, @NAMEOFSPROC = @ProcName;

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#DeletedRecords') is not null
  Begin 
     Drop table #DeletedRecords
  End
Select
	[Media_Number]
	into #DeletedRecords
	from  [sissearch2].[Media_InfoType]
	Except 
	Select
	a.[Media_Number]
	from [sis].[Media] a
	inner join
	(select Media_ID from [sis].[Media_Effectivity] 
	 union
	 select Media_ID from [sis].[Media_ProductFamily_Effectivity] 
	) b
	on  a.Media_ID=b.Media_ID
	inner join [sis].[Media_Translation] c on  c.Media_ID=a.Media_ID
	inner join [sis].[Media_InfoType_Relation] d on d.Media_ID=a.Media_ID and d.InfoType_ID not in
	(SELECT [InfoTypeID] FROM [sissearch2].[Ref_ExcludeInfoType] where [Search2_Status] = 1 and [Selective_Exclude] = 0) 
	left join [sissearch2].[Ref_Selective_ExcludeInfoType] E
	on E.InfoTypeID  = d.InfoType_ID and E.[Excluded_Values] = c.Media_Origin
	where E.InfoTypeID IS NULL

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records Detected';

-- Delete IDenified Deleted Records in Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [sissearch2].[Media_ProductHierarchy] 
From [sissearch2].[Media_ProductHierarchy] a
left join #DeletedRecords d on a.[Media_Number] = d.[Media_Number]
WHere d.[Media_Number] is not null or --Deleted
a.familySubFamilyCode is null or --Not full loaded
a.familySubFamilySalesModel is null or  --Not full loaded
a.familySubFamilySalesModelSNP is null --Not full loaded


SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records from Target [sissearch2].[Media_ProductHierarchy]';

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	
Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [sissearch2].[Media_ProductHierarchy]

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
Declare @Logmessage as varchar(50) = 'Latest Insert Date in Target '+cast (@LastInsertDate as varchar(25))
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = @Logmessage , @LogID = @StepLogID

--Identify Inserted records from Source
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


 If Object_ID('Tempdb..#InsertRecords') is not null
Begin 
 Drop table #InsertRecords
End
	Select
		a.[Media_Number]
	into #InsertRecords
	from [sis].[Media] a
	inner join 
	(select Media_ID from [sis].[Media_Effectivity] 
	 union
	 select Media_ID from [sis].[Media_ProductFamily_Effectivity] 
	) b on  a.Media_ID=b.Media_ID
	inner join [sis].[Media_Translation] c on  c.Media_ID=a.Media_ID
	inner join [sis].[Media_InfoType_Relation] d on d.Media_ID=a.Media_ID and d.InfoType_ID not in
	(SELECT [InfoTypeID] FROM [sissearch2].[Ref_ExcludeInfoType] where [Search2_Status] = 1 and [Selective_Exclude] = 0) 
	left join [sissearch2].[Ref_Selective_ExcludeInfoType] E
	on E.InfoTypeID  = d.InfoType_ID and E.[Excluded_Values] = c.Media_Origin
	where E.InfoTypeID IS NULL
	AND c.LastModified_Date  > @LastInsertDate
	group by a.[Media_Number]
	order by  a.[Media_Number]

--delete from #InsertRecords where Media_Number NOT IN ('AEXQ2126','GEBJ0066')

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Detected #InsertRecords';

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_Media_Number
    ON #InsertRecords([Media_Number])

--Delete Inserted records from Target 	
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [sissearch2].[Media_ProductHierarchy] 
From [sissearch2].[Media_ProductHierarchy] a
inner join #InsertRecords d on a.[Media_Number] = d.[Media_Number]

SET @RowCount= @@RowCount   

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Deleted Inserted Records from Target [sissearch2].[Media_ProductHierarchy]';

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
Drop table #RecordsToString
End

select 
[ID], 
[Media_Number],
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
	,'/', '\/') as FamilyCode,
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
	,'/', '\/') as SubfamilyCode,
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
min(LASTMODIFIED_DATE) [InsertDate] --Must be updated to insert date
into #RecordsToString
from 
(
select distinct a.[Media_Number] as [ID], 
	a.[Media_Number] AS [Media_Number],
	b.Family_Code,
	b.Subfamily_Code,
	b.Sales_Model,
	b.Serial_Number_Prefix,
	c.LASTMODIFIED_DATE
	from [sis].[Media] a
	inner join [sis].[Media_Translation] c on  c.Media_ID=a.Media_ID
	inner join [sis].[Media_ProductFamily_Effectivity] p on a.Media_ID=p.Media_ID
		join sis.ProductFamily f on p.ProductFamily_ID=f.ProductFamily_ID
	inner join sis.vw_Product b on b.Family_Code=f.Family_Code
	inner join #InsertRecords i on i.Media_Number=a.Media_Number
	Union

		select distinct a.[Media_Number] as [ID], 
	a.[Media_Number] AS [Media_Number],
	b.Family_Code,
	b.Subfamily_Code,
	b.Sales_Model,
	b.Serial_Number_Prefix,
	c.LASTMODIFIED_DATE
	from [sis].[Media] a
	inner join [sis].[Media_Translation] c on  c.Media_ID=a.Media_ID
	inner join [sis].[Media_Effectivity] p on a.Media_ID=p.Media_ID
	inner join [sis].[SerialNumberPrefix] snp on snp.SerialNumberPrefix_ID=p.SerialNumberPrefix_ID
	inner join sis.vw_Product b on b.Serial_Number_Prefix=snp.Serial_Number_Prefix
	inner join #InsertRecords i on i.[Media_Number]=a.Media_Number
		inner join [sis].[Media_InfoType_Relation] d on d.Media_ID=a.Media_ID and d.InfoType_ID not in
	(SELECT [InfoTypeID] FROM [sissearch2].[Ref_ExcludeInfoType] where [Media] = 1 and [Search2_Status] = 1 and [Selective_Exclude] = 0) 
	left join [sissearch2].[Ref_Selective_ExcludeInfoType] E
	on E.InfoTypeID  = d.InfoType_ID and E.[Excluded_Values] = c.Media_Origin
	where E.InfoTypeID IS NULL AND  c.Language_ID in (select Language_ID from sis.[Language] where Language_Code='en') --Limit to english
	) x
	Group by 
	[ID],
	[Media_Number],
	Family_Code,
	Subfamily_Code,
	Sales_Model,
	Serial_Number_Prefix
	ORDER BY 	[ID],
	[Media_Number],
	FamilyCode,
	SubfamilyCode,
	Sales_Model,
	Serial_Number_Prefix


SET @RowCount= @@RowCount


SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString';

--NCI
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID] 
ON #RecordsToString ([ID] ASC)
INCLUDE (
	[Media_Number],
	FamilyCode,
	SubfamilyCode,
	Sales_Model,
	Serial_Number_Prefix,
	[InsertDate])

/*
Family_Code
*/

Select  
ID, 
Media_Number,
FamilyCode,
max(InsertDate) INSERTDATE
Into #RecordsToString_FM
From #RecordsToString 
Group by ID, Media_Number, FamilyCode
order by  ID, Media_Number, FamilyCode

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID_FM] 
ON #RecordsToString_FM (ID ASC)
INCLUDE (Media_Number, FamilyCode, INSERTDATE)


--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  
    a.Media_Number,
	a.ID,
	'["' + string_agg(a.FamilyCode,'","') + '"]'  As RecordsToString,
	min(a.INSERTDATE) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into #RecordsToStringResult
from #RecordsToString_FM a
Group by 
a.Media_Number,
a.ID
order by a.Media_Number,
a.ID

SET @RowCount= @@RowCount


SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Temp RecordsToStringResult Family_Code';

--Add pkey to result
Alter Table #RecordsToStringResult Alter Column ID varchar(50) Not NULL
ALTER TABLE #RecordsToStringResult ADD PRIMARY KEY CLUSTERED (ID) 
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into [sissearch2].[Media_ProductHierarchy] (Media_Number,ID,familyCode,InsertDate)
Select Media_Number,ID,RecordsToString,INSERTDATE from #RecordsToStringResult

SET @RowCount= @@RowCount


SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Insert into Target, Family_Code, [sissearch2].[Media_ProductHierarchy]';

--Drop temp
Drop table #RecordsToStringResult
Drop table #RecordsToString_FM





/*
Subfamily_Code
*/

Select  
ID, 
Media_Number, 
----Family_Code,
----Subfamily_Code,
cast(FamilyCode + '_' + SubfamilyCode as varchar(MAX)) RTS,
max(InsertDate) INSERTDATE
Into #RecordsToString_SF
From #RecordsToString 
Group by ID, Media_Number, FamilyCode, SubfamilyCode
order by  ID, Media_Number, FamilyCode, SubfamilyCode

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID_SF] 
ON #RecordsToString_SF (ID ASC)
INCLUDE (Media_Number,RTS, INSERTDATE)

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  
    a.Media_Number,
	a.ID,
	'["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
	min(a.INSERTDATE) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into #RecordsToStringResult_SF
from #RecordsToString_SF a
Group by 
a.Media_Number,
a.ID
order by a.Media_Number,
a.ID

SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Temp RecordsToStringResult Subfamily_Code';

--Add pkey to result
Alter Table  #RecordsToStringResult_SF Alter Column ID varchar(50) Not NULL
ALTER TABLE  #RecordsToStringResult_SF ADD PRIMARY KEY CLUSTERED (ID) 

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Update x
set familySubFamilyCode = y.RecordsToString
From [sissearch2].[Media_ProductHierarchy]  x
inner join  #RecordsToStringResult_SF y on x.ID = y.ID

SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Update Target, Subfamily_Code, [sissearch2].[Media_ProductHierarchy]';

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
Media_Number, 
--Family_Code,
--Subfamily_Code,
--Sales_Model,
cast(FamilyCode + '_' + SubfamilyCode + '_' + Sales_Model as varchar(MAX)) RTS,
max(InsertDate) INSERTDATE
Into #RecordsToString_SM
From #RecordsToString 
Group by ID, Media_Number, FamilyCode, SubfamilyCode, Sales_Model
order by  ID, Media_Number, FamilyCode, SubfamilyCode, Sales_Model

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID_SM] 
ON #RecordsToString_SM (ID ASC)
INCLUDE (Media_Number,RTS, INSERTDATE)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Sales_Model'

Create table #RecordsToStringResult_SM
(
Media_Number varchar(50) not null,
ID varchar(50) not null,
RecordsToString varchar(max) null,
INSERTDATE datetime not null
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
    a.Media_Number,
	a.ID,
	'["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
	min(a.INSERTDATE) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from (Select top (@BatchCount) With Ties * From #RecordsToString_SM order by ID,RTS) a
Group by 
a.Media_Number,
a.ID
order by a.Media_Number,
a.ID

Set @BatchInsertCount = @@ROWCOUNT
SET @RowCount= @RowCount + @BatchInsertCount
Set @LoopCount = @LoopCount + 1


SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @BatchInsertCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Temp RecordsToStringResult Sales_Model';
--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Update x
set familySubFamilySalesModel = y.RecordsToString
From [sissearch2].[Media_ProductHierarchy]  x
inner join  #RecordsToStringResult_SM y on x.ID = y.ID

SET @UpdateCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @UpdateCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Update Target, Sales_Model, [sissearch2].[Media_ProductHierarchy]';

Delete a
From #RecordsToString_SM a
inner join (Select Distinct ID From (Select top (@BatchCount) with Ties ID From #RecordsToString_SM order by ID,RTS) x ) b on a.ID = b.ID

Set @BatchProcessCount = @@ROWCOUNT


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
Media_Number, 
cast(FamilyCode + '_' + SubfamilyCode + '_' + Sales_Model + '_' + Serial_Number_Prefix as varchar(MAX)) RTS,
max(InsertDate) INSERTDATE
Into #RecordsToString_SNP
From #RecordsToString 
Group by ID, Media_Number, FamilyCode, SubfamilyCode, Sales_Model, Serial_Number_Prefix
order by ID, Media_Number, FamilyCode, SubfamilyCode, Sales_Model, Serial_Number_Prefix

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID_SNP] 
ON #RecordsToString_SNP (ID ASC)
INCLUDE (Media_Number, RTS, INSERTDATE)

Create table #RecordsToStringResult_SNP
(
Media_Number varchar(50) not null,
ID varchar(50) not null,
RecordsToString varchar(max) null,
INSERTDATE datetime not null
)

--Add pkey to result
Alter Table  #RecordsToStringResult_SNP Alter Column ID varchar(50) Not NULL
ALTER TABLE  #RecordsToStringResult_SNP ADD PRIMARY KEY CLUSTERED (ID) 


While (Select count(*) from #RecordsToString_SNP) > 0
Begin

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into #RecordsToStringResult_SNP
Select  
    a.Media_Number,
	a.ID,
	'["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
	min(a.INSERTDATE) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from (Select top (@BatchCount) With Ties * From #RecordsToString_SNP order by ID,RTS) a
Group by 
a.Media_Number,
a.ID
order by 
a.Media_Number,
a.ID

Set @BatchInsertCount = @@ROWCOUNT
SET @RowCount= @RowCount + @BatchInsertCount
Set @LoopCount = @LoopCount + 1

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @BatchInsertCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Temp RecordsToStringResult Serial_Number_Prefix';

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Update x
set familySubFamilySalesModelSNP = y.RecordsToString
From [sissearch2].[Media_ProductHierarchy]  x
inner join  #RecordsToStringResult_SNP y on x.ID = y.ID

SET @UpdateCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @UpdateCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Update Target, Serial_Number_Prefix, [sissearch2].[Media_ProductHierarchy]';
	
Delete a
From #RecordsToString_SNP a
inner join (Select Distinct ID From (Select top (@BatchCount) with Ties ID From #RecordsToString_SNP order by ID,RTS) x ) b on a.ID = b.ID

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
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LogID = @SPStartLogID,@DATAVALUE = @RowCount

DELETE FROM sissearch2.Log WHERE DATEDIFF(DD, LogDateTime, GetDate())>30 and NameofSproc= @ProcName

END TRY

BEGIN CATCH 
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT= ERROR_LINE()

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC sissearch2.WriteLog @LogTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error
END CATCH

End