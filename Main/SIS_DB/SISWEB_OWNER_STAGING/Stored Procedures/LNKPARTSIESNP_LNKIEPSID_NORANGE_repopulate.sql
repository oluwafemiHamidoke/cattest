-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20210115
-- Description: Truncates and reloads the table SISWEB_OWNER_SHADOW.LNKPARTSIESNP_LNKIEPSID_NORANGE
--				
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.LNKPARTSIESNP_LNKIEPSID_NORANGE_repopulate (@DEBUG BIT = 'FALSE') 
AS
BEGIN
	DECLARE @PROCNAME   VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
		   ,@PROCESSID  UNIQUEIDENTIFIER = NEWID()
		   ,@LOGMESSAGE VARCHAR(MAX)
		   ,@TABLENAME NVARCHAR (50)='LNKPARTSIESNP_LNKIEPSID_NORANGE'
		   ,@dynsql_truncatetable NVARCHAR(256)
		   ,@dynsql_dropconstraint NVARCHAR(256)
		   ,@dynsql_addconstraint NVARCHAR(256)
		   ,@CurrentShadowSchema NVARCHAR(256)
		   ,@CurrentShadowTable NVARCHAR(256);

	DECLARE @ERRORMESSAGE NVARCHAR(4000)
		   ,@ERRORLINE    INT
		   ,@ERRORNUM     INT;

	BEGIN TRY -- Reloads table
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Truncating and Reloading LNKPARTSIESNP_LNKIEPSID_NORANGE',
		@DATAVALUE = NULL;

		BEGIN TRANSACTION;

		SELECT @CurrentShadowSchema = ltrim(rtrim(substring(base_object_name,2,charindex('].',base_object_name)-2))),
		@CurrentShadowTable=ltrim(rtrim(substring(base_object_name,charindex('.',base_object_name)+2,len(base_object_name)-charindex('.',base_object_name)-2)))
		FROM sys.synonyms 
		WHERE Schema_id = schema_id('SISWEB_OWNER_SHADOW')
		And [Name] = @TABLENAME

		SET @dynsql_truncatetable='TRUNCATE TABLE '+QUOTENAME (@CurrentShadowSchema)+'.'+QUOTENAME(@CurrentShadowTable)
		EXEC sp_executesql @dynsql_truncatetable


		set @dynsql_dropconstraint='ALTER TABLE '+QUOTENAME (@CurrentShadowSchema)+'.'+QUOTENAME(@CurrentShadowTable)+' DROP CONSTRAINT PK_LNKPARTSIESNP_LNKIEPSID_NORANGE;'
		EXEC sp_executesql @dynsql_dropconstraint

		INSERT INTO SISWEB_OWNER_SHADOW.LNKPARTSIESNP_LNKIEPSID_NORANGE WITH(TABLOCK)
			   SELECT a.MEDIANUMBER,a.IESYSTEMCONTROLNUMBER,a.SNP,b.PSID,COUNT_BIG(*) AS N
			   FROM SISWEB_OWNER_SHADOW.LNKPARTSIESNP AS a
					INNER JOIN SISWEB_OWNER_SHADOW.LNKIEPSID AS b ON a.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER AND 
																	 a.MEDIANUMBER = b.MEDIANUMBER
			   GROUP BY a.MEDIANUMBER,a.IESYSTEMCONTROLNUMBER,a.SNP,b.PSID;

		set @dynsql_addconstraint='ALTER TABLE '+QUOTENAME (@CurrentShadowSchema)+'.'+QUOTENAME(@CurrentShadowTable)+' ADD CONSTRAINT PK_LNKPARTSIESNP_LNKIEPSID_NORANGE PRIMARY KEY(SNP,PSID,MEDIANUMBER,IESYSTEMCONTROLNUMBER);'
		EXEC sp_executesql @dynsql_addconstraint

		COMMIT;

		/* STATS command */
		SET @LOGMESSAGE = 'Updating Statistics';
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;
 
        -- If MS does fix the stats when the table swap then uncomment the below line 

		-- UPDATE STATISTICS SISWEB_OWNER_SHADOW.LNKPARTSIESNP_LNKIEPSID_NORANGE WITH FULLSCAN;

		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;
	END TRY
	BEGIN CATCH
		SET @ERRORMESSAGE = ERROR_MESSAGE();
		SET @ERRORLINE = ERROR_LINE();
		SET @ERRORNUM = ERROR_NUMBER();
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @ERRORNUM;
		THROW; --@ERRORNUM,@LOGMESSAGE,1;
	END CATCH;
END;