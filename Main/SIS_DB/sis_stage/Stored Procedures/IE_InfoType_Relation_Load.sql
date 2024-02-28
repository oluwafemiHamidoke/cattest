
/* ==================================================================================================================================================== 
Author:			Paul B. Felix (+Davide Moraschi)
Create date:	2019-08-29
Modify date:	2020-03-16 Removed natural Key InfoTypeID
====================================================================================================================================================== */
CREATE PROCEDURE [sis_stage].[IE_InfoType_Relation_Load]
AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			DECLARE @PROCNAME  VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
				   ,@PROCESSID UNIQUEIDENTIFIER = NEWID();

			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Execution started',NULL);

/*
--------------------------------
IE_InfoType_Relation
--------------------------------
*/
			--Load IE_InfoType_Relation
			INSERT INTO sis_stage.IE_InfoType_Relation (IE_ID, InfoType_ID) 
				SELECT IE.IE_ID, IT.InfoType_ID
				FROM sis_stage.IE AS IE
				Inner Join SISWEB_OWNER.LNKIEINFOTYPE LIT on LIT.IESYSTEMCONTROLNUMBER = IE.IESystemControlNumber
				Inner Join sis_stage.InfoType IT on LIT.INFOTYPEID = IT.InfoType_ID

			--select 'IE' Table_Name, @@RowCount Record_Count 
			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE_InfoType_Relation Load',@@ROWCOUNT);

			--Load Diff table 
			INSERT INTO sis_stage.IE_InfoType_Relation_Diff (Operation,IE_ID,InfoType_ID) 
				   SELECT 'Insert' AS Operation,s.IE_ID,s.InfoType_ID
				   FROM sis_stage.IE_InfoType_Relation AS s
						LEFT OUTER JOIN sis.IE_InfoType_Relation AS x ON s.IE_ID = x.IE_ID and s.InfoType_ID = x.InfoType_ID
				   WHERE x.IE_ID IS NULL --Inserted 
				   UNION ALL
				   SELECT 'Delete' AS Operation,x.IE_ID,x.InfoType_ID
				   FROM sis.IE_InfoType_Relation AS x
						LEFT OUTER JOIN sis_stage.IE_InfoType_Relation AS s ON s.IE_ID = x.IE_ID and s.InfoType_ID = x.InfoType_ID
				   WHERE s.IE_ID IS NULL --Deleted 
				   --Updates cannot occur because there all fields are part of the pkey.  Only insert & delete.

			--Diff Load 
			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE_InfoType_Relation_Diff Load',@@ROWCOUNT);


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