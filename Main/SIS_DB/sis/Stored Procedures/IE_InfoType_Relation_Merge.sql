/* ==================================================================================================================================================== 
Author:			Paul B. Felix (+Davide Moraschi)
Create date:	2018-10-02
Modify date:	2019-09-09 Copied from [sis].[InfoType_Translation_Merge] and renamed

-- Description: Merge external table [sis_stage].[IE_InfoType_Relation_Diff] into [sis].[IE_InfoType_Relation]
====================================================================================================================================================== */
CREATE PROCEDURE sis.IE_InfoType_Relation_Merge
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
			--FROM [sis].[IE_InfoType_Relation] x
			--Inner join [sis_stage].[IE_InfoType_Relation_Diff] s on ON s.InfoType_ID = x.InfoType_ID AND 
			--													s.Language_ID = x.Language_ID
			--Where s.Operation = 'Delete'
			--Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
			--Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'IE_InfoType_Relation Soft Delete', @@RowCount)
			--Update
			/*
			UPDATE x
			  SET x.Description = s.Description
			FROM sis.IE_InfoType_Relation x
				 INNER JOIN sis_stage.IE_InfoType_Relation_Diff s ON s.InfoType_ID = x.InfoType_ID AND 
																	 s.IE_ID = x.IE_ID
			WHERE s.Operation = 'Update';
		   --Updates cannot occur because there all fields are part of the pkey.  Only insert & delete.
		   */

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE_InfoType_Relation Update',@@ROWCOUNT);

			--Insert
			INSERT INTO sis.IE_InfoType_Relation (InfoType_ID,IE_ID) 
				   SELECT InfoType_ID,IE_ID
				   FROM sis_stage.IE_InfoType_Relation_Diff
				   WHERE Operation = 'Insert';

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE_InfoType_Relation Insert',@@ROWCOUNT);

			Update STATISTICS sis.IE_InfoType_Relation with fullscan 

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

