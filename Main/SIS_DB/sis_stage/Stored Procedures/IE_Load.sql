
/* ==================================================================================================================================================== 
Author:			Paul B. Felix (+Davide Moraschi)
Create date:	2018-01-31
Modify date:	2019-08-29 Copied from [sis_stage].[InfoType_Load] and renamed
Modify date:	2019-09-13 Added -1 N/A record to sis_stage_IE_Key table
Modify date:	2020-03-02 Added [IEControlNumber] and [Published_Date] to [sis_stage].[IE_Translation]
Modify date:	2020-03-06 Fixed bug https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/5887
Modify date:	2020-03-23 Added File_Location and Mime_Type https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/5972/
Modify date:	2020-03-23 Filtered out group titles https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/7378/
Modify date:	2020-09-18 Corrected NULL group titles https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/7378/
Modify date:	2021-01-27 Added [Date_Updated] https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/9581/
Modified By:	Kishor Padmanabhan
Modified At:	20220905
Modified Reason: Add LastModified_Date column in IE_Translation table.
Work Item  :	22323
-- Description: Full load [sis_stage].IE
-- Exec [sis_stage].[IE_Load]
====================================================================================================================================================== */
CREATE PROCEDURE sis_stage.IE_Load
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @PROCNAME  VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@PROCESSID UNIQUEIDENTIFIER = NEWID()
			   ,@NULLID    INT              = 0;

		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Execution started',NULL);

