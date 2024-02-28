﻿CREATE PROCEDURE EMP_STAGING.EMPPRODUCTINSTANCE_Refresh_SHADOW_Table (@DEBUG BIT = 'FALSE')
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
									 ,[EMPPRODUCTINSTANCE_ID] INT                NOT NULL
                                     ,[EMPSALESMODEL_ID]      INT                NOT NULL
                                     ,[NUMBER]                VARCHAR (60)       NOT NULL
                                     ,[NAME]                  VARCHAR (60)       NOT NULL
                                     ,[ALIAS1]                VARCHAR (60)           NULL
                                     ,[ALIAS2]                VARCHAR (60)           NULL
                                     ,[ALIAS3]                VARCHAR (60)           NULL
                                     ,[ALTERNATESERIALNUMBER] VARCHAR (60)           NULL
                                     ,[NUMERICVALUE]          VARCHAR (10)           NULL
                                     ,[NUMERICVALUE2]         INT                    NULL
                                     ,[SALESORDERNUMBER]      VARCHAR (60)           NULL
                                     ,[SERVICEABLE]           BIT                    NULL
                                     ,[VERSION]               VARCHAR (13)            NULL
                                     ,[MODEL]                 VARCHAR (60)           NULL
                                     ,[SNP]                   VARCHAR (60)           NULL
                                     ,[STATE]                 VARCHAR (15)           NULL
                                     ,[CURRENTSTATE]          VARCHAR (15)           NULL
                                     ,[LASTMODIFIEDDATE]      DATETIME2 (6)          NULL);

		BEGIN TRANSACTION;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

		/* MERGE command */
		MERGE INTO SISWEB_OWNER_SHADOW.EMPPRODUCTINSTANCE tgt
		USING SISWEB_OWNER.EMPPRODUCTINSTANCE src
        ON src.EMPPRODUCTINSTANCE_ID = tgt.EMPPRODUCTINSTANCE_ID
        WHEN MATCHED AND EXISTS
        (
            SELECT src.EMPSALESMODEL_ID,src.NUMBER,src.NAME,src.ALIAS1,src.ALIAS2,
                   src.ALIAS3,src.ALTERNATESERIALNUMBER,src.NUMERICVALUE,src.NUMERICVALUE2,
                    src.SALESORDERNUMBER,src.SERVICEABLE,src.VERSION,src.MODEL,src.SNP,src.STATE,src.CURRENTSTATE,src.LASTMODIFIEDDATE
                EXCEPT
            SELECT tgt.EMPSALESMODEL_ID,tgt.NUMBER,tgt.NAME,tgt.ALIAS1,tgt.ALIAS2,
                   tgt.ALIAS3,tgt.ALTERNATESERIALNUMBER,tgt.NUMERICVALUE,tgt.NUMERICVALUE2,
                   tgt.SALESORDERNUMBER,tgt.SERVICEABLE,tgt.VERSION,tgt.MODEL,tgt.SNP,tgt.STATE,tgt.CURRENTSTATE,tgt.LASTMODIFIEDDATE
        )
        THEN UPDATE SET tgt.EMPSALESMODEL_ID = src.EMPSALESMODEL_ID,tgt.NUMBER = src.NUMBER,tgt.NAME=src.NAME,
            tgt.ALIAS1 = src.ALIAS1,tgt.ALIAS2 = src.ALIAS2,tgt.ALIAS3 = src.ALIAS3,
            tgt.ALTERNATESERIALNUMBER = src.ALTERNATESERIALNUMBER,tgt.NUMERICVALUE = src.NUMERICVALUE,
            tgt.NUMERICVALUE2 = src.NUMERICVALUE2,tgt.SALESORDERNUMBER = src.SALESORDERNUMBER,
            tgt.SERVICEABLE = src.SERVICEABLE,tgt.VERSION = src.VERSION,tgt.MODEL = src.MODEL,
            tgt.SNP = src.SNP,tgt.STATE = src.STATE,tgt.CURRENTSTATE = src.CURRENTSTATE,tgt.LASTMODIFIEDDATE = src.LASTMODIFIEDDATE
		WHEN NOT MATCHED BY TARGET
            THEN
            INSERT(EMPPRODUCTINSTANCE_ID,EMPSALESMODEL_ID,NUMBER,NAME,ALIAS1,ALIAS2,ALIAS3,ALTERNATESERIALNUMBER,NUMERICVALUE,
                NUMERICVALUE2,SALESORDERNUMBER,SERVICEABLE,VERSION,MODEL,SNP,STATE,CURRENTSTATE,LASTMODIFIEDDATE)
            VALUES (src.EMPPRODUCTINSTANCE_ID,src.EMPSALESMODEL_ID,src.NUMBER,src.NAME,src.ALIAS1,src.ALIAS2,
                src.ALIAS3,src.ALTERNATESERIALNUMBER,src.NUMERICVALUE,src.NUMERICVALUE2,
                src.SALESORDERNUMBER,src.SERVICEABLE,src.VERSION,src.MODEL,src.SNP,src.STATE,src.CURRENTSTATE,src.LASTMODIFIEDDATE)
		WHEN NOT MATCHED BY SOURCE
        THEN DELETE
        OUTPUT $ACTION,COALESCE(inserted.EMPPRODUCTINSTANCE_ID,deleted.EMPPRODUCTINSTANCE_ID) EMPPRODUCTINSTANCE_ID,COALESCE(inserted.EMPSALESMODEL_ID,deleted.EMPSALESMODEL_ID) EMPSALESMODEL_ID,
			COALESCE(inserted.NUMBER,deleted.NUMBER) NUMBER,COALESCE(inserted.NAME,deleted.NAME) NAME,
            COALESCE(inserted.ALIAS1,deleted.ALIAS1) ALIAS1,COALESCE(inserted.ALIAS2,deleted.ALIAS2) ALIAS2,
            COALESCE(inserted.ALIAS3,deleted.ALIAS3) ALIAS3,COALESCE(inserted.ALTERNATESERIALNUMBER,deleted.ALTERNATESERIALNUMBER) ALTERNATESERIALNUMBER,
            COALESCE(inserted.NUMERICVALUE,deleted.NUMERICVALUE) NUMERICVALUE,COALESCE(inserted.NUMERICVALUE2,deleted.NUMERICVALUE2) NUMERICVALUE2,
			COALESCE(inserted.SALESORDERNUMBER,deleted.SALESORDERNUMBER) SALESORDERNUMBER,COALESCE(inserted.SERVICEABLE,deleted.SERVICEABLE) SERVICEABLE,
            COALESCE(inserted.VERSION,deleted.VERSION) VERSION,COALESCE(inserted.MODEL,deleted.MODEL) MODEL,
            COALESCE(inserted.SNP,deleted.SNP) SNP,COALESCE(inserted.STATE,deleted.STATE) STATE,COALESCE(inserted.CURRENTSTATE,deleted.CURRENTSTATE) CURRENTSTATE,
            COALESCE(inserted.LASTMODIFIEDDATE,deleted.LASTMODIFIEDDATE) LASTMODIFIEDDATE
		INTO @MERGE_RESULTS;

		/* MERGE command */
		SELECT @MERGED_ROWS = @@ROWCOUNT;

        SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
			(
				SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE =
				'UPDATE'
				) AS Updated,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
				(
					SELECT MR.ACTIONTYPE,MR.EMPPRODUCTINSTANCE_ID,MR.EMPSALESMODEL_ID,MR.NUMBER,MR.NAME,MR.ALIAS1,MR.ALIAS2,
                           MR.ALIAS3,MR.ALTERNATESERIALNUMBER,MR.NUMERICVALUE,MR.NUMERICVALUE2,
                           MR.SALESORDERNUMBER,MR.SERVICEABLE,MR.VERSION,MR.MODEL,MR.SNP,MR.STATE,MR.CURRENTSTATE,MR.LASTMODIFIEDDATE
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