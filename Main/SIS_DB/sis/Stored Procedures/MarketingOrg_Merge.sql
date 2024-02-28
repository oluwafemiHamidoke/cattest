
/* ==================================================================================================================================================== 
Author:			Paul B. Felix (+Davide Moraschi)
Create date:	2018-10-02
Modify date:	2019-08-30 Copied from [sis].[Dealer_Merge] and renamed

-- Description: Merge external table [sis_stage].[MarketingOrg_Diff] into [sis].[MarketingOrg]
====================================================================================================================================================== */
CREATE PROCEDURE sis.MarketingOrg_Merge
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
			--FROM [sis].[MarketingOrg] x
			--Inner join [sis_stage].[MarketingOrg_Diff] s on s.MarketingOrg_Code = x.MarketingOrg_Code
			--Where s.Operation = 'Delete'
			--Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
			--Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'MarketingOrg Soft Delete', @@RowCount)
			--Update
			UPDATE x
			  SET x.MarketingOrg_ID = s.MarketingOrg_ID
			FROM sis.MarketingOrg x
				 INNER JOIN sis_stage.MarketingOrg_Diff s ON s.MarketingOrg_Code = x.MarketingOrg_Code
			WHERE s.Operation = 'Update';

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'MarketingOrg Update',@@ROWCOUNT);

			--Insert
			INSERT INTO sis.MarketingOrg (MarketingOrg_ID,MarketingOrg_Code) 
				   SELECT MarketingOrg_ID,MarketingOrg_Code
				   FROM sis_stage.MarketingOrg_Diff
				   WHERE Operation = 'Insert';

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'MarketingOrg Insert',@@ROWCOUNT);

            Update STATISTICS sis.MarketingOrg with fullscan 

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