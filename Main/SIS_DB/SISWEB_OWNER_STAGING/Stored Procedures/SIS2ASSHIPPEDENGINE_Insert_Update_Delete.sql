﻿
-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20200131
-- Modify Date: 20200205	fixed deadlock error
-- Description: Conditional load from STAGING SIS2ASSHIPPEDENGINE
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.SIS2ASSHIPPEDENGINE_Insert_Update_Delete (@FORCE_LOAD BIT = 'FALSE'
																			   ,@DEBUG      BIT = 'FALSE') 
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET XACT_ABORT,NOCOUNT ON;
	BEGIN TRY
		DECLARE @SCHEMANAME sysname = 'SISWEB_OWNER_STAGING'
			   ,@TABLENAME  sysname = 'SIS2ASSHIPPEDENGINE';

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

		DECLARE @MERGE_RESULTS TABLE (ACTIONTYPE         NVARCHAR(10)
									 ,SERIALNUMBER       VARCHAR(8) NOT NULL
									 ,PARTSEQUENCENUMBER NUMERIC(10,0) NOT NULL
									 ,PARTNUMBER         VARCHAR(20) NULL
									 ,PARTNAME           VARCHAR(512) NULL
									 ,QUANTITY           VARCHAR(8) NULL
									 ,ENGGCHANGELEVELNO  VARCHAR(4) NULL
									 ,ASSEMBLY           VARCHAR(1) NULL
									 ,LESSINDICATOR      VARCHAR(1) NULL
									 ,INDENTATION        VARCHAR(1) NULL
									 ,UPDATEDATETIME     DATETIME2(6) NULL);

