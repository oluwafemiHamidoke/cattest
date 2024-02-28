
/* ==================================================================================================================================================== 
Author:			Paul B. Felix (+Davide Moraschi)
Create date:	2018-01-31
Modify date:	2019-08-30 Copied from [sis_stage].[Dealer_Load] and renamed

-- Description: Full load [sis_stage].MarketingOrg
-- Exec [sis_stage].[MarketingOrg_Load]
====================================================================================================================================================== */
CREATE PROCEDURE sis_stage.MarketingOrg_Load
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
MarketingOrg
--------------------------------
*/
			--Load MarketingOrg
			INSERT INTO sis_stage.MarketingOrg (MarketingOrg_Code) 
				   SELECT MKT_ORG_DESC
				   FROM SIS_AUTHORING.MKT_ORG_MAP
				   ORDER BY MKT_ORG_DESC;

			--select 'MarketingOrg' Table_Name, @@RowCount Record_Count 
			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'MarketingOrg Load',@@ROWCOUNT);

			--Insert natural keys into key table 
			INSERT INTO sis_stage.MarketingOrg_Key (MarketingOrg_Code) 
				   SELECT s.MarketingOrg_Code
				   FROM sis_stage.MarketingOrg AS s
						LEFT OUTER JOIN sis_stage.MarketingOrg_Key AS k ON s.MarketingOrg_Code = k.MarketingOrg_Code
				   WHERE k.MarketingOrg_ID IS NULL;

			--Key table load 
			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'MarketingOrg Key Load',@@ROWCOUNT);

			--Update stage table with surrogate keys from key table 
			UPDATE s
			  SET MarketingOrg_ID = k.MarketingOrg_ID
			FROM sis_stage.MarketingOrg s
				 INNER JOIN sis_stage.MarketingOrg_Key k ON s.MarketingOrg_Code = k.MarketingOrg_Code
			WHERE s.MarketingOrg_ID IS NULL;

			--Surrogate Update 
			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'MarketingOrg Update Surrogate',@@ROWCOUNT);

			--Load Diff table 
			INSERT INTO sis_stage.MarketingOrg_Diff (Operation,MarketingOrg_ID,MarketingOrg_Code) 
				   SELECT 'Insert' AS Operation,s.MarketingOrg_ID,s.MarketingOrg_Code
				   FROM sis_stage.MarketingOrg AS s
						LEFT OUTER JOIN sis.MarketingOrg AS x ON s.MarketingOrg_Code = x.MarketingOrg_Code
				   WHERE x.MarketingOrg_ID IS NULL --Inserted 
				   UNION ALL
				   SELECT 'Delete' AS Operation,x.MarketingOrg_ID,x.MarketingOrg_Code
				   FROM sis.MarketingOrg AS x
						LEFT OUTER JOIN sis_stage.MarketingOrg AS s ON s.MarketingOrg_Code = x.MarketingOrg_Code
				   WHERE s.MarketingOrg_ID IS NULL --Deleted 
				   UNION ALL
				   SELECT 'Update' AS Operation,s.MarketingOrg_ID,s.MarketingOrg_Code
				   FROM sis_stage.MarketingOrg AS s
						INNER JOIN sis.MarketingOrg AS x ON s.MarketingOrg_Code = x.MarketingOrg_Code
				   WHERE NOT EXISTS --Updated
				   (
					   SELECT s.MarketingOrg_ID,s.MarketingOrg_Code
					   INTERSECT
					   SELECT x.MarketingOrg_ID,x.MarketingOrg_Code
				   );

			--Diff Load 
			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'MarketingOrg Diff Load',@@ROWCOUNT);

			--Load IE_MarketingOrg_Relation
			WITH MKT_IE
				 AS (SELECT m.MKT_ORG_DESC,ie.IESYSTEMCONTROLNUMBER
					 FROM sis.ServiceLetter_Type_Codes AS c
						  JOIN SIS_AUTHORING.MKT_ORG_MAP AS m ON c.OrgCode = m.SIS_TYPE
						  JOIN SISWEB_OWNER.LNKIEINFOTYPE AS ie ON ie.INFOTYPEID = c.InfoTypeID
						  --If a service letter has both dealer codes and distribution codes, distribution codes are to be ignored.
						  --Had meeting on 3/28/2023 with Matt Knox and Warren Anderson to confirm this.
						  where ie.IESYSTEMCONTROLNUMBER not in 
							(select distinct ie.IESystemControlNumber from sis_stage.IE_Dealer_Relation iedr 
								inner join sis.IE ie on ie.IE_ID=iedr.IE_ID)
					)
				 INSERT INTO sis_stage.IE_MarketingOrg_Relation (IE_ID,MarketingOrg_ID) 
						SELECT IE.IE_ID,MO.MarketingOrg_ID
						FROM MKT_IE AS MI
							 JOIN sis_stage.MarketingOrg AS MO ON MO.MarketingOrg_Code = MI.MKT_ORG_DESC
							 JOIN sis_stage.IE AS IE ON IE.IESystemControlNumber = MI.IESYSTEMCONTROLNUMBER;

			--select 'IE_MarketingOrg_Relation' Table_Name, @@RowCount Record_Count   
			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE_MarketingOrg_Relation Load',@@ROWCOUNT);

			--Load Diff table 
			INSERT INTO sis_stage.IE_MarketingOrg_Relation_Diff (Operation,IE_ID,MarketingOrg_ID) 
				   SELECT 'Insert' AS Operation,s.IE_ID,s.MarketingOrg_ID
				   FROM sis_stage.IE_MarketingOrg_Relation AS s
						LEFT OUTER JOIN sis.IE_MarketingOrg_Relation AS x ON s.IE_ID = x.IE_ID AND 
																			 s.MarketingOrg_ID = x.MarketingOrg_ID
				   WHERE x.IE_ID IS NULL AND 
						 x.MarketingOrg_ID IS NULL --Inserted 
				   UNION ALL
				   SELECT 'Delete' AS Operation,x.IE_ID,x.MarketingOrg_ID
				   FROM sis.IE_MarketingOrg_Relation AS x
						LEFT OUTER JOIN sis_stage.IE_MarketingOrg_Relation AS s ON s.IE_ID = x.IE_ID AND 
																				   s.MarketingOrg_ID = x.MarketingOrg_ID
				   WHERE s.IE_ID IS NULL AND 
						 s.MarketingOrg_ID IS NULL  --Deleted 
				   UNION ALL
				   SELECT 'Update' AS Operation,s.IE_ID,s.MarketingOrg_ID
				   FROM sis_stage.IE_MarketingOrg_Relation AS s
						INNER JOIN sis.IE_MarketingOrg_Relation AS x ON s.IE_ID = x.IE_ID AND 
																		s.MarketingOrg_ID = x.MarketingOrg_ID
				   WHERE NOT EXISTS --Updated
				   (
					   SELECT s.*
					   INTERSECT
					   SELECT x.*
				   );

			--Diff Load 
			INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
			VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE_MarketingOrg_Relation Diff Load',@@ROWCOUNT);

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