/****** Object:  StoredProcedure [sissearch2].[ServiceIEProductFamily_Load]    Script Date: 8/16/2022 11:26:52 AM ******/
Create Procedure [sissearch2].[ServiceIEProductFamily_Load]  
AS   
Begin

BEGIN TRY   

    SET NOCOUNT ON; 
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

Select distinct
	a.[IESystemControlNumber]
into #DeletedRecords
from  [sissearch2].[ServiceIE_ProductFamily] a
left outer join 
( 
select Distinct a.IESystemControlNumber
from [sis].[IE] a
inner join [sis].[IE_Translation] d on a.IE_ID=d.IE_ID
inner join [sis].[Language] c on d.Language_ID=c.Language_ID and c.Language_Tag='en-US'
inner join [sis].[IE_InfoType_Relation] b on a.IE_ID = b.IE_ID
and b.InfoType_ID not in (Select x.InfoTypeID from sissearch2.Ref_ExcludeInfoType x) 
and b.IE_ID in (select IE_ID from [sis].[IE_Effectivity] 
union 
select IE_ID from [sis].[IE_ProductFamily_Effectivity]) 
) x on a.IESystemControlNumber = x.Iesystemcontrolnumber
where x.IESystemControlNumber is null --If x is null then it no longer exist in the source; deleted


SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records Detected';

-- Delete Idenified Deleted Records in Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [sissearch2].[SERVICEIE_PRODUCTFAMILY] 
From [sissearch2].[SERVICEIE_PRODUCTFAMILY] a
inner join #DeletedRecords d on a.[IESystemControlNumber] = d.[IESystemControlNumber]

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records from Target [sissearch].[SERVICEIE_PRODUCTFAMILY]';

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	
Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [sissearch2].[SERVICEIE_PRODUCTFAMILY]
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
	Select Distinct
	a.IESystemControlNumber
	into #InsertRecords
	From [sis].[IE] a
	inner join [sis].[IE_ProductFamily_Effectivity] b on a.IE_ID=b.IE_ID
	inner join [sis].[IE_InfoType_Relation] c on a.IE_ID=c.IE_ID
	and c.InfoType_ID not in (Select x.InfoTypeID from sissearch2.Ref_ExcludeInfoType x) 
	left outer join [sis].[IE_Translation] d on a.IE_ID=d.IE_ID
	inner join [sis].[Language] e on d.Language_ID=e.Language_ID and e.Language_Tag='en-US'
	where isnull(d.LastModified_Date, getdate()) > @LastInsertDate 

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

Delete [sissearch2].[SERVICEIE_PRODUCTFAMILY] 
From [sissearch2].[SERVICEIE_PRODUCTFAMILY] a
inner join #InsertRecords d on a.IESystemControlNumber = d.IESystemControlNumber

SET @RowCount= @@RowCount   
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Inserted Records from Target [sissearch2].[SERVICEIE_PRODUCTFAMILY]';

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
Drop table #RecordsToString
End

;with CTE as
(
select a.IESystemControlNumber as [ID], 
	--cast(a.BEGINNINGRANGE as varchar(10)) [BeginRange],
	--cast(a.ENDRANGE as varchar(10)) [EndRange],
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
										isnull(g.Family_Code, '')
									,'\', '\\')
								,char(8), ' ')
							,char(9), ' ')
						,char(10), ' ')
					,char(11), ' ')
				,char(12), ' ')
			,char(13), ' ')
			,'"', '\"')
		,'/', '\/') as  ProductCodes,
	max(e.LastModified_Date) [InsertDate] --Must be updated to insert date NOTE: Change to last modified date when field becomes avaialble
From [sis].[IE] a
inner join #InsertRecords i on 
	a.IESystemControlNumber = i.IESystemControlNumber --Limit to inserted records
inner join [sis].[IE_ProductFamily_Effectivity] b on a.IE_ID=b.IE_ID
inner join [sis].[ProductFamily] g on b.ProductFamily_ID=g.ProductFamily_ID
inner join [sis].[IE_InfoType_Relation] c on a.IE_ID=c.IE_ID
and c.INFOTYPE_ID not in (Select x.InfoTypeID from sissearch2.Ref_ExcludeInfoType x) 		
left outer join [sis].[IE_Translation] e on a.IE_ID=e.IE_ID
inner join [sis].[Language] f on e.Language_ID=f.Language_ID and f.Language_Tag='en-US'
Group by 
a.IESystemControlNumber,
g.Family_Code
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
ON #RecordsToString ([ID] ASC)
INCLUDE (IESystemControlNumber,ProductCodes,[InsertDate])
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


Insert into [sissearch2].[SERVICEIE_PRODUCTFAMILY] 
(
	[ID]
	,[IESystemControlNumber]
	,[ProductCodes]
	,[InsertDate]
)
Select
	a.ID,
	a.IESystemControlNumber,
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
a.IESystemControlNumber,
f.ProductCodeString

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Target [sissearch2].[SERVICEIE_PRODUCTFAMILY]';

SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LOGID = @SPStartLogID,@DATAVALUE = @RowCount

DELETE FROM SISSEARCH.LOG WHERE DATEDIFF(DD, LogDateTime, GetDate())>30 and NameofSproc= @ProcName

END TRY

BEGIN CATCH 
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT= ERROR_LINE()

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC SISSEARCH.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error
END CATCH


End

