
/* ==================================================================================================================================================== 
Author:			Paul B. Felix (+Davide Moraschi)
Create date:	2018-01-31
Modify date:	2019-08-30 Copied from [sis_stage].[IE_Load] and renamed

-- Description: Full load [sis_stage].Dealer
-- Exec [sis_stage].[Dealer_Load]
====================================================================================================================================================== */
CREATE PROCEDURE sis_stage.Dealer_Load
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
Dealer
--------------------------------
*/
			--Load Dealer
			INSERT INTO sis_stage.Dealer (Dealer_Code) 
				   SELECT DISTINCT 
						  EFFECTIVITY
				   FROM SISWEB_OWNER.SIS2IEEFFECTIVITY
				   WHERE TYPEINDICATOR = 'D'
				   ORDER BY EFFECTIVITY;

			--select 'Dealer' Table_Name, @@RowCount Record_Count 
			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Dealer Load',@@ROWCOUNT);

			--Insert natural keys into key table 
			INSERT INTO sis_stage.Dealer_Key (Dealer_Code) 
				   SELECT s.Dealer_Code
				   FROM sis_stage.Dealer AS s
						LEFT OUTER JOIN sis_stage.Dealer_Key AS k ON s.Dealer_Code = k.Dealer_Code
				   WHERE k.Dealer_ID IS NULL;

			--Key table load 
			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Dealer Key Load',@@ROWCOUNT);

			--Update stage table with surrogate keys from key table 
			UPDATE s
			  SET Dealer_ID = k.Dealer_ID
			FROM sis_stage.Dealer s
				 INNER JOIN sis_stage.Dealer_Key k ON s.Dealer_Code = k.Dealer_Code
			WHERE s.Dealer_ID IS NULL;

			--Surrogate Update 
			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Dealer Update Surrogate',@@ROWCOUNT);

			--Load Diff table 
			INSERT INTO sis_stage.Dealer_Diff (Operation,Dealer_ID,Dealer_Code) 
				   SELECT 'Insert' AS Operation,s.Dealer_ID,s.Dealer_Code
				   FROM sis_stage.Dealer AS s
						LEFT OUTER JOIN sis.Dealer AS x ON s.Dealer_Code = x.Dealer_Code
				   WHERE x.Dealer_ID IS NULL --Inserted 
				   UNION ALL
				   SELECT 'Delete' AS Operation,x.Dealer_ID,x.Dealer_Code
				   FROM sis.Dealer AS x
						LEFT OUTER JOIN sis_stage.Dealer AS s ON s.Dealer_Code = x.Dealer_Code
				   WHERE s.Dealer_ID IS NULL --Deleted 
				   UNION ALL
				   SELECT 'Update' AS Operation,s.Dealer_ID,s.Dealer_Code
				   FROM sis_stage.Dealer AS s
						INNER JOIN sis.Dealer AS x ON s.Dealer_Code = x.Dealer_Code
				   WHERE NOT EXISTS --Updated
				   (
					   SELECT s.Dealer_ID,s.Dealer_Code
					   INTERSECT
					   SELECT x.Dealer_ID,x.Dealer_Code
				   );

			--Diff Load 
			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Dealer Diff Load',@@ROWCOUNT);

			--Load IE_Dealer_Relation
			INSERT INTO sis_stage.IE_Dealer_Relation (IE_ID,Dealer_ID) 
				   SELECT IE.IE_ID,Dealer_ID
				   FROM SISWEB_OWNER.SIS2IEEFFECTIVITY AS EF
						JOIN sis_stage.Dealer AS D ON EF.EFFECTIVITY = D.Dealer_Code
						JOIN sis_stage.IE AS IE ON IE.IESystemControlNumber = EF.IESYSTEMCONTROLNUMBER
				   WHERE TYPEINDICATOR = 'D'
				   ORDER BY IE.IE_ID,Dealer_ID;

			--select 'IE_Dealer_Relation' Table_Name, @@RowCount Record_Count   
			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE_Dealer_Relation Load',@@ROWCOUNT);

			--Load Diff table 
			INSERT INTO sis_stage.IE_Dealer_Relation_Diff (Operation,IE_ID,Dealer_ID) 
				   SELECT 'Insert' AS Operation,s.IE_ID,s.Dealer_ID
				   FROM sis_stage.IE_Dealer_Relation AS s
						LEFT OUTER JOIN sis.IE_Dealer_Relation AS x ON s.IE_ID = x.IE_ID AND 
																	   s.Dealer_ID = x.Dealer_ID
				   WHERE x.IE_ID IS NULL AND 
						 x.Dealer_ID IS NULL --Inserted 
				   UNION ALL
				   SELECT 'Delete' AS Operation,x.IE_ID,x.Dealer_ID
				   FROM sis.IE_Dealer_Relation AS x
						LEFT OUTER JOIN sis_stage.IE_Dealer_Relation AS s ON s.IE_ID = x.IE_ID AND 
																			 s.Dealer_ID = x.Dealer_ID
				   WHERE s.IE_ID IS NULL AND 
						 s.Dealer_ID IS NULL  --Deleted 
				   UNION ALL
				   SELECT 'Update' AS Operation,s.IE_ID,s.Dealer_ID
				   FROM sis_stage.IE_Dealer_Relation AS s
						INNER JOIN sis.IE_Dealer_Relation AS x ON s.IE_ID = x.IE_ID AND 
																  s.Dealer_ID = x.Dealer_ID
				   WHERE NOT EXISTS --Updated
				   (
					   SELECT s.*
					   INTERSECT
					   SELECT x.*
				   );

			--Diff Load 
			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE_Dealer_Relation Diff Load',@@ROWCOUNT);

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