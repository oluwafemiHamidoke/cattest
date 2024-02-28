CREATE  Procedure [SISSEARCH].[SERVICEIEPRODUCTFAMILY_2_LOAD] 
As
/*---------------
Date: 20180504
Object Description:  Loading changed data into SISSEARCH.SERVICEIEPRODUCTFAMILY_2 from base tables
Object Description:  Loading changed data into SISSEARCH.BASICSERVICEIE_2 from base tables
Exec [SISSEARCH].[SERVICEIEPRODUCTFAMILY_2_LOAD]
Truncate table [SISSEARCH].[SERVICEIEPRODUCTFAMILY_2]
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

--20180606 pbf: Changed from using set operator (except) to left join with null filter for performance reasons
--Select distinct
--	[IESystemControlNumber]
--into #DeletedRecords
--from  [SISSEARCH].[SERVICEIEPRODUCTFAMILY_2]
--Except 
--Select Distinct
--	a.IESYSTEMCONTROLNUMBER
--From [SISWEB_OWNER].[LNKIESNP] a
--inner join [SISWEB_OWNER].[LNKIEINFOTYPE] b on 
--	a.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER and
--	b.INFOTYPEID not in (Select [INFOTYPEID] from SISSEARCH.REF_EXCLUDEINFOTYPE) 		
--inner join [SISWEB_OWNER].[LNKIETITLE] d on 
--	a.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER and
--	d.IELANGUAGEINDICATOR = 'E' and
--	(d.GROUPTITLEINDICATOR='N' OR GROUPTITLEINDICATOR is NULL)

Select distinct
	a.[IESystemControlNumber]
into #DeletedRecords
from  [SISSEARCH].[SERVICEIEPRODUCTFAMILY_2] a
left outer join 
( 
Select Distinct
	a.IESYSTEMCONTROLNUMBER
From [SISWEB_OWNER].[LNKIESNP] a
inner join [SISWEB_OWNER].[LNKIEINFOTYPE] b on 
	a.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER and
	b.INFOTYPEID not in (Select [INFOTYPEID] from SISSEARCH.REF_EXCLUDEINFOTYPE) 		
inner join [SISWEB_OWNER].[LNKIETITLE] d on 
	a.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER and
	d.IELANGUAGEINDICATOR = 'E' and
	(d.GROUPTITLEINDICATOR='N' OR GROUPTITLEINDICATOR is NULL)
) x on a.IESystemControlNumber = x.IESYSTEMCONTROLNUMBER
where x.IESYSTEMCONTROLNUMBER is null --If x is null then it no longer exist in the source; deleted


SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records Detected';

-- Delete Idenified Deleted Records in Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [SISSEARCH].[SERVICEIEPRODUCTFAMILY_2] 
From [SISSEARCH].[SERVICEIEPRODUCTFAMILY_2] a
inner join #DeletedRecords d on a.[IESystemControlNumber] = d.[IESystemControlNumber]

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records from Target [SISSEARCH].[SERVICEIEPRODUCTFAMILY_2]';

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	
Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [SISSEARCH].[SERVICEIEPRODUCTFAMILY_2]
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
	Select Distinct
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
		(d.GROUPTITLEINDICATOR='N' OR d.GROUPTITLEINDICATOR is NULL)
	where isnull(e.LASTMODIFIEDDATE, getdate()) > @LastInsertDate 
	and a.TYPEINDICATOR = 'P' --Limit to Type
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

Delete [SISSEARCH].[SERVICEIEPRODUCTFAMILY_2] 
From [SISSEARCH].[SERVICEIEPRODUCTFAMILY_2] a
inner join #InsertRecords d on a.IESystemControlNumber = d.IESYSTEMCONTROLNUMBER

SET @RowCount= @@RowCount   
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Inserted Records from Target [SISSEARCH].[SERVICEIEPRODUCTFAMILY_2]';

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
Drop table #RecordsToString
End

;with CTE as
(
select a.IESYSTEMCONTROLNUMBER as [ID], 
	--cast(a.BEGINNINGRANGE as varchar(10)) [BeginRange],
	--cast(a.ENDRANGE as varchar(10)) [EndRange],
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
		,'/', '\/') as  ProductCodes,
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
Where a.TYPEINDICATOR = 'P' --Limite to Type
Group by 
a.IESYSTEMCONTROLNUMBER,
--cast(a.BEGINNINGRANGE as varchar(10)),
--cast(a.ENDRANGE as varchar(10)),
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
ON #RecordsToString ([ID] ASC)
INCLUDE (IESYSTEMCONTROLNUMBER,ProductCodes,[InsertDate])
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


Insert into [SISSEARCH].[SERVICEIEPRODUCTFAMILY_2] 
(
	[ID]
	--,[BeginRange]
	--,[EndRange]
	,[IESystemControlNumber]
	,[ProductCodes]
	,[InsertDate]
)
Select
	a.ID,
	--a.BeginRange,
	--a.EndRange,
	a.IESYSTEMCONTROLNUMBER,
	coalesce(f.ProductCodeString,'[""]') As SNP, --Change empty to [""] per Lu 20190930
	min(a.InsertDate) InsertDate --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from  #RecordsToString a
cross apply 
(
	SELECT  '[' + stuff
	(
		(SELECT '","'+ cast(ProductCodes as varchar(MAX))        
		FROM #RecordsToString as b 
		where a.ID=b.ID
		order by b.ID
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')   
	,1,2,'') + '"'+']'     
) f (ProductCodeString)
Group by 
a.ID,
--a.BeginRange,
--a.EndRange,
a.IESYSTEMCONTROLNUMBER,
f.ProductCodeString

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Target [SISSEARCH].[SERVICEIEPRODUCTFAMILY_2]';

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
