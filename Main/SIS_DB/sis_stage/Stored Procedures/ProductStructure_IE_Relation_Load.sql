
-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180214
-- Modify Date: 20190909
-- Description: Full load [sis_stage].[[ProductStructure_IE_Relation_Load]
--Exec [sis_stage].[[ProductStructure_IE_Relation_Load]
-- =============================================
CREATE PROCEDURE sis_stage.ProductStructure_IE_Relation_Load
AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			DECLARE @PROCNAME  VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
				   ,@PROCESSID UNIQUEIDENTIFIER = NewID();

			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Execution started',NULL);

			-- Insert statements for procedure here
			--Load 
			INSERT INTO sis_stage.ProductStructure_IE_Relation (ProductStructure_ID,IE_ID,Media_ID) 
				   SELECT DISTINCT 
						  CAST(l.PSID AS INT) AS PSID,iep.IE_ID AS IE_ID,m.Media_ID
				   FROM SISWEB_OWNER.LNKIEPSID AS l
						INNER JOIN sis_stage.IE AS iep ON l.IESYSTEMCONTROLNUMBER = iep.IESystemControlNumber
						INNER JOIN sis_stage.Media AS m ON m.Media_Number = l.MEDIANUMBER;

			--select '[ProductStructure_IE_Relation' Table_Name, @@RowCount Record_Count  
			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'ProductStructure_IE_Relation Load',@@ROWCOUNT);

			--Load Diff table
			INSERT INTO sis_stage.ProductStructure_IE_Relation_Diff (Operation,ProductStructure_ID,IE_ID,Media_ID) 
				   SELECT 'Insert' AS Operation,s.ProductStructure_ID,s.IE_ID,s.Media_ID
				   FROM sis_stage.ProductStructure_IE_Relation AS s
						LEFT OUTER JOIN sis.ProductStructure_IE_Relation AS x ON s.ProductStructure_ID = x.ProductStructure_ID AND 
																				 s.IE_ID = x.IE_ID AND 
																				 s.Media_ID = x.Media_ID
						JOIN sis.ProductStructure ps on ps.ProductStructure_ID = s.ProductStructure_ID
				   WHERE x.ProductStructure_ID IS NULL --Inserted
				   UNION ALL
				   SELECT 'Delete' AS Operation,x.ProductStructure_ID,x.IE_ID,x.Media_ID
				   FROM sis.ProductStructure_IE_Relation AS x
						LEFT OUTER JOIN sis_stage.ProductStructure_IE_Relation AS s ON s.ProductStructure_ID = x.ProductStructure_ID AND 
																					   s.IE_ID = x.IE_ID AND 
																					   s.Media_ID = x.Media_ID
				   WHERE s.ProductStructure_ID IS NULL; --Deleted
			--Diff Load
			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'ProductStructure_IE_Relation Diff Load',@@ROWCOUNT);

			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Execution completed',NULL);
		END TRY
		BEGIN CATCH

			DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
				   ,@ERROELINE    INT            = ERROR_LINE();

			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Error',@PROCNAME,'LINE ' + CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE,NULL);
		END CATCH;
	END;