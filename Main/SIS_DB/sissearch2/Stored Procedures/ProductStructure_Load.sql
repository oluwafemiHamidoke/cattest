
CREATE  PROCEDURE [sissearch2].[ProductStructure_Load]
AS
/*---------------
Created On: 20220928
Created By: Kishor Padmanabhan
Object Description:  Loading changed data into sissearch2.ProductStructure from base tables
Associated WI: 22835
EXEC [sissearch2].[ProductStructure_Load]
TRUNCATE TABLE [sissearch2].[ProductStructure]
---------------*/

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

	SET @SPStartTime= GETDATE()
	SET @ProcName= OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)

	--Identify Deleted Records From Source

	EXEC @SPStartLogID = sissearch2.WriteLog @TIME = @SPStartTime, @NAMEOFSPROC = @ProcName;

	SET @StepStartTime= GETDATE()
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	IF OBJECT_ID('Tempdb..#DeletedRecords') IS NOT NULL
	BEGIN
		DROP TABLE #DeletedRecords
	END

	SELECT IESystemControlNumber
	INTO #DeletedRecords
	FROM  [sissearch2].[ProductStructure]
	EXCEPT
	SELECT DISTINCT MS.IESystemControlNumber
	FROM [sis_shadow].[MediaSequence] MS
	INNER JOIN [sis].[IEPart] IE ON MS.IEPart_ID = IE.IEPart_ID;

	SET @RowCount= @@ROWCOUNT
	--Print cast(getdate() as varCHAR(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varCHAR(50))

	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
	@LOGMESSAGE =  'Deleted Records Detected';

	-- Delete Idenified Deleted Records in Target
	SET @StepStartTime= GETDATE()
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	DELETE PS
	FROM [sissearch2].[ProductStructure] PS
	INNER JOIN #DeletedRecords DR ON DR.IESystemControlNumber = PS.IESystemControlNumber

	SET @RowCount= @@ROWCOUNT
	--Print cast(getdate() as varCHAR(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varCHAR(50))

	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
	@LOGMESSAGE =  'Deleted Records from Target [sissearch2].[ProductStructure]';

	--Get Maximum insert date from Target
	SET @StepStartTime= GETDATE()
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	SELECT  @LastInsertDate=COALESCE(MAX(InsertDate),'1900-01-01') FROM [sissearch2].[ProductStructure]
	--Print cast(getdate() as varCHAR(50)) + ' - Latest Insert Date in Target: ' + cast(@LastInsertDate as varCHAR(50))

	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	DECLARE @Logmessage AS VARCHAR(50) = 'Latest Insert Date in Target '+CAST (@LastInsertDate AS VARCHAR(25))
	EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = @Logmessage , @LOGID = @StepLogID


	--Identify Inserted records from Source

	SET @StepStartTime= GETDATE()
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	IF OBJECT_ID('Tempdb..#InsertRecords') IS NOT NULL
	BEGIN
		DROP TABLE #InsertRecords
	END

	SELECT DISTINCT 
	MS.IESystemControlNumber,
	CASE	WHEN MS.LastModified_Date > PIR.LastModified_Date AND MS.LastModified_Date > PS.LastModified_Date 
				THEN MS.LastModified_Date
			WHEN PIR.LastModified_Date > MS.LastModified_Date AND PIR.LastModified_Date > PS.LastModified_Date 
				THEN PIR.LastModified_Date
	ELSE PS.LastModified_Date END AS LastModified_Date	
	INTO #InsertRecords
	FROM [sis_shadow].[MediaSequence] MS
	INNER JOIN [sis].[ProductStructure_IEPart_Relation] PIR ON PIR.IEPart_ID = MS.IEPart_ID
	INNER JOIN [sis].[ProductStructure] PS ON PS.ProductStructure_ID = PIR.ProductStructure_ID
	WHERE MS.LastModified_Date > @LastInsertDate OR PIR.LastModified_Date > @LastInsertDate OR PS.LastModified_Date > @LastInsertDate

	SET @RowCount= @@ROWCOUNT
	--Print cast(getdate() as varCHAR(50)) + ' - Inserted Records Detected Count: ' +  cast(@RowCount as varCHAR(50))

	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
	@LOGMESSAGE =  'Inserted Records Detected into  #InsertRecords';

	--NCI on temp
	CREATE NONCLUSTERED INDEX NIX_InsertRecords_IESystemControlNumber
		ON #InsertRecords(IESystemControlNumber) INCLUDE(LastModified_Date)

	--Delete Inserted records from Target
	SET @StepStartTime= GETDATE()
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	DELETE PS FROM [sissearch2].[ProductStructure] PS
	INNER JOIN #InsertRecords IR ON IR.IESystemControlNumber = PS.IESystemControlNumber

	SET @RowCount= @@ROWCOUNT
	--Print cast(getdate() as varCHAR(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varCHAR(50))

	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
	@LOGMESSAGE =  'Deleted Inserted Records from [sissearch2].[ProductStructure]';

	--Stage R2S Set
	SET @StepStartTime= GETDATE()
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	IF OBJECT_ID('Tempdb..#RecordsToString') IS NOT NULL
	BEGIN
	 DROP TABLE #RecordsToString
	END

	;WITH CTE_PRODUCTSTRUCTURE AS
	(
	
	SELECT DISTINCT
		 C.IESystemControlNumber,
		 C.IESystemControlNumber AS ID,
		 CASE
			WHEN PF.Family_Code NOT IN ('EPG', 'IENG', 'MENG', 'TENG', 'ATCH', 'WKTL')
				AND PS.ParentProductStructure_ID IN (514,62,210,847,1895,1)
					THEN '88888888_'+CAST(PS.ParentProductStructure_ID AS VARCHAR)+'_'+ CAST(PSR.ProductStructure_ID AS VARCHAR)
			ELSE
				CASE
					WHEN ISNULL(PS.ParentProductStructure_ID,0) <> 0
						THEN CAST(PS.ParentProductStructure_ID AS VARCHAR)+'_'+ CAST(PSR.ProductStructure_ID AS VARCHAR)
					ELSE CAST(PSR.ProductStructure_ID AS VARCHAR) +'_'+ CAST(PSR.ProductStructure_ID AS VARCHAR)
				END
		END AS [PSID],
		CASE
			WHEN ISNULL(PS.ParentProductStructure_ID,0) <> 0 THEN PS.ParentProductStructure_ID
			ELSE 
				PSR.ProductStructure_ID
		END AS [SystemPSID],
		IR.LastModified_Date [InsertDate]
	FROM [sis_shadow].[MediaSequence] C
	INNER JOIN [sis].[MediaSection] MSE ON MSE.MediaSection_ID = C.MediaSection_ID
	INNER JOIN [sis].[ProductStructure_IEPart_Relation] PSR ON PSR.IEPart_ID = C.IEPart_ID
	AND PSR.Media_ID = MSE.Media_ID
	INNER JOIN [sis].[Product_Relation] PR ON PR.SerialNumberPrefix_ID = PSR.SerialNumberPrefix_ID
	INNER JOIN [sis].[ProductFamily] PF ON PF.ProductFamily_ID = PR.ProductFamily_ID
	INNER JOIN #InsertRecords IR  ON IR.IESystemControlNumber=C.IESystemControlNumber --Add filter to limit to changed records
	INNER JOIN [sis].[ProductStructure] PS ON PS.ProductStructure_ID = PSR.ProductStructure_ID
	INNER JOIN [sis].[ProductFamily_Translation] PT ON PT.ProductFamily_ID = PF.ProductFamily_ID
	INNER JOIN [sis].[Language] L ON L.Language_ID= PT.Language_ID AND L.Language_Tag='en-US'
	INNER JOIN [sis].[IEPart_Effectivity] IE ON IE.IEPart_ID = C.IEPart_ID
		AND IE.Media_ID = MSE.Media_ID AND IE.SerialNumberPrefix_Type= 'P'
	INNER JOIN [sis].Media M ON MSE.Media_ID = M.Media_ID AND M.Source IN('A', 'C')

	 )

	 SELECT IESystemControlNumber,
	  ID,
	  ISNULL(PSID, '')as PSID,
	  ISNULL([SystemPSID], '') AS [SystemPSID],
	  [InsertDate]
	INTO #RecordsToString
	FROM CTE_PRODUCTSTRUCTURE;

	SET @RowCount= @@ROWCOUNT
	--Print cast(getdate() as varCHAR(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varCHAR(50))

	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
	@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString';

	--NCI to cover R2S Insert
	CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID]
	ON #RecordsToString ([ID] ASC)
	INCLUDE ([IESystemControlNumber],[PSID],[SystemPSID],[InsertDate])
	--Print cast(getdate() as varCHAR(50)) + ' - Nonclustered index added temp'

	--Records to String --PSID
	--Below Script took 12 min

	SET @StepStartTime= GETDATE()
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	INSERT INTO [sissearch2].[ProductStructure] (IESystemControlNumber,ID,[PSID],InsertDate)
	SELECT
		a.IESystemControlNumber,
		a.ID,
		COALESCE(f.PSID,'') AS [PSID],
		MIN(a.InsertDate) InsertDate --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
	FROM  #RecordsToString a
	CROSS APPLY
	(
		SELECT  '[' + STUFF
		(
			(SELECT '","'  + CAST([PSID] AS VARCHAR(MAX))
			FROM #RecordsToString AS b
			WHERE a.ID=b.ID
			ORDER BY b.ID
			FOR XML PATH(''), TYPE).value('.', 'VARCHAR(MAX)')
		,1,2,'') + '"'+']'
	) f (PSID)
	GROUP BY
	a.IESystemControlNumber,
	a.ID,
	f.PSID

	SET @RowCount= @@ROWCOUNT
	--Print cast(getdate() as varCHAR(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varCHAR(50))

	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
	@LOGMESSAGE =  'Inserted into Target [sissearch2].[ProductStructure]';

	--Create distinct list of ID & SYSTEMPSID records

	SET @StepStartTime= GETDATE()
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	SELECT DISTINCT ID, [SystemPSID] INTO #RecordsToStringSystem FROM #RecordsToString

	SET @RowCount= @@ROWCOUNT
	--Print cast(getdate() as varCHAR(50)) + ' - Inserted Records Loaded to Temp #RecordsToStringSystem Count: ' + cast(@@RowCount as varCHAR(50))

	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
	@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToStringSystem ';

	--Records to String --PSID
	SET @StepStartTime= GETDATE()
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	SELECT
		a.ID,
		COALESCE(f.[SYSTEMPSID],'') AS [SYSTEMPSID]
	INTO #SYSTEMPSID
	FROM #RecordsToString a
	CROSS APPLY
	(
		SELECT  '[' + STUFF
		(
			(SELECT '","'  + CAST([SystemPSID] AS VARCHAR(MAX))
			FROM #RecordsToStringSystem AS b
			WHERE a.ID=b.ID
			ORDER BY b.ID
			FOR XML PATH(''), TYPE).value('.', 'VARCHAR(MAX)')
		,1,2,'') + '"'+']'
	) f ([SYSTEMPSID])
	GROUP BY
	a.ID,
	f.[SYSTEMPSID]

	SET @RowCount= @@ROWCOUNT
	--Print cast(getdate() as varCHAR(50)) + ' - Inserted into Temp #SYSTEMPSID Count: ' + Cast(@RowCount as varCHAR(50))

	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
	@LOGMESSAGE =  'Inserted into Temp #SYSTEMPSID';

	--Update SYSTEMPSID in target

	SET @StepStartTime= GETDATE()
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	UPDATE t
	SET t.[System] = s.[SYSTEMPSID], t.[SystemPSID] = s.[SYSTEMPSID]
	FROM [sissearch2].[ProductStructure] t
	INNER JOIN #SYSTEMPSID s on t.[ID] = s.[ID]

	SET @RowCount= @@ROWCOUNT
	--Print cast(getdate() as varCHAR(50)) + ' - Update Target Field [SYSTEM] Count: ' + Cast(@RowCount as varCHAR(50))

	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
	@LOGMESSAGE =  'Update Target Field [SYSTEM]';


	SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
	EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Executed Successfully', @LOGID = @SPStartLogID,@DATAVALUE = @RowCount

	DELETE FROM sissearch2.LOG WHERE DATEDIFF(DD, LogDateTime, GETDATE())>30 and NameofSproc= @ProcName

	END TRY

	BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
				@ERROELINE INT= ERROR_LINE()

		DECLARE @error NVARCHAR(MAX) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
		EXEC sissearch2.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error
	END CATCH


END
