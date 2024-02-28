/* ==================================================================================================================================================== 
Author:			Paul B. Felix (+Davide Moraschi)
Create date:	2018-10-02
Modify date:	2019-09-04 Copied from [sis].[IE_Translation_Merge] and renamed

-- Description: Merge external table [sis_stage].[IE_Illustration_Relation_Diff] into [sis].[IE_Illustration_Relation]
====================================================================================================================================================== */
CREATE PROCEDURE sis.IE_Illustration_Relation_Merge
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
			--FROM [sis].[IE_Illustration_Relation] x
			--Inner join [sis_stage].[IE_Illustration_Relation_Diff] s on ON s.IE_ID = x.IE_ID AND 
			--													s.Language_ID = x.Language_ID
			--Where s.Operation = 'Delete'
			--Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
			--Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'IE_Illustration_Relation Soft Delete', @@RowCount)
			--Update
			UPDATE x
			  SET x.Graphic_Number = s.Graphic_Number
			FROM sis.IE_Illustration_Relation x
				 INNER JOIN sis_stage.IE_Illustration_Relation_Diff s ON s.IE_ID = x.IE_ID AND 
																		 s.Illustration_ID = x.Illustration_ID
			WHERE s.Operation = 'Update';

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Illustration_ID Update',@@ROWCOUNT);

			--Insert
			INSERT INTO sis.IE_Illustration_Relation (Illustration_ID,IE_ID,Graphic_Number) 
				   SELECT Illustration_ID,IE_ID,Graphic_Number
				   FROM sis_stage.IE_Illustration_Relation_Diff
				   WHERE Operation = 'Insert';

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Illustration_ID Insert',@@ROWCOUNT);

			Update STATISTICS sis.IE_Illustration_Relation with fullscan 

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

