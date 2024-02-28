/* ==================================================================================================================================================== 
Author:			Ramesh Ramalingam (+ Sachin P)
Create date:	2020-11-03
Modify date:
-- Description: Load [sis_stage].ServiceFile from [SISWEB_OWNER].MASFILEPROPERTIES
-- Exec [sis_stage].[ServiceFile_Load]
====================================================================================================================================================== */
CREATE PROCEDURE [sis_stage].[ServiceFile_Load]
AS
    BEGIN
        SET NOCOUNT ON;
        BEGIN TRY
            DECLARE @PROCNAME  VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
                   ,@PROCESSID UNIQUEIDENTIFIER = NEWID();

            INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
            VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Execution started',NULL);

            --Load ServiceFile 
            INSERT INTO sis_stage.ServiceFile (ServiceFile_ID, InfoType_ID, ServiceFile_Name, Available_Flag, Mime_Type, ServiceFile_Size, Updated_Date, Created_Date, Insert_Date)
                   SELECT FILERID, INFOTYPEID, [FILENAME], AVAILABLEFLAG, MIMETYPE, FILESIZE, UPDATEDDATE, CREATEDDATE, psps.INSERT_TS
                   FROM SISWEB_OWNER.MASFILEPROPERTIES mas
                   LEFT JOIN PSPS.SIS_PART_DATA psps on psps.PART_NUMBER = (REVERSE(SUBSTRING(REVERSE(mas.[FILENAME]), CHARINDEX('.', REVERSE(mas.[FILENAME])) + 1, 100))) 

            --select 'ServiceFile' Table_Name, @@RowCount Record_Count 
            INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
            VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'ServiceFile Load',@@ROWCOUNT);

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