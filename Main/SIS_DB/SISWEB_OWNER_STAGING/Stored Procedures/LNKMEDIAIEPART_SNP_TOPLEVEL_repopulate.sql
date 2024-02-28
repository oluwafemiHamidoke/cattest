-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20200417
-- Modify Date: 20201120 - Davide: added UPDATE STATS see: https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/86007
-- Modify Date: 20201120 - Davide: added UPDATE STATS see: https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/86007
-- Description: Truncates and reloads the table SISWEB_OWNER_SHADOW.LNKMEDIAIEPART_TOPLEVEL
--				
-- =============================================
CREATE PROCEDURE SISWEB_OWNER_STAGING.LNKMEDIAIEPART_SNP_TOPLEVEL_repopulate (@DEBUG BIT = 'FALSE') 
AS
BEGIN
    DECLARE @PROCNAME   VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
           ,@PROCESSID  UNIQUEIDENTIFIER = NEWID()
           ,@LOGMESSAGE VARCHAR(MAX)
		   ,@TABLENAME NVARCHAR (50)='LNKMEDIAIEPART_SNP_TOPLEVEL'	
		   ,@dynsql_truncatetable NVARCHAR(256)	
		   ,@dynsql_dropindex NVARCHAR(256)	
		   ,@dynsql_addindex NVARCHAR(256)	
		   ,@CurrentShadowSchema NVARCHAR(256)	
		   ,@CurrentShadowTable NVARCHAR(256);

    DECLARE @ERRORMESSAGE NVARCHAR(4000)
           ,@ERRORLINE    INT
           ,@ERRORNUM     INT;

	BEGIN TRY -- Reloads table
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Truncating and Reloading LNKMEDIAIEPART_SNP_TOPLEVEL',
		@DATAVALUE = NULL;

		BEGIN TRANSACTION;
		
		SELECT @CurrentShadowSchema = ltrim(rtrim(substring(base_object_name,2,charindex('].',base_object_name)-2))),	
		@CurrentShadowTable=ltrim(rtrim(substring(base_object_name,charindex('.',base_object_name)+2,len(base_object_name)-charindex('.',base_object_name)-2)))	
		FROM sys.synonyms 	
		WHERE Schema_id = schema_id('SISWEB_OWNER_SHADOW')	
		And [Name] = @TABLENAME	

		SET @dynsql_truncatetable='TRUNCATE TABLE '+QUOTENAME (@CurrentShadowSchema)+'.'+QUOTENAME(@CurrentShadowTable)	
		EXEC sp_executesql @dynsql_truncatetable	
		
		set @dynsql_dropindex='DROP INDEX IF EXISTS IX02_LNKMEDIAIEPART_SNP_TOPLEVEL ON '+QUOTENAME (@CurrentShadowSchema)+'.'+QUOTENAME(@CurrentShadowTable)+';'	
		EXEC sp_executesql @dynsql_dropindex
		
		
		INSERT INTO SISWEB_OWNER_SHADOW.LNKMEDIAIEPART_SNP_TOPLEVEL WITH(TABLOCK)
			   SELECT  distinct 
					  PSID,isTopLevel,MEDIANUMBER,IESYSTEMCONTROLNUMBER,IEPARTNUMBER,ORGCODE,IEPARTNAME,IESEQUENCENUMBER,IEPARTMODIFIER,IECAPTION, SNP
			   FROM
			   (
				   SELECT TL2.PSID,CAST(CASE
						WHEN TL1.ConcistPartNumber IS NULL THEN 1
						ELSE 0
						END AS BIT) AS isTopLevel,TL2.MEDIANUMBER,TL2.IESYSTEMCONTROLNUMBER,TL2.IEPARTNUMBER,TL2.ORGCODE,TL2.IEPARTNAME,TL2.IESEQUENCENUMBER,TL2.IEPARTMODIFIER,
						TL2.IECAPTION,TL2.SNP
				FROM
				(
					SELECT psid.PSID,part.MEDIANUMBER,part.IESYSTEMCONTROLNUMBER,part.IEPARTNUMBER,part.ORGCODE,part.IEPARTNAME,part.IESEQUENCENUMBER,part.IEPARTMODIFIER,part.IECAPTION,lnksnp.SNP
					FROM SISWEB_OWNER_SHADOW.LNKMEDIAIEPART AS part
						INNER JOIN SISWEB_OWNER_SHADOW.LNKIEPSID AS psid ON part.MEDIANUMBER = psid.MEDIANUMBER AND 
																			part.IESYSTEMCONTROLNUMBER = psid.IESYSTEMCONTROLNUMBER
						inner JOIN  SISWEB_OWNER_STAGING.LNKPARTSIESNP lnksnp 
							on part.IESYSTEMCONTROLNUMBER = lnksnp.IESYSTEMCONTROLNUMBER and part.MEDIANUMBER = lnksnp.MEDIANUMBER
							
					UNION

                    SELECT distinct psid.PSID,part.MEDIANUMBER,part.IESYSTEMCONTROLNUMBER,part.IEPARTNUMBER,part.ORGCODE,part.IEPARTNAME,part.IESEQUENCENUMBER,part.IEPARTMODIFIER,part.IECAPTION, inst.SNP
                       FROM SISWEB_OWNER_SHADOW.LNKMEDIAIEPART AS part
                            INNER JOIN SISWEB_OWNER_SHADOW.LNKIEPSID AS psid ON part.MEDIANUMBER = psid.MEDIANUMBER AND 
                                                                                part.IESYSTEMCONTROLNUMBER = psid.IESYSTEMCONTROLNUMBER 

                            inner JOIN  SISWEB_OWNER_SHADOW.LNKIEPRODUCTINSTANCE ieprodinst 
                            on part.IESYSTEMCONTROLNUMBER = ieprodinst.IESYSTEMCONTROLNUMBER and part.MEDIANUMBER = ieprodinst.MEDIANUMBER
                            inner join SISWEB_OWNER_SHADOW.EMPPRODUCTINSTANCE inst on
                            ieprodinst.EMPPRODUCTINSTANCE_ID = inst.EMPPRODUCTINSTANCE_ID
				) AS TL2
				LEFT JOIN
				(
					SELECT IEPSID.PSID
					,IEPSID.MEDIANUMBER
					,CONSIST.PARTNUMBER AS ConcistPartNumber
					,lnksnp.SNP
					FROM SISWEB_OWNER_SHADOW.LNKIEPSID AS IEPSID
						INNER JOIN SISWEB_OWNER_SHADOW.LNKMEDIAIEPART AS IEPART ON IEPART.MEDIANUMBER = IEPSID.MEDIANUMBER AND 
																					IEPART.IESYSTEMCONTROLNUMBER = IEPSID.IESYSTEMCONTROLNUMBER
						INNER JOIN SISWEB_OWNER_SHADOW.LNKCONSISTLIST AS CONSIST ON CONSIST.IESYSTEMCONTROLNUMBER = IEPART.IESYSTEMCONTROLNUMBER
						inner JOIN  SISWEB_OWNER_STAGING.LNKPARTSIESNP lnksnp 
							on IEPSID.IESYSTEMCONTROLNUMBER = lnksnp.IESYSTEMCONTROLNUMBER and IEPSID.MEDIANUMBER = lnksnp.MEDIANUMBER
							
					UNION

                    SELECT distinct IEPSID.PSID
                    ,IEPSID.MEDIANUMBER
                    ,CONSIST.PARTNUMBER AS ConcistPartNumber
                    ,inst.SNP
                    FROM SISWEB_OWNER_SHADOW.LNKIEPSID AS IEPSID
                        INNER JOIN SISWEB_OWNER_SHADOW.LNKMEDIAIEPART AS IEPART ON IEPART.MEDIANUMBER = IEPSID.MEDIANUMBER AND 
                                                                                    IEPART.IESYSTEMCONTROLNUMBER = IEPSID.IESYSTEMCONTROLNUMBER
                        INNER JOIN SISWEB_OWNER_SHADOW.LNKCONSISTLIST AS CONSIST ON CONSIST.IESYSTEMCONTROLNUMBER = IEPART.IESYSTEMCONTROLNUMBER

                            inner JOIN  SISWEB_OWNER_SHADOW.LNKIEPRODUCTINSTANCE ieprodinst
                            on IEPSID.IESYSTEMCONTROLNUMBER = ieprodinst.IESYSTEMCONTROLNUMBER and IEPSID.MEDIANUMBER = ieprodinst.MEDIANUMBER
                            inner join SISWEB_OWNER_SHADOW.EMPPRODUCTINSTANCE inst on
                            ieprodinst.EMPPRODUCTINSTANCE_ID = inst.EMPPRODUCTINSTANCE_ID
							
				) AS TL1 ON TL1.PSID = TL2.PSID AND 
				TL1.MEDIANUMBER = TL2.MEDIANUMBER AND 
				TL1.ConcistPartNumber = TL2.IEPARTNUMBER AND
				TL1.SNP = TL2.SNP
			   ) AS Q;

		SET @dynsql_addindex='CREATE CLUSTERED INDEX IX02_LNKMEDIAIEPART_SNP_TOPLEVEL ON '+QUOTENAME (@CurrentShadowSchema)+'.'+QUOTENAME(@CurrentShadowTable)+' (MEDIANUMBER ASC,IESYSTEMCONTROLNUMBER ASC,PSID ASC, SNP ASC)WITH (STATISTICS_NORECOMPUTE = ON);'	
		EXEC sp_executesql @dynsql_addindex			
		
		
		COMMIT;

		/* STATS command */
		SET @LOGMESSAGE = 'Updating Statistics';
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

      -- If MS does fix the stats when the table swap then uncomment the below line 

		-- UPDATE STATISTICS SISWEB_OWNER_SHADOW.LNKMEDIAIEPART_SNP_TOPLEVEL WITH FULLSCAN;

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
		THROW @ERRORNUM,@LOGMESSAGE,1;
	END CATCH;
END;
