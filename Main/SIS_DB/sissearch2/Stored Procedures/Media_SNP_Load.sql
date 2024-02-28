CREATE  Procedure [sissearch2].[Media_SNP_Load] 
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
from  [sissearch2].[Media_SNP]
Except 
Select
	a.[Media_Number]
    from [sis].[Media] a
    inner join [sis].[Media_Effectivity] b
    on  a.Media_ID=b.Media_ID
    inner join [sis].[Media_Translation] c on  c.Media_ID=a.Media_ID
    inner join [sis].[Media_InfoType_Relation] d on d.Media_ID=a.Media_ID and d.InfoType_ID not in
	(SELECT [InfoTypeID] FROM [sissearch2].[Ref_ExcludeInfoType] where [Search2_Status] = 1 and [Selective_Exclude] = 0) 
	left join [sissearch2].[Ref_Selective_ExcludeInfoType] E
	on E.InfoTypeID  = d.InfoType_ID and E.[Excluded_Values] = c.Media_Origin
	where E.InfoTypeID IS NULL

SET @RowCount= @@RowCount


SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records Detected';

-- Delete Idenified Deleted Records in Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


Delete [sissearch2].[Media_SNP] 
From [sissearch2].[Media_SNP] a
inner join #DeletedRecords d on a.[Media_Number] = d.[Media_Number]

SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Deleted Records from Target [sissearch2].[Media_SNP]';

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [sissearch2].[Media_SNP]

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




SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Detected #InsertRecords';

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_iesystemcontrolnumber 
    ON #InsertRecords([Media_Number])


--Delete Inserted records from Target 	
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


Delete [sissearch2].[Media_SNP] 
From [sissearch2].[Media_SNP] a
inner join #InsertRecords d on a.[Media_Number] = d.[Media_Number]
SET @RowCount= @@RowCount   


SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Deleted Inserted Records from Target [sissearch2].[Media_SNP]';

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
Drop table #RecordsToString
End
select  a.Media_Number  as [ID], 
a.Media_Number ,
SNP.Serial_Number_Prefix AS Serial_Number_Prefix
,min(c.LastModified_Date) [InsertDate] --Must be updated to insert date
,cast(SNR.Start_Serial_Number as varchar(10))  AS Start_Serial_Number
,cast(SNR.End_Serial_Number as varchar(10)) AS End_Serial_Number
into #RecordsToString
from [sis].[Media] a
               inner join [sis].[Media_Effectivity] b on  a.Media_ID=b.Media_ID
               inner join [sis].[Media_Translation] c on  c.Media_ID=a.Media_ID
               inner join [sis].[Media_InfoType_Relation] d on d.Media_ID=a.Media_ID and d.InfoType_ID not in
               (SELECT [InfoTypeID] FROM [sissearch2].[Ref_ExcludeInfoType] where [Media] = 1 and [Search2_Status] = 1 and [Selective_Exclude] = 0) 
inner join #InsertRecords i on i.[Media_Number] = a.[Media_Number]
inner join sis.SerialNumberPrefix SNP on b.SerialNumberPrefix_ID=SNP.SerialNumberPrefix_ID
inner join sis.SerialNumberRange SNR on b.SerialNumberRange_ID= SNR.SerialNumberRange_ID
left join [sissearch2].[Ref_Selective_ExcludeInfoType] E
on E.InfoTypeID  = d.InfoType_ID and E.[Excluded_Values] = c.Media_Origin
where E.InfoTypeID IS NULL AND  c.Language_ID in (select Language_ID from sis.[Language] where Language_Code='en') --Limit to english
Group by 
               a.Media_Number,
               SNP.Serial_Number_Prefix
      ,cast(SNR.Start_Serial_Number as varchar(10))
                 ,cast(SNR.End_Serial_Number as varchar(10)) 


SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to #RecordsToString';

--NCI
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID] 
ON #RecordsToString ([ID],Serial_Number_Prefix,Start_Serial_Number,End_Serial_Number)
INCLUDE (Media_Number,InsertDate)


SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString_Ranked') is not null
Begin 
Drop table #RecordsToString_Ranked
End
Select
case 
	when RowRank < 3000 then x.ID
	else x.ID + '_' + cast(RowRank / 3000 as varchar(50))
end ID, --First 3000 records get no suffix.  Subsequent 3000 get suffixed with _1.
x.Media_Number, 
r.Serial_Number_Prefix,
x.Start_Serial_Number,
x.End_Serial_Number,
r.InsertDate,
x.RowRank
Into #RecordsToString_Ranked
From 
(
	--Get
	Select 
	ID,
	Media_Number, 
	Start_Serial_Number,
	End_Serial_Number,
	Row_Number() Over (Partition By Media_Number Order BY cast(Start_Serial_Number as bigint)) - 1 RowRank --Change to zero base
	From #RecordsToString
	Group by ID, Media_Number, Start_Serial_Number, End_Serial_Number
) x
--Get the SNP & InsertDate
Inner Join #RecordsToString r on 
	x.Media_Number = r.Media_Number and 
	x.Start_Serial_Number = r.Start_Serial_Number and
	x.End_Serial_Number = r.End_Serial_Number

SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString_Ranked';


SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


If Object_ID('Tempdb..#SNPArray') is not null
Begin 
Drop table #SNPArray
End


SELECT [ID],
Media_Number,
ISNULL('["' + STRING_AGG(cast(Serial_Number_Prefix as varchar(max)),'","') WITHIN GROUP (ORDER BY Serial_Number_Prefix) + '"]','[]') AS [serialNumbers.serialNumberPrefixes],
Start_Serial_Number as [serialNumbers.beginningRange],
End_Serial_Number as [serialNumbers.endRange],
max(InsertDate) [InsertDate]
Into #SNPArray
FROM #RecordsToString_Ranked
GROUP BY 
ID,
Media_Number,
Start_Serial_Number,
End_Serial_Number	

SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to #SNPArray';


Insert into [sissearch2].[Media_SNP] (Media_Number,ID,[SerialNumbers],InsertDate)
SELECT 
Media_Number,
ID,
(
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
Media_Number

SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Target [sissearch2].[Media_SNP]';

--Complete

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


