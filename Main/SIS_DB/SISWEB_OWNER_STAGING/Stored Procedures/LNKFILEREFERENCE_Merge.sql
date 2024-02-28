-- =============================================
-- Author:      Sachin Poolamannil
-- Create Date: 20201022
-- Modify Date: 20201027 Add LASTMODIFIEDDATE column to merge
-- Description: Merge SISWEB_OWNER_STAGING.LNKFILEREFERENCE to SISWEB_OWNER.LNKFILEREFERENCE
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.LNKFILEREFERENCE_Merge
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
            (ACTIONTYPE        NVARCHAR(10)
            ,FILERID           INT          NOT NULL
            ,LANGUAGEINDICATOR VARCHAR(2)   NOT NULL
            ,REFERENCEFILERID  INT         NOT NULL
            ,LASTMODIFIEDDATE  DATETIME2(6) NULL);

        BEGIN TRANSACTION;
        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

        IF @FORCE_LOAD = 'FALSE'
        BEGIN

            EXEC @MODIFIED_ROWS_PERCENTAGE = [SISWEB_OWNER_STAGING].[_getModifiedRowsPercentage] @SISWEB_OWNER_TABLE='LNKFILEREFERENCE', @SISWEB_OWNER_STAGING_TABLE = 'LNKFILEREFERENCE'

        END;

        IF
           @FORCE_LOAD = 1
           OR @MODIFIED_ROWS_PERCENTAGE BETWEEN 0 AND 10
        BEGIN
            SET @LOGMESSAGE = 'Executing load: ' + IIF(@FORCE_LOAD = 1,'Force Load = TRUE','Force Load = FALSE');
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

            /* MERGE command */
            MERGE INTO SISWEB_OWNER.LNKFILEREFERENCE tgt
            USING SISWEB_OWNER_STAGING.LNKFILEREFERENCE src
            ON
               src.FILERID = tgt.FILERID
               AND src.LANGUAGEINDICATOR = tgt.LANGUAGEINDICATOR
               AND src.REFERENCEFILERID = tgt.REFERENCEFILERID
                WHEN NOT MATCHED BY TARGET
                  THEN
                  INSERT(FILERID
                        ,LANGUAGEINDICATOR
                        ,REFERENCEFILERID
                        ,LASTMODIFIEDDATE)
                  VALUES
                (src.FILERID
                ,src.LANGUAGEINDICATOR
                ,src.REFERENCEFILERID
                ,src.LASTMODIFIEDDATE)
                WHEN NOT MATCHED BY SOURCE
                  THEN DELETE
            OUTPUT $ACTION
                  ,COALESCE(inserted.FILERID,deleted.FILERID) FILERID
                  ,COALESCE(inserted.LANGUAGEINDICATOR,deleted.LANGUAGEINDICATOR) LANGUAGEINDICATOR
                  ,COALESCE(inserted.REFERENCEFILERID,deleted.REFERENCEFILERID) REFERENCEFILERID
                  ,COALESCE(inserted.LASTMODIFIEDDATE,deleted.LASTMODIFIEDDATE) LASTMODIFIEDDATE
                   INTO @MERGE_RESULTS;
            /* MERGE command */

            SELECT @MERGED_ROWS = @@ROWCOUNT;
            SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                                        ,(SELECT MR.ACTIONTYPE
                                                                ,MR.FILERID
                                                                ,MR.LANGUAGEINDICATOR
                                                                ,MR.REFERENCEFILERID
                                                                ,MR.LASTMODIFIEDDATE
                                                            FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER),'Modified Rows');
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
        END;
        ELSE
        BEGIN
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Skipping load: Row difference outside range (±10%)',@DATAVALUE = NULL;
        END;
        COMMIT;

        						UPDATE STATISTICS SISWEB_OWNER.LNKFILEREFERENCE WITH FULLSCAN;

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

