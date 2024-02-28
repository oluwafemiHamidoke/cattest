/*******************
-- Created By   : Kishor Padmanabhan
-- Created For  : Loading changed data into sissearch2.SNP from base tables
-- Created At   : 20220926

--Script

EXEC [sissearch2].[SNP_LOAD]
TRUNCATE TABLE [sissearch2].[SNP]

********************/
CREATE  PROCEDURE [sissearch2].[SNP_Load]
AS

BEGIN
BEGIN TRY

SET NOCOUNT ON

DECLARE @LastInsertDate DATETIME,
        @SPStartTime DATETIME,
		@StepStartTime DATETIME,
		@ProcName VARCHAR(200),
		@SPStartLogID BIGINT,
		@StepLogID BIGINT,
		@RowCount BIGINT,
		@LAPSETIME BIGINT;

SET @SPStartTime= GETDATE();
SET @ProcName= OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)

--Identify Deleted Records From Source

EXEC @SPStartLogID = sissearch2.WriteLog @TIME = @SPStartTime, @NAMEOFSPROC = @ProcName;

SET @StepStartTime= GETDATE();
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

IF OBJECT_ID('Tempdb..#DeletedRecords') IS NOT NULL
BEGIN
     DROP TABLE #DeletedRecords
END

SELECT S.IESystemControlNumber
INTO #DeletedRecords
FROM  [sissearch2].[SNP] S
EXCEPT
SELECT DISTINCT MS.IESystemControlNumber
FROM [sis_shadow].[MediaSequence] MS
INNER JOIN [sis].IEPart IE ON IE.IEPart_ID = MS.IEPart_ID;

SET @RowCount= @@ROWCOUNT
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog
    @NAMEOFSPROC = @ProcName
    ,@ISUPDATE = 1
    ,@LAPSETIME = @LAPSETIME
    ,@DATAVALUE = @RowCount
    ,@LOGID = @StepLogID
    ,@LOGMESSAGE = 'Deleted Records Detected';

-- Delete Identified Deleted Records in Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

DELETE S FROM
[sissearch2].[SNP] S
INNER JOIN #DeletedRecords D ON D.IESystemControlNumber = S.IESystemControlNumber

SET @RowCount= @@ROWCOUNT
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog
    @NAMEOFSPROC = @ProcName
    ,@ISUPDATE = 1
    ,@LAPSETIME = @LAPSETIME
    ,@DATAVALUE = @RowCount
    ,@LOGID = @StepLogID
    ,@LOGMESSAGE =  'Deleted Records from Target [sissearch2].[SNP]';
--Get Maximum insert date from Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

