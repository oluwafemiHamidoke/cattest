﻿
-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20200115
-- Modify Date: 20200122	refactored LASTMODIFIEDDATE
-- Modify Date: 20200205	fixed deadlock error
-- Modify Date: 20200511	modify the LNKIEIMAGE_Insert_Update_Delete to populate SHADOW schema 
-- Description: Conditional load from STAGING LNKIEIMAGE
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.LNKIEIMAGE_Insert_Update_Delete (@FORCE_LOAD BIT = 'FALSE'
																	 ,@DEBUG      BIT = 'FALSE') 
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET XACT_ABORT,NOCOUNT ON;
	BEGIN TRY
		DECLARE @SCHEMANAME_SIS sysname = 'SISWEB_OWNER_STAGING'
			   ,@SCHEMANAME_EMP sysname = 'EMP_STAGING'
			   ,@TABLENAME  sysname = 'LNKIEIMAGE';

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

		DECLARE @MERGE_RESULTS TABLE (ACTIONTYPE            NVARCHAR(10)
									 ,IESYSTEMCONTROLNUMBER VARCHAR(12) NOT NULL
									 ,GRAPHICCONTROLNUMBER  VARCHAR(60) NOT NULL
									 ,GRAPHICSEQUENCENUMBER SMALLINT NOT NULL
									 ,LASTMODIFIEDDATE      DATETIME2(6) NULL);

