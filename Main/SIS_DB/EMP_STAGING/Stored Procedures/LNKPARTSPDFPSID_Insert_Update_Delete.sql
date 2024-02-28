CREATE PROCEDURE EMP_STAGING.LNKPARTSPDFPSID_Insert_Update_Delete(@FORCE_LOAD BIT = 'FALSE'
                                                                    ,@DEBUG BIT = 'FALSE')
AS
BEGIN
        SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
        SET XACT_ABORT,NOCOUNT ON;
        BEGIN TRY
		DECLARE @SCHEMANAME sysname = 'EMP_STAGING'
			   ,@TABLENAME  sysname = 'LNKPARTSPDFPSID';

		DECLARE @FULLTABLENAME   sysname = @SCHEMANAME + '.' + @TABLENAME
			   ,@CURRENT_VERSION BIGINT  = CHANGE_TRACKING_CURRENT_VERSION();

		DECLARE @LAST_SYNCHRONIZATION_VERSION BIGINT           = EMP_STAGING._getLastSynchVersion (@FULLTABLENAME)
			   ,@RESULT                       BIT
			   ,@ROWCOUNT                     BIGINT
			   ,@MERGED_ROWS                  BIGINT           = 0
			   ,@SYSUTCDATETIME               DATETIME2(6)     = SYSUTCDATETIME()
			   ,@PROCNAME                     VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@PROCESSID                    UNIQUEIDENTIFIER = NEWID()
			   ,@LOGMESSAGE                   VARCHAR(MAX);

		DECLARE @MERGE_RESULTS TABLE (ACTIONTYPE            NVARCHAR(10)
									 ,PARTSPDF_ID           INT                    NOT NULL
									 ,PSID                  VARCHAR(8)             NOT NULL);