/*
--------------------------------
IE
--------------------------------
*/
		--Load IE Case 1: English title, get the value from GROUPTITLEINDICATOR = 'N'. If GROUPTITLEINDICATOR is null then use 'N'.
		INSERT INTO sis_stage.IE (IESystemControlNumber) 
			   SELECT 
					  T.IESYSTEMCONTROLNUMBER
			   FROM SISWEB_OWNER.LNKIETITLE AS T
			   WHERE T.IELANGUAGEINDICATOR = 'E' AND 
					 ISNULL(T.GROUPTITLEINDICATOR,'N') = 'N';

		--Load IE Case 2: No English title, get the MAX(GROUPTITLEINDICATOR) = 'N'.
		WITH ENGLISH_IESCN
			 AS (SELECT 
						T.IESYSTEMCONTROLNUMBER
				 FROM SISWEB_OWNER.LNKIETITLE AS T
				 WHERE T.IELANGUAGEINDICATOR = 'E')
			 INSERT INTO sis_stage.IE (IESystemControlNumber) 
					SELECT DISTINCT 
						   T.IESYSTEMCONTROLNUMBER
					FROM SISWEB_OWNER.LNKIETITLE AS T
					WHERE T.IESYSTEMCONTROLNUMBER NOT IN(SELECT EI.IESYSTEMCONTROLNUMBER FROM ENGLISH_IESCN AS EI)
					GROUP BY T.IESYSTEMCONTROLNUMBER
					HAVING MAX(T.GROUPTITLEINDICATOR) = 'N';

		--Load IE Case 3: No row has value, do not import. See: SELECT * FROM SISWEB_OWNER.LNKIETITLE AS L WHERE L.IESYSTEMCONTROLNUMBER = 'i03850416';
		--
		--select 'IE' Table_Name, @@RowCount Record_Count 
		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE Load',@@ROWCOUNT);

		SELECT @NULLID = COUNT(*) FROM sis_stage.IE_Key WHERE IE_ID = -1;
		IF @NULLID = 0
		BEGIN
			SET IDENTITY_INSERT sis_stage.IE_Key ON;
			INSERT INTO sis_stage.IE_Key (IE_ID,IESystemControlNumber) 
			VALUES (-1,'N/A');
			SET IDENTITY_INSERT sis_stage.IE_Key OFF;
		END;

		SELECT @NULLID = COUNT(*) FROM sis_stage.IE WHERE IE_ID = -1;
		IF @NULLID = 0
		BEGIN
			INSERT INTO sis_stage.IE (IE_ID,IESystemControlNumber) 
			VALUES (-1,'N/A');
		END;

		--Insert natural keys into key table 
		INSERT INTO sis_stage.IE_Key (IESystemControlNumber) 
			   SELECT s.IESystemControlNumber
			   FROM sis_stage.IE AS s
					LEFT OUTER JOIN sis_stage.IE_Key AS k ON s.IESystemControlNumber = k.IESystemControlNumber
			   WHERE k.IE_ID IS NULL;

		--Key table load 
		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE Key Load',@@ROWCOUNT);

		--Update stage table with surrogate keys from key table 
		UPDATE s
		  SET IE_ID = k.IE_ID
		FROM sis_stage.IE s
			 INNER JOIN sis_stage.IE_Key k ON s.IESystemControlNumber = k.IESystemControlNumber
		WHERE s.IE_ID IS NULL;

		--Surrogate Update 
		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE Update Surrogate',@@ROWCOUNT);

		--Load Diff table 
		INSERT INTO sis_stage.IE_Diff (Operation,IE_ID,IESystemControlNumber) 
			   SELECT 'Insert' AS Operation,s.IE_ID,s.IESystemControlNumber
			   FROM sis_stage.IE AS s
					LEFT OUTER JOIN sis.IE AS x ON s.IESystemControlNumber = x.IESystemControlNumber
			   WHERE x.IE_ID IS NULL --Inserted 
			   UNION ALL
			   SELECT 'Delete' AS Operation,x.IE_ID,x.IESystemControlNumber
			   FROM sis.IE AS x
					LEFT OUTER JOIN sis_stage.IE AS s ON s.IESystemControlNumber = x.IESystemControlNumber
			   WHERE s.IE_ID IS NULL --Deleted 
			   UNION ALL
			   SELECT 'Update' AS Operation,s.IE_ID,s.IESystemControlNumber
			   FROM sis_stage.IE AS s
					INNER JOIN sis.IE AS x ON s.IESystemControlNumber = x.IESystemControlNumber
			   WHERE NOT EXISTS --Updated
			   (
				   SELECT s.IE_ID,s.IESystemControlNumber
				   INTERSECT
				   SELECT x.IE_ID,x.IESystemControlNumber
			   );

		--Diff Load 
		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE Diff Load',@@ROWCOUNT);

		--Load IE Translations
		WITH RANKED_LNKIEDATE
			 AS (SELECT RANK() OVER(PARTITION BY IESYSTEMCONTROLNUMBER,LANGUAGEINDICATOR
				 ORDER BY DATEUPDATED DESC,IEPUBDATE DESC) AS R,L.IESYSTEMCONTROLNUMBER,L.DATEUPDATED,L.IEPUBDATE,L.LANGUAGEINDICATOR,L.IERID,L.LASTMODIFIEDDATE
				 FROM SISWEB_OWNER.LNKIEDATE AS L)
			 INSERT INTO sis_stage.IE_Translation (IE_ID,Language_ID,Title,IEControlNumber,Published_Date,File_Location,Mime_Type,Date_Updated,EnglishControlNumber, LastModified_Date 
					,File_Size_Byte) 
					SELECT IE.IE_ID,L.Language_ID,IET.IETITLE,IET.IECONTROLNUMBER,LNKIEDATE.IEPUBDATE,BL.LOCATION,BL.MIMETYPE,LNKIEDATE.DATEUPDATED,IET.ENGLISHCONTROLNUMBER, LNKIEDATE.LASTMODIFIEDDATE
					,BL.FILESIZEBYTE
					FROM SISWEB_OWNER.LNKIETITLE AS IET
						 JOIN sis_stage.IE AS IE ON IE.IESystemControlNumber = IET.IESYSTEMCONTROLNUMBER
						 JOIN SISWEB_OWNER.MASLANGUAGE AS LANG ON LANG.LANGUAGEINDICATOR = IET.IELANGUAGEINDICATOR
						 LEFT JOIN SISWEB_OWNER.SIS2IEBLOBLOCATION AS BL ON BL.IESYSTEMCONTROLNUMBER = IET.IESYSTEMCONTROLNUMBER AND 
																			BL.LANGUAGEINDICATOR = LANG.LANGUAGEINDICATOR
						 JOIN sis_stage.Language AS L ON L.Legacy_Language_Indicator = LANG.LANGUAGEINDICATOR AND 
														 L.Default_Language = 1
						 LEFT JOIN RANKED_LNKIEDATE AS LNKIEDATE ON LNKIEDATE.IESYSTEMCONTROLNUMBER = IET.IESYSTEMCONTROLNUMBER AND 
																	LNKIEDATE.LANGUAGEINDICATOR = IET.IELANGUAGEINDICATOR AND 
																	LNKIEDATE.R = 1
					ORDER BY IE.IE_ID,L.Language_ID;

		--select 'IE_Translation' Table_Name, @@RowCount Record_Count   
		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE_Translation Load',@@ROWCOUNT);

		--Load Diff table 
		INSERT INTO sis_stage.IE_Translation_Diff (Operation,IE_ID,Language_ID,Title,IEControlNumber,Published_Date,File_Location,Mime_Type,Date_Updated,EnglishControlNumber, LastModified_Date, File_Size_Byte) 
			   SELECT 'Insert' AS Operation,s.IE_ID,s.Language_ID,s.Title,s.IEControlNumber,s.Published_Date,s.File_Location,s.Mime_Type,s.Date_Updated,s.EnglishControlNumber, s.LastModified_Date, s.File_Size_Byte
			   FROM sis_stage.IE_Translation AS s
					LEFT OUTER JOIN sis.IE_Translation AS x ON s.IE_ID = x.IE_ID AND 
															   s.Language_ID = x.Language_ID
			   WHERE x.IE_ID IS NULL AND 
					 x.Language_ID IS NULL --Inserted 
			   UNION ALL
			   SELECT 'Delete' AS Operation,x.IE_ID,x.Language_ID,x.Title,s.IEControlNumber,s.Published_Date,s.File_Location,s.Mime_Type,s.Date_Updated,s.EnglishControlNumber, s.LastModified_Date, s.File_Size_Byte
			   FROM sis.IE_Translation AS x
					LEFT OUTER JOIN sis_stage.IE_Translation AS s ON s.IE_ID = x.IE_ID AND 
																	 s.Language_ID = x.Language_ID
			   WHERE s.IE_ID IS NULL  --Deleted 
			   UNION ALL
			   SELECT 'Update' AS Operation,s.IE_ID,s.Language_ID,s.Title,s.IEControlNumber,s.Published_Date,s.File_Location,s.Mime_Type,s.Date_Updated,s.EnglishControlNumber, s.LastModified_Date, s.File_Size_Byte
			   FROM sis_stage.IE_Translation AS s
					INNER JOIN sis.IE_Translation AS x ON s.IE_ID = x.IE_ID AND 
														  s.Language_ID = x.Language_ID
			   WHERE NOT EXISTS --Updated
			   (
				   SELECT s.Title,s.IEControlNumber,s.Published_Date,s.File_Location,s.Mime_Type,s.Date_Updated,s.EnglishControlNumber, s.LastModified_Date, isnull(s.File_Size_Byte,0)
				   INTERSECT
				   SELECT x.Title,x.IEControlNumber,x.Published_Date,x.File_Location,x.Mime_Type,x.Date_Updated,x.EnglishControlNumber, x.LastModified_Date, x.File_Size_Byte
			   );

		--Diff Load 
		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE_Translation Diff Load',@@ROWCOUNT);

		--Load IE_Illustration_Relation
		INSERT INTO sis_stage.IE_Illustration_Relation (Illustration_ID,IE_ID,Graphic_Number) 
			   SELECT I.Illustration_ID,IE.IE_ID,IEI.GRAPHICSEQUENCENUMBER
			   FROM SISWEB_OWNER.LNKIEIMAGE AS IEI
					JOIN sis_stage.Illustration AS I ON I.Graphic_Control_Number = IEI.GRAPHICCONTROLNUMBER
					JOIN sis_stage.IE AS IE ON IE.IESystemControlNumber = IEI.IESYSTEMCONTROLNUMBER
			   ORDER BY I.Illustration_ID,IE.IE_ID;

		--select 'IE_Illustration_Relation' Table_Name, @@RowCount Record_Count   
		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE_Illustration_Relation Load',@@ROWCOUNT);

		--Load Diff table 
		INSERT INTO sis_stage.IE_Illustration_Relation_Diff (Operation,Illustration_ID,IE_ID,Graphic_Number) 
			   SELECT 'Insert' AS Operation,s.Illustration_ID,s.IE_ID,s.Graphic_Number
			   FROM sis_stage.IE_Illustration_Relation AS s
					LEFT OUTER JOIN sis.IE_Illustration_Relation AS x ON s.IE_ID = x.IE_ID AND 
																		 s.Illustration_ID = x.Illustration_ID AND 
																		 s.Graphic_Number = x.Graphic_Number
			   WHERE x.IE_ID IS NULL AND 
					 x.Illustration_ID IS NULL AND 
					 x.Graphic_Number IS NULL --Inserted 
			   UNION ALL
			   SELECT 'Delete' AS Operation,x.Illustration_ID,x.IE_ID,x.Graphic_Number
			   FROM sis.IE_Illustration_Relation AS x
					LEFT OUTER JOIN sis_stage.IE_Illustration_Relation AS s ON s.IE_ID = x.IE_ID AND 
																			   s.Illustration_ID = x.Illustration_ID AND 
																			   s.Graphic_Number = x.Graphic_Number
			   WHERE s.IE_ID IS NULL --Deleted 
			   UNION ALL
			   SELECT 'Update' AS Operation,s.Illustration_ID,s.IE_ID,s.Graphic_Number
			   FROM sis_stage.IE_Illustration_Relation AS s
					INNER JOIN sis.IE_Illustration_Relation AS x ON s.IE_ID = x.IE_ID AND 
																	s.Illustration_ID = x.Illustration_ID AND 
																	s.Graphic_Number = x.Graphic_Number
			   WHERE NOT EXISTS --Updated
			   (
				   SELECT s.*
				   INTERSECT
				   SELECT x.*
			   );

		--Diff Load 
		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE_Illustration_Relation Diff Load',@@ROWCOUNT);

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