SELECT  @LastInsertDate=COALESCE(MAX(InsertDate),'1900-01-01') FROM [sissearch2].[SNP]
--Print cast(getdate() as varchar(50)) + ' - Latest Insert Date in Target: ' + cast(@LastInsertDate as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
DECLARE @Logmessage AS VARCHAR(50) = 'Latest Insert Date in Target '+CAST(@LastInsertDate AS VARCHAR(25))
EXEC sissearch2.WriteLog
    @NAMEOFSPROC = @ProcName
    ,@ISUPDATE = 1
    ,@LAPSETIME = @LAPSETIME
    ,@LOGMESSAGE = @Logmessage
    ,@LOGID = @StepLogID

--Identify Inserted records from Source

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

IF OBJECT_ID('Tempdb..#InsertRecords') IS NOT NULL
BEGIN
    DROP TABLE #InsertRecords;
END

SELECT DISTINCT MS.IESystemControlNumber,
CASE	WHEN MS.LastModified_Date > MSE.LastModified_Date AND MS.LastModified_Date > SP.LastModified_Date AND MS.LastModified_Date > SR.LastModified_Date 
            THEN MS.LastModified_Date
        WHEN MSE.LastModified_Date > MS.LastModified_Date AND MSE.LastModified_Date > SP.LastModified_Date AND MSE.LastModified_Date > SR.LastModified_Date 
            THEN MSE.LastModified_Date
        WHEN SP.LastModified_Date > MS.LastModified_Date AND SP.LastModified_Date > MSE.LastModified_Date AND SP.LastModified_Date > SR.LastModified_Date 
            THEN SP.LastModified_Date
    ELSE SR.LastModified_Date END AS LastModified_Date	
INTO #InsertRecords
FROM [sis_shadow].[MediaSequence] MS
INNER JOIN [sis].[MediaSequence_Effectivity] MSE ON MS.MediaSequence_ID = MSE.MediaSequence_ID
INNER JOIN [sis].[SerialNumberPrefix] SP on MSE.SerialNumberPrefix_ID = SP.SerialNumberPrefix_ID
INNER JOIN [sis].[SerialNumberRange] SR ON SR.SerialNumberRange_ID = MSE.SerialNumberRange_ID
WHERE MS.LastModified_Date > @LastInsertDate 
    OR MSE.LastModified_Date > @LastInsertDate 
    OR SP.LastModified_Date > @LastInsertDate 
    OR SR.LastModified_Date > @LastInsertDate

SET @RowCount= @@ROWCOUNT
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog
    @NAMEOFSPROC = @ProcName
    ,@ISUPDATE = 1
    ,@LAPSETIME = @LAPSETIME
    ,@DATAVALUE = @RowCount
    ,@LOGID = @StepLogID
    ,@LOGMESSAGE = 'Inserted Records Detected #InsertRecords';

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_IESystemControlNumber
    ON #InsertRecords(IESystemControlNumber) INCLUDE(LastModified_Date)

--Delete Inserted records from Target
SET @StepStartTime= GETDATE();
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

DELETE S
FROM [sissearch2].[SNP] S
INNER JOIN #InsertRecords I ON I.IESystemControlNumber = S.IESystemControlNumber

SET @RowCount= @@ROWCOUNT;
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog
    @NAMEOFSPROC = @ProcName
    ,@ISUPDATE = 1
    ,@LAPSETIME = @LAPSETIME
    ,@DATAVALUE = @RowCount
    ,@LOGID = @StepLogID
    ,@LOGMESSAGE =  'Deleted Inserted Records from Target [sissearch2].[SNP]';

--Stage R2S Set

SET @StepStartTime= GETDATE();
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

IF OBJECT_ID('Tempdb..#RecordsToString') IS NOT NULL
BEGIN
    DROP TABLE #RecordsToString;
END

;WITH CTE_SNP AS
(
SELECT DISTINCT
    MSE.IESystemControlNumber,
    MSE.IESystemControlNumber AS ID,
    p.Serial_Number_Prefix AS SNP,
    INS.LastModified_Date AS InsertDate,
    CAST(SR.Start_Serial_Number AS VARCHAR(10)) BEGINNINGRANGE,
    CAST(SR.End_Serial_Number AS VARCHAR(10)) ENDRANGE
FROM [sis_shadow].[MediaSequence] MSE
INNER JOIN [sis].[MediaSection] MS ON MS.MediaSection_ID = MSE.MediaSection_ID
INNER JOIN [sis].[Media] M ON M.Media_ID = MS.Media_ID AND M.Source IN('A','C')
INNER JOIN [sis].MediaSequence_Effectivity MSEE ON MSEE.MediaSequence_ID = MSE.MediaSequence_ID
INNER JOIN [sis].IEPart_Effectivity IE ON M.Media_ID = IE.Media_ID AND MSE.IEPart_ID = IE.IEPart_ID 
	AND MSEE.SerialNumberRange_ID = IE.SerialNumberRange_ID
	AND IE.SerialNumberPrefix_ID = MSEE.SerialNumberPrefix_ID
	AND IE.SerialNumberPrefix_Type = 'P'
INNER JOIN sis.SerialNumberPrefix p ON IE.SerialNumberPrefix_ID = p.SerialNumberPrefix_ID 
INNER JOIN sis.SerialNumberRange SR ON SR.SerialNumberRange_ID = IE.SerialNumberRange_ID
INNER JOIN #InsertRecords INS ON MSE.IESystemControlNumber=INS.IESystemControlNumber

)
Select IESystemControlNumber,
  ID,
  	REPLACE( --escape /
		REPLACE( --escape "
			REPLACE( --escape carriage return (ascii 13)
				REPLACE( --escape form feed (ascii 12)
					REPLACE( --escape vertical tab (ascii 11)
						REPLACE( --escape line feed (ascii 10)
							REPLACE( --escape horizontal tab (ascii 09)
								REPLACE( --escape backspace (ascii 08)
									REPLACE( --escape \
										isnull(SNP,'')
									,'\', '\\')
								,CHAR(8), ' ')
							,CHAR(9), ' ')
						,CHAR(10), ' ')
					,CHAR(11), ' ')
				,CHAR(12), ' ')
			,CHAR(13), ' ')
			,'"', '\"')
		,'/', '\/') as SNP,
InsertDate,
CAST(BEGINNINGRANGE AS VARCHAR(10)) BEGINNINGRANGE,
CAST(ENDRANGE AS VARCHAR(10)) ENDRANGE
INTO #RecordsToString
FROM CTE_SNP;

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog
    @NAMEOFSPROC = @ProcName
    ,@ISUPDATE = 1
    ,@LAPSETIME = @LAPSETIME
    ,@DATAVALUE = @RowCount
    ,@LOGID = @StepLogID
    ,@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString';

--NCI
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID]
ON #RecordsToString (IESystemControlNumber, BEGINNINGRANGE, ENDRANGE)
INCLUDE ([ID], [SNP],[InsertDate]);
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

/*
This section is adding a suffix to the ID to ensure that we do not have over 3000 begin/end range combinations
for the same ID.  The first group of 3000 has no ID suffix.  The second group of 3000 has _1 suffix. Then _2, etc...
*/

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

SELECT
CASE
	WHEN RowRank < 3000 THEN x.ID
	ELSE x.ID + '_' + CAST(RowRank / 3000 AS VARCHAR(50))
END ID, --First 3000 records get no suffix.  Subsequent 3000 get suffixed with _1.
x.IESystemControlNumber,
r.SNP,
x.BEGINNINGRANGE,
x.ENDRANGE,
r.InsertDate,
x.RowRank
INTO #RecordsToString_Ranked
FROM
(
	--Get
	SELECT
	ID,
	IESystemControlNumber,
	BEGINNINGRANGE,
	ENDRANGE,
	ROW_NUMBER() OVER (PARTITION BY IESystemControlNumber Order BY CAST(BEGINNINGRANGE AS BIGINT)) - 1 RowRank --Change to zero base
	FROM #RecordsToString
	--Where IESystemControlNumber = 'REBE50770001' --Example of IE with over 3000 Begin/End combinations - REBE50770001
	GROUP BY ID, IESystemControlNumber, BEGINNINGRANGE, ENDRANGE
) x
--Get the SNP & InsertDate
INNER JOIN #RecordsToString r ON
	x.IESystemControlNumber = r.IESystemControlNumber AND
	x.BEGINNINGRANGE = r.BEGINNINGRANGE AND
	x.ENDRANGE = r.ENDRANGE

SET @RowCount= @@ROWCOUNT
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to #RecordsToString_Ranked Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog
    @NAMEOFSPROC = @ProcName
    ,@ISUPDATE = 1
    ,@LAPSETIME = @LAPSETIME
    ,@DATAVALUE = @RowCount
    ,@LOGID = @StepLogID
    ,@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString_Ranked';



SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

SELECT
    [ID],
    IESystemControlNumber,
    ISNULL('["' + STRING_AGG(CAST(SNP AS VARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY SNP) + '"]','[]') AS [serialNumbers.serialNumberPrefixes],
    BEGINNINGRANGE AS [serialNumbers.beginningRange],
    ENDRANGE AS [serialNumbers.endRange],
    MAX(InsertDate) [InsertDate]
INTO #SNPArray
FROM #RecordsToString_Ranked
GROUP BY
        ID,
        IESystemControlNumber,
        BEGINNINGRANGE,
        ENDRANGE

SET @RowCount= @@ROWCOUNT
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to #SNPArray: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog
    @NAMEOFSPROC = @ProcName
    ,@ISUPDATE = 1
    ,@LAPSETIME = @LAPSETIME
    ,@DATAVALUE = @RowCount
    ,@LOGID = @StepLogID
    ,@LOGMESSAGE =  'Inserted Records Loaded to Temp SNPArray';

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

INSERT INTO [sissearch2].[SNP] (ID, IESystemControlNumber,SerialNumbers,InsertDate)
SELECT ID,
IESystemControlNumber,
(
	SELECT
	JSON_QUERY(b.[serialNumbers.serialNumberPrefixes]) [serialNumberPrefixes], --JSON_Query function ensures that quotes are not escaped
	CAST(b.[serialNumbers.beginningRange] AS INT) [beginRange],
	CAST(b.[serialNumbers.endRange] AS INT) [endRange]
	FROM #SNPArray b
	WHERE a.ID = b.ID
	FOR JSON PATH
) SerialNumbers,
MAX(InsertDate) InsertDate
FROM #SNPArray a
--where ID = 'i06912346'
GROUP BY
ID,
IESystemControlNumber

SET @RowCount= @@ROWCOUNT
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target [SISSEARCH].[SNP] Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog
    @NAMEOFSPROC = @ProcName
    ,@ISUPDATE = 1
    ,@LAPSETIME = @LAPSETIME
    ,@DATAVALUE = @RowCount
    ,@LOGID = @StepLogID
    ,@LOGMESSAGE =  'Inserted into Target [sissearch2].[SNP]';

--Finish

SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
EXEC sissearch2.WriteLog
    @NAMEOFSPROC = @ProcName
    ,@ISUPDATE = 1
    ,@LAPSETIME = @LAPSETIME
    ,@LOGMESSAGE = 'ExecutedSuccessfully'
    ,@LOGID = @SPStartLogID
    ,@DATAVALUE = @RowCount

DELETE FROM sissearch2.LOG WHERE DATEDIFF(DD, LogDateTime, GetDate())>30 AND NameofSproc= @ProcName

END TRY

BEGIN CATCH
    DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
            @ERROELINE INT= ERROR_LINE()

    DECLARE @error NVARCHAR(MAX) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
    EXEC sissearch2.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error
END CATCH

END