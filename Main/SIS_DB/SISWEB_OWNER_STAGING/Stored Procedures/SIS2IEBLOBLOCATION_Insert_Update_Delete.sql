﻿
-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20200203
-- Modify Date: 20200205	fixed deadlock error
-- Description: Conditional load from STAGING SIS2IEBLOBLOCATION
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.SIS2IEBLOBLOCATION_Insert_Update_Delete (@FORCE_LOAD BIT = 'FALSE'
																			  ,@DEBUG      BIT = 'FALSE') 
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET XACT_ABORT,NOCOUNT ON;
	BEGIN TRY
		DECLARE @SCHEMANAME sysname = 'SISWEB_OWNER_STAGING'
			   ,@TABLENAME  sysname = 'SIS2IEBLOBLOCATION';

		DECLARE @FULLTABLENAME   sysname = @SCHEMANAME + '.' + @TABLENAME
			   ,@CURRENT_VERSION BIGINT  = CHANGE_TRACKING_CURRENT_VERSION();

		DECLARE @LAST_SYNCHRONIZATION_VERSION BIGINT           = SISWEB_OWNER_STAGING._getLastSynchVersion (@FULLTABLENAME)
			   ,@RESULT                       BIT
			   ,@ROWCOUNT                     BIGINT
			   ,@MERGED_ROWS                  BIGINT           = 0
			   ,@SYSUTCDATETIME               DATETIME2(6)     = SYSUTCDATETIME()
			   ,@PROCNAME                     VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@PROCESSID                    UNIQUEIDENTIFIER = NEWID()
			   ,@LOGMESSAGE                   VARCHAR(MAX);

		DECLARE @MERGE_RESULTS TABLE (ACTIONTYPE            NVARCHAR(10)
									 ,IESYSTEMCONTROLNUMBER VARCHAR(12) NOT NULL
									 ,LANGUAGEINDICATOR     VARCHAR(2) NOT NULL
									 ,MIMETYPE              VARCHAR(50) NOT NULL
									 ,LOCATION              VARCHAR(50) NOT NULL
									 ,UPDATEDATETIME        DATETIME2(6) NOT NULL
									 ,LASTMODIFIEDDATE      DATETIME2(6) NULL
									 ,FILESIZEBYTE			INT NULL);

