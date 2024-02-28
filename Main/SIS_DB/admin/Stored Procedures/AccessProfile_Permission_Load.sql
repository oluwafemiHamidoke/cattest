CREATE PROCEDURE [admin].[AccessProfile_Permission_Load] 
@permission_list varchar(max), @permission_type varchar(50), @profile_name varchar(50)
AS
BEGIN 
SET NOCOUNT ON 
BEGIN TRY


		DECLARE @LOGMESSAGE VARCHAR(MAX)
		DECLARE @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
		DECLARE @ProcessID uniqueidentifier = NewID()
		DECLARE @Profile_ID INT, @permission_type_ID INT, @SNPCOUNT INT

		EXEC admin.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL
		  
		SELECT @Profile_ID = [Profile_ID] FROM [admin].[AccessProfile] WHERE Profile_Description=@profile_name


		IF (@Profile_ID IS NULL)
		BEGIN 
			SET @LOGMESSAGE = 'The Access Profile Name provided as part of the file name ('+CAST (@profile_name as nvarchar(max))+') is not valid as it does not exist in admin.AccessProfile'
			EXEC admin.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = NULL;
		END

		SELECT @permission_type_ID = PermissionType_ID FROM [admin].[Permission] WHERE PermissionType_Description=@permission_type
 
		IF (@permission_type_ID IS NULL)
		BEGIN 
			SET @LOGMESSAGE = 'The PermissionType Name provided as part of the file name ('+CAST (@permission_type as nvarchar(max))+') is not valid as it does not exist in admin.Permission'
			EXEC admin.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = NULL;
		END

		DROP TABLE IF EXISTS #PermissionList
		CREATE TABLE #PermissionList
		(
		Serial_Number_Prefix varchar(3)
		)

		INSERT INTO #PermissionList 
		SELECT value FROM STRING_SPLIT(@permission_list, ',')
		WHERE len(trim(value))>1

		--Create LogMessage with records to be deleted for existing Association 

		SELECT @LOGMESSAGE='Deleted SNP Associations for PermissionType ('+CAST (@permission_type as nvarchar(max))+') and Profile('+CAST (@profile_name as nvarchar(max))+'): '+STRING_AGG(CAST (SNP.Serial_Number_Prefix as nvarchar(max)), ',') 
		FROM  [admin].[AccessProfile_Permission_Relation] APR
		JOIN [admin].[AccessProfile] AP
		ON APR.Profile_ID = AP.Profile_ID
		JOIN sis.SerialNumberPrefix SNP 
		ON APR.Permission_Detail_ID = SNP.SerialNumberPrefix_ID
		WHERE AP.Profile_Description = @profile_name
		AND APR.PermissionType_ID=@permission_type_ID

		--Delete existing Association 
		DELETE APR
		FROM  [admin].[AccessProfile_Permission_Relation] APR
		JOIN [admin].[AccessProfile] AP
		ON APR.Profile_ID=AP.Profile_ID
		WHERE AP.Profile_Description = @profile_name
		AND APR.PermissionType_ID=@permission_type_ID

		SELECT @SNPCOUNT=@@ROWCOUNT

		EXEC admin.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @SNPCOUNT;

		--Insert New Association 
		INSERT INTO [admin].[AccessProfile_Permission_Relation]
		SELECT @Profile_ID, @permission_type_ID,1,SNP2.SerialNumberPrefix_ID FROM #PermissionList SNP1
		JOIN sis.SerialNumberPrefix SNP2 
		ON SNP1.Serial_Number_Prefix = SNP2.Serial_Number_Prefix

		SELECT @SNPCOUNT=@@ROWCOUNT

		--Create LogMessage with records to be inserted for new Association 
		SELECT @LOGMESSAGE='Inserted SNP Associations for PermissionType ('+CAST (@permission_type as nvarchar(max))+') and Profile('+CAST (@profile_name as nvarchar(max))+'): '+STRING_AGG(CAST(SNP1.Serial_Number_Prefix as nvarchar(max)), ',')  FROM #PermissionList SNP1
		JOIN sis.SerialNumberPrefix SNP2 
		ON SNP1.Serial_Number_Prefix = SNP2.Serial_Number_Prefix
		
		EXEC admin.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @SNPCOUNT;


		SELECT @SNPCOUNT=COUNT(SNP1.Serial_Number_Prefix)  FROM #PermissionList SNP1
		LEFT JOIN sis.SerialNumberPrefix SNP2 
		ON SNP1.Serial_Number_Prefix = SNP2.Serial_Number_Prefix
		WHERE SNP2.Serial_Number_Prefix IS NULL

		--Create LogMessage with records which does not exist in sis.SerialNumberPrefix to associate with the Profile
		SELECT @LOGMESSAGE='SNPs does not exist in sis.SerialNumberPrefix Table and cannot be associated. '+STRING_AGG(SNP1.Serial_Number_Prefix, ',')  FROM #PermissionList SNP1
		LEFT JOIN sis.SerialNumberPrefix SNP2 
		ON SNP1.Serial_Number_Prefix = SNP2.Serial_Number_Prefix
		WHERE SNP2.Serial_Number_Prefix IS NULL

		EXEC admin.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @SNPCOUNT;

		EXEC admin.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;

END TRY

BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
		DECLARE @ERROELINE INT = ERROR_LINE()

		SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
		EXEC admin.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = NULL;

END CATCH

END
