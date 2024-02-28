/* ==================================================================================================================================================== 
Author:			Ramesh Ramalingam (+ Sachin P)
Create date:	2020-11-03
Modify date:	
-- Description: Load [sis_stage].ServiceFile_DisplayTerms from [SISWEB_OWNER].LNKFILEDISPLAYTERMS
-- Exec [sis_stage].[ServiceFile_DisplayTerms_Load]
====================================================================================================================================================== */
CREATE PROCEDURE [sis_stage].[ServiceFile_DisplayTerms_Load]
AS
    BEGIN
        SET NOCOUNT ON;
        BEGIN TRY
            DECLARE @PROCNAME  VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
                   ,@PROCESSID UNIQUEIDENTIFIER = NEWID();

            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID, @LOGTYPE = 'Information', @NAMEOFSPROC = @PROCNAME, @LOGMESSAGE = 'Execution started' , @DATAVALUE = NULL;

            --Load ServiceFile_DisplayTerms
            INSERT INTO sis_stage.ServiceFile_DisplayTerms (ServiceFile_ID, [Type])
                   SELECT l.FILERID, l.DISPLAYTYPE
                   FROM SISWEB_OWNER.LNKFILEDISPLAYTERMS l
				   JOIN SISWEB_OWNER.MASFILEPROPERTIES m
				   ON l.FILERID=m.FILERID;

            --select 'ServiceFile_DisplayTerms' Table_Name, @@RowCount Record_Count
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID, @LOGTYPE = 'Information', @NAMEOFSPROC = @PROCNAME, @LOGMESSAGE = 'ServiceFile_DisplayTerms Load' , @DATAVALUE = @@ROWCOUNT;


            --Insert natural keys into key table
            Insert into [sis_stage].[ServiceFile_DisplayTerms_Key] (ServiceFile_ID, [Type])
            Select s.ServiceFile_ID, s.[Type]
            From [sis_stage].[ServiceFile_DisplayTerms] s
            Left outer join [sis_stage].[ServiceFile_DisplayTerms_Key] k on s.ServiceFile_ID = k.ServiceFile_ID AND s.Type = k.Type
            Where k.ServiceFile_DisplayTerms_ID is null;

            --Key table load
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID, @LOGTYPE = 'Information', @NAMEOFSPROC = @PROCNAME, @LOGMESSAGE = 'ServiceFile_DisplayTerms Key Load' , @DATAVALUE = @@ROWCOUNT;


            --Update stage table with surrogate keys from key table
            Update s
            Set ServiceFile_DisplayTerms_ID = k.ServiceFile_DisplayTerms_ID
            From [sis_stage].[ServiceFile_DisplayTerms] s
            inner join [sis_stage].[ServiceFile_DisplayTerms_Key] k on s.ServiceFile_ID = k.ServiceFile_ID AND s.Type = k.Type
            where s.ServiceFile_DisplayTerms_ID is null;

            --Surrogate Update
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID, @LOGTYPE = 'Information', @NAMEOFSPROC = @PROCNAME, @LOGMESSAGE = 'ServiceFile_DisplayTerms Update Surrogate' , @DATAVALUE = @@ROWCOUNT;

            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID, @LOGTYPE = 'Information', @NAMEOFSPROC = @PROCNAME, @LOGMESSAGE = 'Execution completed' , @DATAVALUE = NULL;

        END TRY
        BEGIN CATCH
            DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
			@ERRORLINE INT= ERROR_LINE(),
			@LOGMESSAGE VARCHAR(MAX);

	        SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID, @LOGTYPE = 'Error', @NAMEOFSPROC = @PROCNAME, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;
        END CATCH;
    END;
