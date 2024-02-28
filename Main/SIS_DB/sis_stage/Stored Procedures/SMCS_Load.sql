
/* ====================================================================================================================================================
Author:			Paul B. Felix (+Davide Moraschi)
Create date:	2018-01-31
Modify date:	2019-08-15 Copied from [sis_stage].[Media_Load] and renamed
Modify date:	2019-08-16 Refactoring for [sis_stage].SMCS load, formatting https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4975/
Modify date:	2019-09-06 Adding SMCS IE Relation https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/5078/

-- Description: Full load [sis_stage].SMCS
-- Exec [sis_stage].[SMCS_Load]
====================================================================================================================================================== */
CREATE PROCEDURE [sis_stage].[SMCS_Load]
AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
		DECLARE @PROCNAME  VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@PROCESSID UNIQUEIDENTIFIER = NEWID();
		--DECLARE @STATIC_ROWCOUNT INT;
		--DECLARE @INSERTED_ROWS TABLE (SMCS_ID      INT NOT NULL
		--							 ,SMCSCOMPCODE CHAR(4) NOT NULL);

		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Execution started',NULL);

		--Load SMCS
		INSERT INTO sis_stage.SMCS (SMCSCOMPCODE,CurrentIndicator)
			   SELECT DISTINCT
					  SMCSCOMPCODE,
					  CASE
					  WHEN CURRENTINDICATOR = 'Y' THEN CAST(1 AS BIT)
					  ELSE 0
					  END AS CURRENTINDICATOR
			   FROM SISWEB_OWNER.MASSMCS AS SMCS
			   WHERE SMCS.CURRENTINDICATOR = 'Y'
			   ORDER BY SMCS.SMCSCOMPCODE;

		--select 'SMCS' Table_Name, @@RowCount Record_Count
		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'SMCS Load',@@ROWCOUNT);

		--Insert natural keys into key table
		INSERT INTO sis_stage.SMCS_Key (SMCSCOMPCODE)
			   --OUTPUT INSERTED.SMCS_ID,INSERTED.SMCSCOMPCODE
			   --	   INTO @INSERTED_ROWS
			   SELECT s.SMCSCOMPCODE
			   FROM sis_stage.SMCS AS s
					LEFT OUTER JOIN sis_stage.SMCS_Key AS k ON s.SMCSCOMPCODE = k.SMCSCOMPCODE
			   WHERE k.SMCS_ID IS NULL;
		--SET @STATIC_ROWCOUNT = @@ROWCOUNT;
		--SELECT @STATIC_ROWCOUNT
		--SELECT * FROM @INSERTED_ROWS
		--Key table load
		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'SMCS Key Load',@@ROWCOUNT);

		--Update stage table with surrogate keys from key table
		UPDATE s
		  SET SMCS_ID = k.SMCS_ID
		FROM sis_stage.SMCS s
			 INNER JOIN sis_stage.SMCS_Key k ON s.SMCSCOMPCODE = k.SMCSCOMPCODE
		WHERE s.SMCS_ID IS NULL;

		--SET @STATIC_ROWCOUNT = @@ROWCOUNT;
		--PRINT 'update @STATIC_ROWCOUNT'
		--Surrogate Update
		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'SMCS Update Surrogate',@@ROWCOUNT);

		--Load Diff table
		INSERT INTO sis_stage.SMCS_Diff (Operation,SMCS_ID,SMCSCOMPCODE,CurrentIndicator)
			   SELECT 'Insert' AS Operation,s.SMCS_ID,s.SMCSCOMPCODE,s.CurrentIndicator
			   FROM sis_stage.SMCS AS s
					LEFT OUTER JOIN sis.SMCS AS x ON s.SMCSCOMPCODE = x.SMCSCOMPCODE
			   WHERE x.SMCS_ID IS NULL --Inserted
			   UNION ALL
			   SELECT 'Delete' AS Operation,x.SMCS_ID,x.SMCSCOMPCODE,x.CurrentIndicator
			   FROM sis.SMCS AS x
					LEFT OUTER JOIN sis_stage.SMCS AS s ON s.SMCSCOMPCODE = x.SMCSCOMPCODE
			   WHERE s.SMCS_ID IS NULL --Deleted
			   UNION ALL
			   SELECT 'Update' AS Operation,s.SMCS_ID,s.SMCSCOMPCODE,s.CurrentIndicator
			   FROM sis_stage.SMCS AS s
					INNER JOIN sis.SMCS AS x ON s.SMCSCOMPCODE = x.SMCSCOMPCODE
			   WHERE NOT EXISTS --Updated
			   (
				   SELECT s.SMCS_ID,s.CurrentIndicator
				   INTERSECT
				   SELECT x.SMCS_ID,x.CurrentIndicator
			   );

		--Diff Load
		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'SMCS Diff Load',@@ROWCOUNT);

		--Load SMCS Translations
		INSERT INTO sis_stage.SMCS_Translation (SMCS_ID,Language_ID,Description)
			   SELECT S.SMCS_ID,L.Language_ID,SMCS.SMCSDESCRIPTION
			   FROM SISWEB_OWNER.MASSMCS AS SMCS
					JOIN sis_stage.SMCS AS S ON SMCS.SMCSCOMPCODE = S.SMCSCOMPCODE
					JOIN SISWEB_OWNER.MASLANGUAGE AS LANG ON LANG.LANGUAGEINDICATOR = SMCS.LANGUAGEINDICATOR
					JOIN sis_stage.Language AS L ON L.Legacy_Language_Indicator = LANG.LANGUAGEINDICATOR AND L.Default_Language = 1
			   WHERE SMCS.CURRENTINDICATOR = 'Y'
			   ORDER BY S.SMCS_ID,L.Language_ID;

		--select 'SMCS_Translation' Table_Name, @@RowCount Record_Count
		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'SMCS_Translation Load',@@ROWCOUNT);

		--Load Diff table
		INSERT INTO sis_stage.SMCS_Translation_Diff (Operation,SMCS_ID,Language_ID,Description)
			   SELECT 'Insert' AS Operation,s.SMCS_ID,s.Language_ID,s.Description
			   FROM sis_stage.SMCS_Translation AS s
					LEFT OUTER JOIN sis.SMCS_Translation AS x ON s.SMCS_ID = x.SMCS_ID AND
																 s.Language_ID = x.Language_ID
			   WHERE x.SMCS_ID IS NULL --Inserted
			   UNION ALL
			   SELECT 'Delete' AS Operation,x.SMCS_ID,x.Language_ID,x.Description
			   FROM sis.SMCS_Translation AS x
					LEFT OUTER JOIN sis_stage.SMCS_Translation AS s ON s.SMCS_ID = x.SMCS_ID AND
																	   s.Language_ID = x.Language_ID
			   WHERE s.SMCS_ID IS NULL --Deleted
			   UNION ALL
			   SELECT 'Update' AS Operation,s.SMCS_ID,s.Language_ID,s.Description
			   FROM sis_stage.SMCS_Translation AS s
					INNER JOIN sis.SMCS_Translation AS x ON s.SMCS_ID = x.SMCS_ID AND
															s.Language_ID = x.Language_ID
			   WHERE NOT EXISTS --Updated
			   (
				   SELECT s.Description
				   INTERSECT
				   SELECT x.Description
			   );

		--Diff Load
		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'SMCS_Translation Diff Load',@@ROWCOUNT);

		--Load SMCS IE Relation
		INSERT INTO sis_stage.SMCS_IE_Relation (SMCS_ID,IE_ID,Media_ID)
			   SELECT DISTINCT
					  SMCS.SMCS_ID,IE.IE_ID,M.Media_ID
			   FROM SISWEB_OWNER.LNKIESMCS AS LNK
					JOIN sis_stage.SMCS AS SMCS ON LNK.SMCSCOMPCODE = SMCS.SMCSCOMPCODE
					JOIN sis_stage.IE AS IE ON IE.IESystemControlNumber = LNK.IESYSTEMCONTROLNUMBER
                    JOIN sis_stage.Media AS M ON M.Media_Number = LNK.MEDIANUMBER
			   ORDER BY SMCS.SMCS_ID,IE.IE_ID,M.Media_ID;

		--select 'SMCS_IE_Relation' Table_Name, @@RowCount Record_Count
		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'SMCS_IE_Relation Load',@@ROWCOUNT);

		--Load Diff table
		INSERT INTO sis_stage.SMCS_IE_Relation_Diff (Operation,SMCS_ID,IE_ID,Media_ID)
			   SELECT 'Insert' AS Operation,s.SMCS_ID,s.IE_ID,s.Media_ID
			   FROM sis_stage.SMCS_IE_Relation AS s
					LEFT OUTER JOIN sis.SMCS_IE_Relation AS x ON s.SMCS_ID = x.SMCS_ID AND
																 s.IE_ID = x.IE_ID AND s.Media_ID = x.Media_ID
			   WHERE x.SMCS_ID IS NULL AND
					 x.IE_ID IS NULL AND x.Media_ID IS NULL --Inserted
			   UNION ALL
			   SELECT 'Delete' AS Operation,x.SMCS_ID,x.IE_ID,x.Media_ID
			   FROM sis.SMCS_IE_Relation AS x
					LEFT OUTER JOIN sis_stage.SMCS_IE_Relation AS s ON s.SMCS_ID = x.SMCS_ID AND
																	   s.IE_ID = x.IE_ID AND s.Media_ID = x.Media_ID
			   WHERE s.SMCS_ID IS NULL AND
					 s.IE_ID IS NULL AND s.Media_ID IS NULL--Deleted
			   UNION ALL
			   SELECT 'Update' AS Operation,s.SMCS_ID,s.IE_ID,s.Media_ID
			   FROM sis_stage.SMCS_IE_Relation AS s
					INNER JOIN sis.SMCS_IE_Relation AS x ON s.SMCS_ID = x.SMCS_ID AND
															s.IE_ID = x.IE_ID AND s.Media_ID = x.Media_ID
			   WHERE NOT EXISTS --Updated
			   (
				   SELECT s.*
				   INTERSECT
				   SELECT x.*
			   );

		--Diff Load
		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'SMCS_IE_Relation Diff Load',@@ROWCOUNT);

		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Execution completed',NULL);
		END TRY
		BEGIN CATCH
			DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
				   ,@ERROELINE    INT            = ERROR_LINE();
			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Error',@PROCNAME,'LINE ' + CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE,NULL);
		END CATCH;
	END;