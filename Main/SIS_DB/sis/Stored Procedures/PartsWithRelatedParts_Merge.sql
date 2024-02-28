-- =============================================
-- Create Date: 10242022
-- Description: Merge parts with related parts data into PartsWithRelatedParts
-- =============================================
CREATE PROCEDURE  [sis].[PartsWithRelatedParts_Merge]  AS BEGIN
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


		DECLARE @EngLanguageId int = (select Language_ID from sis.Language where Language_Code = 'en' and Default_Language = 1)

		SELECT DISTINCT vwxmediase1_.Media_Number                             AS Media_Number,
						vwxmediase1_.Serial_Number_Prefix                           AS Serial_Number_Prefix,
						vwxmediase1_.IESystemControlNumber                          AS IE_System_Control_Number,
						vwxmediase1_.Media_Origin									AS Media_Origin,
						part3_.Part_Number                                          AS Part_Number,
						part3_.Part_ID												AS Part_ID,
						part6_.Part_Number                                          AS Related_Part_Number,
						part6_.Part_ID												AS Related_Part_ID,
						relatedpar5_.Type_Indicator                                 AS Type_Indicator,
						vwxproduct0_.ParentProductStructure_ID                      AS Parent_Product_Structure_ID,
						productstr4_.Description                                    AS Product_Structure_Description,
						vwxproduct0_.ProductStructure_ID                            AS Product_Structure_ID,
						vwxmediase1_.Start_Serial_Number							AS Start_Serial_Number,
						vwxmediase1_.End_Serial_Number								AS End_Serial_Number,
						relatedpar5_.Relation_Type									AS Relation_Type
		INTO #PartsWithRelatedParts_01
		FROM   sis.vw_ProductStructure_IEPart vwxproduct0_
			   INNER JOIN sis.vw_MediaSequenceFamily vwxmediase1_
					   ON ( vwxproduct0_.IEPart_ID = vwxmediase1_.IEPart_ID and vwxproduct0_.Media_ID = vwxmediase1_.Media_ID)
			   INNER JOIN sis.IEPart iepart2_
					   ON ( iepart2_.IEPart_ID = vwxmediase1_.IEPart_ID )
			   INNER JOIN sis.Part part3_
					   ON ( part3_.Part_ID = iepart2_.Part_ID )
			   INNER JOIN sis.ProductStructure_Translation productstr4_
					   ON ( Cast(productstr4_.ProductStructure_ID AS INT) =
										 vwxproduct0_.ParentProductStructure_ID
							AND productstr4_.Language_ID = @EngLanguageId )
			   INNER JOIN sis.Related_Part_Relation relatedpar5_
					   ON ( part3_.Part_ID = relatedpar5_.Part_ID )
			   INNER JOIN sis.Part part6_
					   ON ( part6_.Part_ID = relatedpar5_.Related_Part_ID )
		

				set @AFFECTED_ROWS = @@ROWCOUNT 
				EXEC sis.WriteLog @PROCESSID = @ProcessID,
					@LOGTYPE = 'Information',
					@NAMEOFSPROC = @ProcName,
					@LOGMESSAGE = 'Created PartsWithRelatedParts_01',
					@DATAVALUE = @AFFECTED_ROWS;


SELECT DISTINCT vwxmediase1_.Media_Number                             AS Media_Number,
						vwxmediase1_.Serial_Number_Prefix                           AS Serial_Number_Prefix,
						vwxmediase1_.IESystemControlNumber                          AS IE_System_Control_Number,
						vwxmediase1_.Media_Origin									AS Media_Origin,
						part3_.Part_Number                                          AS Part_Number,
						part3_.Part_ID												AS Part_ID,
						part6_.Part_Number                                          AS Related_Part_Number,
						part6_.Part_ID												AS Related_Part_ID,
						relatedpar5_.Type_Indicator                                 AS Type_Indicator,
						vwxproduct0_.ParentProductStructure_ID                      AS Parent_Product_Structure_ID,
						productstr4_.Description                                    AS Product_Structure_Description,
						vwxproduct0_.ProductStructure_ID                            AS Product_Structure_ID,
						vwxmediase1_.Start_Serial_Number							AS Start_Serial_Number,
						vwxmediase1_.End_Serial_Number								AS End_Serial_Number,
						relatedpar5_.Relation_Type									AS Relation_Type
		INTO #PartsWithRelatedParts_02
		FROM   sis.vw_ProductStructure_IEPart vwxproduct0_
			   INNER JOIN sis.vw_MediaSequenceFamily vwxmediase1_
					   ON ( vwxproduct0_.IEPart_ID = vwxmediase1_.IEPart_ID and vwxproduct0_.Media_ID = vwxmediase1_.Media_ID)
			   INNER JOIN sis.IEPart iepart2_
					   ON ( iepart2_.IEPart_ID = vwxmediase1_.IEPart_ID )
				
				INNER JOIN sis.Part_IEPart_Relation partiepart3_
				ON ( partiepart3_.IEPart_ID = iepart2_.IEPart_ID )

			   INNER JOIN sis.Part part3_
					   ON ( part3_.Part_ID = partiepart3_.Part_ID )
			   INNER JOIN sis.ProductStructure_Translation productstr4_
					   ON ( Cast(productstr4_.ProductStructure_ID AS INT) =
										 vwxproduct0_.ParentProductStructure_ID
							AND productstr4_.Language_ID = @EngLanguageId )
			   INNER JOIN sis.Related_Part_Relation relatedpar5_
					   ON ( part3_.Part_ID = relatedpar5_.Part_ID )
			   INNER JOIN sis.Part part6_
					   ON ( part6_.Part_ID = relatedpar5_.Related_Part_ID )


				set @AFFECTED_ROWS = @@ROWCOUNT 
				EXEC sis.WriteLog @PROCESSID = @ProcessID,
					@LOGTYPE = 'Information',
					@NAMEOFSPROC = @ProcName,
					@LOGMESSAGE = 'Created PartsWithRelatedParts_02',
					@DATAVALUE = @AFFECTED_ROWS;
				   