/* 
	Davide 20200205 
	in order to avoid deadlocks errors like: "Transaction (Process ID 246) was deadlocked on lock | communication buffer resources with another process and has been chosen as the deadlock victim. Rerun the transaction.",
	we move the creation of temp table outside the TRANSACTION block, even if it is not extremely elegant
*/
		DROP TABLE IF EXISTS #DIFF_PRIMARY_KEYS;
		SELECT 
			CT.SYS_CHANGE_OPERATION AS OPERATION, 
			CT.IESYSTEMCONTROLNUMBER AS IESYSTEMCONTROLNUMBER, 
			CT.LANGUAGEINDICATOR AS LANGUAGEINDICATOR, 
			CT.SYS_CHANGE_VERSION AS SYS_CHANGE_VERSION, 
			CT.SYS_CHANGE_COLUMNS AS SYS_CHANGE_COLUMNS
		INTO #DIFF_PRIMARY_KEYS
		FROM CHANGETABLE(CHANGES SISWEB_OWNER_STAGING.SIS2IEBLOBLOCATION, @LAST_SYNCHRONIZATION_VERSION) AS CT;

		BEGIN TRANSACTION;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

		IF @FORCE_LOAD = 'FALSE'
		BEGIN
			EXEC SISWEB_OWNER_STAGING._getFullOrDiff @SCHEMANAME = @SCHEMANAME,@TABLENAME = @TABLENAME,@CURRENT_VERSION = @CURRENT_VERSION,@DEBUG = @DEBUG,@RESULT = @RESULT OUTPUT
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
					DELETE FROM SISWEB_OWNER.SIS2IEBLOBLOCATION
					OUTPUT 'DELETE' ACTIONTYPE,DELETED.IESYSTEMCONTROLNUMBER,DELETED.LANGUAGEINDICATOR,DELETED.MIMETYPE,DELETED.LOCATION,DELETED.UPDATEDATETIME,DELETED.
					LASTMODIFIEDDATE,DELETED.FILESIZEBYTE
						   INTO @MERGE_RESULTS
					WHERE EXISTS
					(
						SELECT *
						FROM #DIFF_PRIMARY_KEYS AS DK
						WHERE DK.IESYSTEMCONTROLNUMBER = SIS2IEBLOBLOCATION.IESYSTEMCONTROLNUMBER AND 
							  DK.LANGUAGEINDICATOR = SIS2IEBLOBLOCATION.LANGUAGEINDICATOR AND 
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
					INSERT INTO SISWEB_OWNER.SIS2IEBLOBLOCATION (IESYSTEMCONTROLNUMBER,LANGUAGEINDICATOR,MIMETYPE,LOCATION,UPDATEDATETIME,LASTMODIFIEDDATE,FILESIZEBYTE) 
					OUTPUT 'INSERT' ACTIONTYPE,INSERTED.IESYSTEMCONTROLNUMBER,INSERTED.LANGUAGEINDICATOR,INSERTED.MIMETYPE,INSERTED.LOCATION,INSERTED.UPDATEDATETIME,INSERTED.
					LASTMODIFIEDDATE,INSERTED.FILESIZEBYTE
						   INTO @MERGE_RESULTS
						   SELECT IESYSTEMCONTROLNUMBER,LANGUAGEINDICATOR,MIMETYPE,LOCATION,UPDATEDATETIME,@SYSUTCDATETIME,FILESIZEBYTE
						   FROM SISWEB_OWNER_STAGING.SIS2IEBLOBLOCATION AS DT
						   WHERE EXISTS
						   (
							   SELECT *
							   FROM #DIFF_PRIMARY_KEYS AS DK
							   WHERE DK.IESYSTEMCONTROLNUMBER = DT.IESYSTEMCONTROLNUMBER AND 
									 DK.LANGUAGEINDICATOR = DT.LANGUAGEINDICATOR AND 
									 DK.OPERATION = 'I'
						   );

					SELECT @MERGED_ROWS = @@ROWCOUNT;

					SET @LOGMESSAGE = FORMATMESSAGE('Inserted %s rows',CAST(@MERGED_ROWS AS VARCHAR(9)));
					EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
				END;

				-- 7.c Update if needed
				SELECT @ROWCOUNT = COUNT(*)
				FROM #DIFF_PRIMARY_KEYS AS DK
				WHERE DK.OPERATION = 'U' AND 
					  (-- if the modified column is LASTMODIFIEDDATE ignore the update 
					  DK.SYS_CHANGE_COLUMNS <> 0x0000000006000000 OR 
					  DK.SYS_CHANGE_COLUMNS IS NULL
					  );
				IF @ROWCOUNT > 0
				BEGIN
					UPDATE SISWEB_OWNER.SIS2IEBLOBLOCATION
					  SET MIMETYPE = ST.MIMETYPE,LOCATION = ST.LOCATION,UPDATEDATETIME = ST.UPDATEDATETIME,FILESIZEBYTE = ST.FILESIZEBYTE, LASTMODIFIEDDATE = @SYSUTCDATETIME
					OUTPUT 'UPDATE' ACTIONTYPE,INSERTED.IESYSTEMCONTROLNUMBER,INSERTED.LANGUAGEINDICATOR,INSERTED.MIMETYPE,INSERTED.LOCATION,INSERTED.UPDATEDATETIME,INSERTED.
					LASTMODIFIEDDATE,INSERTED.FILESIZEBYTE
						   INTO @MERGE_RESULTS
					FROM SISWEB_OWNER_STAGING.SIS2IEBLOBLOCATION AS ST
						 JOIN SISWEB_OWNER.SIS2IEBLOBLOCATION AS TT ON ST.IESYSTEMCONTROLNUMBER = TT.IESYSTEMCONTROLNUMBER AND 
																	   ST.LANGUAGEINDICATOR = TT.LANGUAGEINDICATOR
					WHERE EXISTS
					(
						SELECT *
						FROM #DIFF_PRIMARY_KEYS AS DK
						WHERE DK.IESYSTEMCONTROLNUMBER = ST.IESYSTEMCONTROLNUMBER AND 
							  DK.LANGUAGEINDICATOR = ST.LANGUAGEINDICATOR AND 
							  DK.OPERATION = 'U'
					);
					SELECT @MERGED_ROWS = @@ROWCOUNT;

					SET @LOGMESSAGE = FORMATMESSAGE('Updated %s rows',CAST(@MERGED_ROWS AS VARCHAR(9)));
					EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
				END;

				-- 8. Store current version to be used the next time
				IF @DEBUG = 'TRUE'
					SELECT * FROM @MERGE_RESULTS AS MR;

				EXEC SISWEB_OWNER_STAGING._setLastSynchVersion @FULLTABLENAME,@CURRENT_VERSION;

				SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
				(
					SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE =
					'UPDATE'
					) AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
					(
						SELECT MR.ACTIONTYPE,MR.IESYSTEMCONTROLNUMBER,MR.LANGUAGEINDICATOR,MR.MIMETYPE,MR.LOCATION,MR.UPDATEDATETIME,MR.LASTMODIFIEDDATE
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

			/* MERGE command */
			MERGE INTO SISWEB_OWNER.SIS2IEBLOBLOCATION tgt
			USING SISWEB_OWNER_STAGING.SIS2IEBLOBLOCATION src
			ON src.IESYSTEMCONTROLNUMBER = tgt.IESYSTEMCONTROLNUMBER AND 
			   src.LANGUAGEINDICATOR = tgt.LANGUAGEINDICATOR
			WHEN MATCHED AND EXISTS
			(
				SELECT src.MIMETYPE, src.LOCATION, src.UPDATEDATETIME, src.FILESIZEBYTE
				EXCEPT
				SELECT tgt.MIMETYPE, tgt.LOCATION, tgt.UPDATEDATETIME, tgt.FILESIZEBYTE
			)
				  THEN UPDATE SET tgt.MIMETYPE = src.MIMETYPE
				  	, tgt.LOCATION = src.LOCATION
					, tgt.UPDATEDATETIME = src.UPDATEDATETIME
					, tgt.LASTMODIFIEDDATE = @SYSUTCDATETIME
					, tgt.FILESIZEBYTE = src.FILESIZEBYTE
			WHEN NOT MATCHED BY TARGET
				  THEN
				  INSERT(IESYSTEMCONTROLNUMBER,LANGUAGEINDICATOR,MIMETYPE,LOCATION,UPDATEDATETIME,LASTMODIFIEDDATE, FILESIZEBYTE)
				  VALUES (src.IESYSTEMCONTROLNUMBER,src.LANGUAGEINDICATOR,src.MIMETYPE,src.LOCATION,src.UPDATEDATETIME,@SYSUTCDATETIME, src.FILESIZEBYTE) 
			WHEN NOT MATCHED BY SOURCE
				  THEN DELETE
			OUTPUT $ACTION,COALESCE(inserted.IESYSTEMCONTROLNUMBER,deleted.IESYSTEMCONTROLNUMBER) IESYSTEMCONTROLNUMBER,COALESCE(inserted.LANGUAGEINDICATOR,deleted.
			LANGUAGEINDICATOR) LANGUAGEINDICATOR,COALESCE(inserted.MIMETYPE,deleted.MIMETYPE) MIMETYPE,COALESCE(inserted.LOCATION,deleted.LOCATION) LOCATION,COALESCE(inserted.
			UPDATEDATETIME,deleted.UPDATEDATETIME) UPDATEDATETIME,COALESCE(inserted.LASTMODIFIEDDATE,deleted.LASTMODIFIEDDATE) LASTMODIFIEDDATE, COALESCE(inserted.FILESIZEBYTE, deleted.FILESIZEBYTE)
				   INTO @MERGE_RESULTS;

			/* MERGE command */
			SELECT @MERGED_ROWS = @@ROWCOUNT;

			EXEC SISWEB_OWNER_STAGING._setLastSynchVersion @FULLTABLENAME,@CURRENT_VERSION;

			SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
			(
				SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE =
				'UPDATE'
				) AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
				(
					SELECT MR.ACTIONTYPE,MR.IESYSTEMCONTROLNUMBER,MR.LANGUAGEINDICATOR,MR.MIMETYPE,MR.LOCATION,MR.UPDATEDATETIME,MR.LASTMODIFIEDDATE,MR.FILESIZEBYTE
					FROM @MERGE_RESULTS AS MR FOR JSON AUTO
				) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
			),'Modified Rows');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
		END;

		COMMIT;

		UPDATE STATISTICS SISWEB_OWNER.SIS2IEBLOBLOCATION WITH FULLSCAN;

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
GO

