-- =============================================
-- Author:      Sachin Poolamannil
-- Create Date: 20201022
-- Modify Date: 20201027 Add LASTMODIFIEDDATE column to merge
-- Description: Merge SISWEB_OWNER_STAGING.LNKFILEREPLACEMENTHIERARCHY to SISWEB_OWNER.LNKFILEREPLACEMENTHIERARCHY
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.LNKFILEREPLACEMENTHIERARCHY_Merge
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
            ,FILERID           INT           NOT NULL
            ,REPLACEDBYFILERID INT           NOT NULL
            ,SEQNO             NUMERIC(16,0) NOT NULL
            ,LASTMODIFIEDDATE  DATETIME2(6)  NULL);

        BEGIN TRANSACTION;
        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

        IF @FORCE_LOAD = 'FALSE'
        BEGIN
            EXEC @MODIFIED_ROWS_PERCENTAGE = [SISWEB_OWNER_STAGING].[_getModifiedRowsPercentage] @SISWEB_OWNER_TABLE='LNKFILEREPLACEMENTHIERARCHY', @SISWEB_OWNER_STAGING_TABLE = 'LNKFILEREPLACEMENTHIERARCHY'
        END;

        IF
           @FORCE_LOAD = 1
           OR @MODIFIED_ROWS_PERCENTAGE BETWEEN 0 AND 10
        BEGIN
            SET @LOGMESSAGE = 'Executing load: ' + IIF(@FORCE_LOAD = 1,'Force Load = TRUE','Force Load = FALSE');
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

            /* MERGE command */
            MERGE INTO SISWEB_OWNER.LNKFILEREPLACEMENTHIERARCHY tgt
            USING SISWEB_OWNER_STAGING.LNKFILEREPLACEMENTHIERARCHY src
            ON
               src.FILERID = tgt.FILERID
               AND src.REPLACEDBYFILERID = tgt.REPLACEDBYFILERID
                WHEN MATCHED AND EXISTS(SELECT src.SEQNO, src.LASTMODIFIEDDATE
                                        EXCEPT
                                        SELECT tgt.SEQNO, src.LASTMODIFIEDDATE)
                  THEN UPDATE SET tgt.SEQNO = src.SEQNO,tgt.LASTMODIFIEDDATE = src.LASTMODIFIEDDATE
                WHEN NOT MATCHED BY TARGET
                  THEN
                  INSERT(FILERID
                        ,REPLACEDBYFILERID
                        ,SEQNO
                        ,LASTMODIFIEDDATE)
                  VALUES
                (src.FILERID
                ,src.REPLACEDBYFILERID
                ,src.SEQNO
                ,src.LASTMODIFIEDDATE)
                WHEN NOT MATCHED BY SOURCE
                  THEN DELETE
            OUTPUT $ACTION
                  ,COALESCE(inserted.FILERID,deleted.FILERID) FILERID
                  ,COALESCE(inserted.REPLACEDBYFILERID,deleted.REPLACEDBYFILERID) REPLACEDBYFILERID
                  ,COALESCE(inserted.SEQNO,deleted.SEQNO) SEQNO
                  ,COALESCE(inserted.LASTMODIFIEDDATE,deleted.LASTMODIFIEDDATE) LASTMODIFIEDDATE
                  INTO @MERGE_RESULTS;
            /* MERGE command */

            SELECT @MERGED_ROWS = @@ROWCOUNT;
            SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                                                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                                        ,(SELECT MR.ACTIONTYPE
                                                                ,MR.FILERID
                                                                ,MR.REPLACEDBYFILERID
                                                                ,MR.SEQNO
                                                                ,MR.LASTMODIFIEDDATE
                                                            FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER),'Modified Rows');
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
        END;
        ELSE
        BEGIN
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Skipping load: Row difference outside range (±10%)',@DATAVALUE = NULL;
        END;
        COMMIT;
        						UPDATE STATISTICS SISWEB_OWNER.LNKFILEREPLACEMENTHIERARCHY WITH FULLSCAN;

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

