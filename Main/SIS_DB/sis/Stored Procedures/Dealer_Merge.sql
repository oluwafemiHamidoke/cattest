
/* ==================================================================================================================================================== 
Author:			Paul B. Felix (+Davide Moraschi)
Create date:	2018-10-02
Modify date:	2019-08-30 Copied from [sis].[IE_Merge] and renamed

-- Description: Merge external table [sis_stage].[Dealer_Diff] into [sis].[Dealer]
====================================================================================================================================================== */
CREATE PROCEDURE sis.Dealer_Merge
AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			DECLARE @PROCNAME VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
			DECLARE @PROCESSID UNIQUEIDENTIFIER = NEWID();

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Execution started',NULL);

			----Soft Delete
			--Update x
			--Set x.[isDeleted] = 1
			--FROM [sis].[Dealer] x
			--Inner join [sis_stage].[Dealer_Diff] s on s.Dealer_Code = x.Dealer_Code
			--Where s.Operation = 'Delete'
			--Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
			--Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Dealer Soft Delete', @@RowCount)
			--Update
			UPDATE x
			  SET x.Dealer_ID = s.Dealer_ID
			FROM sis.Dealer x
				 INNER JOIN sis_stage.Dealer_Diff s ON s.Dealer_Code = x.Dealer_Code
			WHERE s.Operation = 'Update';

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Dealer Update',@@ROWCOUNT);

			--Insert
			INSERT INTO sis.Dealer (Dealer_ID,Dealer_Code) 
				   SELECT Dealer_ID,Dealer_Code
				   FROM sis_stage.Dealer_Diff
				   WHERE Operation = 'Insert';

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Dealer Insert',@@ROWCOUNT);

			Update STATISTICS sis.Dealer with fullscan 

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