/* 
	Davide 20200205 
	in order to avoid deadlocks errors like: "Transaction (Process ID 246) was deadlocked on lock | communication buffer resources with another process and has been chosen as the deadlock victim. Rerun the transaction.",
	we move the creation of temp table outside the TRANSACTION block, even if it is not extremely elegant
*/

		DROP TABLE IF EXISTS #DIFF_EMP_PRIMARY_KEYS;
		SELECT * INTO #DIFF_EMP_PRIMARY_KEYS FROM (
			SELECT CT.[IESYSTEMCONTROLNUMBER],CT.[GRAPHICCONTROLNUMBER],CT.[GRAPHICSEQUENCENUMBER]
			,CT.SYS_CHANGE_OPERATION AS OPERATION
			FROM [EMP_STAGING].[LNKIEIMAGE] as T
			RIGHT JOIN CHANGETABLE(CHANGES [EMP_STAGING].[LNKIEIMAGE],@LAST_SYNCHRONIZATION_VERSION_EMP) as CT
			ON T.IESYSTEMCONTROLNUMBER = CT.IESYSTEMCONTROLNUMBER
			and T.GRAPHICCONTROLNUMBER = CT.GRAPHICCONTROLNUMBER
			and T.GRAPHICSEQUENCENUMBER = CT.GRAPHICSEQUENCENUMBER)
		as EMP_DIFF;

		DROP TABLE IF EXISTS #DIFF_SWO_PRIMARY_KEYS;
		SELECT * INTO #DIFF_SWO_PRIMARY_KEYS FROM (
			SELECT CT.[IESYSTEMCONTROLNUMBER],CT.[GRAPHICCONTROLNUMBER],CT.[GRAPHICSEQUENCENUMBER]
			,CT.SYS_CHANGE_OPERATION AS OPERATION
			FROM [SISWEB_OWNER_STAGING].[LNKIEIMAGE] as T
			RIGHT JOIN CHANGETABLE(CHANGES [SISWEB_OWNER_STAGING].[LNKIEIMAGE],@LAST_SYNCHRONIZATION_VERSION_SIS) as CT
			ON T.IESYSTEMCONTROLNUMBER = CT.IESYSTEMCONTROLNUMBER
			and T.GRAPHICCONTROLNUMBER = CT.GRAPHICCONTROLNUMBER
			and T.GRAPHICSEQUENCENUMBER = CT.GRAPHICSEQUENCENUMBER)
		AS SWO_DIFF;

		DROP TABLE IF EXISTS #duplicateRecords;
        SELECT a.IESYSTEMCONTROLNUMBER, a.GRAPHICCONTROLNUMBER, a.GRAPHICSEQUENCENUMBER INTO #duplicateRecords FROM #DIFF_EMP_PRIMARY_KEYS a INNER JOIN SISWEB_OWNER_STAGING.LNKIEIMAGE b
            ON a.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER and a.GRAPHICCONTROLNUMBER = b.GRAPHICCONTROLNUMBER and a.GRAPHICSEQUENCENUMBER = b.GRAPHICSEQUENCENUMBER

        DELETE FROM #DIFF_EMP_PRIMARY_KEYS WHERE IESYSTEMCONTROLNUMBER IN (SELECT IESYSTEMCONTROLNUMBER FROM #duplicateRecords) AND
		GRAPHICCONTROLNUMBER IN (SELECT GRAPHICCONTROLNUMBER FROM #duplicateRecords) AND GRAPHICSEQUENCENUMBER IN (SELECT GRAPHICSEQUENCENUMBER FROM #duplicateRecords)


		DROP TABLE IF EXISTS #DIFF_PRIMARY_KEYS;
		SELECT * INTO #DIFF_PRIMARY_KEYS FROM (
		SELECT * FROM #DIFF_EMP_PRIMARY_KEYS
		UNION
		SELECT * FROM #DIFF_SWO_PRIMARY_KEYS) AS DIFF;

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
					DELETE FROM SISWEB_OWNER_SHADOW.LNKIEIMAGE
					OUTPUT 'DELETE' ACTIONTYPE,DELETED.IESYSTEMCONTROLNUMBER,DELETED.GRAPHICCONTROLNUMBER,DELETED.GRAPHICSEQUENCENUMBER,DELETED.LASTMODIFIEDDATE
						   INTO @MERGE_RESULTS
					WHERE EXISTS
					(
						SELECT *
						FROM #DIFF_PRIMARY_KEYS AS DK
						WHERE DK.IESYSTEMCONTROLNUMBER = LNKIEIMAGE.IESYSTEMCONTROLNUMBER AND 
							  DK.GRAPHICCONTROLNUMBER = LNKIEIMAGE.GRAPHICCONTROLNUMBER AND 
							  DK.GRAPHICSEQUENCENUMBER = LNKIEIMAGE.GRAPHICSEQUENCENUMBER AND 
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
					INSERT INTO SISWEB_OWNER_SHADOW.LNKIEIMAGE (IESYSTEMCONTROLNUMBER,GRAPHICCONTROLNUMBER,GRAPHICSEQUENCENUMBER,LASTMODIFIEDDATE) 
					OUTPUT 'INSERT' ACTIONTYPE,INSERTED.IESYSTEMCONTROLNUMBER,INSERTED.GRAPHICCONTROLNUMBER,INSERTED.GRAPHICSEQUENCENUMBER,INSERTED.LASTMODIFIEDDATE
						   INTO @MERGE_RESULTS
						   SELECT IESYSTEMCONTROLNUMBER,GRAPHICCONTROLNUMBER,GRAPHICSEQUENCENUMBER,@SYSUTCDATETIME
						   FROM #DIFF_PRIMARY_KEYS AS DK
							   WHERE DK.OPERATION = 'I'
						  

					SELECT @MERGED_ROWS = @@ROWCOUNT;

					SET @LOGMESSAGE = FORMATMESSAGE('Inserted %s rows',CAST(@MERGED_ROWS AS VARCHAR(9)));
					EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
				END;

/*				-- CAN'T HAPPEN ALL COLUMNS IN PK
				-- 7.c Update if needed
				SELECT @ROWCOUNT = COUNT(*) FROM #DIFF_PRIMARY_KEYS AS DK WHERE DK.OPERATION = 'U';
				IF @ROWCOUNT > 0
				BEGIN
					UPDATE SISWEB_OWNER_SHADOW.LNKIEIMAGE
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
					  FROM SISWEB_OWNER_STAGING.LNKIEIMAGE AS ST
						   JOIN SISWEB_OWNER_SHADOW.LNKIEIMAGE AS TT ON
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

				SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
				(
					SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE =
					'UPDATE'
					) AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
					(
						SELECT MR.ACTIONTYPE,MR.IESYSTEMCONTROLNUMBER,MR.GRAPHICCONTROLNUMBER,MR.GRAPHICSEQUENCENUMBER,MR.LASTMODIFIEDDATE
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
			MERGE INTO SISWEB_OWNER_SHADOW.LNKIEIMAGE tgt
			USING (
				SELECT [IESYSTEMCONTROLNUMBER],[GRAPHICCONTROLNUMBER],[GRAPHICSEQUENCENUMBER]
  				FROM [SISWEB_OWNER_STAGING].[LNKIEIMAGE]
				UNION
				SELECT [IESYSTEMCONTROLNUMBER],[GRAPHICCONTROLNUMBER],[GRAPHICSEQUENCENUMBER]
  				FROM [EMP_STAGING].[LNKIEIMAGE]
			)  src
			ON src.IESYSTEMCONTROLNUMBER = tgt.IESYSTEMCONTROLNUMBER AND 
			   src.GRAPHICCONTROLNUMBER = tgt.GRAPHICCONTROLNUMBER AND 
			   src.GRAPHICSEQUENCENUMBER = tgt.GRAPHICSEQUENCENUMBER

			-- CAN'T HAPPEN ALL COLUMNS IN PK
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
				  INSERT(IESYSTEMCONTROLNUMBER,GRAPHICCONTROLNUMBER,GRAPHICSEQUENCENUMBER,LASTMODIFIEDDATE)
				  VALUES (src.IESYSTEMCONTROLNUMBER,src.GRAPHICCONTROLNUMBER,src.GRAPHICSEQUENCENUMBER,@SYSUTCDATETIME) 
			WHEN NOT MATCHED BY SOURCE
				  THEN DELETE
			OUTPUT $ACTION,COALESCE(inserted.IESYSTEMCONTROLNUMBER,deleted.IESYSTEMCONTROLNUMBER) IESYSTEMCONTROLNUMBER,COALESCE(inserted.GRAPHICCONTROLNUMBER,deleted.
			GRAPHICCONTROLNUMBER) GRAPHICCONTROLNUMBER,COALESCE(inserted.GRAPHICSEQUENCENUMBER,deleted.GRAPHICSEQUENCENUMBER) GRAPHICSEQUENCENUMBER,COALESCE(inserted.
			LASTMODIFIEDDATE,deleted.LASTMODIFIEDDATE) LASTMODIFIEDDATE
				   INTO @MERGE_RESULTS;

			/* MERGE command */
			SELECT @MERGED_ROWS = @@ROWCOUNT;

			SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
			(
				SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE =
				'UPDATE'
				) AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
				(
					SELECT MR.ACTIONTYPE,MR.IESYSTEMCONTROLNUMBER,MR.GRAPHICCONTROLNUMBER,MR.GRAPHICSEQUENCENUMBER,MR.LASTMODIFIEDDATE
					FROM @MERGE_RESULTS AS MR FOR JSON AUTO
				) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
			),'Modified Rows');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
		END;

		EXEC SISWEB_OWNER_STAGING._setLastSynchVersion @FULLTABLENAME_SIS,@CURRENT_VERSION;
		EXEC EMP_STAGING._setLastSynchVersion @FULLTABLENAME_EMP,@CURRENT_VERSION;

        SET @LOGMESSAGE = FORMATMESSAGE('Version before running sproc: %s and after running sproc %s', CAST(@CURRENT_VERSION  as varchar(max)),  CAST(CHANGE_TRACKING_CURRENT_VERSION() as varchar(max)));
        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

		COMMIT;
      -- If MS does fix the stats when the table swap then uncomment the below line 
								-- UPDATE STATISTICS SISWEB_OWNER_SHADOW.LNKIEIMAGE WITH FULLSCAN;

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
		THROW;
	END CATCH;
END;
GO
