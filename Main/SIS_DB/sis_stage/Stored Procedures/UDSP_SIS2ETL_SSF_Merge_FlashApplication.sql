-- =============================================
-- Author:      Madhukar Bhandari
-- Create Date: 20220714
-- Description: Merge sis_stage.ssf_sisecm,sis_stage.ssf_sisecm_foreignlang to sis.FlashApplication_Syn and sis.FlashApplication_Translation_Syn
-- =============================================
-- Exec [sis_stage].[UDSP_SIS2ETL_SSF_Merge_FlashApplication] @DEBUG = 'TRUE'
CREATE PROCEDURE [sis_stage].[UDSP_SIS2ETL_SSF_Merge_FlashApplication]
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
            (	ACTIONTYPE                      NVARCHAR(10),
             	FlashApplication_ID             INT         NOT NULL,
             	Is_Engine_Related                 BIT         NOT NULL
			);
        DECLARE @TRANSLATION_MERGE_RESULTS TABLE
			(	ACTIONTYPE                      NVARCHAR(10),
				FlashApplication_ID             INT                NOT NULL,
				Language_ID                     INT                NOT NULL,
				[Application_Description]                   NVARCHAR (720)     NULL
             );

        BEGIN TRANSACTION;
        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;


		DROP TABLE IF EXISTS  #FLASHAPPLICATIONCODES

        SELECT * INTO #FLASHAPPLICATIONCODES FROM
		(
			select distinct s.FlashApplication_ID,s.Application_Description,'E' Language_Indicator, (CASE WHEN erl.Application_Description is NULL THEN 0 ELSE 1 END) Is_Engine_Related 
			from sis_stage.ssf_sisecm s
			LEFT JOIN sis_stage.ssf_flash_application_engine_related_lookup erl -- Maintaing the list of Engile related 
			ON erl.FlashApplication_ID = s.FlashApplication_ID and erl.Is_Engine_Related = '1'

			Union 

			select distinct s.FlashApplication_ID,s.Application_Description,Language_Indicator, (CASE WHEN erl.Application_Description is NULL THEN 0 ELSE 1 END) Is_Engine_Related
			from sis_stage.ssf_sisecm_foreignlang s
			LEFT JOIN sis_stage.ssf_flash_application_engine_related_lookup erl
			ON erl.FlashApplication_ID = s.FlashApplication_ID and erl.Is_Engine_Related = '1'
		) a

		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Loading FlashApplication_Syn',@DATAVALUE = NULL;

        /* MERGE command */
        MERGE INTO sis_stage.FlashApplication_Syn tgt
		USING #FLASHAPPLICATIONCODES src
		ON src.FlashApplication_ID = tgt.FlashApplication_ID
			WHEN MATCHED AND EXISTS
				(
					SELECT src.Is_Engine_Related
					EXCEPT
					SELECT tgt.[Is_Engine_Related]
				)
				THEN 
					UPDATE SET [Is_Engine_Related] = src.Is_Engine_Related
			
			WHEN NOT MATCHED BY TARGET
				THEN INSERT([FlashApplication_ID],[Is_Engine_Related])
				VALUES (src.FlashApplication_ID,src.Is_Engine_Related)
			OUTPUT $ACTION,
				inserted.FlashApplication_ID,inserted.[Is_Engine_Related]
				INTO @MERGE_RESULTS;
        /* MERGE command */

		        SELECT @MERGED_ROWS = @@ROWCOUNT;
        SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                                    ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                                                    ,(SELECT MR.ACTIONTYPE
                                                            ,MR.FlashApplication_ID
                                                            ,MR.Is_Engine_Related
                                                        FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER),'FlashApplication_Syn Modified Rows');
        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
        
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Loading FlashApplication_Translation_Syn',@DATAVALUE = NULL;


        -- Translation Table Merge
        MERGE INTO [sis_stage].[FlashApplication_Translation_Syn] tgt
		USING 
			(	select FlashApplication_ID,[Application_Description], [Language_ID]
				From #FLASHAPPLICATIONCODES s
				inner join [sis].[Language] l 
				on l.[Legacy_Language_Indicator]  = s .Language_Indicator
				and l.Default_Language = 1
			) src
		ON src.FlashApplication_ID = tgt.FlashApplication_ID
		and src.Language_ID = tgt.Language_ID
			WHEN MATCHED AND EXISTS
				(
					SELECT src.[Application_Description]
					EXCEPT
					SELECT tgt.[Description]
				)
				THEN 
				UPDATE SET [Description] = src.[Application_Description]
			WHEN NOT MATCHED BY TARGET
				THEN
					INSERT([FlashApplication_ID],[Language_ID],[Description])
					VALUES(src.FlashApplication_ID,src.Language_ID,src.[Application_Description])
			OUTPUT $ACTION,
					inserted.FlashApplication_ID,inserted.Language_ID,inserted.[Description]
					INTO @TRANSLATION_MERGE_RESULTS;


        SELECT @MERGED_ROWS = @@ROWCOUNT;
        SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @TRANSLATION_MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                                                    ,(SELECT COUNT(*) FROM @TRANSLATION_MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                                                    ,(SELECT MR.ACTIONTYPE
                                                            ,MR.FlashApplication_ID
                                                            ,MR.Language_ID
                                                            ,MR.[Application_Description]
                                                        FROM @TRANSLATION_MERGE_RESULTS AS MR FOR JSON AUTO) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER),'FlashApplication_Translation_Syn Modified Rows');
        EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
        
		DROP TABLE IF EXISTS  #FLASHAPPLICATIONCODES

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
    END CATCH;
END;



