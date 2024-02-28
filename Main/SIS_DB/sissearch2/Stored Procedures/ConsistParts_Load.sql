CREATE PROCEDURE [sissearch2].[ConsistParts_Load]
AS
/*---------------
Created On: 20220929
Created By: Kishor Padmanabhan
Object Description:     Loading changed data into sissearch2.ConsistParts from base tables
Associated WI: 22834

EXEC [sissearch2].[ConsistParts_Load]
TRUNCATE TABLE [sissearch2].[ConsistParts]
---------------*/
BEGIN
	BEGIN TRY

	SET NOCOUNT ON

	DECLARE @LASTINSERTDATE DATETIME,
			@SPStartTime DATETIME,
			@StepStartTime DATETIME,
			@ProcName VARCHAR(200),
			@SPStartLogID BIGINT,
			@StepLogID BIGINT,
			@RowCount BIGINT,
			@LAPSETIME BIGINT;

	SET @SPStartTime= GETDATE();
	SET @ProcName= OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID);

	--Identify Deleted Records From Source
	EXEC @SPStartLogID = sissearch2.WriteLog @TIME = @SPStartTime, @NAMEOFSPROC = @ProcName;

	SET @StepStartTime= GETDATE();
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	IF OBJECT_ID('Tempdb..#DeletedRecords') IS NOT NULL
	BEGIN
		 DROP TABLE #DeletedRecords;
	END

	SELECT IESystemControlNumber
	INTO #DeletedRecords
	FROM [sissearch2].[ConsistParts]
	EXCEPT
	SELECT DISTINCT MS.IESystemControlNumber
	FROM [sis_shadow].[MediaSequence] MS
	INNER JOIN [sis].IEPart IE ON IE.IEPart_ID = MS.IEPart_ID;

	SET @RowCount= @@ROWCOUNT;
	--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog
			@NAMEOFSPROC = @ProcName
			,@ISUPDATE = 1
			,@LAPSETIME = @LAPSETIME
			,@LOGMESSAGE = 'Deleted Records Detected'
			,@DATAVALUE = @RowCount
			,@LOGID = @StepLogID

	-- Delete Idenified Deleted Records in Target
	SET @StepStartTime= GETDATE();
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	DELETE CP FROM [sissearch2].[ConsistParts] CP
	INNER JOIN #DeletedRecords DR ON DR.IESystemControlNumber = CP.IESystemControlNumber;

	SET @RowCount= @@ROWCOUNT
	--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))
	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog
		@NAMEOFSPROC = @ProcName
		,@ISUPDATE = 1
		,@LAPSETIME = @LAPSETIME
		,@LOGMESSAGE = 'Deleted Records from Target [sissearch2].[ConsistParts] '
		,@DATAVALUE = @RowCount
		,@LOGID = @StepLogID;

	--Drop Temp
	DROP TABLE #DeletedRecords;

	--Get Maximum insert date from Target
	SET @StepStartTime= GETDATE();
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	SELECT  @LASTINSERTDATE=COALESCE(MAX(InsertDate),'1900-01-01') FROM [sissearch2].[ConsistParts];

	--Print cast(getdate() as varchar(50)) + ' - Latest Insert Date in Target: ' + cast(@LASTINSERTDATE as varchar(50))
	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	DECLARE @Logmessage AS VARCHAR(50) = 'Latest Insert Date in Target '+cast (@LASTINSERTDATE AS VARCHAR(25));
	EXEC sissearch2.WriteLog
		@NAMEOFSPROC = @ProcName
		,@ISUPDATE = 1
		,@LAPSETIME = @LAPSETIME
		,@LOGMESSAGE = @Logmessage
		,@LOGID = @StepLogID

	--Identify Inserted records from Source
	SET @StepStartTime= GETDATE();
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	IF OBJECT_ID('Tempdb..#InsertRecords') IS NOT NULL
	BEGIN
		DROP TABLE #InsertRecords
	END

	SELECT DISTINCT MS.IESystemControlNumber,
	CASE	WHEN MS.LastModified_Date > PIR.LastModified_Date THEN MS.LastModified_Date
	ELSE PIR.LastModified_Date END AS LastModified_Date	
	INTO #InsertRecords
	FROM [sis_shadow].[MediaSequence] MS
	INNER JOIN [sis].[Part_IEPart_Relation] PIR ON PIR.IEPart_ID = MS.IEPart_ID
	WHERE MS.LastModified_Date > @LASTINSERTDATE OR PIR.LastModified_Date > @LASTINSERTDATE;

	SET @RowCount= @@ROWCOUNT
	--Print cast(getdate() as varchar(50)) + ' - Inserted Records Detected Count: ' +  cast(@RowCount as varchar(50))
	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog
		@NAMEOFSPROC = @ProcName
		,@ISUPDATE = 1
		,@LAPSETIME = @LAPSETIME
		,@LOGMESSAGE = 'Inserted Records Detected into #InsertRecords'
		,@DATAVALUE = @RowCount
		,@LOGID = @StepLogID;

	--NCI on temp
	CREATE NONCLUSTERED INDEX NIX_InsertRecords_IESystemControlNumber ON #InsertRecords(IESystemControlNumber)
	INCLUDE(LastModified_Date);

	--Delete Inserted records from Target
	SET @StepStartTime= GETDATE()
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	DELETE C FROM [sissearch2].[ConsistParts] C
	INNER JOIN #InsertRecords I ON C.IESystemControlNumber = I.IESystemControlNumber;

	SET @RowCount= @@ROWCOUNT
	--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))
	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog
		@NAMEOFSPROC = @ProcName
		,@ISUPDATE = 1
		,@LAPSETIME = @LAPSETIME
		,@LOGMESSAGE = 'Deleted Inserted Records from Target [sissearch2].[ConsistParts]'
		,@DATAVALUE = @RowCount
		,@LOGID = @StepLogID;

	--Stage R2S Set
	SET @StepStartTime= GETDATE()
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	IF OBJECT_ID('Tempdb..#RecordsToString') IS NOT NULL
	BEGIN
		DROP TABLE #RecordsToString;
	END

	IF OBJECT_ID('Tempdb..#PreRecordsToString') IS NOT NULL
	BEGIN
		DROP TABLE #PreRecordsToString;
	END

	SELECT MS.IESystemControlNumber
		  ,MS.IESystemControlNumber AS ID
		  ,IR.LastModified_Date AS INSERTDATE
		  ,P.Part_Number AS PARTNUMBER
		  ,PIRT.Part_IEPart_Name AS PARTNAME
		  ,PIRT.Part_IEPart_Modifier AS PARTMODIFIER
		  ,PT.Part_Name AS TRANSLATEDPARTNAME
		  ,L.Legacy_Language_Indicator AS LANGUAGEINDICATOR
	INTO #PreRecordsToString
	FROM [sis_shadow].[MediaSequence] AS MS
	INNER JOIN #InsertRecords IR ON IR.IESystemControlNumber = MS.IESystemControlNumber
    INNER JOIN [sis].[MediaSection] MSec ON MSec.MediaSection_ID = MS.MediaSection_ID
    INNER JOIN [sis].[Media] M ON M.Media_ID = MSec.Media_ID AND M.[Source] = 'A'
	INNER JOIN [sis].[Part_IEPart_Relation] PIR ON PIR.IEPart_ID = MS.IEPart_ID
	INNER JOIN [sis].[Part] P ON P.Part_ID = PIR.Part_ID
	INNER JOIN [sis].[Part_IEPart_Relation_Translation] PIRT ON PIRT.Part_IEPart_Relation_ID = PIR.Part_IEPart_Relation_ID
	INNER JOIN [sis].[Part_Translation] PT ON PT.Part_ID = PIR.Part_ID
	INNER JOIN [sis].[Language] L ON L.Language_ID = PT.Language_ID
	
	SELECT IESystemControlNumber
		  ,ID
		  ,INSERTDATE
		  ,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(PARTNUMBER,'') + ':' + ISNULL(PARTNAME,'') + IIF(ISNULL(PARTMODIFIER,'') != '',' ' + PARTMODIFIER,''),'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS CONSISTPART
		  ,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([8],'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                          [consistPartNames_id-ID]
		  ,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(C,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_zh-CN]
		  ,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(F,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_fr-FR]
		  ,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(G,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_de-DE]
		  ,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(L,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_it-IT]
		  ,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(P,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_pt-BR]
		  ,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(S,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_es-ES]
		  ,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(R,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_ru-RU]
		  ,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(J,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_ja-JP]
	INTO #RecordsToString
	  FROM #PreRecordsToString PIVOT(MAX(TRANSLATEDPARTNAME) FOR LANGUAGEINDICATOR IN([8]
																					 ,C
																					 ,F
																					 ,G
																					 ,L
																					 ,P
																					 ,S
																					 ,R
																					 ,J)) AS pvt;

	DROP TABLE IF EXISTS #PreRecordsToString;

	SET @RowCount= @@ROWCOUNT
	--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))
	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog
		@NAMEOFSPROC = @ProcName
		,@ISUPDATE = 1
		,@LAPSETIME = @LAPSETIME
		,@LOGMESSAGE = 'Inserted Records Loaded to #RecordsToString'
		,@DATAVALUE = @RowCount
		,@LOGID = @StepLogID

	--NCI to cover R2S Insert
	CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID]
	ON #RecordsToString ([ID] ASC)
	INCLUDE ([IESystemControlNumber],[CONSISTPART],[INSERTDATE])
	--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'
	--29 Minutes to Get to this Point
	--Records to String

	SET @StepStartTime= GETDATE()
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName

	
	SELECT
	a.[ID] ID,
	a.[IESystemControlNumber],
	COALESCE('["' + STRING_AGG(CAST(CONSISTPART AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS CONSISTPART,
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_id-ID] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_id-ID],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_zh-CN] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_zh-CN],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_fr-FR] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_fr-FR],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_de-DE] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_de-DE],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_it-IT] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_it-IT],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_pt-BR] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_pt-BR],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_es-ES] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_es-ES],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_ru-RU] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_ru-RU],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_ja-JP] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_ja-JP],
	min(a.[INSERTDATE]) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
	INTO #RecordsToStringResult
	FROM #RecordsToString a
	GROUP BY
	a.IESystemControlNumber,
	a.ID;


	SET @RowCount= @@ROWCOUNT
	--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult Count: ' + Cast(@RowCount as varchar(50))
	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog
		@NAMEOFSPROC = @ProcName
		,@ISUPDATE = 1
		,@LAPSETIME = @LAPSETIME
		,@LOGMESSAGE = 'Inserted into Temp RecordsToStringResult'
		,@DATAVALUE = @RowCount
		,@LOGID = @StepLogID;

	--Drop temp table
	DROP TABLE #RecordsToString;
	--Add pkey to result
	ALTER TABLE #RecordsToStringResult ALTER COLUMN ID VARCHAR(50) NOT NULL;
	ALTER TABLE #RecordsToStringResult ADD PRIMARY KEY CLUSTERED (ID);

	--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'
	--Insert result into target
	SET @StepStartTime= GETDATE();
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	
	INSERT INTO [sissearch2].[ConsistParts]
	([IESystemControlNumber]
	,[ID]
	,[ConsistPart]
	,[InsertDate]
	,[ConsistPartNames_es-ES]
	,[ConsistPartNames_zh-CN]
	,[ConsistPartNames_fr-FR]
	,[ConsistPartNames_it-IT]
	,[ConsistPartNames_de-DE]
	,[ConsistPartNames_pt-BR]
	,[ConsistPartNames_id-ID]
	,[ConsistPartNames_ja-JP]
	,[ConsistPartNames_ru-RU])
	SELECT
	 [IESystemControlNumber]
	,[ID]
	,[CONSISTPART]
	,[INSERTDATE]
	,[consistPartNames_es-ES]
	,[consistPartNames_zh-CN]
	,[consistPartNames_fr-FR]
	,[consistPartNames_it-IT]
	,[consistPartNames_de-DE]
	,[consistPartNames_pt-BR]
	,[consistPartNames_id-ID]
	,[consistPartNames_ja-JP]
	,[consistPartNames_ru-RU]
	FROM #RecordsToStringResult;

	SET @RowCount= @@ROWCOUNT
	--Print cast(getdate() as varchar(50)) + ' - Insert into Target Count: ' + Cast(@RowCount as varchar(50))
	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog
		@NAMEOFSPROC = @ProcName
		,@ISUPDATE = 1
		,@LAPSETIME = @LAPSETIME
		,@LOGMESSAGE = 'Insert into Target [sissearch2].[ConsistParts]',
		@DATAVALUE = @RowCount
		,@LOGID = @StepLogID;

	--Drop temp
	DROP TABLE #RecordsToStringResult;
	/*
	----------------------------------------------------------
	Conversion
	----------------------------------------------------------
	*/
	--Print cast(getdate() as varchar(50)) + ' - Conversion Start'
	SET @StepStartTime= GETDATE()
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	--7:14
	--Drop table #RecordsToString_C
	;WITH CTE_CONSISTPART AS
	(
	SELECT
		MS.IESystemControlNumber,
		MS.IESystemControlNumber as ID,
		REPLACE( --escape /
			REPLACE( --escape "
				REPLACE( --escape carriage return (ascii 13)
					REPLACE( --escape form feed (ascii 12)
						REPLACE( --escape vertical tab (ascii 11)
							REPLACE( --escape line feed (ascii 10)
								REPLACE( --escape horizontal tab (ascii 09)
									REPLACE( --escape backspace (ascii 08)
										REPLACE( --escape \
											ISNULL(P.Part_Number,'')+':'+ISNULL(PT.Part_Name, '')+
											IIF(ISNULL(PIRT.Part_IEPart_Modifier, '') != '', ' '+PIRT.Part_IEPart_Modifier, '')
										,'\', '\\')
									,CHAR(8), ' ')
								,CHAR(9), ' ')
							,CHAR(10), ' ')
						,CHAR(11), ' ')
					,CHAR(12), ' ')
				,CHAR(13), ' ')
				,'"', '\"')
			,'/', '\/') as CONSISTPART,
	   IR.LastModified_Date INSERTDATE,
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(tr.[consistPartNames_id-ID]
	,'\', '\\'),CHAR(8), ' '),CHAR(9), ' '),CHAR(10), ' '),CHAR(11), ' '),CHAR(12), ' '),CHAR(13), ' '),'"', '\"'),'/', '\/') AS [consistPartNames_id-ID],
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(tr.[consistPartNames_zh-CN]
	,'\', '\\'),CHAR(8), ' '),CHAR(9), ' '),CHAR(10), ' '),CHAR(11), ' '),CHAR(12), ' '),CHAR(13), ' '),'"', '\"'),'/', '\/') AS [consistPartNames_zh-CN],
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(tr.[consistPartNames_fr-FR]
	,'\', '\\'),CHAR(8), ' '),CHAR(9), ' '),CHAR(10), ' '),CHAR(11), ' '),CHAR(12), ' '),CHAR(13), ' '),'"', '\"'),'/', '\/') AS [consistPartNames_fr-FR],
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(tr.[consistPartNames_de-DE]
	,'\', '\\'),CHAR(8), ' '),CHAR(9), ' '),CHAR(10), ' '),CHAR(11), ' '),CHAR(12), ' '),CHAR(13), ' '),'"', '\"'),'/', '\/') AS [consistPartNames_de-DE],
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(tr.[consistPartNames_it-IT]
	,'\', '\\'),CHAR(8), ' '),CHAR(9), ' '),CHAR(10), ' '),CHAR(11), ' '),CHAR(12), ' '),CHAR(13), ' '),'"', '\"'),'/', '\/') AS [consistPartNames_it-IT],
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(tr.[consistPartNames_pt-BR]
	,'\', '\\'),CHAR(8), ' '),CHAR(9), ' '),CHAR(10), ' '),CHAR(11), ' '),CHAR(12), ' '),CHAR(13), ' '),'"', '\"'),'/', '\/') AS [consistPartNames_pt-BR],
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(tr.[consistPartNames_es-ES]
	,'\', '\\'),CHAR(8), ' '),CHAR(9), ' '),CHAR(10), ' '),CHAR(11), ' '),CHAR(12), ' '),CHAR(13), ' '),'"', '\"'),'/', '\/') AS [consistPartNames_es-ES],
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(tr.[consistPartNames_ru-RU]
	,'\', '\\'),CHAR(8), ' '),CHAR(9), ' '),CHAR(10), ' '),CHAR(11), ' '),CHAR(12), ' '),CHAR(13), ' '),'"', '\"'),'/', '\/') AS [consistPartNames_ru-RU],
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(tr.[consistPartNames_ja-JP]
	,'\', '\\'),CHAR(8), ' '),CHAR(9), ' '),CHAR(10), ' '),CHAR(11), ' '),CHAR(12), ' '),CHAR(13), ' '),'"', '\"'),'/', '\/') AS [consistPartNames_ja-JP]
	FROM [sis_shadow].[MediaSequence] MS
	INNER JOIN #InsertRecords IR ON IR.IESystemControlNumber = MS.IESystemControlNumber
	INNER JOIN [sis].MediaSection MSN ON MSN.MediaSection_ID = MS.MediaSection_ID
    INNER JOIN [sis].Media M ON M.Media_ID = MSN.Media_ID AND M.[Source] ='C' --Conversion
	INNER JOIN [sis].[Part_IEPart_Relation] PIR ON PIR.IEPart_ID = MS.IEPart_ID
	INNER JOIN [sis].[Part] P ON P.Part_ID = PIR.Part_ID
	INNER JOIN sis.Part_Translation PT ON PT.Part_ID = PIR.Part_ID
	INNER JOIN [sis].[Part_IEPart_Relation_Translation] PIRT ON PIR.Part_IEPart_Relation_ID = PIRT.Part_IEPart_Relation_ID
		AND PT.Language_ID = PIRT.Language_ID
	LEFT OUTER JOIN
	(
		SELECT
			[PARTNAME],
			[8] [consistPartNames_id-ID],
			[C] [consistPartNames_zh-CN],
			[F] [consistPartNames_fr-FR],
			[G] [consistPartNames_de-DE],
			[L] [consistPartNames_it-IT],
			[P] [consistPartNames_pt-BR],
			[S] [consistPartNames_es-ES],
			[R] [consistPartNames_ru-RU],
			[J] [consistPartNames_ja-JP]
		FROM
		(
			SELECT PIRT.Part_IEPart_Name AS PARTNAME
				  ,L.Legacy_Language_Indicator AS [LANGUAGEINDICATOR]
				  ,PT.Part_Name AS [TRANSLATEDPARTNAME]
			FROM sis.Part P
			INNER JOIN [sis].[Part_IEPart_Relation] PIR ON P.Part_ID = PIR.Part_ID
			INNER JOIN [sis].[Part_IEPart_Relation_Translation] PIRT ON PIRT.Part_IEPart_Relation_ID = PIR.Part_IEPart_Relation_ID
			INNER JOIN [sis].[Part_Translation] PT ON PT.Part_ID = P.Part_ID
			INNER JOIN [sis].[Language] L ON PT.Language_ID = L.Language_ID
		) p
		PIVOT
		(
		MAX([TRANSLATEDPARTNAME])
		FOR [LANGUAGEINDICATOR] IN ([8], [C], [F], [G], [L], [P], [S], [R], [J])
		) pvt
	) tr ON tr.PARTNAME = PT.Part_Name
	)

	SELECT *
	INTO #RecordsToString_C
	FROM CTE_CONSISTPART;

	SET @RowCount= @@ROWCOUNT
	--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))
	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog
		@NAMEOFSPROC = @ProcName
		,@ISUPDATE = 1
		,@LAPSETIME = @LAPSETIME
		,@LOGMESSAGE = 'Inserted Records Loaded to Temp #RecordsToString_C'
		,@DATAVALUE = @RowCount
		,@LOGID = @StepLogID;

	--Drop temp
	DROP TABLE #InsertRecords;

	--NCI to cover R2S Insert
	CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID]
	ON #RecordsToString_C ([ID] ASC)
	INCLUDE ([IESystemControlNumber],[CONSISTPART],[INSERTDATE])
	--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'
	--Records to String

	SET @StepStartTime= GETDATE()
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	
	SELECT
	a.[ID] ID,
	a.[IESystemControlNumber],
	COALESCE('["' + STRING_AGG(CAST(CONSISTPART AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS CONSISTPART,
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_id-ID] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_id-ID],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_zh-CN] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_zh-CN],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_fr-FR] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_fr-FR],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_de-DE] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_de-DE],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_it-IT] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_it-IT],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_pt-BR] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_pt-BR],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_es-ES] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_es-ES],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_ru-RU] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_ru-RU],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_ja-JP] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_ja-JP],
	min(a.[INSERTDATE]) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
	INTO #RecordsToStringResult_C
	FROM #RecordsToString_C a
	GROUP BY
	a.IESystemControlNumber,
	a.ID;

	SET @RowCount= @@ROWCOUNT;
	--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult_C Count: ' + Cast(@RowCount as varchar(50))
	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog
		@NAMEOFSPROC = @ProcName
		, @ISUPDATE = 1
		,@LAPSETIME = @LAPSETIME
		, @LOGMESSAGE = 'Inserted into Temp RecordsToStringResult_C'
		,@DATAVALUE = @RowCount
		, @LOGID = @StepLogID;

	--Drop temp table
	DROP TABLE #RecordsToString_C;

	--Add pkey to result
	ALTER TABLE #RecordsToStringResult_C ALTER Column ID VARCHAR(50) NOT NULL
	ALTER TABLE #RecordsToStringResult_C ADD PRIMARY KEY CLUSTERED (ID)
	--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult_C'
	--Insert result into target
	SET @StepStartTime= GETDATE()
	EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	INSERT INTO [sissearch2].[ConsistParts]
	([IESystemControlNumber]
	,[ID]
	,[ConsistPart]
	,[InsertDate]
	,[ConsistPartNames_es-ES]
	,[ConsistPartNames_zh-CN]
	,[ConsistPartNames_fr-FR]
	,[ConsistPartNames_it-IT]
	,[ConsistPartNames_de-DE]
	,[ConsistPartNames_pt-BR]
	,[ConsistPartNames_id-ID]
	,[ConsistPartNames_ja-JP]
	,[ConsistPartNames_ru-RU])
	SELECT
	 [IESystemControlNumber]
	,[ID]
	,[CONSISTPART]
	,[INSERTDATE]
	,[consistPartNames_es-ES]
	,[consistPartNames_zh-CN]
	,[consistPartNames_fr-FR]
	,[consistPartNames_it-IT]
	,[consistPartNames_de-DE]
	,[consistPartNames_pt-BR]
	,[consistPartNames_id-ID]
	,[consistPartNames_ja-JP]
	,[consistPartNames_ru-RU]
	FROM #RecordsToStringResult_C;


	SET @RowCount= @@ROWCOUNT
	--Print cast(getdate() as varchar(50)) + ' - Insert into Target Count: ' + Cast(@RowCount as varchar(50))
	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog
		@NAMEOFSPROC = @ProcName
		,@ISUPDATE = 1
		,@LAPSETIME = @LAPSETIME
		,@LOGMESSAGE = 'Insert into Target [sissearch2].[ConsistParts]'
		,@DATAVALUE = @RowCount
		,@LOGID = @StepLogID

	SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
	EXEC sissearch2.WriteLog
		@NAMEOFSPROC = @ProcName
		,@ISUPDATE = 1
		,@LAPSETIME = @LAPSETIME
		,@LOGMESSAGE = 'Executed Successfully'
		,@LOGID = @SPStartLogID
		,@DATAVALUE = @RowCount;

	DELETE FROM sissearch2.LOG WHERE DATEDIFF(DD, LogDateTime, GETDATE())>30 AND NameofSproc= @ProcName

	END TRY
	BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(), @ERROELINE INT= ERROR_LINE()
		DECLARE @error NVARCHAR(MAX) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
		EXEC sissearch2.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error
	END CATCH
END
