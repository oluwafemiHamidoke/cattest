Create  Procedure [sissearch2].[ServiceIESMCS_Load] 
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
from  [sissearch2].[ServiceIE_SMCS]
Except 
Select a.IESystemControlNumber
From [sis].[IE] a
inner join (select IE_ID from [sis].[IE_Effectivity] union select IE_ID from [sis].[IE_ProductFamily_Effectivity]) e
on a.IE_ID=e.IE_ID
inner join [sis].[IE_InfoType_Relation] b on a.IE_ID=b.IE_ID
and b.InfoType_ID not in (Select x.InfoTypeID from sissearch2.Ref_ExcludeInfoType x)  		
inner join [sis].[IE_Translation] d on a.IE_ID = d.IE_ID 
inner join [sis].[Language] c on d.Language_ID=c.Language_ID and c.Language_Tag='en-US'

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records Detected';

-- Delete Idenified Deleted Records in Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [sissearch2].[ServiceIE_SMCS]
From [sissearch2].[ServiceIE_SMCS] a
inner join #DeletedRecords d on a.[IESystemControlNumber] = d.[IESystemControlNumber]

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records from Target [sissearch2].[ServiceIE_SMCS]';

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	
Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [sissearch2].[ServiceIE_SMCS]
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
	Select
		a.IESystemControlNumber
	into #InsertRecords
	From [sis].[IE] a
	inner join [sis].[IE_InfoType_Relation] b on a.IE_ID=b.IE_ID
	and b.InfoType_ID not in (Select x.InfoTypeID from sissearch2.Ref_ExcludeInfoType x) 
	inner join (select IE_ID from [sis].[IE_Effectivity] union select IE_ID from [sis].[IE_ProductFamily_Effectivity]) c
	on c.IE_ID=a.IE_ID
	left outer join [sis].[IE_Translation] d on d.IE_ID=a.IE_ID
	inner join [sis].[Language] e on d.Language_ID=e.Language_ID and e.Language_Tag='en-US'
	and isnull(d.LastModified_Date, getdate()) > @LastInsertDate
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

Delete [sissearch2].[ServiceIE_SMCS]
From [sissearch2].[ServiceIE_SMCS] a
inner join #InsertRecords d on a.IESystemControlNumber = d.IESystemControlNumber

SET @RowCount= @@RowCount   
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Deleted Inserted Records from Target [sissearch2].[ServiceIE_SMCS]';

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
										isnull(d.SMCSCOMPCODE, '')
									,'\', '\\')
								,char(8), ' ')
							,char(9), ' ')
						,char(10), ' ')
					,char(11), ' ')
				,char(12), ' ')
			,char(13), ' ')
			,'"', '\"')
		,'/', '\/') as  SMCSCOMPCODE,
	max(e.LASTMODIFIED_DATE) [InsertDate] --Must be updated to insert date
From [sis].[IE] a
inner join #InsertRecords i on 
	a.IESystemControlNumber = i.IESystemControlNumber --Limit to inserted records
inner join 
(select IE_ID from [sis].[IE_Effectivity] 
union select IE_ID from [sis].[IE_ProductFamily_Effectivity]) g on a.IE_ID=g.IE_ID
inner join [sis].[IE_InfoType_Relation] b on a.IE_ID=b.IE_ID
and b.InfoType_ID not in (Select x.InfoTypeID from sissearch2.Ref_ExcludeInfoType x) 
inner join [sis].[SMCS_IE_Relation] c on a.IE_ID=c.IE_ID
inner join [sis].[SMCS] d on c.SMCS_ID=d.SMCS_ID
left outer join [sis].[IE_Translation] e on a.IE_ID=e.IE_ID
inner join [sis].[Language] f on e.Language_ID=f.Language_ID and f.Language_Tag='en-US'
Group by 
a.IESystemControlNumber,
d.SMCSCOMPCODE
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
INCLUDE (IESystemControlNumber,SMCSCOMPCODE,[InsertDate])
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


Insert into [sissearch2].[ServiceIE_SMCS]
(
	[ID]
	,[IESystemControlNumber]
	,SMCSCompCode
	,[InsertDate]
)
Select
	a.ID,
	a.IESystemControlNumber,
	coalesce(f.SMCSCOMPCODEString,'') As SMCSCOMPCODE,
	min(a.InsertDate) InsertDate --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from  #RecordsToString a
cross apply 
(
	SELECT  '[' + stuff
	(
		(SELECT '","'+ cast(SMCSCOMPCODE as varchar(MAX))        
		FROM #RecordsToString as b 
		where a.ID=b.ID
		order by b.ID
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')   
	,1,2,'') + '"'+']'     
) f (SMCSCOMPCODEString)
Group by 
a.ID,
a.IESystemControlNumber,
f.SMCSCOMPCODEString

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Target [sissearch2].[ServiceIE_SMCS]';

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