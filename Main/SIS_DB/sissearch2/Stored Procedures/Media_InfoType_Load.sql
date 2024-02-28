CREATE  Procedure [sissearch2].[Media_InfoType_Load] 
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
	(SELECT [InfoTypeID] FROM [sissearch2].[Ref_ExcludeInfoType] where [Media] = 1 and [Search2_Status] = 1 and [Selective_Exclude] = 0) 
	left join [sissearch2].[Ref_Selective_ExcludeInfoType] E
	on E.InfoTypeID  = d.InfoType_ID and E.[Excluded_Values] = c.Media_Origin
	where E.InfoTypeID IS NULL

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records Detected';

-- Delete Idenified Deleted Records in Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [sissearch2].[Media_InfoType] 
From [sissearch2].[Media_InfoType] a
inner join #DeletedRecords d on a.[Media_Number] = d.[Media_Number]

SET @RowCount= @@RowCount


SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records from Target [sissearch2].[Media_Infotype]';

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [sissearch2].[Media_InfoType]


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
	(SELECT [InfoTypeID] FROM [sissearch2].[Ref_ExcludeInfoType] where [Media] = 1 and [Search2_Status] = 1 and [Selective_Exclude] = 0) 
	left join [sissearch2].[Ref_Selective_ExcludeInfoType] E
	on E.InfoTypeID  = d.InfoType_ID and E.[Excluded_Values] = c.Media_Origin
	where E.InfoTypeID IS NULL
	AND c.LastModified_Date  > @LastInsertDate
	group by a.[Media_Number]


SET @RowCount= @@RowCount


SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Detected #InsertRecords';

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_iesystemcontrolnumber 
    ON #InsertRecords([Media_Number])

----Delete Inserted records from Target 	
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete [sissearch2].[Media_InfoType] 
From [sissearch2].[Media_InfoType] a
inner join #InsertRecords d on a.[Media_Number] = d.[Media_Number]

SET @RowCount= @@RowCount   


SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Deleted Inserted Records from Target [sissearch2].[Media_Infotype]';

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
Drop table #RecordsToString
End

select a.[Media_Number] as [ID], 
	a.[Media_Number] AS [Media_Number],
	d.InfoType_ID AS InfoType_ID,
	min(c.LastModified_Date) [InsertDate] --Must be updated to insert date
into #RecordsToString
from [sis].[Media] a
	inner join 	
	(select Media_ID from [sis].[Media_Effectivity] 
	 union
	 select Media_ID from [sis].[Media_ProductFamily_Effectivity] 
	) b on  a.Media_ID=b.Media_ID
	inner join [sis].[Media_Translation] c on  c.Media_ID=a.Media_ID
	inner join [sis].[Media_InfoType_Relation] d on d.Media_ID=a.Media_ID and d.InfoType_ID not in
	(SELECT [InfoTypeID] FROM [sissearch2].[Ref_ExcludeInfoType] where [Media] = 1 and [Search2_Status] = 1 and [Selective_Exclude] = 0) 
	inner join #InsertRecords i on i.[Media_Number] = a.[Media_Number]
	left join [sissearch2].[Ref_Selective_ExcludeInfoType] E
	on E.InfoTypeID  = d.InfoType_ID and E.[Excluded_Values] = c.Media_Origin
	where E.InfoTypeID IS NULL AND  c.Language_ID in (select Language_ID from sis.[Language] where Language_Code='en') --Limit to english
	Group by 
	a.Media_Number,
	d.InfoType_ID
	order by
	d.InfoType_ID

	SET @RowCount= @@RowCount


SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString';

--NCI
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID] 
ON #RecordsToString ([ID] ASC)
INCLUDE ([Media_Number],InfoType_ID,[InsertDate])

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;



Insert into [sissearch2].[Media_InfoType] (Media_Number,ID,[InformationType],InsertDate)
Select  
    a.[Media_Number],
	a.ID,
	coalesce(f.InfoTypeString,'') As InformationType,
	min(a.InsertDate) InsertDate --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from  #RecordsToString a
cross apply 
(
	SELECT  '[' + stuff
	(
		(SELECT '","'+ cast(InfoType_ID as varchar(MAX))        
		FROM #RecordsToString as b 
		where a.ID=b.ID 
		order by b.InfoType_ID
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')   
	,1,2,'') + '"'+']'     
) f (InfoTypeString)
Group by 
a.[Media_Number],
a.ID,
f.InfoTypeString


SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Target [sissearch2].[Media_Infotype]';

SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LogID = @SPStartLogID,@DATAVALUE = @RowCount

DELETE FROM sissearch2.Log WHERE DATEDIFF(DD, LogDateTime, GetDate())>30 and NameofSproc= @ProcName


END TRY

BEGIN CATCH 
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT= ERROR_LINE()
		 SELECT @ERRORMESSAGE,@ERROELINE
declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC sissearch2.WriteLog @LogTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error
END CATCH


End
GO


