
-- =============================================
-- Author:      Madhukar Bhandari
-- Create Date: 20220803
-- Description: Merge sis_stage.ssf_sissoft to sis_stage.ServiceFile_ReplacementHierarchy_Syn
-- =============================================
--exec  sis_stage.UDSP_SFF_Load_FlashSerialNumbers
CREATE PROCEDURE sis_stage.UDSP_SIS2ETL_SSF_Load_ReplacementHierarchy
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
            
				DROP TABLE IF EXISTS #ServiceFileIds
                CREATE TABLE #ServiceFileIds(
                    Part_Number VARCHAR(50),
                    ServiceFile_ID INT
                )
                
                INSERT INTO #ServiceFileIds (Part_Number, ServiceFile_ID)
					select Part_Number,
					(select top 1 [ServiceFile_ID] from [sis_stage].ServiceFile_Syn sfile WHERE  c.Part_Number + '.FLS' = sfile.ServiceFile_Name or sfile.ServiceFile_Name like c.Part_Number + '%'
					order by CASE WHEN  c.Part_Number + '.FLS' = sfile.ServiceFile_Name then 1 WHEN  sfile.ServiceFile_Name like c.Part_Number + '.%' THEN 2 ELSE 3 END) [ServiceFile_ID]
					from [sis_stage].[ssf_sissoft] c
					union
					select Replacement_Part_Number,
					(select top 1 [ServiceFile_ID] from [sis_stage].ServiceFile_Syn sfile WHERE  c1.Replacement_Part_Number + '.FLS' = sfile.ServiceFile_Name or sfile.ServiceFile_Name like c1.Replacement_Part_Number + '%'
					order by CASE WHEN  c1.Replacement_Part_Number + '.FLS' = sfile.ServiceFile_Name then 1 WHEN  sfile.ServiceFile_Name like c1.Replacement_Part_Number + '.%' THEN 2 ELSE 3 END) [ServiceFile_ID]
					from [sis_stage].[ssf_sissoft] c1

                INSERT INTO [sis_stage].[ServiceFile_Syn] ([ServiceFile_ID],[InfoType_ID],[ServiceFile_Name],[Available_Flag],[Mime_Type],[ServiceFile_Size],[Updated_Date],[Created_Date],[Insert_Date])
                    SELECT NEXT VALUE FOR [SISWEB_OWNER_STAGING].[SEQ_RID], 41, Part_Number + '.FLS','N','z',NULL ,GETDATE(),GETDATE(),GETDATE()
                    from #ServiceFileIds
                    where [ServiceFile_ID] is null
				
                UPDATE  s
                SET ServiceFile_ID = (select top 1 [ServiceFile_ID] from [sis_stage].ServiceFile_Syn sfile WHERE  s.Part_Number + '.FLS' = sfile.ServiceFile_Name or sfile.ServiceFile_Name like s.Part_Number + '%'
				order by CASE WHEN  s.Part_Number + '.FLS' = sfile.ServiceFile_Name then 1 WHEN  sfile.ServiceFile_Name like s.Part_Number + '.%' THEN 2 ELSE 3 END) 
                FROM #ServiceFileIds s
                WHERE s.ServiceFile_ID is null
                
				DROP TABLE IF EXISTS #servicefiles 
                ;WITH CTE as(
                        select *,Part_Number Parent_Part_Number,1 Seq from [sis_stage].[ssf_sissoft] a --where Part_Number in( '1290160')
                        union all
                        select b.*,c.Parent_Part_Number Parent_Part_Number,c.Seq + 1 Seq from [sis_stage].[ssf_sissoft] b 
                        inner join cte c
                        on c.Replacement_Part_Number = b.Part_Number
                    )
                select 
					(SELECT top 1 [ServiceFile_ID] FROM #ServiceFileIds sfile WHERE  c.Parent_Part_Number = sfile.Part_Number) ServiceFile_ID,
					(SELECT top 1 [ServiceFile_ID] FROM #ServiceFileIds sfile WHERE  c.Replacement_Part_Number = sfile.Part_Number) Replacement_ServiceFile_ID,
					c.Seq
					into #servicefiles from CTE c
                    where c.Replacement_Part_Number is not null and c.Replacement_Part_Number <> ''
                
                MERGE INTO sis_stage.[ServiceFile_ReplacementHierarchy_Syn] tgt
                USING (select * from #servicefiles) src
                on tgt.ServiceFile_ID = src.ServiceFile_ID
				and tgt.[Replacing_ServiceFile_ID] = src.Replacement_ServiceFile_ID
				WHEN MATCHED AND EXISTS
					(	SELECT src.Seq 
						except 
						select tgt.[Sequence_No]
					)
					THEN
						UPDATE SET [Sequence_No] = src.Seq
				WHEN NOT MATCHED BY TARGET
				THEN
					INSERT ([ServiceFile_ID],[Replacing_ServiceFile_ID],[Sequence_No])
					VALUES (src.[ServiceFile_ID],src.Replacement_ServiceFile_ID,src.[Seq])
				WHEN NOT MATCHED BY SOURCE
				THEN DELETE;


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
	   