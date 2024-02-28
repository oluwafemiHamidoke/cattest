
-- =============================================
-- Author:      Madhukar Bhandari
-- Create Date: 20220803
-- Description: Merge sis_stage.ssf_sissoft to sis.ssf_sisprod and sis_stage.ServiceFile_** tables
-- =============================================
--exec  sis_stage.UDSP_SFF_Load_FlashSerialNumbers
CREATE PROCEDURE sis_stage.UDSP_SIS2ETL_SFF_Load_FlashSerialNumbers
    (@DEBUG      BIT = 'FALSE')
AS
BEGIN
	BEGIN TRY
			DECLARE @RELOADED_ROWS                 INT              = 0
				   ,@PROCNAME                      VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
				   ,@PROCESSID                     UNIQUEIDENTIFIER = NEWID()
				   ,@LOGMESSAGE                    VARCHAR(MAX);

			BEGIN TRANSACTION;
				EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;
            
				DECLARE @recordCount INT = (SELECT count(1) FROM [sis_stage].[ssf_sisprod])
				IF (@recordCount < 1000000)
					BEGIN
						EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,
							@LOGMESSAGE = 'Source data count lessor than usual validate "sisprod.idx" file',@DATAVALUE = @recordCount;
					
						THROW 60000,'Invalid file size "sisprod.idx" file',1;
					END

				EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,
					@LOGMESSAGE = 'Removing duplicates from ssf_sisprod',@DATAVALUE = NULL;

				WITH cte AS (
					SELECT [Serial_Number_Prefix],[Start_Serial_Number],[End_Serial_Number],[Application_Code],[Part_Number],
							ROW_NUMBER() OVER (
								PARTITION BY [Serial_Number_Prefix],[Start_Serial_Number],[End_Serial_Number],[Application_Code],[Part_Number]
								ORDER BY [Serial_Number_Prefix]
							) row_num
						 FROM 
							  [sis_stage].[ssf_sisprod]
					)
					DELETE FROM cte	WHERE row_num > 1;

				EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,
					@LOGMESSAGE = 'Findins Diff between last run data and current data',@DATAVALUE = NULL;

				TRUNCATE TABLE [sis_stage].ssf_sisprod_diff
				INSERT INTO [sis_stage].ssf_sisprod_diff
				SELECT DISTINCT
				CASE WHEN a.[Serial_Number_Prefix] IS NULL THEN b.[Serial_Number_Prefix]	ELSE a.[Serial_Number_Prefix] END [Serial_Number_Prefix],
				CASE WHEN a.[Serial_Number_Prefix] IS NULL THEN b.[Start_Serial_Number]		ELSE a.[Start_Serial_Number] END [Start_Serial_Number],
				CASE WHEN a.[Serial_Number_Prefix] IS NULL THEN b.[End_Serial_Number]		ELSE a.[End_Serial_Number] END [End_Serial_Number],
				CASE WHEN a.[Serial_Number_Prefix] IS NULL THEN b.[Application_Code]		ELSE a.[Application_Code] END [Application_Code],
				CASE WHEN a.[Serial_Number_Prefix] IS NULL THEN b.[Part_Number]				ELSE a.[Part_Number] END [Part_Number],
				CASE WHEN a.[Serial_Number_Prefix] IS NULL THEN 'DELETED'					ELSE 'INSERTED' END OPERATION,
				CASE WHEN a.[Serial_Number_Prefix] IS NULL 
						THEN (SELECT top 1 [ServiceFile_ID] FROM [sis_stage].ServiceFile_Syn sfile WHERE  b.Part_Number + '.FLS' = sfile.ServiceFile_Name or sfile.ServiceFile_Name like b.Part_Number + '%'
						order by CASE WHEN  b.Part_Number + '.FLS' = sfile.ServiceFile_Name then 1 WHEN  sfile.ServiceFile_Name like b.Part_Number + '.%' THEN 2 ELSE 3 END)
						ELSE (SELECT top 1 [ServiceFile_ID] FROM [sis_stage].ServiceFile_Syn sfile WHERE  a.Part_Number + '.FLS' = sfile.ServiceFile_Name or sfile.ServiceFile_Name like a.Part_Number + '%'
						order by CASE WHEN  a.Part_Number + '.FLS' = sfile.ServiceFile_Name then 1 WHEN  sfile.ServiceFile_Name like a.Part_Number + '.%' THEN 2 ELSE 3 END) 
					END	[ServiceFile_ID] 
				FROM sis_stage.ssf_sisprod  a 
				FULL OUTER JOIN sis_stage.[ssf_sisprod_last_run] b
				ON  a.[Serial_Number_Prefix] = b.[Serial_Number_Prefix] and a.[Start_Serial_Number]	 = b.[Start_Serial_Number]
				AND a.[End_Serial_Number]	 = b.[End_Serial_Number] and a.[Application_Code]	 = b.[Application_Code]
				AND a.[Part_Number]			 = b.[Part_Number]
				WHERE a.[Serial_Number_Prefix] IS NULL OR b.[Serial_Number_Prefix] IS NULL

				EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,
					@LOGMESSAGE = 'Insert the file rid for new records into ServiceFile_Syn',@DATAVALUE = NULL;


				INSERT INTO [sis_stage].[ServiceFile_Syn] ([ServiceFile_ID],[InfoType_ID],[ServiceFile_Name],[Available_Flag],[Mime_Type],[ServiceFile_Size],[Updated_Date],[Created_Date],[Insert_Date])
					SELECT NEXT VALUE FOR [SISWEB_OWNER_STAGING].[SEQ_RID], 41, diff.Part_Number + '.FLS','N','z',NULL ,GETDATE(),GETDATE(),GETDATE()
					FROM [sis_stage].ssf_sisprod_diff diff WHERE diff.ServiceFile_ID IS NULL group by diff.Part_Number

				update diff
				SET [ServiceFile_ID] = sf.[ServiceFile_ID]
				FROM [sis_stage].ssf_sisprod_diff diff
				inner join [sis_stage].[ServiceFile_Syn] sf
				on sf.InfoType_ID = 41 and sf.ServiceFile_Name = diff.Part_Number + '.FLS' and sf.Available_Flag = 'N' and sf.Mime_Type = 'z'
				WHERE diff.[ServiceFile_ID] is null

				EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,
					@LOGMESSAGE = 'Delete records from ServiceFile_SearchCriteria_Syn',@DATAVALUE = NULL;

				--DELETE FROM [sis_stage].ServiceFile_SearchCriteria_Syn
				DELETE s FROM [sis_stage].ServiceFile_SearchCriteria_Syn s 
				INNER JOIN [sis_stage].ssf_sisprod_diff m
				ON m.ServiceFile_ID = s.ServiceFile_ID AND m.Serial_Number_Prefix = s.Search_Value
				AND m.Start_Serial_Number = s.Begin_Range AND m.End_Serial_Number = s.End_Range
				AND m.OPERATION = 'DELETED' WHERE s.InfoType_ID = 41 and s.Search_Type = 'SN'

				EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,
					@LOGMESSAGE = 'Delete records from ServiceFile_DisplayTerms_Syn & ServiceFile_DisplayTerms_Translation_Syn',@DATAVALUE = NULL;
				
				-- Delete [sis_stage].[ServiceFile_DisplayTerms_Translation_Syn]
				DELETE s1 FROM [sis_stage].[ServiceFile_DisplayTerms_Translation_Syn] s1
				INNER JOIN [sis_stage].ServiceFile_DisplayTerms_Syn s ON s.ServiceFile_DisplayTerms_ID = s1.ServiceFile_DisplayTerms_ID
				INNER JOIN [sis_stage].ssf_sisprod_diff m ON m.ServiceFile_ID = s.ServiceFile_ID
				AND m.OPERATION = 'DELETED' AND s1.Value_Type = 'N' AND s.Type = 'AC'

				-- Delete sis.ServiceFile_DisplayTerms_Syn
				DELETE s from [sis_stage].ServiceFile_DisplayTerms_Syn s
				INNER JOIN [sis_stage].ssf_sisprod_diff m ON m.ServiceFile_ID = s.ServiceFile_ID
				AND m.OPERATION = 'DELETED' AND s.Type = 'AC'

				EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,
					@LOGMESSAGE = 'Inser records new into ServiceFile_SearchCriteria_Syn',@DATAVALUE = NULL;
				
				-- Insert into [sis_stage].[ServiceFile_SearchCriteria_Syn]
				INSERT INTO [sis_stage].[ServiceFile_SearchCriteria_Syn] ([ServiceFile_ID],[InfoType_ID],[Search_Type],[Value],[Search_Value],[Begin_Range],[End_Range],[Num_Data])
					SELECT m.[ServiceFile_ID],41,'SN',Serial_Number_Prefix,Serial_Number_Prefix,Start_Serial_Number,End_Serial_Number,[Application_Code] 
					from [sis_stage].ssf_sisprod_diff m WHERE m.OPERATION = 'INSERTED' --AND m.[ServiceFile_ID] IS NULL

				EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,
					@LOGMESSAGE = 'Insert records new into ServiceFile_DisplayTerms_Syn for TYPE AC and FN',@DATAVALUE = NULL;


				-- Insert into [sis_stage].ServiceFile_DisplayTerms_Syn

				MERGE INTO [sis_stage].[ServiceFile_DisplayTerms_Syn] tgt
				USING (
						SELECT DISTINCT [ServiceFile_ID],'AC' [Type] FROM [sis_stage].ssf_sisprod_diff m WHERE m.OPERATION = 'INSERTED'
						UNION ALL
						SELECT DISTINCT [ServiceFile_ID],'FN' [Type] FROM [sis_stage].ssf_sisprod_diff m WHERE m.OPERATION = 'INSERTED'
					) src
				ON src.[ServiceFile_ID] = tgt.[ServiceFile_ID]
				AND src.[Type] = tgt.[Type]
				WHEN NOT MATCHED BY TARGET
				THEN INSERT VALUES (src.[ServiceFile_ID],src.[Type]);


				-- Insert into [sis_stage].ServiceFile_DisplayTerms_Translation_Syn
				
				MERGE INTO [sis_stage].[ServiceFile_DisplayTerms_Translation_Syn] tgt
				USING (
						SELECT a.ServiceFile_DisplayTerms_ID,a.Language_ID,a.[Value_Type],a.[Display_Value] FROM(
						SELECT DISTINCT dt.ServiceFile_DisplayTerms_ID, l.Language_ID,'N' [Value_Type],CAST(m.Application_Code as VARCHAR(50)) [Display_Value],
						ROW_NUMBER() OVER (PARTITION BY dt.ServiceFile_DisplayTerms_ID, l.Language_ID ORDER BY Serial_Number_Prefix,	Start_Serial_Number,	End_Serial_Number  ) row_num
						FROM [sis_stage].ssf_sisprod_diff m 
						INNER JOIN [sis_stage].[ServiceFile_DisplayTerms_Syn] dt ON dt.ServiceFile_ID = m.ServiceFile_ID AND dt.Type = 'AC'
						INNER JOIN [sis].Language l ON l.Legacy_Language_Indicator = 'E' AND l.Default_Language = 1
						WHERE m.OPERATION = 'INSERTED' --and m.Part_Number like '5197890' 
						)a WHERE a.row_num = 1 --and ServiceFile_DisplayTerms_ID = 4930490 -- Take the latest of the app code only
	
						UNION ALL

						SELECT DISTINCT dt.ServiceFile_DisplayTerms_ID, l.Language_ID,'C' [Value_Type],m.Part_Number + '.FLS' [Display_Value]
						FROM [sis_stage].ssf_sisprod_diff m 
						INNER JOIN [sis_stage].[ServiceFile_DisplayTerms_Syn] dt ON dt.ServiceFile_ID = m.ServiceFile_ID AND dt.Type = 'FN'
						INNER JOIN [sis].Language l on l.Legacy_Language_Indicator = 'E' AND l.Default_Language = 1
						WHERE m.OPERATION = 'INSERTED' --and ServiceFile_DisplayTerms_ID = 4930490
					) src
				ON src.ServiceFile_DisplayTerms_ID = tgt.ServiceFile_DisplayTerms_ID
				AND src.Language_ID = tgt.Language_ID
				
				WHEN NOT MATCHED BY TARGET
					THEN INSERT VALUES (src.[ServiceFile_DisplayTerms_ID],src.[Language_ID],src.[Value_Type],src.[Display_Value],src.[Display_Value])
				WHEN MATCHED AND EXISTS
				(
					SELECT src.[Value_Type],src.[Display_Value]
					EXCEPT 
					SELECT tgt.[Value_Type],tgt.[Display_Value]
				)	
				THEN UPDATE SET
					tgt.[Value_Type]= src.[Value_Type],
					tgt.[Display_Value] = src.[Display_Value];
					
				
				EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,
					@LOGMESSAGE = 'Sync ssf_sisprod_last_run table with ssf_sisprod',@DATAVALUE = NULL;

				TRUNCATE TABLE sis_stage.[ssf_sisprod_last_run]
				INSERT INTO sis_stage.[ssf_sisprod_last_run] ( [Serial_Number_Prefix],[Start_Serial_Number],[End_Serial_Number],[Application_Code],[Part_Number])
					SELECT [Serial_Number_Prefix],[Start_Serial_Number],[End_Serial_Number],[Application_Code],[Part_Number]
					FROM [sis_stage].[ssf_sisprod]


				EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,
					@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;
				COMMIT
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
GO
	   