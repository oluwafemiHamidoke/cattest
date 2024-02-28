-- =============================================
-- Create Date: 10242022
-- Description: Load data from parts, related parts & consists from new data model & Old data model ( EMP) into IEPart_SNP_TopLevel
-- =============================================
CREATE PROCEDURE [sis].[IEPart_SNP_TopLevel_Load]  AS BEGIN
SET XACT_ABORT,
	NOCOUNT ON;
BEGIN TRY
	DECLARE @AFFECTED_ROWS INT = 0,
		@LOGMESSAGE VARCHAR(MAX),
		@ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID),
		@ProcessID UNIQUEIDENTIFIER = NEWID(),
		@DEFAULT_ORGCODE VARCHAR(12) = SISWEB_OWNER_STAGING._getDefaultORGCODE();
	EXEC sis.WriteLog @PROCESSID = @ProcessID,
	@LOGTYPE = 'Information',
	@NAMEOFSPROC = @ProcName,
	@LOGMESSAGE = 'Execution started',
	@DATAVALUE = NULL;
	BEGIN TRANSACTION;
		

		-- Typically (9479418 rows affected)
		SELECT ProductStructure_ID
			,isTopLevel
			,Media_Number
			,IESystemControlNumber
			,Sequence_Number
			,Modifier
			,Caption
			,Serial_Number_Prefix
			,Part_ID
		INTO #PartsAndConsistsDataNDM
		FROM (
			SELECT v2.ProductStructure_ID
				,CASE 
					WHEN ier.Part_ID IS NULL
						THEN 1
					ELSE 0
					END isTopLevel
				,v1.Media_Number
				,v1.IESystemControlNumber
				,v1.Sequence_Number
				,mseqt.Modifier
				,mseqt.Caption
				,v1.Serial_Number_Prefix
				,p.Part_ID
			FROM [sis].[vw_MediaSequenceFamily] v1
			INNER JOIN [sis].[vw_ProductStructure_IEPart] v2 ON v1.IEPart_ID = v2.IEPart_ID
				AND v1.Media_ID = v2.Media_ID
			INNER JOIN sis.MediaSequence_Translation mseqt ON mseqt.MediaSequence_ID = v1.MediaSequence_ID
			INNER JOIN sis.IEPart iep ON iep.IEPart_ID = v1.IEPart_ID
			INNER JOIN sis.Part p ON p.Part_ID = iep.Part_ID
			LEFT JOIN sis.ProductStructure_IEPart_Relation pir
				INNER JOIN sis.Part_IEPart_Relation ier ON pir.IEPart_ID = ier.IEPart_ID
				ON pir.Media_ID = v1.Media_ID
				AND pir.SerialNumberPrefix_ID = v1.SerialNumberPrefix_ID
				AND p.Part_ID = ier.Part_ID
				AND pir.ProductStructure_ID = v2.ProductStructure_ID
			) x
		GROUP BY ProductStructure_ID
			,isTopLevel
			,Media_Number
			,IESystemControlNumber
			,Sequence_Number
			,Modifier
			,Caption
			,Serial_Number_Prefix
			,Part_ID
		
		set @AFFECTED_ROWS = @@ROWCOUNT EXEC sis.WriteLog @PROCESSID = @ProcessID,
			@LOGTYPE = 'Information',
			@NAMEOFSPROC = @ProcName,
			@LOGMESSAGE = 'Created 1st Temp table #PartsAndConsistsDataNDM',
			@DATAVALUE = @AFFECTED_ROWS;
		

		--Create temp table for consists data
		--Typically (39004666 rows affected)
		SELECT  psid1.MEDIANUMBER
			,inst1.SNP
			,pier1.Part_ID
			,PSID
		INTO #consists
		FROM sis_shadow.MediaSequence mseq1
		INNER JOIN sis.Part_IEPart_Relation pier1 ON pier1.IEPart_ID = mseq1.IEPart_ID
		INNER JOIN SISWEB_OWNER.LNKIEPSID psid1 ON psid1.IESYSTEMCONTROLNUMBER = mseq1.IESystemControlNumber
		INNER JOIN SISWEB_OWNER.LNKIEPRODUCTINSTANCE ieprodinst1 ON mseq1.IESystemControlNumber = ieprodinst1.IESYSTEMCONTROLNUMBER
			AND psid1.MEDIANUMBER = ieprodinst1.MEDIANUMBER
		INNER JOIN SISWEB_OWNER_SHADOW.EMPPRODUCTINSTANCE inst1 ON ieprodinst1.EMPPRODUCTINSTANCE_ID = inst1.EMPPRODUCTINSTANCE_ID


		set @AFFECTED_ROWS = @@ROWCOUNT EXEC sis.WriteLog @PROCESSID = @ProcessID,
			@LOGTYPE = 'Information',
			@NAMEOFSPROC = @ProcName,
			@LOGMESSAGE = 'Created 2nd temp table #consists for consists data',
			@DATAVALUE = @AFFECTED_ROWS;

		-- Create Column store index on #consists for join performance in subssequent queries
		CREATE CLUSTERED COLUMNSTORE INDEX cci_consists ON #consists 

		set @AFFECTED_ROWS = NULL 
		EXEC sis.WriteLog @PROCESSID = @ProcessID,
			@LOGTYPE = 'Information',
			@NAMEOFSPROC = @ProcName,
			@LOGMESSAGE = 'Created Column store index on #consists',
			@DATAVALUE = @AFFECTED_ROWS;


		--Create temp table for parts data
		--Typically (2900821 rows affected)
		SELECT  pir.PSID
		,p.Part_ID
		,m.Media_Number
		,mseq.IESystemControlNumber
		,mseq.Sequence_Number
		,mseqt.Modifier
		,mseqt.Caption
		,inst.SNP
		,snp.Serial_Number_Prefix
		INTO #partstemp
		FROM SISWEB_OWNER.LNKIEPSID pir
		INNER JOIN sis.Media m ON m.Media_Number = pir.MEDIANUMBER
		INNER JOIN sis.MediaSection msec ON msec.Media_ID = m.Media_ID
		INNER JOIN sis_shadow.MediaSequence mseq ON mseq.MediaSection_ID = msec.MediaSection_ID
			AND mseq.IESystemControlNumber = pir.IESYSTEMCONTROLNUMBER
		INNER JOIN sis.MediaSequence_Translation mseqt ON mseqt.MediaSequence_ID = mseq.MediaSequence_ID
		INNER JOIN sis.IEPart iep ON iep.IEPart_ID = mseq.IEPart_ID
		INNER JOIN sis.Part p ON p.Part_ID = iep.Part_ID
		INNER JOIN SISWEB_OWNER.LNKIEPRODUCTINSTANCE ieprodinst ON mseq.IESystemControlNumber = ieprodinst.IESYSTEMCONTROLNUMBER
			AND m.Media_Number = ieprodinst.MEDIANUMBER
		INNER JOIN SISWEB_OWNER.EMPPRODUCTINSTANCE inst ON ieprodinst.EMPPRODUCTINSTANCE_ID = inst.EMPPRODUCTINSTANCE_ID
		INNER JOIN sis.SerialNumberPrefix snp ON snp.Serial_Number_Prefix = inst.SNP



		set @AFFECTED_ROWS = @@ROWCOUNT 
		EXEC sis.WriteLog @PROCESSID = @ProcessID,
			@LOGTYPE = 'Information',
			@NAMEOFSPROC = @ProcName,
			@LOGMESSAGE = 'Created 3rd temp table #partstemp for parts & EMP data',
			@DATAVALUE = @AFFECTED_ROWS;

		
		-- mERGE final result into [sis].[IEPart_SNP_TopLevel]
		-- Typically (9873205 rows affected)

	MERGE [sis].[IEPart_SNP_TopLevel] AS TARGET
		USING
		(SELECT  P.PSID	AS ProductStructure_ID
			,CASE 
				WHEN con.Part_ID IS NULL
					THEN 1
				ELSE 0
				END isTopLevel
			,p.Media_Number
			,p.IESystemControlNumber
			,p.Sequence_Number
			,p.Modifier
			,p.Caption
			,p.SNP AS Serial_Number_Prefix
			,p.Part_ID
		FROM #partstemp p
		LEFT JOIN #consists con ON CON.MEDIANUMBER = P.Media_Number
			AND CON.SNP = P.Serial_Number_Prefix
			AND CON.Part_ID = p.Part_ID
			AND CON.PSID = P.PSID
		GROUP BY P.PSID
			,con.Part_ID
			,P.Media_Number
			,P.IESystemControlNumber
			,P.Sequence_Number
			,P.Modifier
			,P.Caption
			,P.SNP
			,p.Part_ID
		UNION ALL
		SELECT ProductStructure_ID
			,isTopLevel
			,Media_Number
			,IESystemControlNumber
			,Sequence_Number
			,Modifier
			,Caption
			,Serial_Number_Prefix
			,Part_ID
		FROM #PartsAndConsistsDataNDM

		) AS SOURCE
		ON
		(
			TARGET.[ProductStructure_ID]		=		SOURCE.[ProductStructure_ID]       AND
			TARGET.[isTopLevel]					=		SOURCE.[isTopLevel]                AND
			TARGET.[Media_Number]				=		SOURCE.[Media_Number]              AND
			TARGET.[IESystemControlNumber]		=		SOURCE.[IESystemControlNumber]     AND
			TARGET.[Sequence_Number]			=		SOURCE.[Sequence_Number]           AND
			TARGET.[Modifier]					=		SOURCE.[Modifier]                  AND
			TARGET.[Caption]					=		SOURCE.[Caption]                   AND
			TARGET.[Serial_Number_Prefix]		=		SOURCE.[Serial_Number_Prefix]      AND
			TARGET.[Part_ID]					=		SOURCE.[Part_ID]
		)
		WHEN MATCHED AND
		(
			TARGET.[ProductStructure_ID]		<>		SOURCE.[ProductStructure_ID]       OR
			TARGET.[isTopLevel]					<>		SOURCE.[isTopLevel]                OR
			TARGET.[Media_Number]				<>		SOURCE.[Media_Number]              OR
			TARGET.[IESystemControlNumber]		<>		SOURCE.[IESystemControlNumber]     OR
			TARGET.[Sequence_Number]			<>		SOURCE.[Sequence_Number]           OR
			TARGET.[Modifier]					<>		SOURCE.[Modifier]                  OR
			TARGET.[Caption]					<>		SOURCE.[Caption]                   OR
			TARGET.[Serial_Number_Prefix]		<>		SOURCE.[Serial_Number_Prefix]      OR
			TARGET.[Part_ID]					<>		SOURCE.[Part_ID]
		)
				THEN
			UPDATE
			SET 
			TARGET.[ProductStructure_ID]		=		SOURCE.[ProductStructure_ID]       ,
			TARGET.[isTopLevel]					=		SOURCE.[isTopLevel]                ,
			TARGET.[Media_Number]				=		SOURCE.[Media_Number]              ,
			TARGET.[IESystemControlNumber]		=		SOURCE.[IESystemControlNumber]     ,
			TARGET.[Sequence_Number]			=		SOURCE.[Sequence_Number]           ,
			TARGET.[Modifier]					=		SOURCE.[Modifier]                  ,
			TARGET.[Caption]					=		SOURCE.[Caption]                   ,
			TARGET.[Serial_Number_Prefix]		=		SOURCE.[Serial_Number_Prefix]      ,
			TARGET.[Part_ID]					=		SOURCE.[Part_ID]
		WHEN NOT MATCHED BY TARGET
			THEN 
		INSERT(
			[ProductStructure_ID]	
			,[isTopLevel]				
			,[Media_Number]			
			,[IESystemControlNumber]	
			,[Sequence_Number]		
			,[Modifier]				
			,[Caption]				
			,[Serial_Number_Prefix]	
			,[Part_ID]		
		)		
		VALUES
			(
			SOURCE.[ProductStructure_ID]   
			,SOURCE.[isTopLevel]            
			,SOURCE.[Media_Number]          
			,SOURCE.[IESystemControlNumber] 
			,SOURCE.[Sequence_Number]       
			,SOURCE.[Modifier]              
			,SOURCE.[Caption]               
			,SOURCE.[Serial_Number_Prefix]  
			,SOURCE.[Part_ID]

			)
										WHEN NOT MATCHED BY SOURCE
						THEN
							DELETE;

		set @AFFECTED_ROWS = @@ROWCOUNT 
		EXEC sis.WriteLog @PROCESSID = @ProcessID,
			@LOGTYPE = 'Information',
			@NAMEOFSPROC = @ProcName,
			@LOGMESSAGE = 'Merged final result into [sis].[IEPart_SNP_TopLevel]',
			@DATAVALUE = @AFFECTED_ROWS;

		-- Drop Temp Tables
		DROP TABLE IF EXISTS #consists
		DROP TABLE IF EXISTS #partstemp
		DROP TABLE IF EXISTS #PartsAndConsistsDataNDM

		

	COMMIT;
	
	EXEC sis.WriteLog @PROCESSID = @ProcessID,
	@LOGTYPE = 'Information',
	@NAMEOFSPROC = @ProcName,
	@LOGMESSAGE = 'Execution Completed',
	@DATAVALUE = NULL;
END TRY 
BEGIN CATCH
	DECLARE @ERRORMESSAGE2 NVARCHAR(4000) = ERROR_MESSAGE()
		,@ERRORLINE2 INT = ERROR_LINE();

	SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s', CAST(@ERRORLINE2 AS VARCHAR(10)), CAST(@ERRORMESSAGE2 AS VARCHAR(4000)));

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

	EXEC sis.WriteLog @PROCESSID = @ProcessID
		,@LOGTYPE = 'Error'
		,@NAMEOFSPROC = @ProcName
		,@LOGMESSAGE = @LOGMESSAGE
		,@DATAVALUE = NULL;

	RAISERROR (
			@LOGMESSAGE
			,17
			,1
			)
	WITH NOWAIT;
END CATCH
END
GO