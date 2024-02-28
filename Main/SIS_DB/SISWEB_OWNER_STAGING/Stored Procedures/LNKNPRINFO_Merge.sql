
-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20200602 https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/6358/
-- Modify Date: 20200626 https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/6536/
-- Description: Conditional load from STAGING LNKNPRINFO + populate sis tables (Part, Part_Translation, PartHistory)
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.LNKNPRINFO_Merge (@FORCE_LOAD BIT = 'FALSE'
													  ,@DEBUG      BIT = 'FALSE') 
AS
BEGIN
	SET XACT_ABORT,NOCOUNT ON;
	BEGIN TRY
		DECLARE @MODIFIED_ROWS_PERCENTAGE      DECIMAL(12,4)    = 0
			   ,@MERGED_ROWS                   INT              = 0
			   ,@PROCNAME                      VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@PROCESSID                     UNIQUEIDENTIFIER = NEWID()
			   ,@LOGMESSAGE                    VARCHAR(MAX)
			   ,@SYSUTCDATETIME                DATETIME2(6)     = SYSUTCDATETIME()
               ,@DEFAULT_ORGCODE			   VARCHAR(12) 	   = SISWEB_OWNER_STAGING._getDefaultORGCODE();

		DECLARE @MERGE_RESULTS TABLE (ACTIONTYPE               NVARCHAR(10)
									 ,PARTNUMBER               VARCHAR(20) NOT NULL
									 ,COUNTRYCODE              VARCHAR(2) NOT NULL
									 ,ENGGCHANGELEVELNO        VARCHAR(2) NOT NULL
									 ,PRIMARYSEQNO             INT NOT NULL
									 ,PARTNUMBERDESCRIPTION    VARCHAR(200) NULL
									 ,NONRETURNABLEINDICATOR   VARCHAR(1) NULL
									 ,PARTREPLACEMENTINDICATOR VARCHAR(1) NULL
									 ,PACKAGEQUANTITY          VARCHAR(8) NULL
									 ,WEIGHT                   INT NULL
									 ,CANCELLEDNPRINFORMATION  VARCHAR(20) NULL
									 ,NPRINDICATOR             VARCHAR(20) NULL);

		DECLARE @MERGE_RESULTS_PARTHISTORY TABLE (ACTIONTYPE      NVARCHAR(10)
												 ,Part_ID         INT NOT NULL
												 ,Sequence_Number INT NOT NULL
												 ,Non_Returnable  BIT NULL
												 ,Weight_in_Pound NUMERIC(9,2) NULL
												 ,Change_Level    SMALLINT NOT NULL
												 ,Country_Code    CHAR(2) NULL);
		
		DECLARE @LANGUAGE_ID INT;
		SELECT @LANGUAGE_ID = L.Language_ID
		FROM sis.Language AS L
		WHERE L.Language_Code = 'en' AND 
			  Default_Language = 'TRUE';

		BEGIN TRANSACTION;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

		IF @FORCE_LOAD = 'FALSE'
		BEGIN
            EXEC @MODIFIED_ROWS_PERCENTAGE = [SISWEB_OWNER_STAGING].[_getModifiedRowsPercentage] @SISWEB_OWNER_TABLE='LNKNPRINFO', @SISWEB_OWNER_STAGING_TABLE = 'LNKNPRINFO'
		END;

		IF @FORCE_LOAD = 1 OR 
		   @MODIFIED_ROWS_PERCENTAGE BETWEEN 0 AND 10
		BEGIN
			SET @LOGMESSAGE = 'Executing load: ' + IIF(@FORCE_LOAD = 1,'Force Load = TRUE','Force Load = FALSE');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

			/* MERGE command */
			MERGE INTO SISWEB_OWNER.LNKNPRINFO tgt
			USING SISWEB_OWNER_STAGING.LNKNPRINFO src
			ON src.PARTNUMBER = tgt.PARTNUMBER AND 
			   src.COUNTRYCODE = tgt.COUNTRYCODE AND 
			   src.ENGGCHANGELEVELNO = tgt.ENGGCHANGELEVELNO AND 
			   src.PRIMARYSEQNO = tgt.PRIMARYSEQNO
			WHEN MATCHED AND EXISTS
			(
				SELECT src.PARTNUMBERDESCRIPTION,src.NONRETURNABLEINDICATOR,src.PARTREPLACEMENTINDICATOR,src.PACKAGEQUANTITY,src.WEIGHT,src.CANCELLEDNPRINFORMATION,src.
				NPRINDICATOR
				EXCEPT
				SELECT tgt.PARTNUMBERDESCRIPTION,tgt.NONRETURNABLEINDICATOR,tgt.PARTREPLACEMENTINDICATOR,tgt.PACKAGEQUANTITY,tgt.WEIGHT,tgt.CANCELLEDNPRINFORMATION,tgt.
				NPRINDICATOR
			)
				  THEN UPDATE SET tgt.PARTNUMBERDESCRIPTION = src.PARTNUMBERDESCRIPTION,tgt.NONRETURNABLEINDICATOR = src.NONRETURNABLEINDICATOR,tgt.PARTREPLACEMENTINDICATOR = src.
				  PARTREPLACEMENTINDICATOR,tgt.PACKAGEQUANTITY = src.PACKAGEQUANTITY,tgt.WEIGHT = src.WEIGHT,tgt.CANCELLEDNPRINFORMATION = src.CANCELLEDNPRINFORMATION,tgt.
				  NPRINDICATOR = src.NPRINDICATOR,tgt.LASTMODIFIEDDATE = @SYSUTCDATETIME
			WHEN NOT MATCHED BY TARGET
				  THEN
				  INSERT(PARTNUMBER,COUNTRYCODE,ENGGCHANGELEVELNO,PRIMARYSEQNO,PARTNUMBERDESCRIPTION,NONRETURNABLEINDICATOR,PARTREPLACEMENTINDICATOR,PACKAGEQUANTITY,WEIGHT,
				  CANCELLEDNPRINFORMATION,NPRINDICATOR,LASTMODIFIEDDATE)
				  VALUES (src.PARTNUMBER,src.COUNTRYCODE,src.ENGGCHANGELEVELNO,src.PRIMARYSEQNO,src.PARTNUMBERDESCRIPTION,src.NONRETURNABLEINDICATOR,src.PARTREPLACEMENTINDICATOR,
				  src.PACKAGEQUANTITY,src.WEIGHT,src.CANCELLEDNPRINFORMATION,src.NPRINDICATOR,@SYSUTCDATETIME) 
			WHEN NOT MATCHED BY SOURCE
				  THEN DELETE
			OUTPUT $ACTION,COALESCE(inserted.PARTNUMBER,deleted.PARTNUMBER) PARTNUMBER,COALESCE(inserted.COUNTRYCODE,deleted.COUNTRYCODE) COUNTRYCODE,COALESCE(inserted.
			ENGGCHANGELEVELNO,deleted.ENGGCHANGELEVELNO) ENGGCHANGELEVELNO,COALESCE(inserted.PRIMARYSEQNO,deleted.PRIMARYSEQNO) PRIMARYSEQNO,COALESCE(inserted.
			PARTNUMBERDESCRIPTION,deleted.PARTNUMBERDESCRIPTION) PARTNUMBERDESCRIPTION,COALESCE(inserted.NONRETURNABLEINDICATOR,deleted.NONRETURNABLEINDICATOR)
			NONRETURNABLEINDICATOR,COALESCE(inserted.PARTREPLACEMENTINDICATOR,deleted.PARTREPLACEMENTINDICATOR) PARTREPLACEMENTINDICATOR,COALESCE(inserted.PACKAGEQUANTITY,deleted.
			PACKAGEQUANTITY) PACKAGEQUANTITY,COALESCE(inserted.WEIGHT,deleted.WEIGHT) WEIGHT,COALESCE(inserted.CANCELLEDNPRINFORMATION,deleted.CANCELLEDNPRINFORMATION)
			CANCELLEDNPRINFORMATION,COALESCE(inserted.NPRINDICATOR,deleted.NPRINDICATOR) NPRINDICATOR
				   INTO @MERGE_RESULTS;

			/* MERGE command */

			SELECT @MERGED_ROWS = @@ROWCOUNT;
			SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
			(
				SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE =
				'UPDATE'
				) AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
				(
					SELECT MR.ACTIONTYPE,MR.PARTNUMBER,MR.COUNTRYCODE,MR.ENGGCHANGELEVELNO,MR.PRIMARYSEQNO,MR.PARTNUMBERDESCRIPTION,MR.NONRETURNABLEINDICATOR,MR.
					PARTREPLACEMENTINDICATOR,MR.PACKAGEQUANTITY,MR.WEIGHT,MR.CANCELLEDNPRINFORMATION,MR.NPRINDICATOR
					FROM @MERGE_RESULTS AS MR FOR JSON AUTO
				) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
			),'Modified Rows');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
		END;
		ELSE
		BEGIN
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Skipping load: Row difference outside range (±10%)',
			@DATAVALUE = NULL;
		END;
		COMMIT;

