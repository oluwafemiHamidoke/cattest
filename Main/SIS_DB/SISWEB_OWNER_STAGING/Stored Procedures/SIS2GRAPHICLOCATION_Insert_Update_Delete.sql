﻿-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20200203
-- Modify Date: 20200205	fixed deadlock error
-- Modify Date: 20200223	Added [LOCATIONHIGHRES] and [FILESIZEBYTEHIGHRES]
-- Description: Conditional load from STAGING SIS2GRAPHICLOCATION
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.SIS2GRAPHICLOCATION_Insert_Update_Delete (@FORCE_LOAD BIT = 'FALSE'
																			   ,@DEBUG      BIT = 'FALSE') 
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET XACT_ABORT,NOCOUNT ON;
	BEGIN TRY
		DECLARE @SCHEMANAME_SIS sysname = 'SISWEB_OWNER_STAGING'
		       ,@SCHEMANAME_EMP sysname = 'EMP_STAGING'
			   ,@TABLENAME  sysname = 'SIS2GRAPHICLOCATION';

		DECLARE @FULLTABLENAME_SIS   sysname = @SCHEMANAME_SIS + '.' + @TABLENAME
			   ,@FULLTABLENAME_EMP   sysname = @SCHEMANAME_EMP + '.' + @TABLENAME
			   ,@CURRENT_VERSION BIGINT  = CHANGE_TRACKING_CURRENT_VERSION();

		DECLARE @LAST_SYNCHRONIZATION_VERSION_SIS BIGINT           = SISWEB_OWNER_STAGING._getLastSynchVersion (@FULLTABLENAME_SIS)
			   ,@LAST_SYNCHRONIZATION_VERSION_EMP BIGINT           = EMP_STAGING._getLastSynchVersion (@FULLTABLENAME_EMP)
			   ,@RESULT                       BIT
			   ,@ROWCOUNT                     BIGINT
			   ,@MERGED_ROWS                  BIGINT           = 0
			   ,@SYSUTCDATETIME               DATETIME2(6)     = SYSUTCDATETIME()
			   ,@PROCNAME                     VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@PROCESSID                    UNIQUEIDENTIFIER = NEWID()
			   ,@LOGMESSAGE                   VARCHAR(MAX);

		DECLARE @MERGE_RESULTS TABLE (ACTIONTYPE           NVARCHAR(10)
									 ,GRAPHICCONTROLNUMBER VARCHAR(60) NOT NULL
									 ,MIMETYPE             VARCHAR(50) NOT NULL
									 ,LOCATION             VARCHAR(70) NOT NULL
									 ,UPDATEDATETIME       DATETIME2(6) NOT NULL
									 ,LASTMODIFIEDDATE     DATETIME2(6) NULL
									 ,FILESIZEBYTE         INT NULL
									 ,LOCATIONHIGHRES	   VARCHAR(150) NULL
									 ,FILESIZEBYTEHIGHRES  INT NULL
									);

