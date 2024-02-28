-- =============================================
-- Author:      Sachin Poolamannil (+Ramesh Ramalingam)
-- Create Date: 20201030
-- Description: Merge SISWEB_OWNER.LNKFILEREFERENCE to sis.ServiceFile_Reference
-- =============================================
CREATE PROCEDURE [sis].[ServiceFile_Reference_Merge] (@DEBUG BIT = 'FALSE')
AS
BEGIN
    SET XACT_ABORT,NOCOUNT ON;
    BEGIN TRY
        DECLARE @MERGED_ROWS                        INT              = 0
               ,@PROCNAME                           VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
               ,@PROCESSID                          UNIQUEIDENTIFIER = NEWID()
               ,@LOGMESSAGE                         VARCHAR(MAX)
               ,@MISSING_SERVICE_FILE_IDS           VARCHAR(MAX)
               ,@MISSING_SERVICE_FILE_REFERENCE_IDS VARCHAR(MAX);

        DECLARE @MERGE_RESULTS TABLE
            (ACTIONTYPE                 NVARCHAR(10),
             ServiceFile_ID             INT         NOT NULL,
             Referred_ServiceFile_ID    INT         NOT NULL,
             Language_ID                INT         NOT NULL);

        BEGIN TRANSACTION;

        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

        WITH SERVICEFILE_REFERENCE AS
        (
            SELECT DISTINCT FR.FILERID, FR.REFERENCEFILERID, L.Language_ID
            FROM SISWEB_OWNER.LNKFILEREFERENCE AS FR
            INNER JOIN sis.Language AS L on L.Legacy_Language_Indicator = FR.LANGUAGEINDICATOR AND L.Default_Language = 1
            INNER JOIN sis_stage.ServiceFile as SFF on FR.FILERID = SFF.ServiceFile_ID
            INNER JOIN sis_stage.ServiceFile as SFR on FR.REFERENCEFILERID = SFR.ServiceFile_ID
        )

        /* MERGE command */
        MERGE
        INTO    sis.ServiceFile_Reference tgt
        USING   SERVICEFILE_REFERENCE src
        ON      src.FILERID = tgt.ServiceFile_ID
        AND     src.REFERENCEFILERID = tgt.Referred_ServiceFile_ID
        AND     src.Language_ID = tgt.Language_ID

        WHEN NOT MATCHED BY TARGET
        THEN
        INSERT( ServiceFile_ID, Referred_ServiceFile_ID, Language_ID)
        VALUES( src.[FILERID], src.[REFERENCEFILERID], src.[Language_ID])

        WHEN NOT MATCHED BY SOURCE
        THEN
        DELETE
        OUTPUT  $ACTION,
                COALESCE(inserted.ServiceFile_ID,deleted.ServiceFile_ID) ServiceFile_ID,
                COALESCE(inserted.Referred_ServiceFile_ID,deleted.Referred_ServiceFile_ID) Referred_ServiceFile_ID,
                COALESCE(inserted.Language_ID,deleted.Language_ID) Language_ID
        INTO    @MERGE_RESULTS;

        /* MERGE command */
        SELECT @MERGED_ROWS = @@ROWCOUNT;
        SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
        (
            SELECT
                (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,
                (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
                (SELECT MR.ACTIONTYPE, MR.ServiceFile_ID, MR.Referred_ServiceFile_ID, MR.Language_ID FROM @MERGE_RESULTS AS MR FOR JSON AUTO)
                 AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
        ),'Modified Rows');

        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

        SELECT  @MISSING_SERVICE_FILE_IDS = STRING_AGG(CAST(FILERID AS VARCHAR(MAX)), ',')
        FROM    (
                    SELECT DISTINCT FR.FILERID
                    FROM SISWEB_OWNER.LNKFILEREFERENCE AS FR
                    LEFT JOIN sis_stage.ServiceFile AS SFF ON FR.FILERID = SFF.ServiceFile_ID
                    WHERE SFF.ServiceFile_ID IS NULL
                 ) AS MISSING_FILES;

        SELECT  @MISSING_SERVICE_FILE_REFERENCE_IDS = STRING_AGG(CAST(FILERID AS VARCHAR(MAX)), ',')
        FROM    (
                    SELECT DISTINCT FR.FILERID
                    FROM SISWEB_OWNER.LNKFILEREFERENCE AS FR
                    LEFT JOIN sis_stage.ServiceFile AS SFR ON FR.REFERENCEFILERID = SFR.ServiceFile_ID
                    WHERE SFR.ServiceFile_ID IS NULL
                 ) AS MISSING_FILE_REFERENCES;

        IF @MISSING_SERVICE_FILE_IDS IS NOT NULL
        BEGIN
            SET @LOGMESSAGE = FORMATMESSAGE('Missing Service File IDs are %s', @MISSING_SERVICE_FILE_IDS);
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID, @LOGTYPE = 'Information', @NAMEOFSPROC = @PROCNAME, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = NULL;
        END;

        IF @MISSING_SERVICE_FILE_REFERENCE_IDS IS NOT NULL
        BEGIN
            SET @LOGMESSAGE = FORMATMESSAGE('Missing Service File Reference IDs are %s', @MISSING_SERVICE_FILE_REFERENCE_IDS);
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;
        END;

        COMMIT;

        Update STATISTICS sis.ServiceFile_Reference with fullscan

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

