/* ==================================================================================================================================================== 
Author:			Ramesh Ramalingam (+ Sachin P)
Create date:	2020-11-03
Modify date:    
-- Description: Load [sis_stage].ServiceFile_DisplayTerms_Translation from [SISWEB_OWNER].LNKFILEDISPLAYTERMS
-- Exec [sis_stage].[ServiceFile_DisplayTerms_Translation_Load]
====================================================================================================================================================== */
CREATE PROCEDURE [sis_stage].[ServiceFile_DisplayTerms_Translation_Load]
AS
    BEGIN
        SET NOCOUNT ON;
        BEGIN TRY
            DECLARE @PROCNAME  VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
                   ,@PROCESSID UNIQUEIDENTIFIER = NEWID();

            INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
            VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Execution started',NULL);

            --Load ServiceFile_DisplayTerms_Translation
            INSERT INTO sis_stage.ServiceFile_DisplayTerms_Translation (ServiceFile_DisplayTerms_ID, Language_ID, Value_Type, [Value], Display_Value)
            SELECT SD.ServiceFile_DisplayTerms_ID, L.Language_ID, VALUEDATATYPE, DISPLAYVALUE, DISPLAYVALUE
                    FROM SISWEB_OWNER.LNKFILEDISPLAYTERMS D
                    INNER JOIN sis_stage.ServiceFile_DisplayTerms SD ON SD.ServiceFile_ID = D.FILERID AND SD.Type = D.DISPLAYTYPE
                    INNER JOIN sis_stage.Language L ON L.Legacy_Language_Indicator = D.LANGUAGEINDICATOR AND L.Default_Language = 1;

            --select 'ServiceFile_DisplayTerms_Translation' Table_Name, @@RowCount Record_Count
            INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
            VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'ServiceFile_DisplayTerms_Translation Load',@@ROWCOUNT);

            --Load Diff table
            INSERT INTO sis_stage.ServiceFile_DisplayTerms_Translation_Diff (Operation, ServiceFile_DisplayTerms_ID, Language_ID, Value_Type, [Value])
                   SELECT 'Insert' AS Operation, s.ServiceFile_DisplayTerms_ID, s.Language_ID, s.Value_Type, s.Value
                   FROM sis_stage.ServiceFile_DisplayTerms_Translation AS s
                        LEFT OUTER JOIN sis.ServiceFile_DisplayTerms_Translation AS x ON s.ServiceFile_DisplayTerms_ID = x.ServiceFile_DisplayTerms_ID AND s.Language_ID = x.Language_ID
                   WHERE x.ServiceFile_DisplayTerms_ID IS NULL --Inserted
                   UNION ALL
                   SELECT 'Delete' AS Operation, x.ServiceFile_DisplayTerms_ID, x.Language_ID, x.Value_Type, x.Value
                   FROM sis.ServiceFile_DisplayTerms_Translation AS x
                        LEFT OUTER JOIN sis_stage.ServiceFile_DisplayTerms_Translation AS s ON s.ServiceFile_DisplayTerms_ID = x.ServiceFile_DisplayTerms_ID AND s.Language_ID = x.Language_ID
                   WHERE s.ServiceFile_DisplayTerms_ID IS NULL --Deleted
                   UNION ALL
                   SELECT 'Update' AS Operation, s.ServiceFile_DisplayTerms_ID, s.Language_ID, s.Value_Type, s.Value
                   FROM sis_stage.ServiceFile_DisplayTerms_Translation AS s
                         INNER JOIN sis.ServiceFile_DisplayTerms_Translation AS x ON s.ServiceFile_DisplayTerms_ID = x.ServiceFile_DisplayTerms_ID AND s.Language_ID = x.Language_ID
                   WHERE NOT EXISTS --Updated
                   (
                       SELECT s.Value_Type, s.Value
                       INTERSECT
                       SELECT x.Value_Type, x.Value
                   );

            --Diff Load 
            INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
            VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'ServiceFile_DisplayTerms_Translation Diff Load',@@ROWCOUNT);

            INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
            VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Execution completed',NULL);
        END TRY
        BEGIN CATCH
            DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
                   ,@ERROELINE    INT            = ERROR_LINE();
            INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
            VALUES (@PROCESSID,GETDATE(),'Error',@PROCNAME,'LINE ' + CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE,NULL);
        END CATCH;
    END;