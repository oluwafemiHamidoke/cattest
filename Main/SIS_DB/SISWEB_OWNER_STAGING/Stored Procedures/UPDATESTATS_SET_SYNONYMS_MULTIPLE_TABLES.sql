CREATE PROCEDURE [SISWEB_OWNER_STAGING].[UPDATESTATS_SET_SYNONYMS_MULTIPLE_TABLES] @TABLENAMES VARCHAR (1024)
AS
   BEGIN

   
   DECLARE @PROCNAME        VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			,@PROCESSID     UNIQUEIDENTIFIER = NEWID()
			,@TABLENAME	    VARCHAR(50)
			,@TABLENAMES2	VARCHAR(1024)
			,@LOGMESSAGE    VARCHAR(MAX)
   SET @TABLENAMES2=@TABLENAMES
   DECLARE	@ERRORMESSAGE NVARCHAR(4000)
		    ,@ERRORLINE    INT
		    ,@ERRORNUM     INT;
   DECLARE @Base_Table  VARCHAR(50);
   DECLARE @owner_schema VARCHAR(50);
   DECLARE @shadow_schema VARCHAR(50);
   DECLARE @dynsql_updstats NVARCHAR(256);
   Declare @CurrentOwnerSchema NVARCHAR(256);
   Declare @CurrentOwnerTable NVARCHAR(256);
   Declare @CurrentShadowTable NVARCHAR(256);
   Declare @CurrentShadowSchema NVARCHAR(256);
   DECLARE @dropsyn1  NVARCHAR(256);
   DECLARE @dropsyn2  NVARCHAR(256);
   DECLARE @createsyn1  NVARCHAR(max);
   DECLARE @createsyn2  NVARCHAR(max);
   
   SET @owner_schema='SISWEB_OWNER'
   SET @shadow_schema='SISWEB_OWNER_SHADOW'

   SET @LOGMESSAGE= 'Execution started';
   
   EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE =@LOGMESSAGE,@DATAVALUE = NULL;
   

  WHILE len(@TABLENAMES) > 0
  BEGIN
   SET @TABLENAME=left(@TABLENAMES, charindex(',', @TABLENAMES+',')-1)

   SET @Base_Table=@TABLENAME+'_BASE'
   
   SELECT 
   @CurrentOwnerSchema = ltrim(rtrim(substring(base_object_name,2,charindex('].',base_object_name)-2))),
   @CurrentOwnerTable=ltrim(rtrim(substring(base_object_name,charindex('.',base_object_name)+2,len(base_object_name)-charindex('.',base_object_name)-2)))
   from sys.synonyms 
   Where Schema_id = schema_id(@owner_schema)
   And [Name] = @TABLENAME

   SELECT 
   @CurrentShadowSchema = ltrim(rtrim(substring(base_object_name,2,charindex('].',base_object_name)-2))),
   @CurrentShadowTable=ltrim(rtrim(substring(base_object_name,charindex('.',base_object_name)+2,len(base_object_name)-charindex('.',base_object_name)-2)))
   from sys.synonyms 
   Where Schema_id = schema_id(@shadow_schema)
   And [Name] = @TABLENAME


   SET @dynsql_updstats=N'UPDATE STATISTICS ' + QUOTENAME(@CurrentShadowSchema) +'.'+  QUOTENAME(@CurrentShadowTable)+N' WITH FULLSCAN, PERSIST_SAMPLE_PERCENT = ON;';
   EXEC sp_executesql @dynsql_updstats
   
   SET @LOGMESSAGE = 'Performed update stats for table ' + @TABLENAME;

   EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE =@LOGMESSAGE,@DATAVALUE = NULL;
   SET @TABLENAMES = stuff(@TABLENAMES, 1, charindex(',', @TABLENAMES+','), '')
   END

   BEGIN TRY 
   
   WHILE len(@TABLENAMES2) > 0
   BEGIN

   SET @TABLENAME=left(@TABLENAMES2, charindex(',', @TABLENAMES2+',')-1)
   SET @Base_Table=@TABLENAME+'_BASE'

   SET @LOGMESSAGE= 'Resetting Synonyms started for table ' + @TABLENAME;
   
   EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE =@LOGMESSAGE,@DATAVALUE = NULL;
   
   SELECT 
   @CurrentOwnerSchema = ltrim(rtrim(substring(base_object_name,2,charindex('].',base_object_name)-2))),
   @CurrentOwnerTable=ltrim(rtrim(substring(base_object_name,charindex('.',base_object_name)+2,len(base_object_name)-charindex('.',base_object_name)-2)))
   from sys.synonyms 
   Where Schema_id = schema_id(@owner_schema)
   And [Name] = @TABLENAME

   SELECT 
   @CurrentShadowSchema = ltrim(rtrim(substring(base_object_name,2,charindex('].',base_object_name)-2))),
   @CurrentShadowTable=ltrim(rtrim(substring(base_object_name,charindex('.',base_object_name)+2,len(base_object_name)-charindex('.',base_object_name)-2)))
   from sys.synonyms 
   Where Schema_id = schema_id(@shadow_schema)
   And [Name] = @TABLENAME

   
   BEGIN TRANSACTION;
   

   SET @dropsyn1=N'DROP SYNONYM [SISWEB_OWNER].' +QUOTENAME( @TABLENAME)  + N';';
   EXEC sp_executesql @dropsyn1

   SET @dropsyn2=N'DROP SYNONYM [SISWEB_OWNER_SHADOW].' +QUOTENAME(@TABLENAME)  + N';';
   EXEC sp_executesql @dropsyn2

   SET @createsyn1=
	'CREATE SYNONYM [SISWEB_OWNER].'+QUOTENAME(cast(@TABLENAME AS nvarchar(max))) +'FOR' + QUOTENAME(cast(@CurrentShadowSchema AS nvarchar(max))) +'.'+  QUOTENAME(cast(@CurrentShadowTable AS nvarchar(max)))+';'+char(10)+
	
	'   
    DECLARE @PERMSTRING nvarchar(max)

    DECLARE @TABLEPERM TABLE
	(
	PERMISSION varchar(1024)
	)

	INSERT INTO @TABLEPERM
	SELECT 	state_desc + '' '' + permission_name + '' on [SISWEB_OWNER].'+cast(QUOTENAME(cast(@TABLENAME AS nvarchar(max))) AS nvarchar(max))+' to ['' + sdpr.name + '']'' COLLATE LATIN1_General_CI_AS as [PermissionsTSQL]
	FROM SYS.DATABASE_PERMISSIONS AS sdp
	JOIN sys.objects AS so
    ON sdp.major_id = so.OBJECT_ID
	JOIN SYS.SCHEMAS AS ss
    ON so.SCHEMA_ID = ss.SCHEMA_ID
	JOIN SYS.DATABASE_PRINCIPALS AS sdpr
    ON sdp.grantee_principal_id = sdpr.principal_id
	where 1=1
	AND so.name = '''+cast(@Base_Table AS nvarchar(max))+'''
	AND ss.name=''SISWEB_OWNER''


   SELECT @PERMSTRING =STUFF((SELECT '';'' + PERMISSION FROM @TABLEPERM FOR XML PATH('''')) ,1,1,'''');'+char(10)+'EXEC (@PERMSTRING);'
    
   EXEC sp_executesql @createsyn1

   SET @createsyn2='CREATE SYNONYM [SISWEB_OWNER_SHADOW].'+QUOTENAME(cast(@TABLENAME AS nvarchar(max))) +'FOR' + QUOTENAME(cast(@CurrentOwnerSchema AS nvarchar(max))) +'.'+  QUOTENAME(cast(@CurrentOwnerTable AS nvarchar(max)))+';'+char(10)+
	
	'   
    DECLARE @PERMSTRING nvarchar(max)

    DECLARE @TABLEPERM TABLE
	(
	PERMISSION varchar(1024)
	)

	INSERT INTO @TABLEPERM
	SELECT 	state_desc + '' '' + permission_name + '' on [SISWEB_OWNER_SHADOW].'+cast(QUOTENAME(cast(@TABLENAME AS nvarchar(max))) AS nvarchar(max))+' to ['' + sdpr.name + '']'' COLLATE LATIN1_General_CI_AS as [PermissionsTSQL]
	FROM SYS.DATABASE_PERMISSIONS AS sdp
	JOIN sys.objects AS so
    ON sdp.major_id = so.OBJECT_ID
	JOIN SYS.SCHEMAS AS ss
    ON so.SCHEMA_ID = ss.SCHEMA_ID
	JOIN SYS.DATABASE_PRINCIPALS AS sdpr
    ON sdp.grantee_principal_id = sdpr.principal_id
	where 1=1
	AND so.name = '''+cast(@Base_Table AS nvarchar(max))+'''
	AND ss.name=''SISWEB_OWNER_SHADOW''


	SELECT @PERMSTRING =STUFF((SELECT '';'' + PERMISSION FROM @TABLEPERM FOR XML PATH('''')) ,1,1,'''');'+char(10)+'EXEC (@PERMSTRING);'
	
   EXEC sp_executesql @createsyn2
      
   COMMIT;

   SET @LOGMESSAGE = 'Resetting Synonyms completed for table ' + @TABLENAME;

   EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

   SET @TABLENAMES2 = stuff(@TABLENAMES2, 1, charindex(',', @TABLENAMES2+','), '')
   
   END

	END TRY
	BEGIN CATCH
		SET @ERRORMESSAGE = ERROR_MESSAGE();
		SET @ERRORLINE = ERROR_LINE();
		SET @ERRORNUM = ERROR_NUMBER();
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID
							   ,@LOGTYPE = 'Error'
							   ,@NAMEOFSPROC = @PROCNAME
							   ,@LOGMESSAGE = @LOGMESSAGE
							   ,@DATAVALUE = @ERRORNUM;
		THROW;
	END CATCH;
    
   EXEC SISWEB_OWNER_STAGING.VALIDATE_PERSIST_PERCENT

   SET @LOGMESSAGE = 'Execution completed ';

   EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE =@LOGMESSAGE,@DATAVALUE = NULL;

   END