/* 
	Davide 20200205 
	in order to avoid deadlocks errors like: "Transaction (Process ID 246) was deadlocked on lock | communication buffer resources with another process and has been chosen as the deadlock victim. Rerun the transaction.",
	we move the creation of temp table outside the TRANSACTION block, even if it is not extremely elegant
*/
		DROP TABLE IF EXISTS #DIFF_PRIMARY_KEYS;
		SELECT CT.SYS_CHANGE_OPERATION AS OPERATION,CT.SERIALNUMBER AS SERIALNUMBER,CT.PARTSEQUENCENUMBER AS PARTSEQUENCENUMBER,CT.SYS_CHANGE_VERSION AS SYS_CHANGE_VERSION
		--,CT.SYS_CHANGE_COLUMNS AS   SYS_CHANGE_COLUMNS -- doesn't have LASTMODIFIEDDATE 
		INTO #DIFF_PRIMARY_KEYS
		FROM CHANGETABLE(CHANGES SISWEB_OWNER_STAGING.SIS2ASSHIPPEDENGINE,@LAST_SYNCHRONIZATION_VERSION) AS CT;

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
					DELETE FROM SISWEB_OWNER.SIS2ASSHIPPEDENGINE
					OUTPUT 'DELETE' ACTIONTYPE,DELETED.SERIALNUMBER,DELETED.PARTSEQUENCENUMBER,DELETED.PARTNUMBER,DELETED.PARTNAME,DELETED.QUANTITY,DELETED.ENGGCHANGELEVELNO,
					DELETED.ASSEMBLY,DELETED.LESSINDICATOR,DELETED.INDENTATION,DELETED.UPDATEDATETIME
						   INTO @MERGE_RESULTS
					WHERE EXISTS
					(
						SELECT *
						FROM #DIFF_PRIMARY_KEYS AS DK
						WHERE DK.SERIALNUMBER = SIS2ASSHIPPEDENGINE.SERIALNUMBER AND 
							  DK.PARTSEQUENCENUMBER = SIS2ASSHIPPEDENGINE.PARTSEQUENCENUMBER AND 
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
					INSERT INTO SISWEB_OWNER.SIS2ASSHIPPEDENGINE (SERIALNUMBER,PARTSEQUENCENUMBER,PARTNUMBER,PARTNAME,QUANTITY,ENGGCHANGELEVELNO,ASSEMBLY,LESSINDICATOR,INDENTATION,
					UPDATEDATETIME) 
					OUTPUT 'INSERT' ACTIONTYPE,INSERTED.SERIALNUMBER,INSERTED.PARTSEQUENCENUMBER,INSERTED.PARTNUMBER,INSERTED.PARTNAME,INSERTED.QUANTITY,INSERTED.ENGGCHANGELEVELNO,
					INSERTED.ASSEMBLY,INSERTED.LESSINDICATOR,INSERTED.INDENTATION,INSERTED.UPDATEDATETIME
						   INTO @MERGE_RESULTS
						   SELECT SERIALNUMBER,PARTSEQUENCENUMBER,PARTNUMBER,PARTNAME,QUANTITY,ENGGCHANGELEVELNO,ASSEMBLY,LESSINDICATOR,INDENTATION,UPDATEDATETIME
						   FROM SISWEB_OWNER_STAGING.SIS2ASSHIPPEDENGINE AS DT
						   WHERE EXISTS
						   (
							   SELECT *
							   FROM #DIFF_PRIMARY_KEYS AS DK
							   WHERE DK.SERIALNUMBER = DT.SERIALNUMBER AND 
									 DK.PARTSEQUENCENUMBER = DT.PARTSEQUENCENUMBER AND 
									 DK.OPERATION = 'I'
						   );

					SELECT @MERGED_ROWS = @@ROWCOUNT;

					SET @LOGMESSAGE = FORMATMESSAGE('Inserted %s rows',CAST(@MERGED_ROWS AS VARCHAR(9)));
					EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
				END;

				-- 7.c Update if needed
				SELECT @ROWCOUNT = COUNT(*) FROM #DIFF_PRIMARY_KEYS AS DK WHERE DK.OPERATION = 'U'; -- no LASTMODIFIEDDATE column
				--AND (-- if the modified column is LASTMODIFIEDDATE ignore the update 
				--DK.SYS_CHANGE_COLUMNS <> 0x000000000A000000
				--OR DK.SYS_CHANGE_COLUMNS IS NULL);
				IF @ROWCOUNT > 0
				BEGIN
					UPDATE SISWEB_OWNER.SIS2ASSHIPPEDENGINE
					  SET PARTNUMBER = ST.PARTNUMBER,PARTNAME = ST.PARTNAME,QUANTITY = ST.QUANTITY,ENGGCHANGELEVELNO = ST.ENGGCHANGELEVELNO,ASSEMBLY = ST.ASSEMBLY,LESSINDICATOR =
					  ST.LESSINDICATOR,INDENTATION = ST.INDENTATION,UPDATEDATETIME = ST.UPDATEDATETIME
					OUTPUT 'UPDATE' ACTIONTYPE,INSERTED.SERIALNUMBER,INSERTED.PARTSEQUENCENUMBER,INSERTED.PARTNUMBER,INSERTED.PARTNAME,INSERTED.QUANTITY,INSERTED.ENGGCHANGELEVELNO,
					INSERTED.ASSEMBLY,INSERTED.LESSINDICATOR,INSERTED.INDENTATION,INSERTED.UPDATEDATETIME
						   INTO @MERGE_RESULTS
					FROM SISWEB_OWNER_STAGING.SIS2ASSHIPPEDENGINE AS ST
						 JOIN SISWEB_OWNER.SIS2ASSHIPPEDENGINE AS TT ON ST.SERIALNUMBER = TT.SERIALNUMBER AND 
																		ST.PARTSEQUENCENUMBER = TT.PARTSEQUENCENUMBER
					WHERE EXISTS
					(
						SELECT *
						FROM #DIFF_PRIMARY_KEYS AS DK
						WHERE DK.SERIALNUMBER = ST.SERIALNUMBER AND 
							  DK.PARTSEQUENCENUMBER = ST.PARTSEQUENCENUMBER AND 
							  DK.OPERATION = 'U'
					);
					SELECT @MERGED_ROWS = @@ROWCOUNT;

					SET @LOGMESSAGE = FORMATMESSAGE('Updated %s rows',CAST(@MERGED_ROWS AS VARCHAR(9)));
					EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
				END;

				-- 8. Store current version to be used the next time
				IF @DEBUG = 'TRUE'
					SELECT * FROM @MERGE_RESULTS AS MR;

				SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
				(
					SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE =
					'UPDATE'
					) AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
					(
						SELECT MR.ACTIONTYPE,MR.SERIALNUMBER,MR.PARTSEQUENCENUMBER,MR.PARTNUMBER,MR.PARTNAME,MR.QUANTITY,MR.ENGGCHANGELEVELNO,MR.ASSEMBLY,MR.LESSINDICATOR,MR.
						INDENTATION,MR.UPDATEDATETIME
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
			MERGE INTO SISWEB_OWNER.SIS2ASSHIPPEDENGINE tgt
			USING SISWEB_OWNER_STAGING.SIS2ASSHIPPEDENGINE src
			ON src.SERIALNUMBER = tgt.SERIALNUMBER AND 
			   src.PARTSEQUENCENUMBER = tgt.PARTSEQUENCENUMBER
			WHEN MATCHED AND EXISTS
			(
				SELECT src.PARTNUMBER,src.PARTNAME,src.QUANTITY,src.ENGGCHANGELEVELNO,src.ASSEMBLY,src.LESSINDICATOR,src.INDENTATION,src.UPDATEDATETIME
				EXCEPT
				SELECT tgt.PARTNUMBER,tgt.PARTNAME,tgt.QUANTITY,tgt.ENGGCHANGELEVELNO,tgt.ASSEMBLY,tgt.LESSINDICATOR,tgt.INDENTATION,tgt.UPDATEDATETIME
			)
				  THEN UPDATE SET tgt.PARTNUMBER = src.PARTNUMBER,tgt.PARTNAME = src.PARTNAME,tgt.QUANTITY = src.QUANTITY,tgt.ENGGCHANGELEVELNO = src.ENGGCHANGELEVELNO,tgt.
				  ASSEMBLY = src.ASSEMBLY,tgt.LESSINDICATOR = src.LESSINDICATOR,tgt.INDENTATION = src.INDENTATION,tgt.UPDATEDATETIME = src.UPDATEDATETIME
			WHEN NOT MATCHED BY TARGET
				  THEN
				  INSERT(SERIALNUMBER,PARTSEQUENCENUMBER,PARTNUMBER,PARTNAME,QUANTITY,ENGGCHANGELEVELNO,ASSEMBLY,LESSINDICATOR,INDENTATION,UPDATEDATETIME)
				  VALUES (src.SERIALNUMBER,src.PARTSEQUENCENUMBER,src.PARTNUMBER,src.PARTNAME,src.QUANTITY,src.ENGGCHANGELEVELNO,src.ASSEMBLY,src.LESSINDICATOR,src.INDENTATION,src
				  .UPDATEDATETIME) 
			WHEN NOT MATCHED BY SOURCE
				  THEN DELETE
			OUTPUT $ACTION,COALESCE(inserted.SERIALNUMBER,deleted.SERIALNUMBER) SERIALNUMBER,COALESCE(inserted.PARTSEQUENCENUMBER,deleted.PARTSEQUENCENUMBER) PARTSEQUENCENUMBER,
			COALESCE(inserted.PARTNUMBER,deleted.PARTNUMBER) PARTNUMBER,COALESCE(inserted.PARTNAME,deleted.PARTNAME) PARTNAME,COALESCE(inserted.QUANTITY,deleted.QUANTITY) QUANTITY,
			COALESCE(inserted.ENGGCHANGELEVELNO,deleted.ENGGCHANGELEVELNO) ENGGCHANGELEVELNO,COALESCE(inserted.ASSEMBLY,deleted.ASSEMBLY) ASSEMBLY,COALESCE(inserted.LESSINDICATOR,
			deleted.LESSINDICATOR) LESSINDICATOR,COALESCE(inserted.INDENTATION,deleted.INDENTATION) INDENTATION,COALESCE(inserted.UPDATEDATETIME,deleted.UPDATEDATETIME)
			UPDATEDATETIME
				   INTO @MERGE_RESULTS;

			/* MERGE command */
			SELECT @MERGED_ROWS = @@ROWCOUNT;

			SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
			(
				SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE =
				'UPDATE'
				) AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
				(
					SELECT MR.ACTIONTYPE,MR.SERIALNUMBER,MR.PARTSEQUENCENUMBER,MR.PARTNUMBER,MR.PARTNAME,MR.QUANTITY,MR.ENGGCHANGELEVELNO,MR.ASSEMBLY,MR.LESSINDICATOR,MR.
					INDENTATION,MR.UPDATEDATETIME
					FROM @MERGE_RESULTS AS MR FOR JSON AUTO
				) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
			),'Modified Rows');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
		END;

		EXEC SISWEB_OWNER_STAGING._setLastSynchVersion @FULLTABLENAME,@CURRENT_VERSION;

		SET @LOGMESSAGE = FORMATMESSAGE('Version before running sproc: %s and after running sproc %s', CAST(@CURRENT_VERSION  as varchar(max)),  CAST(CHANGE_TRACKING_CURRENT_VERSION() as varchar(max)));

		COMMIT;
				UPDATE STATISTICS SISWEB_OWNER.SIS2ASSHIPPEDENGINE WITH FULLSCAN;

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
