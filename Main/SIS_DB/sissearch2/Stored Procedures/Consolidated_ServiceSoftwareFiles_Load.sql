-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20230531
-- Description: Load data into [sissearch2].[Consolidated_ServiceSoftwareFiles]
-- =============================================

CREATE  Procedure [sissearch2].[Consolidated_ServiceSoftwareFiles_Load]
As
Begin

	BEGIN TRY

		SET NOCOUNT ON

		Declare @LastInsertDate DATETIME,
				@Mime_type CHAR(1) = 'h',
				@Available_Flag CHAR(1) = 'Y', 
				@FlashFilesID INT =41,
				@PermissionType_ID INT= 3,
				@Permission_Detail_ID INT = 41,
				@Include_Exclude INT = 1

		Declare @SPStartTime DATETIME,
				@StepStartTime DATETIME,
				@ProcName VARCHAR(200),
				@SPStartLogID BIGINT,
				@StepLogID BIGINT,
				@RowCount BIGINT,
				@LAPSETIME BIGINT
		SET @SPStartTime= GETDATE()
		SET @ProcName= OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)

		--Identify Deleted Records From Source

		EXEC @SPStartLogID = sissearch2.WriteLog @TIME = @SPStartTime, @NAMEOFSPROC = @ProcName;

		SET @StepStartTime= GETDATE()
		EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

		If Object_ID('Tempdb..#DeletedRecords') is not null
		Begin 
			Drop table #DeletedRecords
		End
		Select
			[ServiceFile_ID]
		into #DeletedRecords
		from  [sissearch2].[Consolidated_ServiceSoftwareFiles]
		Except 
		Select Distinct SF.[ServiceFile_ID]				
		from [sis].[ServiceFile] SF 
		left join [sis].[ServiceFile_CPI] SFC on SF.[ServiceFile_ID] = SFC.[ServiceFile_ID]
		Left join (Select  [Permission_Detail_ID],'['+string_agg( Profile_ID, ',') WITHIN GROUP (ORDER BY [Profile_ID] ASC)+']' as Profile_ID 
				   from [admin].[AccessProfile_Permission_Relation] 
				   where [PermissionType_ID] = @PermissionType_ID and [Permission_Detail_ID] = @Permission_Detail_ID 
					and [Include_Exclude] = @Include_Exclude group by [Permission_Detail_ID]) APR 
		on APR.[Permission_Detail_ID] = SF.[InfoType_ID] 
		where  SF.[Mime_Type] = @Mime_type
		and SF.[Available_Flag]= @Available_Flag 
		and SF.[InfoType_ID]=  @FlashFilesID 
		and SF.[ServiceFile_Name] like '%HTML'
		and len(SF.[ServiceFile_Name]) > 8 
		and substring(SF.[ServiceFile_Name],1,7) <> '0000000' --- removing unwanted records

		SET @RowCount= @@RowCount


		SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
		EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
		@LOGMESSAGE =  'Deleted Records Detected';

		-- Delete Idenified Deleted Records in Target

		SET @StepStartTime= GETDATE()
		EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


		Delete sissearch2.Consolidated_ServiceSoftwareFiles 
		From sissearch2.Consolidated_ServiceSoftwareFiles a
		inner join #DeletedRecords d on a.[ServiceFile_ID] = d.[ServiceFile_ID]

		SET @RowCount= @@RowCount

		SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
		EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
		@LOGMESSAGE =  'Deleted Records from Target [sissearch2].[Consolidated_ServiceSoftwareFiles]';

		--Get Maximum insert date from Target
		SET @StepStartTime= GETDATE()
		EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

		Select  @LastInsertDate=coalesce(Max(Updated_Date),'1900-01-01') From sissearch2.Consolidated_ServiceSoftwareFiles

		SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
		Declare @Logmessage as varchar(50) = 'Latest Insert Date in Target '+cast (@LastInsertDate as varchar(25))
		EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = @Logmessage , @LogID = @StepLogID


		--Identify Inserted records from Source
		SET @StepStartTime= GETDATE()
		EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


		If Object_ID('Tempdb..#InsertRecords') is not null
		Begin 
		 Drop table #InsertRecords
		End
		Select
				SF.[ServiceFile_ID]
		into #InsertRecords
		from [sis].[ServiceFile] SF 
		left join [sis].[ServiceFile_CPI] SFC on SF.[ServiceFile_ID] = SFC.[ServiceFile_ID]
		Left join (Select  [Permission_Detail_ID],'['+string_agg( Profile_ID, ',') WITHIN GROUP (ORDER BY [Profile_ID] ASC)+']' as Profile_ID 
				   from [admin].[AccessProfile_Permission_Relation] 
				   where [PermissionType_ID] = @PermissionType_ID and [Permission_Detail_ID] = @Permission_Detail_ID 
				         and [Include_Exclude] = @Include_Exclude group by [Permission_Detail_ID]) APR 
		on APR.[Permission_Detail_ID] = SF.[InfoType_ID] 
		where  SF.[Mime_Type] = @Mime_type
		and SF.[Available_Flag]= @Available_Flag 
		and SF.[InfoType_ID]=  @FlashFilesID 
		and SF.[ServiceFile_Name] like '%HTML'
		and len(SF.[ServiceFile_Name]) > 8 
		and substring(SF.[ServiceFile_Name],1,7) <> '0000000' AND SF.Updated_Date  > @LastInsertDate


		SET @RowCount= @@RowCount

		SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
		EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
		@LOGMESSAGE =  'Inserted Records Detected #InsertRecords';


		--Delete Inserted records from Target 	
		SET @StepStartTime= GETDATE()
		EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


		Delete [sissearch2].[Consolidated_ServiceSoftwareFiles]
		From [sissearch2].[Consolidated_ServiceSoftwareFiles] a
		inner join #InsertRecords d on a.[ServiceFile_ID] = d.[ServiceFile_ID]
		SET @RowCount= @@RowCount   


		SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
		EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
		@LOGMESSAGE =  'Deleted Inserted Records from Target [sissearch2].[Consolidated_ServiceSoftwareFiles]';

		--Stage R2S Set
		SET @StepStartTime= GETDATE()
		EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

		If Object_ID('Tempdb..#RecordsToString') is not null
		Begin 
			Drop table #RecordsToString
		End
		Select Distinct (substring(SF.[ServiceFile_Name],0,charindex('.HTML',upper(SF.ServiceFile_Name))) +'_'+ CAST(SF.ServiceFile_ID as varchar(100)) +substring(SF.[ServiceFile_Name],charindex('.HTML',upper(SF.[ServiceFile_Name])),100)) Servicefile_Name,
						 SF.[ServiceFile_ID],
						'['''+cast(SF.[InfoType_ID] as varchar(10))+''']' [InfoTypeID], 
						substring(SF.[ServiceFile_Name],1,7) as MediaNumber, 
						substring(SF.[ServiceFile_Name],1,7) as PartNumber , 
						SF.[Updated_Date], 
						0 as [IsMedia], 
						APR.[Profile_ID] ,
						SF.[Insert_Date], 
						SF.[Created_Date] as [PubDate],
						'FIDS' as [MediaOrigin], 
						'['+string_agg( SFC.[CPINumber], ',') WITHIN GROUP (ORDER BY SFC.[CPINumber] ASC)+']'  	AS CPINumber			
		into #RecordsToString
		from [sis].[ServiceFile] SF 
		Left join sis.ServiceFile_Reference SFR on SFR.[Referred_ServiceFile_ID] = SF.[ServiceFile_ID]
		Inner join #InsertRecords IR on SF.[ServiceFile_ID] = IR.[ServiceFile_ID]
		Left join [sis].[ServiceFile_CPI] SFC on SFR.[ServiceFile_ID] = SFC.[ServiceFile_ID]
		Left join (Select  [Permission_Detail_ID],'['+string_agg( Profile_ID, ',') WITHIN GROUP (ORDER BY [Profile_ID] ASC)+']' as Profile_ID 
					from [admin].[AccessProfile_Permission_Relation] 
					where [PermissionType_ID] = @PermissionType_ID and [Permission_Detail_ID] = @Permission_Detail_ID 
					and [Include_Exclude] = @Include_Exclude group by [Permission_Detail_ID]) APR 
		on APR.[Permission_Detail_ID] = SF.[InfoType_ID] 
		where  SF.[Mime_Type] = @Mime_type
		and SF.[Available_Flag]= @Available_Flag 
		and SF.[InfoType_ID]=  @FlashFilesID 
		and SF.[ServiceFile_Name] like '%HTML'
		and len(SF.[ServiceFile_Name]) > 8
		and substring(SF.[ServiceFile_Name],1,7) <> '0000000' --- removing unwanted records
		Group by SF.[ServiceFile_Name] , SF.[InfoType_ID], APR.[Profile_ID], SF.[ServiceFile_ID],SF.[Updated_Date], SF.[Insert_Date], SF.[Created_Date]


		SET @RowCount= @@RowCount

		SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
		EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
		@LOGMESSAGE =  'Inserted Records Loaded to #RecordsToString';

		SET @StepStartTime= GETDATE()
		EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


		Insert into [sissearch2].[Consolidated_ServiceSoftwareFiles]
		SELECT * FROM #RecordsToString

		SET @RowCount= @@RowCount

		SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
		EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
		@LOGMESSAGE =  'Inserted into Target [sissearch2].[Consolidated_ServiceSoftwareFiles]';

		--Complete

		SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
		EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LogID = @SPStartLogID,@DATAVALUE = @RowCount


	END TRY

	BEGIN CATCH 
		 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
				 @ERROELINE INT= ERROR_LINE()
									  SELECT @ERRORMESSAGE,@ERROELINE
		 Declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
		 EXEC sissearch2.WriteLog @LogTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error
	END CATCH


End