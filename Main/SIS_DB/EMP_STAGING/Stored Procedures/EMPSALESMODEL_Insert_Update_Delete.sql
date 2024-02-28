CREATE PROCEDURE EMP_STAGING.EMPSALESMODEL_Insert_Update_Delete(@FORCE_LOAD BIT = 'FALSE'
                                                                        ,@DEBUG BIT = 'FALSE')
AS
BEGIN
        SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
        SET XACT_ABORT,NOCOUNT ON;
        BEGIN TRY
		DECLARE @SCHEMANAME sysname = 'EMP_STAGING'
			   ,@TABLENAME  sysname = 'EMPSALESMODEL';

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

		DECLARE @MERGE_RESULTS TABLE (ACTIONTYPE              NVARCHAR(10)
									 ,[EMPSALESMODEL_ID]      INT                NOT NULL
                                     ,[EMPPRODUCTFAMILY_ID]   INT                NOT NULL
                                     ,[NUMBER]                VARCHAR (60)       NOT NULL
                                     ,[NAME]                  VARCHAR (60)       NOT NULL
                                     ,[ALTERNATEMODEL]        VARCHAR (60)           NULL
                                     ,[ISCATMODEL]            BIT                    NULL
                                     ,[SERVICEABLE]           BIT                    NULL
                                     ,[MODEL]                 VARCHAR (60)           NULL
                                     ,[SNP]                   VARCHAR (60)           NULL
                                     ,[VERSION]               VARCHAR (13)           NULL
                                     ,[STATE]                 VARCHAR (15)           NULL
                                     ,[CURRENTSTATE]          VARCHAR (15)           NULL
                                     ,[LASTMODIFIEDDATE]      DATETIME2 (6)          NULL);

