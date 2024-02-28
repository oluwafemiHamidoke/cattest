-- =============================================
-- Author:      Kuldeep Singh + Mahendra Kundare
-- Create Date: 20210205
-- Modify Date: 
-- Description: Merge SISWEB_OWNER_STAGING.MASCCROPERATIONS to SISWEB_OWNER.MASCCROPERATIONS
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.MASCCROPERATIONS_Merge
    (@FORCE_LOAD BIT = 'FALSE'
    ,@DEBUG      BIT = 'FALSE') 
AS
BEGIN
    SET XACT_ABORT,NOCOUNT ON;
    BEGIN TRY
        DECLARE @MODIFIED_ROWS_PERCENTAGE      DECIMAL(12,4)    = 0
               ,@MERGED_ROWS                   INT              = 0
               ,@PROCNAME                      VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
               ,@PROCESSID                     UNIQUEIDENTIFIER = NEWID()
               ,@LOGMESSAGE                    VARCHAR(MAX);
        DECLARE @MERGE_RESULTS TABLE
            (ACTIONTYPE        NVARCHAR(10),
            OPERATIONRID    NUMERIC(10)     NOT NULL,
            SEGMENTRID      NUMERIC(10)     NOT NULL,
            OPERATION       VARCHAR(5)      NOT NULL,
            OPERATIONNUMBER VARCHAR(5)      NOT NULL,
            COMPONENTCODE   VARCHAR(4)      NOT NULL,
            JOBCODE         VARCHAR(3)      NOT NULL,
            MODIFIERCODE    VARCHAR(3)      NULL,
            LASTMODIFIEDDATE    DATETIME2(6) NULL);

        BEGIN TRANSACTION;
        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

        IF @FORCE_LOAD = 'FALSE'
        BEGIN
            EXEC @MODIFIED_ROWS_PERCENTAGE = [SISWEB_OWNER_STAGING].[_getModifiedRowsPercentage] @SISWEB_OWNER_TABLE='MASCCROPERATIONS', @SISWEB_OWNER_STAGING_TABLE = 'MASCCROPERATIONS'
        END;

        IF
           @FORCE_LOAD = 1
           OR @MODIFIED_ROWS_PERCENTAGE BETWEEN 0 AND 10
        BEGIN
            SET @LOGMESSAGE = 'Executing load: ' + IIF(@FORCE_LOAD = 1,'Force Load = TRUE','Force Load = FALSE');
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

            /* MERGE command */
            MERGE INTO SISWEB_OWNER.MASCCROPERATIONS tgt
            USING SISWEB_OWNER_STAGING.MASCCROPERATIONS src
            ON
               src.OPERATIONRID = tgt.OPERATIONRID
                WHEN MATCHED AND EXISTS(SELECT src.SEGMENTRID
                							  ,src.OPERATION
                							  ,src.OPERATION
                							  ,src.COMPONENTCODE
                							  ,src.JOBCODE
                							  ,src.MODIFIERCODE
                						EXCEPT
                						SELECT tgt.SEGMENTRID
                							  ,tgt.OPERATION
                							  ,tgt.OPERATIONNUMBER
                							  ,tgt.COMPONENTCODE
                							  ,tgt.JOBCODE
                							  ,tgt.MODIFIERCODE)
                 THEN UPDATE SET tgt.SEGMENTRID = src.SEGMENTRID,tgt.OPERATION = src.OPERATION,tgt.OPERATIONNUMBER = src.OPERATION,
                     tgt.COMPONENTCODE = src.COMPONENTCODE,tgt.JOBCODE = src.JOBCODE,tgt.MODIFIERCODE = src.MODIFIERCODE,tgt.LASTMODIFIEDDATE = src.LASTMODIFIEDDATE
                WHEN NOT MATCHED BY TARGET
                  THEN
                  INSERT(OPERATIONRID
                        ,SEGMENTRID
                        ,OPERATION
                        ,OPERATIONNUMBER
                        ,COMPONENTCODE
                        ,JOBCODE
                        ,MODIFIERCODE
                        ,LASTMODIFIEDDATE)
                  VALUES
                (src.OPERATIONRID
                ,src.SEGMENTRID
                ,src.OPERATION
                ,src.OPERATION
                ,src.COMPONENTCODE
                ,src.JOBCODE
                ,src.MODIFIERCODE
                ,src.LASTMODIFIEDDATE)
                WHEN NOT MATCHED BY SOURCE
                  THEN DELETE
            OUTPUT $ACTION
                  ,COALESCE(inserted.OPERATIONRID,deleted.OPERATIONRID) OPERATIONRID
                  ,COALESCE(inserted.SEGMENTRID,deleted.SEGMENTRID) SEGMENTRID
                  ,COALESCE(inserted.OPERATION,deleted.OPERATION) OPERATION
                  ,COALESCE(inserted.OPERATIONNUMBER,deleted.OPERATIONNUMBER) OPERATIONNUMBER
                  ,COALESCE(inserted.COMPONENTCODE,deleted.COMPONENTCODE) COMPONENTCODE
                  ,COALESCE(inserted.JOBCODE,deleted.JOBCODE) JOBCODE
                  ,COALESCE(inserted.MODIFIERCODE,deleted.MODIFIERCODE) MODIFIERCODE
                  ,COALESCE(inserted.LASTMODIFIEDDATE,deleted.LASTMODIFIEDDATE) LASTMODIFIEDDATE
                   INTO @MERGE_RESULTS;
            /* MERGE command */

            SELECT @MERGED_ROWS = @@ROWCOUNT;
            SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                                        ,(SELECT MR.ACTIONTYPE
                                                                ,MR.OPERATIONRID
                                                                ,MR.SEGMENTRID
                                                                ,MR.OPERATION
                                                                ,MR.OPERATIONNUMBER
                                                                ,MR.COMPONENTCODE
                                                                ,MR.JOBCODE
                                                                ,MR.MODIFIERCODE
                                                                ,MR.LASTMODIFIEDDATE
                                                            FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER),'Modified Rows');
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
        END;
        ELSE
        BEGIN
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Skipping load: Row difference outside range (±10%)',@DATAVALUE = NULL;
        END;
        COMMIT;

        						UPDATE STATISTICS SISWEB_OWNER.MASCCROPERATIONS WITH FULLSCAN;

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
GO

