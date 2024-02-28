

CREATE  Procedure [SISSEARCH].[PRODUCTHIERARCHY_2_LOAD] 
As
/*---------------
Date: 20190402
Object Description:  Loading changed data into SISSEARCH.PRODUCTHIERARCHY from base tables
Exec [SISSEARCH].[PRODUCTHIERARCHY_2_LOAD]
Truncate table [SISSEARCH].[PRODUCTHIERARCHY_2]
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
from  [SISSEARCH].[PRODUCTHIERARCHY_2]
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

Delete [SISSEARCH].[PRODUCTHIERARCHY_2] 
from [SISSEARCH].[PRODUCTHIERARCHY_2] a
left outer join #DeletedRecords d on a.Iesystemcontrolnumber = d.Iesystemcontrolnumber
where  d.Iesystemcontrolnumber is not null or --Deleted
a.familySubFamilyCode is null or --Not full loaded
a.familySubFamilySalesModel is null or  --Not full loaded
a.familySubFamilySalesModelSNP is null --Not full loaded

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records from Target [SISSEARCH].[PRODUCTHIERARCHY_2]';


--Get Maximum insert date from Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	
Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [SISSEARCH].[PRODUCTHIERARCHY_2]
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

Delete from [SISSEARCH].[PRODUCTHIERARCHY_2]
where Iesystemcontrolnumber in
 (Select IESYSTEMCONTROLNUMBER from  #InsertRecords)
 
SET @RowCount= @@RowCount   
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Inserted Records from Target [SISSEARCH].[PRODUCTHIERARCHY_2]';

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

select a.IESYSTEMCONTROLNUMBER as id, 
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
									isnull(b.Family_Code,'')
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
									isnull(b.Subfamily_Code,'')
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
									isnull(b.Sales_Model,'')
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
									isnull(b.Serial_Number_Prefix,'')
								,'\', '\\')
							,char(8), ' ')
						,char(9), ' ')
					,char(10), ' ')
				,char(11), ' ')
			,char(12), ' ')
		,char(13), ' ')
		,'"', '\"')
	,'/', '\/') as Serial_Number_Prefix,
c.LASTMODIFIEDDATE INSERTDATE
into #RecordsToString
from SISWEB_OWNER_SHADOW.LNKPARTSIESNP a
inner join sis.vw_Product b on a.SNP=b.Serial_Number_Prefix 
inner join SISWEB_OWNER_SHADOW.LNKMEDIAIEPART c on a.IESYSTEMCONTROLNUMBER = c.IESYSTEMCONTROLNUMBER
inner join [SISWEB_OWNER].[MASMEDIA] d on d.MEDIANUMBER=c.MEDIANUMBER and d.MEDIASOURCE in ('A','C')
inner join #InsertRecords i on i.IESYSTEMCONTROLNUMBER = a.IESYSTEMCONTROLNUMBER  --Add filter to limit to changed records
where a.SNPTYPE='P' 

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to #RecordsToString';

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID] 
ON #RecordsToString (id ASC)
INCLUDE (IESYSTEMCONTROLNUMBER,Family_Code, Subfamily_Code, Sales_Model, Serial_Number_Prefix, INSERTDATE)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'



/*
Family_Code
*/

Select  
id, 
IESYSTEMCONTROLNUMBER,
Family_Code,
max(INSERTDATE) INSERTDATE
Into #RecordsToString_FM
From #RecordsToString 
Group by id, IESYSTEMCONTROLNUMBER, Family_Code

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID_FM] 
ON #RecordsToString_FM (id ASC)
INCLUDE (IESYSTEMCONTROLNUMBER, Family_Code, INSERTDATE)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Family_Code'

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  
    a.IESYSTEMCONTROLNUMBER,
	a.id,
	'["' + string_agg(a.Family_Code,'","') + '"]'  As RecordsToString,
	min(a.INSERTDATE) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into #RecordsToStringResult
from #RecordsToString_FM a
Group by 
a.IESYSTEMCONTROLNUMBER,
a.id

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Family_Code, Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Temp RecordsToStringResult Family_Code';

--Add pkey to result
Alter Table #RecordsToStringResult Alter Column id varchar(50) Not NULL
ALTER TABLE #RecordsToStringResult ADD PRIMARY KEY CLUSTERED (id) 
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into [SISSEARCH].[PRODUCTHIERARCHY_2] (Iesystemcontrolnumber,ID,familyCode,InsertDate)
Select IESYSTEMCONTROLNUMBER,id,RecordsToString,INSERTDATE from #RecordsToStringResult

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Insert into Target Count, Family_Code: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Insert into Target, Family_Code, [SISSEARCH].[PRODUCTHIERARCHY_2]';

--Drop temp
Drop table #RecordsToStringResult
Drop table #RecordsToString_FM





/*
Subfamily_Code
*/

Select  
id, 
IESYSTEMCONTROLNUMBER, 
----Family_Code,
----Subfamily_Code,
cast(Family_Code + '_' + Subfamily_Code as varchar(MAX)) RTS,
max(INSERTDATE) INSERTDATE
Into #RecordsToString_SF
From #RecordsToString 
Group by id, IESYSTEMCONTROLNUMBER, Family_Code, Subfamily_Code

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID_SF] 
ON #RecordsToString_SF (id ASC)
INCLUDE (IESYSTEMCONTROLNUMBER,RTS, INSERTDATE)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Subfamily_Code'

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  
    a.IESYSTEMCONTROLNUMBER,
	a.id,
	'["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
	min(a.INSERTDATE) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into #RecordsToStringResult_SF
