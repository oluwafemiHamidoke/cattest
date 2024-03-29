﻿-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20200109
-- Modify Date: 20200123
-- Modify Date: 20200205	fixed deadlock error
-- Description: Conditional load from STAGING LNKMEDIAINFOTYPE
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.LNKMEDIAINFOTYPE_Insert_Update_Delete (@FORCE_LOAD BIT = 'FALSE'
																			,@DEBUG      BIT = 'FALSE') 
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET XACT_ABORT,NOCOUNT ON;
	BEGIN TRY
		DECLARE @SCHEMANAME sysname = 'SISWEB_OWNER_STAGING'
			   ,@TABLENAME  sysname = 'LNKMEDIAINFOTYPE';

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

		DECLARE @MERGE_RESULTS TABLE (ACTIONTYPE       NVARCHAR(10)
									 ,MEDIANUMBER      VARCHAR(8) NOT NULL
									 ,INFOTYPEID       SMALLINT NOT NULL
									 ,LASTMODIFIEDDATE DATETIME2(6) NULL);

/* 
	Davide 20200205 
	in order to avoid deadlocks errors like: "Transaction (Process ID 246) was deadlocked on lock | communication buffer resources with another process and has been chosen as the deadlock victim. Rerun the transaction.",
	we move the creation of temp table outside the TRANSACTION block, even if it is not extremely elegant
*/
		DROP TABLE IF EXISTS #DIFF_PRIMARY_KEYS;
		SELECT CT.SYS_CHANGE_OPERATION AS OPERATION,CT.MEDIANUMBER AS MEDIANUMBER,CT.INFOTYPEID AS INFOTYPEID,CT.SYS_CHANGE_VERSION AS SYS_CHANGE_VERSION
		--,CT.SYS_CHANGE_COLUMNS AS   SYS_CHANGE_COLUMNS -- not needed all columns in PK
		INTO #DIFF_PRIMARY_KEYS
		FROM CHANGETABLE(CHANGES SISWEB_OWNER_STAGING.LNKMEDIAINFOTYPE,@LAST_SYNCHRONIZATION_VERSION) AS CT;

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
					DELETE FROM SISWEB_OWNER.LNKMEDIAINFOTYPE
					OUTPUT 'DELETE' ACTIONTYPE,DELETED.MEDIANUMBER,DELETED.INFOTYPEID,DELETED.LASTMODIFIEDDATE
						   INTO @MERGE_RESULTS
					WHERE EXISTS
					(
						SELECT *
						FROM #DIFF_PRIMARY_KEYS AS DK
						WHERE DK.MEDIANUMBER = LNKMEDIAINFOTYPE.MEDIANUMBER AND 
							  DK.INFOTYPEID = LNKMEDIAINFOTYPE.INFOTYPEID AND 
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
					INSERT INTO SISWEB_OWNER.LNKMEDIAINFOTYPE (MEDIANUMBER,INFOTYPEID,LASTMODIFIEDDATE) 
					OUTPUT 'INSERT' ACTIONTYPE,INSERTED.MEDIANUMBER,INSERTED.INFOTYPEID,INSERTED.LASTMODIFIEDDATE
						   INTO @MERGE_RESULTS
						   SELECT MEDIANUMBER,INFOTYPEID,@SYSUTCDATETIME
						   FROM SISWEB_OWNER_STAGING.LNKMEDIAINFOTYPE AS DT
						   WHERE EXISTS
						   (
							   SELECT *
							   FROM #DIFF_PRIMARY_KEYS AS DK
							   WHERE DK.MEDIANUMBER = DT.MEDIANUMBER AND 
									 DK.INFOTYPEID = DT.INFOTYPEID AND 
									 DK.OPERATION = 'I'
						   );

					SELECT @MERGED_ROWS = @@ROWCOUNT;

					SET @LOGMESSAGE = FORMATMESSAGE('Inserted %s rows',CAST(@MERGED_ROWS AS VARCHAR(9)));
					EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
				END;

/*				-- can't happen all columns in PK
				-- 7.c Update if needed
				SELECT @ROWCOUNT = COUNT(*) FROM #DIFF_PRIMARY_KEYS AS DK WHERE DK.OPERATION = 'U';-- not needed no LASTMODIFIEDDATE column
				--AND -- if the modified column is LASTMODIFIEDDATE ignore the update 
				--DK.SYS_CHANGE_COLUMNS <> 0x000000000A000000;
				IF @ROWCOUNT > 0
				BEGIN
					UPDATE SISWEB_OWNER.LNKMEDIAINFOTYPE
						   SET PARTNUMBER = ST.PARTNUMBER
							  ,PARTNAME = ST.PARTNAME
							  ,QUANTITY = ST.QUANTITY
							  ,ENGGCHANGELEVELNO = ST.ENGGCHANGELEVELNO
							  ,ASSEMBLY = ST.ASSEMBLY
							  ,LESSINDICATOR = ST.LESSINDICATOR
							  ,INDENTATION = ST.INDENTATION
							  ,LASTMODIFIEDDATE = @SYSUTCDATETIME
							  ,isValidSerialNumber = ST.isValidSerialNumber
							  ,isValidPartNumber = ST.isValidPartNumber
							  ,ID = ST.ID
							  ,ParentID = ST.ParentID
							  ,SNP = ST.SNP
							  ,SNR = ST.SNR
					OUTPUT 'UPDATE' ACTIONTYPE
						  ,INSERTED.SERIALNUMBER
						  ,INSERTED.PARTSEQUENCENUMBER
						  ,INSERTED.PARTNUMBER
						  ,INSERTED.PARTNAME
						  ,INSERTED.QUANTITY
						  ,INSERTED.ENGGCHANGELEVELNO
						  ,INSERTED.ASSEMBLY
						  ,INSERTED.LESSINDICATOR
						  ,INSERTED.INDENTATION
						  ,INSERTED.LASTMODIFIEDDATE
						  ,INSERTED.isValidSerialNumber
						  ,INSERTED.isValidPartNumber
						  ,INSERTED.ID
						  ,INSERTED.ParentID
						  ,INSERTED.SNP
						  ,INSERTED.SNR
						   INTO @MERGE_RESULTS
					  FROM SISWEB_OWNER_STAGING.LNKMEDIAINFOTYPE AS ST
						   JOIN SISWEB_OWNER.LNKMEDIAINFOTYPE AS TT ON
																	   ST.SERIALNUMBER = TT.SERIALNUMBER
																	   AND ST.PARTSEQUENCENUMBER = TT.PARTSEQUENCENUMBER
					  WHERE EXISTS(SELECT *
									 FROM #DIFF_PRIMARY_KEYS AS DK
									 WHERE
										   DK.SERIALNUMBER = ST.SERIALNUMBER
										   AND DK.PARTSEQUENCENUMBER = ST.PARTSEQUENCENUMBER
										   AND DK.OPERATION = 'U');
					SELECT @MERGED_ROWS = @@ROWCOUNT;

					SET @LOGMESSAGE = FORMATMESSAGE('Updated %s rows',CAST(@MERGED_ROWS AS VARCHAR(9)));
					EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID
										   ,@LOGTYPE = 'Information'
										   ,@NAMEOFSPROC = @PROCNAME
										   ,@LOGMESSAGE = @LOGMESSAGE
										   ,@DATAVALUE = @MERGED_ROWS;
				END;
*/

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
						SELECT MR.ACTIONTYPE,MR.MEDIANUMBER,MR.INFOTYPEID,MR.LASTMODIFIEDDATE
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
			MERGE INTO SISWEB_OWNER.LNKMEDIAINFOTYPE tgt
			USING SISWEB_OWNER_STAGING.LNKMEDIAINFOTYPE src
			ON src.MEDIANUMBER = tgt.MEDIANUMBER AND 
			   src.INFOTYPEID = tgt.INFOTYPEID
			-- can't happen all columns in PK
			--WHEN MATCHED AND EXISTS(SELECT src.PARTNUMBER
			--							  ,src.PARTNAME
			--							  ,src.QUANTITY
			--							  ,src.ENGGCHANGELEVELNO
			--							  ,src.ASSEMBLY
			--							  ,src.LESSINDICATOR
			--							  ,src.INDENTATION
			--							  ,src.isValidSerialNumber
			--							  ,src.isValidPartNumber
			--							  ,src.ID
			--							  ,src.ParentID
			--							  ,src.SNP
			--							  ,src.SNR
			--						EXCEPT
			--						SELECT tgt.PARTNUMBER
			--							  ,tgt.PARTNAME
			--							  ,tgt.QUANTITY
			--							  ,tgt.ENGGCHANGELEVELNO
			--							  ,tgt.ASSEMBLY
			--							  ,tgt.LESSINDICATOR
			--							  ,tgt.INDENTATION
			--							  ,tgt.isValidSerialNumber
			--							  ,tgt.isValidPartNumber
			--							  ,tgt.ID
			--							  ,tgt.ParentID
			--							  ,tgt.SNP
			--							  ,tgt.SNR)
			--  THEN UPDATE SET tgt.PARTNUMBER = src.PARTNUMBER
			--				 ,tgt.PARTNAME = src.PARTNAME
			--				 ,tgt.QUANTITY = src.QUANTITY
			--				 ,tgt.ENGGCHANGELEVELNO = src.ENGGCHANGELEVELNO
			--				 ,tgt.ASSEMBLY = src.ASSEMBLY
			--				 ,tgt.LESSINDICATOR = src.LESSINDICATOR
			--				 ,tgt.INDENTATION = src.INDENTATION
			--				 ,tgt.LASTMODIFIEDDATE = @SYSUTCDATETIME
			--				 ,tgt.isValidSerialNumber = src.isValidSerialNumber
			--				 ,tgt.isValidPartNumber = src.isValidPartNumber
			--				 ,tgt.ID = src.ID
			--				 ,tgt.ParentID = src.ParentID
			--				 ,tgt.SNP = src.SNP
			--				 ,tgt.SNR = src.SNR
			WHEN NOT MATCHED BY TARGET
				  THEN
				  INSERT(MEDIANUMBER,INFOTYPEID,LASTMODIFIEDDATE)
				  VALUES (src.MEDIANUMBER,src.INFOTYPEID,@SYSUTCDATETIME) 
			WHEN NOT MATCHED BY SOURCE
				  THEN DELETE
			OUTPUT $ACTION,COALESCE(inserted.MEDIANUMBER,deleted.MEDIANUMBER) MEDIANUMBER,COALESCE(inserted.INFOTYPEID,deleted.INFOTYPEID) INFOTYPEID,COALESCE(inserted.
			LASTMODIFIEDDATE,deleted.LASTMODIFIEDDATE) LASTMODIFIEDDATE
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
					SELECT MR.ACTIONTYPE,MR.MEDIANUMBER,MR.INFOTYPEID,MR.LASTMODIFIEDDATE
					FROM @MERGE_RESULTS AS MR FOR JSON AUTO
				) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
			),'Modified Rows');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
		END;

		COMMIT;

								UPDATE STATISTICS SISWEB_OWNER.LNKMEDIAINFOTYPE WITH FULLSCAN;

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

