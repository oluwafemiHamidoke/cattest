
/* ==================================================================================================================================================== 
Author:			Paul B. Felix (+Davide Moraschi)
Create date:	2018-10-02
Modify date:	2019-08-15 Copied from [sis].[Media_Merge] and renamed

-- Description: Merge external table [sis_stage].[SMCS_Diff] into [sis].[SMCS]
====================================================================================================================================================== */
CREATE PROCEDURE sis.SMCS_Merge
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
			--FROM [sis].[SMCS] x
			--Inner join [sis_stage].[SMCS_Diff] s on s.SMCSCOMPCODE = x.SMCSCOMPCODE
			--Where s.Operation = 'Delete'
			--Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
			--Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'SMCS Soft Delete', @@RowCount)
			--Update
			UPDATE x
			  SET 
				  x.SMCS_ID = s.SMCS_ID
				 ,x.CurrentIndicator = s.CurrentIndicator
				 ,x.LastModified_Date = GETDATE()
			FROM sis.SMCS x
				 INNER JOIN sis_stage.SMCS_Diff s ON s.SMCSCOMPCODE = x.SMCSCOMPCODE
			WHERE s.Operation = 'Update';

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'SMCS Update',@@ROWCOUNT);

			--Insert
			INSERT INTO sis.SMCS (SMCS_ID,SMCSCOMPCODE,CurrentIndicator, LastModified_Date) 
				   SELECT SMCS_ID,SMCSCOMPCODE,CurrentIndicator, GETDATE()
				   FROM sis_stage.SMCS_Diff
				   WHERE Operation = 'Insert';

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'SMCS Insert',@@ROWCOUNT);

Update STATISTICS sis.SMCS with fullscan 

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