from #RecordsToString_SF a
Group by 
a.IESYSTEMCONTROLNUMBER,
a.id

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Subfamily_Code, Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Temp RecordsToStringResult Subfamily_Code';

--Add pkey to result
Alter Table  #RecordsToStringResult_SF Alter Column id varchar(50) Not NULL
ALTER TABLE  #RecordsToStringResult_SF ADD PRIMARY KEY CLUSTERED (id) 
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Update x
set familySubFamilyCode = y.RecordsToString
From [SISSEARCH].[PRODUCTHIERARCHY_2]  x
inner join  #RecordsToStringResult_SF y on x.ID = y.id

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Update Target Count, Subfamily_Code: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Update Target, Subfamily_Code, [SISSEARCH].[PRODUCTHIERARCHY_2]';

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
IESYSTEMCONTROLNUMBER, 
--Family_Code,
--Subfamily_Code,
--Sales_Model,
cast(Family_Code + '_' + Subfamily_Code + '_' + Sales_Model as varchar(MAX)) RTS,
max(INSERTDATE) INSERTDATE
Into #RecordsToString_SM
From #RecordsToString 
Group by id, IESYSTEMCONTROLNUMBER, Family_Code, Subfamily_Code, Sales_Model

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID_SM] 
ON #RecordsToString_SM (id ASC)
INCLUDE (IESYSTEMCONTROLNUMBER,RTS, INSERTDATE)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Sales_Model'

Create table #RecordsToStringResult_SM
(
IESYSTEMCONTROLNUMBER varchar(50) not null,
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
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into #RecordsToStringResult_SM
Select  
    a.IESYSTEMCONTROLNUMBER,
	a.id,
	'["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
	min(a.INSERTDATE) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from (Select top (@BatchCount) With Ties * From #RecordsToString_SM order by id) a
Group by 
a.IESYSTEMCONTROLNUMBER,
a.id


Set @BatchInsertCount = @@ROWCOUNT
SET @RowCount= @RowCount + @BatchInsertCount
Set @LoopCount = @LoopCount + 1

--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Sales_Model, Count: ' + Cast(@BatchInsertCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @BatchInsertCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Temp RecordsToStringResult Sales_Model';

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Update x
set familySubFamilySalesModel = y.RecordsToString
From [SISSEARCH].[PRODUCTHIERARCHY_2]  x
inner join  #RecordsToStringResult_SM y on x.ID = y.id

SET @UpdateCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Update Target Count, Sales_Model: ' + Cast(@UpdateCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @UpdateCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Update Target, Sales_Model, [SISSEARCH].[PRODUCTHIERARCHY_2]';

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
IESYSTEMCONTROLNUMBER, 
--Family_Code,
--Subfamily_Code,
--Sales_Model,
--Serial_Number_Prefix,
cast(Family_Code + '_' + Subfamily_Code + '_' + Sales_Model + '_' + Serial_Number_Prefix as varchar(MAX)) RTS,
max(INSERTDATE) INSERTDATE
Into #RecordsToString_SNP
From #RecordsToString 
Group by id, IESYSTEMCONTROLNUMBER, Family_Code, Subfamily_Code, Sales_Model, Serial_Number_Prefix

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID_SNP] 
ON #RecordsToString_SNP (id ASC)
INCLUDE (IESYSTEMCONTROLNUMBER, RTS, INSERTDATE)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Sales_Model'

Create table #RecordsToStringResult_SNP
(
IESYSTEMCONTROLNUMBER varchar(50) not null,
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
    a.IESYSTEMCONTROLNUMBER,
	a.id,
	'["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
	min(a.INSERTDATE) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from (Select top (@BatchCount) With Ties * From #RecordsToString_SNP order by id) a
Group by 
a.IESYSTEMCONTROLNUMBER,
a.id

Set @BatchInsertCount = @@ROWCOUNT
SET @RowCount= @RowCount + @BatchInsertCount
Set @LoopCount = @LoopCount + 1

--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Serial_Number_Prefix, Count: ' + Cast(@BatchInsertCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @BatchInsertCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Temp RecordsToStringResult Serial_Number_Prefix';

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Update x
set familySubFamilySalesModelSNP = y.RecordsToString
From [SISSEARCH].[PRODUCTHIERARCHY_2]  x
inner join  #RecordsToStringResult_SNP y on x.ID = y.id

SET @UpdateCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Update Target Count, Serial_Number_Prefix: ' + Cast(@UpdateCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @UpdateCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Update Target, Serial_Number_Prefix, [SISSEARCH].[PRODUCTHIERARCHY_2]';

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

DELETE FROM SISSEARCH.LOG WHERE DATEDIFF(DD, LogDateTime, GetDate())>30 and NameofSproc= @ProcName

SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LOGID = @SPStartLogID

END TRY

BEGIN CATCH 
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT= ERROR_LINE()

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC SISSEARCH.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error
END CATCH

End
