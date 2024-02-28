
/* ==================================================================================================================================================== 
Author:			Paul B. Felix (+Davide Moraschi)
Create date:	2018-10-02
Modify date:	2019-09-03 Copied from [sis].[IE_Dealer_Relation_Merge] and renamed

-- Description: Merge external table [sis_stage].[IE_MarketingOrg_Relation_Diff] into [sis].[IE_MarketingOrg_Relation]
====================================================================================================================================================== */
CREATE PROCEDURE sis.IE_MarketingOrg_Relation_Merge
AS
	BEGIN
		SET NOCOUNT ON;

		--BEGIN TRY

		DECLARE @PROCNAME VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
		DECLARE @PROCESSID UNIQUEIDENTIFIER = NEWID();

		INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Execution started',NULL);

		----Soft Delete
		--Update x
		--Set x.[isDeleted] = 1
		--FROM [sis].[IE_MarketingOrg_Relation] x
		--Inner join [sis_stage].[IE_MarketingOrg_Relation_Diff] s.IE_ID = x.IE_ID AND 
		--															 s.MarketingOrg_ID = x.MarketingOrg_ID
		--Where s.Operation = 'Delete'
		--Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
		--Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'IE_MarketingOrg_Relation Soft Delete', @@RowCount)
		--Update
		UPDATE x
		  SET x.IE_ID = s.IE_ID
			 ,x.MarketingOrg_ID = s.MarketingOrg_ID
		FROM sis.IE_MarketingOrg_Relation x
			 INNER JOIN sis_stage.IE_MarketingOrg_Relation_Diff s ON s.MarketingOrg_ID = x.MarketingOrg_ID AND 
																	 s.IE_ID = x.IE_ID
		WHERE s.Operation = 'Update';

		INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE_MarketingOrg_Relation Update',@@ROWCOUNT);

		--Insert
		INSERT INTO sis.IE_MarketingOrg_Relation (MarketingOrg_ID,IE_ID) 
			   SELECT MarketingOrg_ID,IE_ID
			   FROM sis_stage.IE_MarketingOrg_Relation_Diff
			   WHERE Operation = 'Insert';

		INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE_MarketingOrg_Relation Insert',@@ROWCOUNT);

		Update STATISTICS sis.IE_MarketingOrg_Relation with fullscan 


		INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Execution completed',NULL);
		--END TRY
		--BEGIN CATCH
		--	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE();
		--	DECLARE @ERROELINE INT = ERROR_LINE();
		--	INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		--	VALUES (@PROCESSID,GETDATE(),'Error',@PROCNAME,'LINE ' + CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE,NULL);
		--END CATCH;
	END;