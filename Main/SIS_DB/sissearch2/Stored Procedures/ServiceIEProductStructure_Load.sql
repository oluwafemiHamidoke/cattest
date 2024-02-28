Create Procedure [sissearch2].[ServiceIEProductStructure_Load]
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
Select distinct
	[IESystemControlNumber]
into #DeletedRecords
from  [sissearch2].[ServiceIE_ProductStructure]
Except
Select Distinct
	a.IESystemControlNumber
From sis.IE a
inner join (select IE_ID from sis.IE_Effectivity 
union select IE_ID from sis.IE_ProductFamily_Effectivity) b on a.IE_ID=b.IE_ID
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

Delete [sissearch2].[ServiceIE_ProductStructure]
From [sissearch2].[ServiceIE_ProductStructure] a
inner join #DeletedRecords d on a.[IESystemControlNumber] = d.[IESystemControlNumber]

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
@LOGMESSAGE =  'Deleted Records from Target [sissearch2].[ServiceIE_ProductStructure]';

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [sissearch2].[ServiceIE_ProductStructure]
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
	From 	sis.IE a
inner join (select IE_ID from sis.IE_Effectivity 
union select IE_ID from sis.IE_ProductFamily_Effectivity) b on a.IE_ID=b.IE_ID
inner join sis.IE_InfoType_Relation g on g.IE_ID=a.IE_ID
and g.InfoType_ID not in (Select x.InfoTypeID from sissearch2.Ref_ExcludeInfoType x)
left outer join sis.IE_Translation e on e.IE_ID=a.IE_ID
inner join sis.Language f on e.Language_ID=f.Language_ID and f.Language_Tag='en-US'
where isnull(e.LastModified_Date, getdate()) > @LastInsertDate
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

Delete [sissearch2].[ServiceIE_ProductStructure]
From [sissearch2].[ServiceIE_ProductStructure] a
inner join #InsertRecords d on a.IESystemControlNumber = d.IESystemControlNumber

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
@LOGMESSAGE =  'Deleted Inserted Records from Target [sissearch2].[ServiceIE_ProductStructure]';

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin
Drop table #RecordsToString
End

;with CTE as
(
select a.IESystemControlNumber as [ID],
	a.IESystemControlNumber,
	case
		when h.PARENTPRODUCTSTRUCTURE_ID <> '00000000' then h.PARENTPRODUCTSTRUCTURE_ID
	else 
	h.ProductStructure_ID
    end as [SystemPSID],
	max(e.LastModified_Date) [InsertDate] --Must be updated to insert date
From 	sis.IE a
inner join #InsertRecords i on
a.IESystemControlNumber = i.IESystemControlNumber --Limit to inserted records
inner join (select IE_ID from sis.IE_Effectivity 
union select IE_ID from sis.IE_ProductFamily_Effectivity) b on a.IE_ID=b.IE_ID
inner join sis.IE_InfoType_Relation g on g.IE_ID=a.IE_ID
and g.InfoType_ID not in (Select x.InfoTypeID from sissearch2.Ref_ExcludeInfoType x)
left outer join sis.IE_Translation e on e.IE_ID=a.IE_ID
inner join sis.Language f on e.Language_ID=f.Language_ID and f.Language_Tag='en-US'
inner join sis.ProductStructure_IE_Relation j on a.IE_ID=j.IE_ID
inner join sis.ProductStructure h on j.ProductStructure_ID=h.ProductStructure_ID
Group by
a.IESystemControlNumber,
case
	when h.ParentProductStructure_ID <> '00000000' then h.ParentProductStructure_ID
	else h.ProductStructure_ID
end
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
INCLUDE (IESystemControlNumber,[SystemPSID],[InsertDate])
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


Insert into [sissearch2].[ServiceIE_ProductStructure]
(
	[ID]
	,[IESystemControlNumber]
	,[System]
	,[SystemPSID]
	,[InsertDate]
)
Select
	a.ID,
	a.IESystemControlNumber,
	coalesce(f.SystemString,'') As [SystemPSID],
	coalesce(f.SystemString,'') As [SystemPSID],
	min(a.InsertDate) InsertDate --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from  #RecordsToString a
cross apply
(
	SELECT  '[' + stuff
	(
		(SELECT '","'+ cast([SystemPSID] as varchar(MAX))
		FROM #RecordsToString as b
		where a.ID=b.ID
		order by b.ID
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
	,1,2,'') + '"'+']'
) f (SystemString)
Group by
a.ID,
a.IESystemControlNumber,
f.SystemString

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
@LOGMESSAGE =  'Inserted into Target [sissearch2].[ServiceIE_ProductStructure]';

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