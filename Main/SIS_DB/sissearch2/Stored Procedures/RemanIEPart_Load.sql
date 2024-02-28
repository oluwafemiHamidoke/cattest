CREATE  Procedure [sissearch2].[RemanIEPart_Load] As
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

SET @SPStartTime = GETDATE()
SET @ProcName = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)

--Identify Deleted Records From Source

EXEC @SPStartLogID = sissearch2.WriteLog @TIME = @SPStartTime, @NAMEOFSPROC = @ProcName;
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#DeletedRecords') is not null
  Begin
    Drop table #DeletedRecords
  End

Select Distinct IESystemControlNumber
into #DeletedRecords
From [sissearch2].[RemanIEPart]
Except
Select Distinct MS.IESystemControlNumber
From [sis_shadow].[MediaSequence] MS
inner join [sis].[IEPart] IP on IP.IEPart_ID = MS.IEPart_ID

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, @LOGMESSAGE =  'Deleted Records Detected';

-- Delete Idenified Deleted Records in Target
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete From [sissearch2].[RemanIEPart]
Where IESystemControlNumber  IN (Select IESystemControlNumber From #DeletedRecords)

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, @LOGMESSAGE =  'Deleted Records from Target [sissearch2].[RemanIEPart] ';

--Get Maximum insert date from Target	
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select @LastInsertDate = coalesce(Max(InsertDate),'1900-01-01') From [sissearch2].[RemanIEPart]
--Print cast(getdate() as varchar(50)) + ' - Latest Insert Date in Target: ' + cast(@LastInsertDate as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
Declare @Logmessage as varchar(50) = 'Latest Insert Date in Target '+cast (@LastInsertDate as varchar(25))
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = @Logmessage , @LOGID = @StepLogID

--Identify Inserted records from Source
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

--Query for InsertRecord
If Object_ID('Tempdb..#InsertRecords') is not null
Begin
    Drop table #InsertRecords
End

SELECT DISTINCT MS.IESystemControlNumber,
CASE	WHEN MS.LastModified_Date > IP.LastModified_Date THEN MS.LastModified_Date
ELSE IP.LastModified_Date END AS LastModified_Date	
INTO #InsertRecords
FROM [sis_shadow].[MediaSequence] MS
INNER JOIN [sis].[IEPart] IP ON IP.IEPart_ID = MS.IEPart_ID
WHERE MS.LastModified_Date > @LastInsertDate OR IP.LastModified_Date > @LastInsertDate

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, @LOGMESSAGE =  'Inserted Records Detected into #InsertRecords';

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_IESystemControlNumber ON #InsertRecords(IESystemControlNumber) INCLUDE(LastModified_Date)

--Delete Inserted records from Target
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
 	
Delete From [sissearch2].[RemanIEPart]
Where IESystemControlNumber IN (Select IESystemControlNumber From #InsertRecords)
 
SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, @LOGMESSAGE =  'Deleted Inserted Records from Target [sissearch2].[RemanIEPart]';

--Stage R2S Set
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
	Drop table #RecordsToString
End;

WITH CTE_REMANIEPART AS (
SELECT
    MS.IESystemControlNumber,
	MS.IESystemControlNumber as ID,
	RPNK.Part_Number,
	RPNK.Related_Part_Number,
	RPNK.Related_Part_Name,
	IR.LastModified_Date as InsertDate
FROM [sis_shadow].[MediaSequence] MS
inner join #InsertRecords IR on IR.IESystemControlNumber = MS.IESystemControlNumber
inner join [sis].[MediaSection] MSec on MSec.MediaSection_ID = MS.MediaSection_ID
inner join [sis].[Media] M on M.Media_ID = MSec.Media_ID and M.Source IN ('A', 'C')  -- Authoring & Conversion
inner join [sis].[IEPart] IP on IP.IEPart_ID = MS.IEPart_ID
inner join [sis].[PART] P on P.PART_ID = IP.Part_ID
inner join [sis].[vw_RelatedPartsNoKits_2] RPNK on RPNK.Part_Number = P.Part_Number
	and RPNK.Type_Indicator = 'R' and RPNK.Language_Tag = 'en-US')

Select Distinct IESystemControlNumber, ID,
       	replace( --escape /
       		replace( --escape "
       			replace( --replace carriage return (ascii 13)
       				replace( --replace form feed (ascii 12)
       					replace( --replace vertical tab (ascii 11)
       						replace( --replace line feed (ascii 10)
       							replace( --replace horizontal tab (ascii 09)
       								replace( --replace backspace (ascii 08)
       									replace( --escape \
       										isnull(Part_Number, '')+':'+isnull(Related_Part_Number, '')+':'+isnull(Related_Part_Name, '')
       									,'\', '\\')
       								,char(8), ' ')
       							,char(9), ' ')
       						,char(10), ' ')
       					,char(11), ' ')
       				,char(12), ' ')
       			,char(13), ' ')
       			,'"', '\"')
       		,'/', '\/') as RemanIEPart,
        InsertDate
into #RecordsToString
From CTE_REMANIEPART;

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, @LOGMESSAGE =  'Inserted Records Loaded to #RecordsToString';

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID]
ON #RecordsToString ([ID] ASC)
INCLUDE ([IESYSTEMCONTROLNUMBER],[REMANIEPART],[INSERTDATE])
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

--Records to String
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into [sissearch2].[RemanIEPart] (IESystemControlNumber, ID, RemanIEPart, InsertDate)
SELECT	a.IESystemControlNumber, a.Id,
		COALESCE(f.RemanIEPartsString,'') AS RemanIEPart,
        min(a.InsertDate) as InsertDate --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
FROM	#RecordsToString a
CROSS apply
	(
		SELECT '[' + stuff (
			(
				SELECT  '","' + cast(RemanIEPart AS varchar(max))
				FROM	#RecordsToString AS b
                WHERE    a.Id = b.Id
                ORDER BY b.Id
				FOR xml path(''), type).value('.', 'varchar(max)') ,1,2,''
			) + '"'+']'
	) f (RemanIEPartsString)
GROUP BY a.IESystemControlNumber,
         a.Id,
         f.RemanIEPartsString

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, @LOGMESSAGE =  'Insert into Target [sissearch2].[RemanIEPart]';

--Drop temp table
Drop Table #DeletedRecords
Drop Table #InsertRecords
Drop Table #RecordsToString

SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LOGID = @SPStartLogID, @DATAVALUE = @RowCount

DELETE FROM sissearch2.LOG WHERE DATEDIFF(DD, LogDateTime, GetDate())>30 and NameofSproc = @ProcName

END TRY

BEGIN CATCH 
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT = ERROR_LINE()

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC sissearch2.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @error
END CATCH

End