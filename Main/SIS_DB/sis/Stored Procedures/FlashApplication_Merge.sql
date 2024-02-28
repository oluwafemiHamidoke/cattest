-- =============================================
-- Author:      Sachin Poolamannil (+Ramesh Ramalingam)
-- Create Date: 20201030
-- Description: Merge SISWEB_OWNER.LNKFLASHAPPLICATIONCODE to sis.FlashApplication and sis.FlashApplication_Translation
-- =============================================
CREATE PROCEDURE [sis].[FlashApplication_Merge]
    (@DEBUG      BIT = 'FALSE')
AS
BEGIN
    SET XACT_ABORT,NOCOUNT ON;
    BEGIN TRY
        DECLARE @MERGED_ROWS                   INT              = 0
               ,@PROCNAME                      VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
               ,@PROCESSID                     UNIQUEIDENTIFIER = NEWID()
               ,@LOGMESSAGE                    VARCHAR(MAX);
        DECLARE @MERGE_RESULTS TABLE
            (ACTIONTYPE                      NVARCHAR(10),
             FlashApplication_ID             INT         NOT NULL,
             IsEngineRelated                 BIT         NOT NULL);
        DECLARE @TRANSLATION_MERGE_RESULTS TABLE
            (ACTIONTYPE                      NVARCHAR(10),
             FlashApplication_ID             INT                NOT NULL,
             Language_ID                     INT                NOT NULL,
             [Description]                   NVARCHAR (720)     NULL
             );

        DECLARE @FLASHAPPLICATIONCODES TABLE
            (
                FlashApplication_ID             INT         NOT NULL,
                IsEngineRelated                 BIT         NOT NULL
            );

        BEGIN TRANSACTION;
        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

        INSERT INTO @FLASHAPPLICATIONCODES (FlashApplication_ID, IsEngineRelated)
        SELECT APPLICATIONCODE, convert(bit, MAX(convert(int, ISENGINERELATED)))
        FROM SISWEB_OWNER.LNKFLASHAPPLICATIONCODE
        GROUP BY APPLICATIONCODE;

        -- Delete the translations
        DELETE t
        FROM sis.FlashApplication_Translation t
        INNER JOIN sis.Language l on l.Language_ID = t.Language_ID 
        LEFT OUTER JOIN SISWEB_OWNER.LNKFLASHAPPLICATIONCODE s on s.APPLICATIONCODE = t.FlashApplication_ID AND s.LANGUAGEINDICATOR = l.Legacy_Language_Indicator
        WHERE s.APPLICATIONCODE is NULL;

        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'FlashApplication_Translation Delete',@DATAVALUE = @@ROWCOUNT;

        /* MERGE command */
        MERGE INTO sis.FlashApplication tgt
        USING @FLASHAPPLICATIONCODES src
        ON
            src.FlashApplication_ID = tgt.FlashApplication_ID
            WHEN MATCHED AND EXISTS (SELECT src.IsEngineRelated EXCEPT SELECT tgt.Is_Engine_Related)
                 THEN UPDATE SET 
                    tgt.Is_Engine_Related = src.IsEngineRelated
            WHEN NOT MATCHED BY TARGET
                THEN
                INSERT (FlashApplication_ID, Is_Engine_Related)
                VALUES (src.FlashApplication_ID, src.IsEngineRelated)
            WHEN NOT MATCHED BY SOURCE
                THEN DELETE
        OUTPUT $ACTION
                ,COALESCE(inserted.FlashApplication_ID,deleted.FlashApplication_ID) FlashApplication_ID
                ,COALESCE(inserted.Is_Engine_Related,deleted.Is_Engine_Related) IsEngineRelated
                INTO @MERGE_RESULTS;
        /* MERGE command */

        SELECT @MERGED_ROWS = @@ROWCOUNT;
        SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                                    ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                                                    ,(SELECT MR.ACTIONTYPE
                                                            ,MR.FlashApplication_ID
                                                            ,MR.IsEngineRelated
                                                        FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER),'FlashApplication Modified Rows');
        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
        
        -- Translation Table Merge
        WITH FlashApplicationDetails
        AS (SELECT A.FlashApplication_ID, F.APPLICATIONDESC, L.Language_ID
        FROM SISWEB_OWNER.LNKFLASHAPPLICATIONCODE F
        INNER JOIN @FLASHAPPLICATIONCODES A on F.APPLICATIONCODE = A.FlashApplication_ID
        INNER JOIN sis.Language L on L.Legacy_Language_Indicator = F.LANGUAGEINDICATOR AND L.Default_Language = 1)
            MERGE INTO sis.FlashApplication_Translation tgt
            USING FlashApplicationDetails src
            ON
                src.FlashApplication_ID = tgt.FlashApplication_ID AND
                src.Language_ID = tgt.Language_ID
                WHEN MATCHED AND EXISTS(SELECT src.APPLICATIONDESC
                                        EXCEPT
                                        SELECT  tgt.Description)
                  THEN UPDATE SET tgt.Description = src.APPLICATIONDESC
                WHEN NOT MATCHED BY TARGET
                    THEN
                    INSERT (FlashApplication_ID, Language_ID, [Description])
                    VALUES (src.[FlashApplication_ID], src.Language_ID, src.APPLICATIONDESC)
            OUTPUT $ACTION
                    ,COALESCE(inserted.FlashApplication_ID,deleted.FlashApplication_ID) FlashApplication_ID
                    ,COALESCE(inserted.Language_ID,deleted.Language_ID) Language_ID
                    ,COALESCE(inserted.Description,deleted.Description) Description
                    INTO @TRANSLATION_MERGE_RESULTS;

        SELECT @MERGED_ROWS = @@ROWCOUNT;
        SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @TRANSLATION_MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                                    ,(SELECT COUNT(*) FROM @TRANSLATION_MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                                                    ,(SELECT MR.ACTIONTYPE
                                                            ,MR.FlashApplication_ID
                                                            ,MR.Language_ID
                                                            ,MR.Description
                                                        FROM @TRANSLATION_MERGE_RESULTS AS MR FOR JSON AUTO) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER),'FlashApplication_Translation Modified Rows');
        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
        
        COMMIT;
        		Update STATISTICS sis.FlashApplication with fullscan 

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
