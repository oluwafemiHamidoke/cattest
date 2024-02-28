
/* ==================================================================================================================================================== 
Author:			Paul B. Felix (+Davide Moraschi)
Create date:	2018-10-02
Modify date:	2019-08-20 Copied from [sis].[SMCS_Merge] and renamed

-- Description: Merge external table [sis_stage].[SMCS_Translation_Diff] into [sis].[SMCS_Translation]
====================================================================================================================================================== */
CREATE PROCEDURE sis.SMCS_Translation_Merge
AS
	BEGIN
		SET NOCOUNT ON;

		BEGIN TRY

			DECLARE @PROCNAME VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
			DECLARE @PROCESSID UNIQUEIDENTIFIER = NewID();

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Execution started',NULL);

			----Soft Delete
			--Update x
			--Set x.[isDeleted] = 1
			--FROM [sis].[SMCS_Translation] x
			--Inner join [sis_stage].[SMCS_Translation_Diff] s on ON s.SMCS_ID = x.SMCS_ID AND 
			--													s.Language_ID = x.Language_ID
			--Where s.Operation = 'Delete'
			--Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
			--Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'SMCS_Translation Soft Delete', @@RowCount)
			--Update
			UPDATE x
			  SET x.Description = s.Description
			FROM sis.SMCS_Translation x
				 INNER JOIN sis_stage.SMCS_Translation_Diff s ON s.SMCS_ID = x.SMCS_ID AND 
																 s.Language_ID = x.Language_ID
			WHERE s.Operation = 'Update';

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'SMCS_Translation Update',@@ROWCOUNT);

			--Insert
			INSERT INTO sis.SMCS_Translation (SMCS_ID,Language_ID,Description) 
				   SELECT SMCS_ID,Language_ID,Description
				   FROM sis_stage.SMCS_Translation_Diff
				   WHERE Operation = 'Insert';

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'SMCS_Translation Insert',@@ROWCOUNT);

Update STATISTICS sis.SMCS_Translation with fullscan 

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Execution completed',NULL);
		END TRY
		BEGIN CATCH

			DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE();
			DECLARE @ERROELINE INT = ERROR_LINE();

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Error',@PROCNAME,'LINE ' + CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE,NULL);
		END CATCH;
	END;