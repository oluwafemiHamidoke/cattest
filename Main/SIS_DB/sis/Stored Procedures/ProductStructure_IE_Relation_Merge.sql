-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181002
-- Modify Date: 20190909
-- Description: Merge external table [sis_stage].[ProductStructure_IE_Relation_Diff] into [sis].[ProductStructure_IE_Relation]
-- =============================================
CREATE PROCEDURE sis.ProductStructure_IE_Relation_Merge
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
			--FROM [sis].[ProductStructure_IE_Relation] x
			--Inner join [sis_stage].[ProductStructure_IE_Relation_Diff] s on s.ProductStructure_ID = x.ProductStructure_ID and s.IE_ID = x.IE_ID and s.Media_ID = x.Media_ID
			--Where s.Operation = 'Delete'
			--Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
			--Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ProductStructure_IE_Relation Soft Delete', @@RowCount)
			----Update
			--Update x
			--Set 
			--FROM [sis].[ProductStructure_IE_Relation] x
			--Inner join [sis_stage].[ProductStructure_IE_Relation_Diff] s on s.ProductStructure_ID = x.ProductStructure_ID and s.IE_ID = x.IE_ID and s.Media_ID = x.Media_ID
			--Where s.Operation = 'Update'
			--Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
			--Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ProductStructure_IE_Relation Update', @@RowCount)
			--Insert
			INSERT INTO sis.ProductStructure_IE_Relation (ProductStructure_ID,IE_ID,Media_ID) 
				   SELECT ProductStructure_ID,IE_ID,Media_ID
				   FROM sis_stage.ProductStructure_IE_Relation_Diff
				   WHERE Operation = 'Insert';

			INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'ProductStructure_IE_Relation Insert',@@ROWCOUNT);

Update STATISTICS sis.ProductStructure_IE_Relation with fullscan 

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