MERGE sis.PartsWithRelatedParts AS TARGET
		USING(SELECT Media_Number,
					 Serial_Number_Prefix,
					 IE_System_Control_Number,
					 Media_Origin,
					 Part_Number,
					 Part_ID,
					 Related_Part_Number,
					 Related_Part_ID,
					 Type_Indicator,
					 Parent_Product_Structure_ID,
					 Product_Structure_Description,
					 Product_Structure_ID,
					 Start_Serial_Number,
					 End_Serial_Number,
					 Relation_Type
				FROM #PartsWithRelatedParts_01
				UNION 
				SELECT Media_Number,
					 Serial_Number_Prefix,
					 IE_System_Control_Number,
					 Media_Origin,
					 Part_Number,
					 Part_ID,
					 Related_Part_Number,
					 Related_Part_ID,
					 Type_Indicator,
					 Parent_Product_Structure_ID,
					 Product_Structure_Description,
					 Product_Structure_ID,
					 Start_Serial_Number,
					 End_Serial_Number,
					 Relation_Type
				FROM #PartsWithRelatedParts_02
		) AS SOURCE
		ON
		(
				TARGET.[Media_Number]                    = SOURCE.[Media_Number]                    AND
				TARGET.[Serial_Number_Prefix]            = SOURCE.[Serial_Number_Prefix]            AND
				TARGET.[IE_System_Control_Number]        = SOURCE.[IE_System_Control_Number]        AND
				TARGET.[Media_Origin]                    = SOURCE.[Media_Origin]                    AND
				TARGET.[Part_Number]                     = SOURCE.[Part_Number]                     AND
				TARGET.[Part_ID]                         = SOURCE.[Part_ID]                         AND
				TARGET.[Related_Part_Number]             = SOURCE.[Related_Part_Number]             AND
				TARGET.[Related_Part_ID]                 = SOURCE.[Related_Part_ID]                 AND
				TARGET.[Type_Indicator]                  = SOURCE.[Type_Indicator]                  AND
				TARGET.[Parent_Product_Structure_ID]     = SOURCE.[Parent_Product_Structure_ID]     AND
				TARGET.[Product_Structure_Description]   = SOURCE.[Product_Structure_Description]   AND
				TARGET.[Product_Structure_ID]            = SOURCE.[Product_Structure_ID]            AND
				TARGET.[Start_Serial_Number]             = SOURCE.[Start_Serial_Number]             AND
				TARGET.[End_Serial_Number]				 = SOURCE.[End_Serial_Number]				AND
				TARGET.[Relation_Type]					 = SOURCE.[Relation_Type]
		)
		WHEN MATCHED AND
		(
			TARGET.[Media_Number]                    <> SOURCE.[Media_Number]                    OR
			TARGET.[Serial_Number_Prefix]            <> SOURCE.[Serial_Number_Prefix]            OR
			TARGET.[IE_System_Control_Number]        <> SOURCE.[IE_System_Control_Number]        OR
			TARGET.[Media_Origin]                    <> SOURCE.[Media_Origin]                    OR
			TARGET.[Part_Number]                     <> SOURCE.[Part_Number]                     OR
			TARGET.[Part_ID]                         <> SOURCE.[Part_ID]                         OR
			TARGET.[Related_Part_Number]             <> SOURCE.[Related_Part_Number]             OR
			TARGET.[Related_Part_ID]                 <> SOURCE.[Related_Part_ID]                 OR
			TARGET.[Type_Indicator]                  <> SOURCE.[Type_Indicator]                  OR
			TARGET.[Parent_Product_Structure_ID]     <> SOURCE.[Parent_Product_Structure_ID]     OR
			TARGET.[Product_Structure_Description]   <> SOURCE.[Product_Structure_Description]   OR
			TARGET.[Product_Structure_ID]            <> SOURCE.[Product_Structure_ID]            OR
			TARGET.[Start_Serial_Number]             <> SOURCE.[Start_Serial_Number]             OR
			TARGET.[End_Serial_Number]				 <> SOURCE.[End_Serial_Number]               OR
			TARGET.[Relation_Type]					 <> SOURCE.[Relation_Type] )
		THEN
			UPDATE
			SET TARGET.[Media_Number]                    = SOURCE.[Media_Number]                    ,
				TARGET.[Serial_Number_Prefix]            = SOURCE.[Serial_Number_Prefix]            ,
				TARGET.[IE_System_Control_Number]        = SOURCE.[IE_System_Control_Number]        ,
				TARGET.[Media_Origin]                    = SOURCE.[Media_Origin]                    ,
				TARGET.[Part_Number]                     = SOURCE.[Part_Number]                     ,
				TARGET.[Part_ID]                         = SOURCE.[Part_ID]                         ,
				TARGET.[Related_Part_Number]             = SOURCE.[Related_Part_Number]             ,
				TARGET.[Related_Part_ID]                 = SOURCE.[Related_Part_ID]                 ,
				TARGET.[Type_Indicator]                  = SOURCE.[Type_Indicator]                  ,
				TARGET.[Parent_Product_Structure_ID]     = SOURCE.[Parent_Product_Structure_ID]     ,
				TARGET.[Product_Structure_Description]   = SOURCE.[Product_Structure_Description]   ,
				TARGET.[Product_Structure_ID]            = SOURCE.[Product_Structure_ID]            ,
				TARGET.[Start_Serial_Number]             = SOURCE.[Start_Serial_Number]             ,
				TARGET.[End_Serial_Number]				 = SOURCE.[End_Serial_Number]				,
				TARGET.[Relation_Type]					 = SOURCE.[Relation_Type]
			WHEN NOT MATCHED BY TARGET
				THEN 
					INSERT(
						Media_Number
						,Serial_Number_Prefix
						,IE_System_Control_Number
						,Media_Origin
						,Part_Number
						,Part_ID
						,Related_Part_Number
						,Related_Part_ID
						,Type_Indicator
						,Parent_Product_Structure_ID
						,Product_Structure_Description
						,Product_Structure_ID
						,Start_Serial_Number
						,End_Serial_Number
						,Relation_Type
					)
					VALUES
					(
						SOURCE.[Media_Number]                 
						,SOURCE.[Serial_Number_Prefix]         
						,SOURCE.[IE_System_Control_Number]     
						,SOURCE.[Media_Origin]                 
						,SOURCE.[Part_Number]                  
						,SOURCE.[Part_ID]                      
						,SOURCE.[Related_Part_Number]          
						,SOURCE.[Related_Part_ID]              
						,SOURCE.[Type_Indicator]               
						,SOURCE.[Parent_Product_Structure_ID]  
						,SOURCE.[Product_Structure_Description]
						,SOURCE.[Product_Structure_ID]         
						,SOURCE.[Start_Serial_Number]          
						,SOURCE.[End_Serial_Number]
						,SOURCE.[Relation_Type]

					)
										WHEN NOT MATCHED BY SOURCE
						THEN
							DELETE;
				set @AFFECTED_ROWS = @@ROWCOUNT 
				EXEC sis.WriteLog @PROCESSID = @ProcessID,
					@LOGTYPE = 'Information',
					@NAMEOFSPROC = @ProcName,
					@LOGMESSAGE = 'Merged into PartsWithRelatedParts',
					@DATAVALUE = @AFFECTED_ROWS;
		
			COMMIT;

			Update STATISTICS sis.PartsWithRelatedParts with fullscan
			
			EXEC sis.WriteLog @PROCESSID = @ProcessID,
			@LOGTYPE = 'Information',
			@NAMEOFSPROC = @ProcName,
			@LOGMESSAGE = 'Execution Completed',
			@DATAVALUE = NULL;
END TRY 
BEGIN CATCH
	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
		,@ERRORLINE INT = ERROR_LINE();

	SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s', CAST(@ERRORLINE AS VARCHAR(10)), CAST(@ERRORMESSAGE AS VARCHAR(4000)));

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