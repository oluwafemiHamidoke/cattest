

/* ==================================================================================================================================================== 
Author:			Paul B. Felix (+Davide Moraschi)
Create date:	2018-10-02
Modify date:	2019-08-29 Copied from [sis].[InfoType_Merge] and renamed

-- Description: Merge external table [sis_stage].[IE_Diff] into [sis].[IE]
====================================================================================================================================================== */
CREATE PROCEDURE [sis].[IE_Merge]
AS
	BEGIN
		SET NOCOUNT ON;

		--BEGIN TRY

			DECLARE @PROCNAME VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
			DECLARE @PROCESSID UNIQUEIDENTIFIER = NEWID();

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Execution started',NULL);

			UPDATE x
			  SET x.IE_ID = s.IE_ID
			FROM sis.IE x
				 INNER JOIN sis_stage.IE_Diff s ON s.IESystemControlNumber = x.IESystemControlNumber 
			WHERE s.Operation = 'Update';

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE Update',@@ROWCOUNT);

			--Insert
			INSERT INTO sis.IE (IE_ID,IESystemControlNumber) 
				   SELECT IE_ID,IESystemControlNumber
				   FROM sis_stage.IE_Diff
				   WHERE Operation = 'Insert';

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE Insert',@@ROWCOUNT);

     		Update STATISTICS sis.IE with fullscan 

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Execution completed',NULL);

	END;