/*
	Davide 20200205
	in order to avoid deadlocks errors like: "Transaction (Process ID 246) was deadlocked on lock | communication buffer resources with another process and has been chosen as the deadlock victim. Rerun the transaction.",
	we move the creation of temp table outside the TRANSACTION block, even if it is not extremely elegant
*/
        DROP TABLE IF EXISTS #DIFF_PRIMARY_KEYS;
        SELECT CT.SYS_CHANGE_OPERATION AS OPERATION, CT.PARTSPDF_ID AS PARTSPDF_ID, CT.PSID AS PSID, CT.SYS_CHANGE_VERSION AS SYS_CHANGE_VERSION
        INTO #DIFF_PRIMARY_KEYS
        FROM CHANGETABLE(CHANGES EMP_STAGING.LNKPARTSPDFPSID, @LAST_SYNCHRONIZATION_VERSION) AS CT;

        BEGIN TRANSACTION;
        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

		IF @FORCE_LOAD = 'FALSE'
        BEGIN
            EXEC SISWEB_OWNER_STAGING._getFullOrDiffEMP @SCHEMANAME = @SCHEMANAME,@TABLENAME = @TABLENAME,@CURRENT_VERSION = @CURRENT_VERSION,@DEBUG = @DEBUG,@RESULT = @RESULT OUTPUT;

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
                    DELETE FROM SISWEB_OWNER_SHADOW.LNKPARTSPDFPSID
                    OUTPUT 'DELETE' ACTIONTYPE,DELETED.PARTSPDF_ID,DELETED.PSID
                    INTO @MERGE_RESULTS
                    WHERE EXISTS
                    (
                        SELECT *
                        FROM #DIFF_PRIMARY_KEYS AS DK
                        WHERE DK.PARTSPDF_ID = LNKPARTSPDFPSID.PARTSPDF_ID AND
                              DK.PSID        = LNKPARTSPDFPSID.PSID AND
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
                    INSERT INTO SISWEB_OWNER_SHADOW.LNKPARTSPDFPSID (PARTSPDF_ID, PSID)
                    OUTPUT 'INSERT' ACTIONTYPE,INSERTED.PARTSPDF_ID,INSERTED.PSID
						    INTO @MERGE_RESULTS
                            SELECT PARTSPDF_ID,PSID
                            FROM EMP_STAGING.LNKPARTSPDFPSID AS DT
                            WHERE EXISTS
                                      (
                                          SELECT *
                                          FROM #DIFF_PRIMARY_KEYS AS DK
                                          WHERE DK.PARTSPDF_ID = DT.PARTSPDF_ID AND
                                                DK.PSID        = DT.PSID AND
                                                DK.OPERATION   = 'I'
                                      );

                    SELECT @MERGED_ROWS = @@ROWCOUNT;

                    SET @LOGMESSAGE = FORMATMESSAGE('Inserted %s rows',CAST(@MERGED_ROWS AS VARCHAR(9)));
                    EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
                END;

  /*              -- cant' happen, all columns in PK
				-- 7.c Update if needed
                SELECT @ROWCOUNT = COUNT(*) FROM #DIFF_PRIMARY_KEYS AS DK WHERE DK.OPERATION = 'U';
                IF @ROWCOUNT > 0
                BEGIN
                    UPDATE SISWEB_OWNER_SHADOW.LNKPARTSPDFPSID
                    SET PARTSPDF_ID = ST.PARTSPDF_ID,PSID = ST.PSID
                    OUTPUT 'UPDATE' ACTIONTYPE,INSERTED.PARTSPDF_ID,INSERTED.PSID
                    INTO @MERGE_RESULTS
                    FROM EMP_STAGING.LNKPARTSPDFPSID AS ST
                        JOIN SISWEB_OWNER_SHADOW.LNKPARTSPDFPSID AS TT ON ST.PARTSPDF_ID = TT.PARTSPDF_ID
                    WHERE EXISTS
                    (
                        SELECT *
                        FROM #DIFF_PRIMARY_KEYS AS DK
                        WHERE DK.PARTSPDF_ID = ST.PARTSPDF_ID AND
                              DK.PSID        = ST.PSID AND
                              DK.OPERATION = 'U'
                    );
                    SELECT @MERGED_ROWS = @@ROWCOUNT;

                    SET @LOGMESSAGE = FORMATMESSAGE('Updated %s rows',CAST(@MERGED_ROWS AS VARCHAR(9)));
                    EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
                END;
*/
				-- 8. Store current version to be used the next time
				IF @DEBUG = 'TRUE'
                    SELECT * FROM @MERGE_RESULTS AS MR;

                EXEC EMP_STAGING._setLastSynchVersion @FULLTABLENAME,@CURRENT_VERSION;

				SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
				(
					SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE =
					'UPDATE'
					) AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
					(
						SELECT MR.ACTIONTYPE,MR.PARTSPDF_ID,MR.PSID
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
            MERGE INTO SISWEB_OWNER_SHADOW.LNKPARTSPDFPSID tgt
            USING EMP_STAGING.LNKPARTSPDFPSID src
            ON src.PARTSPDF_ID = tgt.PARTSPDF_ID AND
               src.PSID        = tgt.PSID
            WHEN NOT MATCHED BY TARGET
                THEN
                INSERT(PARTSPDF_ID, PSID)
                VALUES (src.PARTSPDF_ID,src.PSID)
                WHEN NOT MATCHED BY SOURCE
                THEN DELETE
            OUTPUT $ACTION,COALESCE(inserted.PARTSPDF_ID,deleted.PARTSPDF_ID) PARTSPDF_ID,COALESCE(inserted.PSID,deleted.PSID) PSID
				   INTO @MERGE_RESULTS;

			/* MERGE command */
            SELECT @MERGED_ROWS = @@ROWCOUNT;

            EXEC EMP_STAGING._setLastSynchVersion @FULLTABLENAME,@CURRENT_VERSION;

			SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
			(
				SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE =
				'UPDATE'
				) AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
				(
					SELECT MR.ACTIONTYPE,MR.PARTSPDF_ID,MR.PSID
					FROM @MERGE_RESULTS AS MR FOR JSON AUTO
				) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
			),'Modified Rows');
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
        END;

        COMMIT;
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
