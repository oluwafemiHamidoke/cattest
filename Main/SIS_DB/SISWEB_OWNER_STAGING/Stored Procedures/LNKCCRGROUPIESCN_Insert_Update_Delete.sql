-- =============================================
-- Author:      Mahendra Kundare + Kuldeep Singh
-- Create Date: 20210204
-- Modify Date: 
-- Description: Conditional load from STAGING for LNKCCRGROUPIESCN
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.LNKCCRGROUPIESCN_Insert_Update_Delete (@FORCE_LOAD BIT = 'FALSE'
                                                                               ,@DEBUG      BIT = 'FALSE') 
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
    SET XACT_ABORT,NOCOUNT ON;
    BEGIN TRY
        DECLARE @SCHEMANAME sysname = 'SISWEB_OWNER_STAGING'
               ,@TABLENAME  sysname = 'LNKCCRGROUPIESCN';

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

        DECLARE @MERGE_RESULTS TABLE ([ACTIONTYPE]              [NVARCHAR](10)
                                    ,[SNP]                      [VARCHAR](10)      NOT NULL
                                    ,[OPERATIONRID]             [NUMERIC](10)      NOT NULL
                                    ,[IESYSTEMCONTROLNUMBER]    [VARCHAR](12)      NOT NULL
                                    ,[LASTMODIFIEDDATE]         [DATETIME2](6)     NULL);

        DROP TABLE IF EXISTS #DIFF_PRIMARY_KEYS;
        SELECT CT.SYS_CHANGE_OPERATION AS OPERATION,CT.SNP AS SNP,CT.OPERATIONRID AS OPERATIONRID,CT.IESYSTEMCONTROLNUMBER AS IESYSTEMCONTROLNUMBER,CT.SYS_CHANGE_VERSION AS SYS_CHANGE_VERSION,CT.SYS_CHANGE_COLUMNS AS SYS_CHANGE_COLUMNS
        INTO #DIFF_PRIMARY_KEYS
        FROM CHANGETABLE(CHANGES SISWEB_OWNER_STAGING.LNKCCRGROUPIESCN,@LAST_SYNCHRONIZATION_VERSION) AS CT;

        CREATE NONCLUSTERED INDEX IX_DIFF_PRIMARY_KEYS_OPERATION ON #DIFF_PRIMARY_KEYS (OPERATION);
        CREATE NONCLUSTERED INDEX IX_DIFF_PRIMARY_KEYS_SNP_OPERATIONID_IESCN_OPERATION ON #DIFF_PRIMARY_KEYS (SNP,OPERATIONRID,IESYSTEMCONTROLNUMBER,OPERATION);

        BEGIN TRANSACTION;
        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

        IF @FORCE_LOAD = 'FALSE'
        BEGIN
            EXEC SISWEB_OWNER_STAGING._getFullOrDiff @SCHEMANAME = @SCHEMANAME,@TABLENAME = @TABLENAME,@CURRENT_VERSION = @CURRENT_VERSION,@DEBUG = @DEBUG,@RESULT = @RESULT OUTPUT;

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
                    DELETE FROM SISWEB_OWNER.LNKCCRGROUPIESCN
                    OUTPUT 'DELETE' ACTIONTYPE,DELETED.SNP, DELETED.OPERATIONRID, DELETED.IESYSTEMCONTROLNUMBER, DELETED.LASTMODIFIEDDATE 
                           INTO @MERGE_RESULTS
                    WHERE EXISTS
                    (
                        SELECT 1
                        FROM #DIFF_PRIMARY_KEYS AS DK
                        WHERE DK.SNP = LNKCCRGROUPIESCN.SNP AND
                              DK.OPERATIONRID = LNKCCRGROUPIESCN.OPERATIONRID AND
                              DK.IESYSTEMCONTROLNUMBER = LNKCCRGROUPIESCN.IESYSTEMCONTROLNUMBER AND
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
                    INSERT INTO SISWEB_OWNER.LNKCCRGROUPIESCN (SNP, OPERATIONRID, IESYSTEMCONTROLNUMBER, LASTMODIFIEDDATE) 
                    OUTPUT 'INSERT' ACTIONTYPE,INSERTED.SNP, INSERTED.OPERATIONRID, INSERTED.IESYSTEMCONTROLNUMBER, INSERTED.LASTMODIFIEDDATE
                           INTO @MERGE_RESULTS
                           SELECT SNP, OPERATIONRID, IESYSTEMCONTROLNUMBER, LASTMODIFIEDDATE
                           FROM SISWEB_OWNER_STAGING.LNKCCRGROUPIESCN AS DT
                           WHERE EXISTS
                           (
                               SELECT 1
                               FROM #DIFF_PRIMARY_KEYS AS DK
                               WHERE DK.SNP = DT.SNP AND
                                     DK.OPERATIONRID = DT.OPERATIONRID AND
                                     DK.IESYSTEMCONTROLNUMBER = DT.IESYSTEMCONTROLNUMBER AND
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
                      DK.SYS_CHANGE_COLUMNS <> 0x000000000A000000 OR 
                      DK.SYS_CHANGE_COLUMNS IS NULL
                      );
                IF @ROWCOUNT > 0
                BEGIN
                    UPDATE SISWEB_OWNER.LNKCCRGROUPIESCN
                      SET LASTMODIFIEDDATE = @SYSUTCDATETIME
                    OUTPUT 'UPDATE' ACTIONTYPE,INSERTED.SNP, INSERTED.OPERATIONRID, INSERTED.IESYSTEMCONTROLNUMBER, INSERTED.LASTMODIFIEDDATE
                           INTO @MERGE_RESULTS
                    FROM SISWEB_OWNER_STAGING.LNKCCRGROUPIESCN AS ST
                         JOIN SISWEB_OWNER.LNKCCRGROUPIESCN AS TT ON ST.SNP = TT.SNP AND
                                                                     ST.OPERATIONRID = TT.OPERATIONRID AND
                                                                     ST.IESYSTEMCONTROLNUMBER = TT.IESYSTEMCONTROLNUMBER
                    WHERE EXISTS
                    (
                        SELECT 1
                        FROM #DIFF_PRIMARY_KEYS AS DK
                        WHERE DK.SNP = ST.SNP AND
                              DK.OPERATIONRID = ST.OPERATIONRID AND
                              DK.IESYSTEMCONTROLNUMBER = ST.IESYSTEMCONTROLNUMBER AND                              
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
                        SELECT MR.ACTIONTYPE,MR.SNP, MR.OPERATIONRID, MR.IESYSTEMCONTROLNUMBER, MR.LASTMODIFIEDDATE
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
            SET @LOGMESSAGE = 'Executing load: ' + IIF(@FORCE_LOAD = 1,'Force Load = TRUE','Force Load = FALSE');
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

            /* MERGE command */
            MERGE INTO SISWEB_OWNER.LNKCCRGROUPIESCN tgt
            USING SISWEB_OWNER_STAGING.LNKCCRGROUPIESCN src
            ON
               src.SNP = tgt.SNP AND
               src.OPERATIONRID = tgt.OPERATIONRID AND
               src.IESYSTEMCONTROLNUMBER = tgt.IESYSTEMCONTROLNUMBER
                  WHEN MATCHED AND EXISTS(SELECT src.LASTMODIFIEDDATE
                                        EXCEPT
                                        SELECT tgt.LASTMODIFIEDDATE)
                  THEN UPDATE SET tgt.LASTMODIFIEDDATE = src.LASTMODIFIEDDATE
                WHEN NOT MATCHED BY TARGET
                  THEN
                  INSERT([SNP],
                        [OPERATIONRID],
                        [IESYSTEMCONTROLNUMBER],
                        [LASTMODIFIEDDATE])
                  VALUES
                       (src.SNP
                       ,src.OPERATIONRID
                       ,src.IESYSTEMCONTROLNUMBER
                       ,src.LASTMODIFIEDDATE
                ) 
                WHEN NOT MATCHED BY SOURCE
                  THEN DELETE
            OUTPUT $ACTION
                  ,COALESCE(inserted.SNP,deleted.SNP) [SNP]
                  ,COALESCE(inserted.OPERATIONRID,deleted.OPERATIONRID) [OPERATIONRID]
                  ,COALESCE(inserted.IESYSTEMCONTROLNUMBER,deleted.IESYSTEMCONTROLNUMBER) [IESYSTEMCONTROLNUMBER]
                  ,COALESCE(inserted.LASTMODIFIEDDATE,deleted.LASTMODIFIEDDATE) [LASTMODIFIEDDATE]
                   INTO @MERGE_RESULTS;
            /* MERGE command */

            SELECT @MERGED_ROWS = @@ROWCOUNT;
            
            SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                                        ,(SELECT MR.ACTIONTYPE
                                                                ,MR.SNP
                                                                ,MR.OPERATIONRID
                                                                ,MR.IESYSTEMCONTROLNUMBER
                                                                ,MR.LASTMODIFIEDDATE
                                                            FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER),'Modified Rows');
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
        END;

        EXEC SISWEB_OWNER_STAGING._setLastSynchVersion @FULLTABLENAME, @CURRENT_VERSION;

        SET @LOGMESSAGE = FORMATMESSAGE('Version before running sproc: %s and after running sproc %s', CAST(@CURRENT_VERSION  as varchar(max)),  CAST(CHANGE_TRACKING_CURRENT_VERSION() as varchar(max)));
        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

        COMMIT;

		UPDATE STATISTICS SISWEB_OWNER.LNKCCRGROUPIESCN WITH FULLSCAN;

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