/* Load sis tables, see mail from Scott/Evan Re: New NPR data Tuesday, June 2, 2020 9:18 AM
		https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/6358/
		
		1. Part Numbers from NPR that do not exist in sis.Part
        Fine with omitting unless these have ever been legitimate/orderable parts.

		2. Part Numbers from NPR that do exist in sis.Part  but have different description
		Yes, please leverage our existing name(s) where possible.
		
		3. Part Numbers from NPR that exist in sis.Part, and have description in NPR but not in sis.Part_Translation.
		Yes, please load these names to supplement our potentially missing names.  One point of clarification: 
		if a Part IE is subsequently loaded that includes the part, we would want to “overwrite” the NPR name with the authored name.
		
		*/

		-- Case 1 we skip
		-- Case 2 and 3 we load into PartHistory
		BEGIN TRANSACTION;

		DROP TABLE IF EXISTS #PARTNUMBERS;

		-- Gets all partnumbers already present in sis.Part but not in sis.PartHistory, and saves in a temp table

		SELECT P.Part_ID AS Part_ID,ISNULL(CAST(NPR.PRIMARYSEQNO AS INT),-1) AS Sequence_Number,CAST(CASE
																									 WHEN NPR.NONRETURNABLEINDICATOR = '@' THEN 'TRUE'
																									 WHEN NPR.NONRETURNABLEINDICATOR IS NULL THEN 'FALSE'
																									 END AS BIT) AS Non_Returnable,CAST(NPR.WEIGHT * 0.01 AS NUMERIC(9,2)) AS
																									 Weight_in_Pound,CAST(NPR.ENGGCHANGELEVELNO AS CHAR(2)) AS Change_Level,CAST(
																									 NPR.COUNTRYCODE AS CHAR(2)) AS Country_Code
		INTO #PARTNUMBERS
		FROM SISWEB_OWNER.LNKNPRINFO AS NPR
			 JOIN sis.Part AS P ON P.Part_Number = NPR.PARTNUMBER AND P.Org_Code = @DEFAULT_ORGCODE;

		IF EXISTS(SELECT * FROM #PARTNUMBERS)
		BEGIN
			IF @DEBUG = 'TRUE'
				SELECT * FROM #PARTNUMBERS;

			ALTER TABLE #PARTNUMBERS
			ADD CONSTRAINT PK_#PARTNUMBERS PRIMARY KEY(Part_ID,Sequence_Number) WITH(ONLINE = OFF);

			/* MERGE command */
			MERGE INTO sis.PartHistory tgt
			USING #PARTNUMBERS src
			ON src.Part_ID = tgt.Part_ID AND 
			   src.Sequence_Number = tgt.Sequence_Number
			WHEN MATCHED AND EXISTS
			(
				SELECT src.Non_Returnable,src.Weight_in_Pound,src.Change_Level,src.Country_Code
				EXCEPT
				SELECT tgt.Non_Returnable,tgt.Weight_in_Pound,tgt.Change_Level,tgt.Country_Code
			)
				  THEN UPDATE SET tgt.Non_Returnable = src.Non_Returnable,tgt.Weight_in_Pound = src.Weight_in_Pound,tgt.Change_Level = src.Change_Level,tgt.Country_Code = src.
				  Country_Code
			WHEN NOT MATCHED BY TARGET
				  THEN
				  INSERT(Part_ID,Sequence_Number,Non_Returnable,Weight_in_Pound,Change_Level,Country_Code)
				  VALUES (src.Part_ID,src.Sequence_Number,src.Non_Returnable,src.Weight_in_Pound,src.Change_Level,src.Country_Code) 
			WHEN NOT MATCHED BY SOURCE
				  THEN DELETE
			OUTPUT $ACTION,COALESCE(inserted.Part_ID,deleted.Part_ID) Part_ID,COALESCE(inserted.Sequence_Number,deleted.Sequence_Number) Sequence_Number,COALESCE(inserted.
			Non_Returnable,deleted.Non_Returnable) Non_Returnable,COALESCE(inserted.Weight_in_Pound,deleted.Weight_in_Pound) Weight_in_Pound,COALESCE(inserted.Change_Level,deleted
			.Change_Level) Change_Level,COALESCE(inserted.Country_Code,deleted.Country_Code) Country_Code
				   INTO @MERGE_RESULTS_PARTHISTORY;

			/* MERGE command */
			SELECT @MERGED_ROWS = @@ROWCOUNT;
			SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
			(
				SELECT
				(
					SELECT COUNT(*)
					FROM @MERGE_RESULTS_PARTHISTORY AS MR
					WHERE MR.ACTIONTYPE = 'INSERT'
				) AS Inserted,
				(
					SELECT COUNT(*)
					FROM @MERGE_RESULTS_PARTHISTORY AS MR
					WHERE MR.ACTIONTYPE = 'UPDATE'
				) AS Updated,
				(
					SELECT COUNT(*)
					FROM @MERGE_RESULTS_PARTHISTORY AS MR
					WHERE MR.ACTIONTYPE = 'DELETE'
				) AS Deleted,
				(
					SELECT MR.ACTIONTYPE,MR.Part_ID,MR.Sequence_Number,MR.Non_Returnable,MR.Weight_in_Pound,MR.Change_Level,MR.Country_Code
					FROM @MERGE_RESULTS_PARTHISTORY AS MR FOR JSON AUTO
				) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
			),'sis.PartHistory - Modified Rows');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
		END;
		ELSE
		BEGIN
			SET @LOGMESSAGE = 'sis.PartHistory - No new/updated row, skipping load';
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = 0;
		END;

		DROP TABLE IF EXISTS #PARTNUMBERS;

		COMMIT;
    	
		UPDATE STATISTICS sis.PartHistory WITH FULLSCAN;		

		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;
	END TRY
	BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
			   ,@ERRORLINE    INT            = ERROR_LINE();

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		SET @LOGMESSAGE = 'LINE ' + CAST(@ERRORLINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;
	END CATCH;
END;