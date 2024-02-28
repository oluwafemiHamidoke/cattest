/* ==================================================================================================================================================== 
Author:			Paul B. Felix (+Davide Moraschi)
Create date:	2018-10-02
Modify date:	2019-08-20 Copied from [sis].[SMCS_Translation] and renamed

-- Description: Merge external table [sis_stage].[SMCS_IE_Relation_Diff] into [sis].[SMCS_IE_Relation]
====================================================================================================================================================== */
CREATE PROCEDURE sis.SMCS_IE_Relation_Merge
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
			--FROM [sis].[SMCS_IE_Relation] x
			--Inner join [sis_stage].[SMCS_IE_Relation_Diff] s on ON s.SMCS_ID = x.SMCS_ID AND 
			--													s.IE_ID = x.IE_ID
			--Where s.Operation = 'Delete'
			--Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
			--Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'SMCS_IE_Relation Soft Delete', @@RowCount)
			--Update
			UPDATE x
			  SET x.IE_ID = s.IE_ID
			FROM sis.SMCS_IE_Relation x
				 INNER JOIN sis_stage.SMCS_IE_Relation_Diff s ON s.SMCS_ID = x.SMCS_ID AND 
																 s.IE_ID = x.IE_ID AND s.Media_ID = x.Media_ID
			WHERE s.Operation = 'Update';

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'SMCS_IE_Relation Update',@@ROWCOUNT);

			--Insert
			INSERT INTO sis.SMCS_IE_Relation (SMCS_ID,IE_ID,Media_ID)
				   SELECT SMCS_ID,IE_ID,Media_ID
				   FROM sis_stage.SMCS_IE_Relation_Diff
				   WHERE Operation = 'Insert';

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'SMCS_IE_Relation Insert',@@ROWCOUNT);

 Update STATISTICS sis.SMCS_IE_Relation with fullscan 

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
GO