/*
	Davide 20200205
	in order to avoid deadlocks errors like: "Transaction (Process ID 246) was deadlocked on lock | communication buffer resources with another process and has been chosen as the deadlock victim. Rerun the transaction.",
	we move the creation of temp table outside the TRANSACTION block, even if it is not extremely elegant
*/
        DROP TABLE IF EXISTS #DIFF_PRIMARY_KEYS;
        SELECT CT.SYS_CHANGE_OPERATION AS OPERATION, CT.EMPSALESMODEL_ID AS EMPSALESMODEL_ID, CT.SYS_CHANGE_VERSION AS SYS_CHANGE_VERSION
        INTO #DIFF_PRIMARY_KEYS
        FROM CHANGETABLE(CHANGES EMP_STAGING.EMPSALESMODEL, @LAST_SYNCHRONIZATION_VERSION) AS CT;

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
                    DELETE FROM SISWEB_OWNER_SHADOW.EMPSALESMODEL
                    OUTPUT 'DELETE' ACTIONTYPE,DELETED.EMPSALESMODEL_ID,DELETED.EMPPRODUCTFAMILY_ID,DELETED.NUMBER,DELETED.NAME,
                    DELETED.ALTERNATEMODEL,DELETED.ISCATMODEL,DELETED.SERVICEABLE,DELETED.MODEL,DELETED.SNP,DELETED.VERSION,
                    DELETED.STATE,DELETED.CURRENTSTATE,DELETED.LASTMODIFIEDDATE
                    INTO @MERGE_RESULTS
                    WHERE EXISTS
                    (
                        SELECT *
                        FROM #DIFF_PRIMARY_KEYS AS DK
                        WHERE DK.EMPSALESMODEL_ID     = EMPSALESMODEL.EMPSALESMODEL_ID AND
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
                    INSERT INTO SISWEB_OWNER_SHADOW.EMPSALESMODEL (EMPSALESMODEL_ID,EMPPRODUCTFAMILY_ID,NUMBER,NAME,ALTERNATEMODEL,
                                                                   ISCATMODEL,SERVICEABLE,MODEL,SNP,VERSION,STATE,CURRENTSTATE,LASTMODIFIEDDATE)
                    OUTPUT 'INSERT' ACTIONTYPE,INSERTED.EMPSALESMODEL_ID,INSERTED.EMPPRODUCTFAMILY_ID,INSERTED.NUMBER,INSERTED.NAME,INSERTED.ALTERNATEMODEL,
                    INSERTED.ISCATMODEL,INSERTED.SERVICEABLE,INSERTED.MODEL,INSERTED.SNP,INSERTED.VERSION,INSERTED.STATE,INSERTED.CURRENTSTATE,INSERTED.LASTMODIFIEDDATE
						    INTO @MERGE_RESULTS
                            SELECT EMPSALESMODEL_ID,EMPPRODUCTFAMILY_ID,NUMBER,NAME,ALTERNATEMODEL,ISCATMODEL,SERVICEABLE,MODEL,SNP,VERSION,STATE,STATE,LASTMODIFIEDDATE
                            FROM EMP_STAGING.EMPSALESMODEL AS DT
                            WHERE EXISTS
                                      (
                                          SELECT *
                                          FROM #DIFF_PRIMARY_KEYS AS DK
                                          WHERE DK.EMPSALESMODEL_ID = DT.EMPSALESMODEL_ID
                                          AND DK.OPERATION = 'I'
                                      );

                    SELECT @MERGED_ROWS = @@ROWCOUNT;

                    SET @LOGMESSAGE = FORMATMESSAGE('Inserted %s rows',CAST(@MERGED_ROWS AS VARCHAR(9)));
                    EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
                END;

				-- 7.c Update if needed
                SELECT @ROWCOUNT = COUNT(*) FROM #DIFF_PRIMARY_KEYS AS DK WHERE DK.OPERATION = 'U';
                IF @ROWCOUNT > 0
                BEGIN
                    UPDATE SISWEB_OWNER_SHADOW.EMPSALESMODEL
                    SET EMPPRODUCTFAMILY_ID = ST.EMPPRODUCTFAMILY_ID,NUMBER = ST.NUMBER,NAME = ST.NAME,ALTERNATEMODEL = ST.ALTERNATEMODEL,
                        ISCATMODEL = ST.ISCATMODEL,SERVICEABLE = ST.SERVICEABLE,MODEL = ST.MODEL,SNP = ST.SNP,VERSION = ST.VERSION,STATE = ST.STATE,
                        CURRENTSTATE = ST.STATE,LASTMODIFIEDDATE = ST.LASTMODIFIEDDATE
                    OUTPUT 'UPDATE' ACTIONTYPE,INSERTED.EMPSALESMODEL_ID,INSERTED.EMPPRODUCTFAMILY_ID,INSERTED.NUMBER,INSERTED.NAME,INSERTED.ALTERNATEMODEL,
                    INSERTED.ISCATMODEL,INSERTED.SERVICEABLE,INSERTED.MODEL,INSERTED.SNP,INSERTED.VERSION,INSERTED.STATE,INSERTED.CURRENTSTATE,INSERTED.LASTMODIFIEDDATE
                    INTO @MERGE_RESULTS
                    FROM EMP_STAGING.EMPSALESMODEL AS ST
                        JOIN SISWEB_OWNER_SHADOW.EMPSALESMODEL AS TT ON ST.EMPSALESMODEL_ID = TT.EMPSALESMODEL_ID
                    WHERE EXISTS
                    (
                        SELECT *
                        FROM #DIFF_PRIMARY_KEYS AS DK
                        WHERE DK.EMPSALESMODEL_ID = ST.EMPSALESMODEL_ID AND
                              DK.OPERATION = 'U'
                    );
                    SELECT @MERGED_ROWS = @@ROWCOUNT;

                    SET @LOGMESSAGE = FORMATMESSAGE('Updated %s rows',CAST(@MERGED_ROWS AS VARCHAR(9)));
                    EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
                END;

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
						SELECT MR.EMPSALESMODEL_ID,MR.EMPPRODUCTFAMILY_ID,MR.NUMBER,MR.NAME,MR.ALTERNATEMODEL,
                               MR.ISCATMODEL,MR.SERVICEABLE,MR.MODEL,MR.SNP,MR.VERSION,MR.STATE,MR.CURRENTSTATE,MR.LASTMODIFIEDDATE
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
            MERGE INTO SISWEB_OWNER_SHADOW.EMPSALESMODEL tgt
            USING EMP_STAGING.EMPSALESMODEL src
            ON src.EMPSALESMODEL_ID = tgt.EMPSALESMODEL_ID
            WHEN MATCHED AND EXISTS
            (
                SELECT src.EMPPRODUCTFAMILY_ID,src.NUMBER,src.NAME,src.ALTERNATEMODEL,src.ISCATMODEL
                      ,src.SERVICEABLE,src.MODEL,src.SNP,src.VERSION,src.STATE,src.STATE,src.LASTMODIFIEDDATE
                    EXCEPT
                SELECT tgt.EMPPRODUCTFAMILY_ID,tgt.NUMBER,tgt.NAME,tgt.ALTERNATEMODEL,tgt.ISCATMODEL,
                       tgt.SERVICEABLE,tgt.MODEL,tgt.SNP,tgt.VERSION,tgt.STATE,tgt.CURRENTSTATE,tgt.LASTMODIFIEDDATE
            )
                THEN UPDATE SET tgt.EMPPRODUCTFAMILY_ID = src.EMPPRODUCTFAMILY_ID,tgt.NUMBER = src.NUMBER,
                                tgt.NAME=src.NAME,tgt.ALTERNATEMODEL = src.ALTERNATEMODEL,tgt.ISCATMODEL = src.ISCATMODEL,
                                tgt.SERVICEABLE = src.SERVICEABLE,tgt.MODEL = src.MODEL,tgt.SNP = src.SNP,
                                tgt.VERSION = src.VERSION,tgt.STATE = src.STATE,tgt.CURRENTSTATE = src.STATE,tgt.LASTMODIFIEDDATE = src.LASTMODIFIEDDATE
            WHEN NOT MATCHED BY TARGET
                THEN
                INSERT(EMPSALESMODEL_ID,EMPPRODUCTFAMILY_ID,NUMBER,NAME,ALTERNATEMODEL,
                       ISCATMODEL,SERVICEABLE,MODEL,SNP,VERSION,STATE,CURRENTSTATE,LASTMODIFIEDDATE)
                VALUES (src.EMPSALESMODEL_ID,src.EMPPRODUCTFAMILY_ID,src.NUMBER,src.NAME,src.ALTERNATEMODEL,
                        src.ISCATMODEL,src.SERVICEABLE,src.MODEL,src.SNP,src.VERSION,src.STATE,src.STATE,src.LASTMODIFIEDDATE)
                WHEN NOT MATCHED BY SOURCE
                THEN DELETE
            OUTPUT $ACTION,COALESCE(inserted.EMPSALESMODEL_ID,deleted.EMPSALESMODEL_ID) EMPSALESMODEL_ID,COALESCE(inserted.EMPPRODUCTFAMILY_ID,deleted.EMPPRODUCTFAMILY_ID) EMPPRODUCTFAMILY_ID,
			COALESCE(inserted.NUMBER,deleted.NUMBER) NUMBER,COALESCE(inserted.NAME,deleted.NAME) NAME,
            COALESCE(inserted.ALTERNATEMODEL,deleted.ALTERNATEMODEL) ALTERNATEMODEL,COALESCE(inserted.ISCATMODEL,deleted.ISCATMODEL) ISCATMODEL,
            COALESCE(inserted.SERVICEABLE,deleted.SERVICEABLE) SERVICEABLE,COALESCE(inserted.MODEL,deleted.MODEL) MODEL,
            COALESCE(inserted.SNP,deleted.SNP) SNP,COALESCE(inserted.VERSION,deleted.VERSION) VERSION,COALESCE(inserted.STATE,deleted.STATE) STATE,
            COALESCE(inserted.CURRENTSTATE,deleted.CURRENTSTATE) CURRENTSTATE,COALESCE(inserted.LASTMODIFIEDDATE,deleted.LASTMODIFIEDDATE) LASTMODIFIEDDATE
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
					SELECT MR.ACTIONTYPE,MR.EMPSALESMODEL_ID,MR.EMPPRODUCTFAMILY_ID,MR.NUMBER,MR.NAME,MR.ALTERNATEMODEL,
                           MR.ISCATMODEL,MR.SERVICEABLE,MR.MODEL,MR.SNP,MR.VERSION,MR.STATE,MR.CURRENTSTATE,MR.LASTMODIFIEDDATE
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