/* 
	Davide 20200205 
	in order to avoid deadlocks errors like: "Transaction (Process ID 246) was deadlocked on lock | communication buffer resources with another process and has been chosen as the deadlock victim. Rerun the transaction.",
	we move the creation of temp table outside the TRANSACTION block, even if it is not extremely elegant
*/
		DROP TABLE IF EXISTS #DIFF_EMP_PRIMARY_KEYS;
		SELECT * INTO #DIFF_EMP_PRIMARY_KEYS FROM (
			SELECT CT.[GRAPHICCONTROLNUMBER],CT.[MIMETYPE],T.[LOCATION],T.[UPDATEDATETIME],T.[LASTMODIFIEDDATE],T.[FILESIZEBYTE], T.LOCATIONHIGHRES, T.FILESIZEBYTEHIGHRES,CT.SYS_CHANGE_OPERATION AS OPERATION,CT.SYS_CHANGE_COLUMNS AS SYS_CHANGE_COLUMNS
			FROM [EMP_STAGING].[SIS2GRAPHICLOCATION] as T
			RIGHT JOIN CHANGETABLE(CHANGES [EMP_STAGING].[SIS2GRAPHICLOCATION],@LAST_SYNCHRONIZATION_VERSION_EMP) as CT
			ON T.GRAPHICCONTROLNUMBER = CT.GRAPHICCONTROLNUMBER
			and T.MIMETYPE = CT.MIMETYPE) 
		as EMP_DIFF;

		DROP TABLE IF EXISTS #DIFF_SWO_PRIMARY_KEYS;
		SELECT * INTO #DIFF_SWO_PRIMARY_KEYS FROM (
			SELECT CT.[GRAPHICCONTROLNUMBER],CT.[MIMETYPE],T.[LOCATION],T.[UPDATEDATETIME],T.[LASTMODIFIEDDATE],T.[FILESIZEBYTE], T.LOCATIONHIGHRES, T.FILESIZEBYTEHIGHRES,CT.SYS_CHANGE_OPERATION AS OPERATION,CT.SYS_CHANGE_COLUMNS AS SYS_CHANGE_COLUMNS
			FROM [SISWEB_OWNER_STAGING].[SIS2GRAPHICLOCATION] as T
			RIGHT JOIN CHANGETABLE(CHANGES [SISWEB_OWNER_STAGING].[SIS2GRAPHICLOCATION],@LAST_SYNCHRONIZATION_VERSION_SIS) as CT
			ON T.GRAPHICCONTROLNUMBER = CT.GRAPHICCONTROLNUMBER
			and T.MIMETYPE = CT.MIMETYPE ) 
		AS SWO_DIFF;

        DROP TABLE IF EXISTS #duplicateRecords;
        SELECT a.GRAPHICCONTROLNUMBER, a.MIMETYPE INTO #duplicateRecords 
		FROM #DIFF_EMP_PRIMARY_KEYS a 
		INNER JOIN SISWEB_OWNER_STAGING.SIS2GRAPHICLOCATION b
            ON a.GRAPHICCONTROLNUMBER = b.GRAPHICCONTROLNUMBER and a.MIMETYPE = b.MIMETYPE

        DELETE FROM #DIFF_EMP_PRIMARY_KEYS WHERE GRAPHICCONTROLNUMBER IN (SELECT GRAPHICCONTROLNUMBER FROM #duplicateRecords) AND
        MIMETYPE IN (SELECT MIMETYPE FROM #duplicateRecords)


        DROP TABLE IF EXISTS #DIFF_PRIMARY_KEYS;
		SELECT * INTO #DIFF_PRIMARY_KEYS FROM (
            SELECT * FROM #DIFF_EMP_PRIMARY_KEYS
            UNION
            SELECT * FROM #DIFF_SWO_PRIMARY_KEYS
		) AS DIFF;

		BEGIN TRANSACTION;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

		IF @FORCE_LOAD = 'FALSE'
		BEGIN
			EXEC SISWEB_OWNER_STAGING._getFullOrDiffWithEMP @TABLENAME = @TABLENAME,@CURRENT_VERSION = @CURRENT_VERSION,@DEBUG = @DEBUG,@RESULT = @RESULT OUTPUT
			;

			IF @DEBUG = 'TRUE'
				PRINT FORMATMESSAGE('@RESULT=%s',IIF(@RESULT = 1,'TRUE','FALSE'));

			IF @RESULT = 'TRUE'
			BEGIN
				-- 6. Obtain the changes

				IF @DEBUG = 'TRUE'
					SELECT * FROM #DIFF_PRIMARY_KEYS AS DK;

				-- 7.a Delete if needed
				SELECT @ROWCOUNT = COUNT(*) FROM #DIFF_PRIMARY_KEYS AS DK WHERE DK.OPERATION = 'D';
				IF @ROWCOUNT > 0
				BEGIN
					DELETE FROM SISWEB_OWNER.SIS2GRAPHICLOCATION
					OUTPUT 'DELETE' ACTIONTYPE,DELETED.GRAPHICCONTROLNUMBER,DELETED.MIMETYPE,DELETED.LOCATION,DELETED.UPDATEDATETIME,DELETED.LASTMODIFIEDDATE,DELETED.FILESIZEBYTE, DELETED.LOCATIONHIGHRES, DELETED.FILESIZEBYTEHIGHRES
						   INTO @MERGE_RESULTS
					WHERE EXISTS
					(
						SELECT *
						FROM #DIFF_PRIMARY_KEYS AS DK
						WHERE DK.GRAPHICCONTROLNUMBER = SIS2GRAPHICLOCATION.GRAPHICCONTROLNUMBER AND 
							  DK.MIMETYPE = SIS2GRAPHICLOCATION.MIMETYPE AND 
							  DK.OPERATION = 'D'
					);

					SELECT @MERGED_ROWS = @@ROWCOUNT;

					SET @LOGMESSAGE = FORMATMESSAGE('Deleted %s rows',CAST(@MERGED_ROWS AS VARCHAR(9)));
					EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
				END;

				-- 7.b Insert if needed
				SELECT @ROWCOUNT = COUNT(*) FROM #DIFF_PRIMARY_KEYS AS DK WHERE DK.OPERATION = 'I';
				IF @ROWCOUNT > 0
				BEGIN
					INSERT INTO SISWEB_OWNER.SIS2GRAPHICLOCATION (GRAPHICCONTROLNUMBER,MIMETYPE,LOCATION,UPDATEDATETIME,LASTMODIFIEDDATE,FILESIZEBYTE,LOCATIONHIGHRES, FILESIZEBYTEHIGHRES) 
					OUTPUT 'INSERT' ACTIONTYPE,INSERTED.GRAPHICCONTROLNUMBER,INSERTED.MIMETYPE,INSERTED.LOCATION,INSERTED.UPDATEDATETIME,INSERTED.LASTMODIFIEDDATE,INSERTED.FILESIZEBYTE,INSERTED.LOCATIONHIGHRES, INSERTED.FILESIZEBYTEHIGHRES
						   INTO @MERGE_RESULTS
						   SELECT GRAPHICCONTROLNUMBER,MIMETYPE,LOCATION,UPDATEDATETIME,@SYSUTCDATETIME,FILESIZEBYTE, LOCATIONHIGHRES, FILESIZEBYTEHIGHRES
						   FROM #DIFF_PRIMARY_KEYS AS DK
							   WHERE DK.OPERATION = 'I';

					SELECT @MERGED_ROWS = @@ROWCOUNT;

					SET @LOGMESSAGE = FORMATMESSAGE('Inserted %s rows',CAST(@MERGED_ROWS AS VARCHAR(9)));
					EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
				END;

				-- 7.c Update if needed
				SELECT @ROWCOUNT = COUNT(*)
				FROM #DIFF_PRIMARY_KEYS AS DK
				WHERE DK.OPERATION = 'U' AND 
					  (-- if the modified column is LASTMODIFIEDDATE ignore the update 
					  DK.SYS_CHANGE_COLUMNS <> 0x0000000005000000 OR 
					  DK.SYS_CHANGE_COLUMNS IS NULL
					  );
				IF @ROWCOUNT > 0
				BEGIN
					UPDATE SISWEB_OWNER.SIS2GRAPHICLOCATION
					  SET LOCATION = ST.LOCATION,UPDATEDATETIME = ST.UPDATEDATETIME,LASTMODIFIEDDATE = @SYSUTCDATETIME, FILESIZEBYTE = ST.FILESIZEBYTE
					  ,LOCATIONHIGHRES = ST.LOCATIONHIGHRES , FILESIZEBYTEHIGHRES = ST.FILESIZEBYTEHIGHRES
					OUTPUT 'UPDATE' ACTIONTYPE,INSERTED.GRAPHICCONTROLNUMBER,INSERTED.MIMETYPE,INSERTED.LOCATION,INSERTED.UPDATEDATETIME,INSERTED.LASTMODIFIEDDATE,INSERTED.FILESIZEBYTE, INSERTED.LOCATIONHIGHRES, INSERTED.FILESIZEBYTEHIGHRES
						   INTO @MERGE_RESULTS
					FROM #DIFF_PRIMARY_KEYS AS ST
						 JOIN SISWEB_OWNER.SIS2GRAPHICLOCATION AS TT ON ST.GRAPHICCONTROLNUMBER = TT.GRAPHICCONTROLNUMBER AND 
																		ST.MIMETYPE = TT.MIMETYPE
																		WHERE ST.OPERATION = 'U'
					
					SELECT @MERGED_ROWS = @@ROWCOUNT;

					SET @LOGMESSAGE = FORMATMESSAGE('Updated %s rows',CAST(@MERGED_ROWS AS VARCHAR(9)));
					EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
				END;

				-- 8. Store current version to be used the next time
				IF @DEBUG = 'TRUE'
					SELECT * FROM @MERGE_RESULTS AS MR;

				EXEC SISWEB_OWNER_STAGING._setLastSynchVersion @FULLTABLENAME_SIS,@CURRENT_VERSION;
				EXEC EMP_STAGING._setLastSynchVersion @FULLTABLENAME_EMP,@CURRENT_VERSION;

				SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
				(
					SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE =
					'UPDATE'
					) AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
					(
						SELECT MR.ACTIONTYPE,MR.GRAPHICCONTROLNUMBER,MR.MIMETYPE,MR.LOCATION,MR.UPDATEDATETIME,MR.LASTMODIFIEDDATE,MR.FILESIZEBYTE, MR.LOCATIONHIGHRES,MR.FILESIZEBYTEHIGHRES
						FROM @MERGE_RESULTS AS MR FOR JSON AUTO
					) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
				),'Modified Rows');
				EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
			END;
		END;

		/* to be done: handle full load with MERGE */
		IF @FORCE_LOAD = 'TRUE'
		--   OR @MODIFIED_ROWS_PERCENTAGE BETWEEN-0.10 AND 0.10
		BEGIN
			SET @LOGMESSAGE = 'Executing load: Force Load = TRUE';
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @FORCE_LOAD;

		DROP TABLE IF EXISTS #duplicateRecordsInFullLoad;
        SELECT a.GRAPHICCONTROLNUMBER, a.MIMETYPE INTO #duplicateRecordsInFullLoad FROM [EMP_STAGING].[SIS2GRAPHICLOCATION] a INNER JOIN SISWEB_OWNER_STAGING.SIS2GRAPHICLOCATION b
            ON a.GRAPHICCONTROLNUMBER = b.GRAPHICCONTROLNUMBER and a.MIMETYPE = b.MIMETYPE

        DELETE FROM [EMP_STAGING].[SIS2GRAPHICLOCATION] WHERE GRAPHICCONTROLNUMBER IN (SELECT GRAPHICCONTROLNUMBER FROM #duplicateRecordsInFullLoad) AND
        MIMETYPE IN (SELECT MIMETYPE FROM #duplicateRecordsInFullLoad)

			/* MERGE command */
			MERGE INTO SISWEB_OWNER.SIS2GRAPHICLOCATION tgt
			USING (
				SELECT [GRAPHICCONTROLNUMBER],[MIMETYPE],[LOCATION],[UPDATEDATETIME],[LASTMODIFIEDDATE],[FILESIZEBYTE], [LOCATIONHIGHRES],[FILESIZEBYTEHIGHRES]
				FROM [EMP_STAGING].[SIS2GRAPHICLOCATION]
				UNION
				SELECT [GRAPHICCONTROLNUMBER],[MIMETYPE],[LOCATION],[UPDATEDATETIME],[LASTMODIFIEDDATE],[FILESIZEBYTE], [LOCATIONHIGHRES],[FILESIZEBYTEHIGHRES]
				FROM [SISWEB_OWNER_STAGING].[SIS2GRAPHICLOCATION]
			) src
			ON src.GRAPHICCONTROLNUMBER = tgt.GRAPHICCONTROLNUMBER AND 
			   src.MIMETYPE = tgt.MIMETYPE
			WHEN MATCHED AND EXISTS
			(
				SELECT src.LOCATION,src.UPDATEDATETIME,src.FILESIZEBYTE, SRC.LOCATIONHIGHRES, SRC.FILESIZEBYTEHIGHRES
				EXCEPT
				SELECT tgt.LOCATION,tgt.UPDATEDATETIME,tgt.FILESIZEBYTE, TGT.LOCATIONHIGHRES, TGT.FILESIZEBYTEHIGHRES
			)
				  THEN UPDATE SET tgt.LOCATION = src.LOCATION,tgt.UPDATEDATETIME = src.UPDATEDATETIME,tgt.LASTMODIFIEDDATE = @SYSUTCDATETIME,tgt.FILESIZEBYTE = src.FILESIZEBYTE
				  ,TGT.LOCATIONHIGHRES = SRC.LOCATIONHIGHRES, TGT.FILESIZEBYTEHIGHRES = SRC.FILESIZEBYTEHIGHRES
			WHEN NOT MATCHED BY TARGET
				  THEN
				  INSERT(GRAPHICCONTROLNUMBER,MIMETYPE,LOCATION,UPDATEDATETIME,LASTMODIFIEDDATE, FILESIZEBYTE, LOCATIONHIGHRES, FILESIZEBYTEHIGHRES)
				  VALUES (src.GRAPHICCONTROLNUMBER,src.MIMETYPE,src.LOCATION,src.UPDATEDATETIME,@SYSUTCDATETIME,src.FILESIZEBYTE, SRC.LOCATIONHIGHRES, SRC.FILESIZEBYTEHIGHRES) 
			WHEN NOT MATCHED BY SOURCE
				  THEN DELETE
			OUTPUT $ACTION,COALESCE(inserted.GRAPHICCONTROLNUMBER,deleted.GRAPHICCONTROLNUMBER) GRAPHICCONTROLNUMBER,COALESCE(inserted.MIMETYPE,deleted.MIMETYPE) MIMETYPE,COALESCE
			(inserted.LOCATION,deleted.LOCATION) LOCATION,COALESCE(inserted.UPDATEDATETIME,deleted.UPDATEDATETIME) UPDATEDATETIME,COALESCE(inserted.LASTMODIFIEDDATE,deleted.
			LASTMODIFIEDDATE) LASTMODIFIEDDATE, COALESCE(inserted.FILESIZEBYTE,deleted.FILESIZEBYTE) FILESIZEBYTE,
			COALESCE(inserted.LOCATIONHIGHRES,deleted.LOCATIONHIGHRES) LOCATIONHIGHRES, COALESCE(inserted.FILESIZEBYTEHIGHRES,deleted.FILESIZEBYTEHIGHRES) FILESIZEBYTEHIGHRES
				   INTO @MERGE_RESULTS;

			/* MERGE command */
			SELECT @MERGED_ROWS = @@ROWCOUNT;

			EXEC SISWEB_OWNER_STAGING._setLastSynchVersion @FULLTABLENAME_SIS,@CURRENT_VERSION;
			EXEC EMP_STAGING._setLastSynchVersion @FULLTABLENAME_EMP,@CURRENT_VERSION;

			SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
			(
				SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE =
				'UPDATE'
				) AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
				(
					SELECT MR.ACTIONTYPE,MR.GRAPHICCONTROLNUMBER,MR.MIMETYPE,MR.LOCATION,MR.UPDATEDATETIME,MR.LASTMODIFIEDDATE , MR.LOCATIONHIGHRES, MR.FILESIZEBYTEHIGHRES 
					FROM @MERGE_RESULTS AS MR FOR JSON AUTO
				) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
			),'Modified Rows');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
		END;

		COMMIT;

						UPDATE STATISTICS SISWEB_OWNER.SIS2GRAPHICLOCATION WITH FULLSCAN;

		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;
	END TRY
	BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
			   ,@ERRORLINE    INT            = ERROR_LINE()
			   ,@ERRORNUM     INT            = ERROR_NUMBER();
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @ERRORNUM;
	END CATCH;
END;