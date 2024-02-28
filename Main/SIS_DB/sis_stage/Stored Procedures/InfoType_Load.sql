/* ==================================================================================================================================================== 
Author:			Paul B. Felix (+Davide Moraschi)
Create date:	2018-01-31
Modify date:	2019-08-27 Copied from [sis_stage].[SMCS_Load] and renamed
Modify date:	2020-03-16 Removed natural Key InfoTypeID

-- Description: Full load [sis_stage].InfoType
-- Exec [sis_stage].[InfoType_Load]
====================================================================================================================================================== */
CREATE PROCEDURE [sis_stage].[InfoType_Load]
AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			DECLARE @ProcName  VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
				   ,@ProcessID UNIQUEIDENTIFIER = NEWID();

			EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

			-- static list of structured infotypes
			select * into #StructuredInfoType 
			from (values 
					(1, 'General Service Information'),
					(2, 'Schematic'),
					(3, 'Specifications'),
					(4, 'Systems Operation'),
					(6, 'Testing and Adjusting'),
					(7, 'Troubleshooting'),
					(8, 'Disassembly and Assembly'),
					(13, 'Operation and Maintenance Manual'),
					(30, 'Torque Specifications'),
					(36, 'Safety'),
					(56, 'Systems Operations - Fundamentals')
				) a (InfoType_ID, InfoType_Description)
								
			--Load InfoType 
			INSERT INTO sis_stage.InfoType (InfoType_ID, Is_Structured) 
				   SELECT INFOTYPEID, IIF(InfoType_ID is null, 0, 1) as Is_Structured
				   FROM SISWEB_OWNER.MASINFOTYPE mas
				   LEFT JOIN #StructuredInfoType structured ON structured.InfoType_ID = mas.INFOTYPEID
				   WHERE LANGUAGEINDICATOR = 'E'
				   AND INFOTYPEID NOT IN (SELECT [InfoTypeID] FROM [SISSEARCH].[REF_EXCLUDEINFOTYPE] where [Media] = 1 and [Search2_Status] = 1 and [Selective_Exclude] = 0)
				   ORDER BY INFOTYPEID;

			--select 'InfoType' Table_Name, @@RowCount Record_Count 
			EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'InfoType Load', @DATAVALUE = @@RowCount;

			--Load InfoType Translations
			INSERT INTO sis_stage.InfoType_Translation (InfoType_ID,Language_ID,Description) 
				   SELECT IT.INFOTYPEID,L.Language_ID,INFORMATIONTYPEDESC
				   FROM SISWEB_OWNER.MASINFOTYPE AS IT
						JOIN sis_stage.InfoType AS S ON IT.INFOTYPEID = S.InfoType_ID
						JOIN SISWEB_OWNER.MASLANGUAGE AS LANG ON LANG.LANGUAGEINDICATOR = IT.LANGUAGEINDICATOR
						JOIN sis_stage.Language AS L ON L.Legacy_Language_Indicator = LANG.LANGUAGEINDICATOR AND L.Default_Language = 1
				   ORDER BY IT.INFOTYPEID,L.Language_ID;

			--select 'InfoType_Translation' Table_Name, @@RowCount Record_Count   
			EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'InfoType_Translation Load', @DATAVALUE = @@RowCount;

			--Load Diff table 
			INSERT INTO sis_stage.InfoType_Translation_Diff (Operation,InfoType_ID,Language_ID,Description) 
				   SELECT 'Insert' AS Operation,s.InfoType_ID,s.Language_ID,s.Description
				   FROM sis_stage.InfoType_Translation AS s
						LEFT OUTER JOIN sis.InfoType_Translation AS x ON s.InfoType_ID = x.InfoType_ID AND 
																		 s.Language_ID = x.Language_ID
				   WHERE x.InfoType_ID IS NULL --Inserted 
				   UNION ALL
				   SELECT 'Delete' AS Operation,x.InfoType_ID,x.Language_ID,x.Description
				   FROM sis.InfoType_Translation AS x
						LEFT OUTER JOIN sis_stage.InfoType_Translation AS s ON s.InfoType_ID = x.InfoType_ID AND 
																			   s.Language_ID = x.Language_ID
				   WHERE s.InfoType_ID IS NULL --Deleted 
				   UNION ALL
				   SELECT 'Update' AS Operation,s.InfoType_ID,s.Language_ID,s.Description
				   FROM sis_stage.InfoType_Translation AS s
						INNER JOIN sis.InfoType_Translation AS x ON s.InfoType_ID = x.InfoType_ID AND 
																	s.Language_ID = x.Language_ID
				   WHERE NOT EXISTS --Updated
				   (
					   SELECT s.Description
					   INTERSECT
					   SELECT x.Description
				   );

			--Diff Load 
			EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'InfoType_Translation Diff Load', @DATAVALUE = @@RowCount;

			EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;
		END TRY
		BEGIN CATCH
	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
			@ERRORLINE INT= ERROR_LINE(),
			@LOGMESSAGE VARCHAR(MAX);

	SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
	EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;
		END CATCH;
	END;