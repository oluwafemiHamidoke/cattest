﻿CREATE PROCEDURE EMP_STAGING.EMPSALESMODEL_Refresh_SHADOW_Table (@DEBUG BIT = 'FALSE')
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
	SET XACT_ABORT,NOCOUNT ON;
	BEGIN TRY

		DECLARE @MERGED_ROWS BIGINT           = 0
			   ,@PROCNAME    VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@PROCESSID   UNIQUEIDENTIFIER = NEWID()
			   ,@LOGMESSAGE  VARCHAR(MAX);

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

		BEGIN TRANSACTION;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

		/* MERGE command */
		MERGE INTO SISWEB_OWNER_SHADOW.EMPSALESMODEL tgt
		USING SISWEB_OWNER.EMPSALESMODEL src
        ON src.EMPSALESMODEL_ID = tgt.EMPSALESMODEL_ID
        WHEN MATCHED AND EXISTS
        (
            SELECT src.EMPPRODUCTFAMILY_ID,src.NUMBER,src.NAME,src.ALTERNATEMODEL,src.ISCATMODEL
                 ,src.SERVICEABLE,src.MODEL,src.SNP,src.VERSION,src.STATE,src.CURRENTSTATE,src.LASTMODIFIEDDATE
                EXCEPT
            SELECT tgt.EMPPRODUCTFAMILY_ID,tgt.NUMBER,tgt.NAME,tgt.ALTERNATEMODEL,tgt.ISCATMODEL,
                   tgt.SERVICEABLE,tgt.MODEL,tgt.SNP,tgt.VERSION,tgt.STATE,tgt.CURRENTSTATE,tgt.LASTMODIFIEDDATE
        )
        THEN UPDATE SET tgt.EMPPRODUCTFAMILY_ID = src.EMPPRODUCTFAMILY_ID,tgt.NUMBER = src.NUMBER,
            tgt.NAME=src.NAME,tgt.ALTERNATEMODEL = src.ALTERNATEMODEL,tgt.ISCATMODEL = src.ISCATMODEL,
            tgt.SERVICEABLE = src.SERVICEABLE,tgt.MODEL = src.MODEL,tgt.SNP = src.SNP,
            tgt.VERSION = src.VERSION,tgt.STATE = src.STATE,tgt.CURRENTSTATE = src.CURRENTSTATE,tgt.LASTMODIFIEDDATE = src.LASTMODIFIEDDATE
		WHEN NOT MATCHED BY TARGET
            THEN
            INSERT(EMPSALESMODEL_ID,EMPPRODUCTFAMILY_ID,NUMBER,NAME,ALTERNATEMODEL,
                    ISCATMODEL,SERVICEABLE,MODEL,SNP,VERSION,STATE,CURRENTSTATE,LASTMODIFIEDDATE)
            VALUES (src.EMPSALESMODEL_ID,src.EMPPRODUCTFAMILY_ID,src.NUMBER,src.NAME,src.ALTERNATEMODEL,
                    src.ISCATMODEL,src.SERVICEABLE,src.MODEL,src.SNP,src.VERSION,src.STATE,src.CURRENTSTATE,src.LASTMODIFIEDDATE)
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