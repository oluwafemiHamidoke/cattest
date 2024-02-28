-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180131
-- Modify Date: 20201118 Davide: util.udf_HTMLDecode SECTIONNAME as in: https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/8523/
-- Modify Date: 20201204 Davide: added Title column as in: https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/8798/
-- Modify Date: 20210122 Davide: split Media Sequence Translation query in two parts, see: https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/9477/
-- Modify Date: 20210202 Davide: added join to MEDIANUMBER, see: https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/9477/
-- Modify Date: 20210203 Davide: Refactored the MediaSequence_Translation, see: https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/9733/
-- Modify Date: 20210218 Davide: Increased NAme col in MediaSequence_Translation, see: https://dev.azure.com/sis-cat-com/sis2-ui/_workitems/edit/10148/
-- Description: Full load [sis_stage].Media
-- Modified By: Kishor Padmanabhan
-- Modified Date: 20220919
-- Modified Reason: Moved Part and OfParts column to MediaSequence from IEPart
-- Associated User Story: 21373
-- Modified Reason: Added LastModified_Date column to MediaSequence
-- Associated User Story: 22559
--Exec [sis_stage].Media_Load
/*
Truncate table [sis_stage].[sis_stage].[MediaSequence_Translation]
Truncate table [sis_stage].[sis_stage].[MediaSequence_Effectivity]
Delete from [sis_stage].[MediaSequence]
*/
-- =============================================
CREATE PROCEDURE [sis_stage].[Media_Load]
--(
--    -- Add the parameters for the stored procedure here
--    <@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>,
--    <@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
--)
AS
BEGIN 
    -- SET NOCOUNT ON added to prevent extra result sets from --Adding this to trigger commit.
    -- interfering with SELECT statements. 
    SET NOCOUNT ON 
 
BEGIN TRY 
 
Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID), 
@ProcessID uniqueidentifier = NewID()
		,@NULLID    INT              = 0;

 
 
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL; 
 
--=========================================================================================================================================================================
-- Loading Media
--=========================================================================================================================================================================
 
--Load Media 
Insert into [sis_stage].[Media] 
([Media_Number] 
,[Source] 
,[Safety_Document_Indicator] 
,[PIPPS_Number]
,[Termination_Date]
) 
SELECT   
 [BASEENGLISHMEDIANUMBER] --Media 
,max([MEDIASOURCE]) --Media 
,case max([SAFETYDOCUMENTINDICATOR]) when 'Y' then 1 else 0 end --Media 
,max([PIPPSPNUMBER]) --Media
,NULLIF(PWD.TERM_DT,'0001-01-01')
FROM [SISWEB_OWNER].[MASMEDIA] M
LEFT JOIN [PIS].[WHS_PIP_PSP_DESC] PWD ON M.[PIPPSPNUMBER] = 
CASE 	WHEN LEFT(PIP_PSP_NO,2)='95' THEN STUFF(PIP_PSP_NO,1,2,'PS')
		WHEN LEFT(PIP_PSP_NO,2)='94' THEN STUFF(PIP_PSP_NO,1,2,'PI')
END
Group By [BASEENGLISHMEDIANUMBER],PWD.TERM_DT
 
--select 'Media' Table_Name, @@RowCount Record_Count 
 
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Media Load', @DATAVALUE = @@RowCount;   

--Insert natural keys into key table 
Insert into [sis_stage].[Media_Key] (Media_Number) 
Select s.Media_Number 
From [sis_stage].[Media] s 
Left outer join [sis_stage].[Media_Key] k on s.Media_Number = k.Media_Number 
Where k.Media_ID is null 
 
--Key table load 
 
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Media Key Load', @DATAVALUE = @@RowCount; 
 
--Update stage table with surrogate keys from key table 
Update s 
Set Media_ID = k.Media_ID 
From [sis_stage].[Media] s 
inner join [sis_stage].[Media_Key] k on s.Media_Number = k.Media_Number 
where s.Media_ID is null 
 
--Surrogate Update 
 
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Media Update Surrogate', @DATAVALUE = @@RowCount; 
 
--=========================================================================================================================================================================
-- Loading Media Translation
--=========================================================================================================================================================================
 
Insert Into [sis_stage].[Media_Translation] 
( 
 [Media_ID] 
,[Language_ID] 
,[Media_Number] 
,[Title] 
,[Published_Date] 
,[Updated_Date] 
,[Revision_Number]
,[Media_Origin]
,[LastModified_Date]
 ) 
SELECT  
 m.Media_ID 
,l.Language_ID 
,max(mm.[MEDIANUMBER]) [MEDIANUMBER]  
,max(mm.[MEDIATITLE]) [MEDIATITLE] 
,max(mm.[PUBLISHEDDATE]) [PUBLISHEDDATE]  
,max(mm.[MEDIAUPDATEDDATE]) [MEDIAUPDATEDDATE] 
,max(cast(mm.[REVISIONNO] as int)) [REVISIONNO]
,max(mm.MEDIAORIGIN) MEDIAORIGIN
,max(mm.[LASTMODIFIEDDATE]) [LASTMODIFIED_DATE] 
FROM [SISWEB_OWNER].[MASMEDIA] mm 
inner join [sis_stage].[Media] m on mm.[BASEENGLISHMEDIANUMBER] = m.Media_Number 
inner join [SISWEB_OWNER].[MASLANGUAGE] ml on mm.[LANGUAGEINDICATOR] = ml.[LANGUAGEINDICATOR] 
inner join [sis_stage].[Language] l on l.Legacy_Language_Indicator = ml.LANGUAGEINDICATOR AND l.Default_Language = 1
Group by   
 m.Media_ID 
,l.Language_ID 
 
--select 'Media_Translation' Table_Name, @@RowCount Record_Count   
 
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Media_Translation Load', @DATAVALUE = @@RowCount; 

--=========================================================================================================================================================================
-- Loading Media Effectivity
--=========================================================================================================================================================================

Insert into [sis_stage].[Media_Effectivity] 
( 
[Media_ID] 
,[SerialNumberPrefix_ID] 
,[SerialNumberRange_ID] 
) 
SELECT Distinct 
m.[Media_ID] 
,snp.[SerialNumberPrefix_ID] 
,snr.[SerialNumberRange_ID] 
--,l.[MEDIANUMBER] 
--,l.[SNP] 
--,l.[BEGINNINGRANGE] 
--,l.[ENDRANGE] 
  FROM [SISWEB_OWNER].[LNKMEDIASNP] l 
  --From [SISWEB_OWNER].[LNKPARTSIESNP] l 
  inner join [sis_stage].[Media] m on l.[MEDIANUMBER] = m.[Media_Number] 
  inner join [sis_stage].[SerialNumberPrefix] snp on l.[SNP] = snp.[Serial_Number_Prefix] 
  inner join [sis_stage].[SerialNumberRange] snr on l.[BEGINNINGRANGE] = snr.[Start_Serial_Number] and l.[ENDRANGE] = snr.[End_Serial_Number] 
  --where l.INFOTYPEID = 5 --Parts 
  and TYPEINDICATOR = 'S' --Serial Effectivity --and SNP = '46P' 
 
--select 'Media_Effectivity' Table_Name, @@RowCount Record_Count   
 
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Media_Effectivity Load', @DATAVALUE = @@RowCount; 
--Delete from [sis_stage].[Media_Effectivity] 
 
--=========================================================================================================================================================================
-- Loading Media Section
--=========================================================================================================================================================================

Insert into [sis_stage].[MediaSection]  
( 
[Media_ID] 
,[Section_Number] 
) 
SELECT  Distinct 
m.[Media_ID] 
,l.SECTIONNUMBER 
--,[MEDIANUMBER] 
--,[SECTIONNUMBER] 
--,[SECTIONLANGUAGEINDICATOR] 
--,[SECTIONNAME] 
--,[SAFETYINDICATOR] 
  FROM [SISWEB_OWNER].[LNKMEDIASECTION] l 
  inner join [sis_stage].[Media] m on l.[MEDIANUMBER] = [Media_Number] 
 
--select 'MediaSection' Table_Name, @@RowCount Record_Count  
 
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'MediaSection Load', @DATAVALUE = @@RowCount; 
 
--Insert natural keys into key table 
Insert into [sis_stage].[MediaSection_Key] (Media_ID, Section_Number) 
Select s.Media_ID, s.Section_Number 
From [sis_stage].[MediaSection] s 
Left outer join [sis_stage].[MediaSection_Key] k on s.Media_ID = k.Media_ID and s.Section_Number = k.Section_Number 
Where k.[MediaSection_ID] is null 
 
--Key table load 
 
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'MediaSection Key Load', @DATAVALUE = @@RowCount; 
 
--Update stage table with surrogate keys from key table 
Update s 
Set [MediaSection_ID] = k.[MediaSection_ID] 
From [sis_stage].[MediaSection] s 
inner join [sis_stage].[MediaSection_Key] k on s.Media_ID = k.Media_ID and s.Section_Number = k.Section_Number 
where s.[MediaSection_ID] is null 
 
--Surrogate Update 
 
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'MediaSection Update Surrogate', @DATAVALUE = @@RowCount; 

--=========================================================================================================================================================================
-- Loading Media Translation
--=========================================================================================================================================================================

Insert into [sis_stage].[MediaSection_Translation] 
( 
 [MediaSection_ID] 
,[Language_ID] 
,[Name] 
) 
Select 
 pms.[MediaSection_ID] 
,ls.[Language_ID] 
,util.udf_HTMLDecode(l.[SECTIONNAME]) [SECTIONNAME] 
From [SISWEB_OWNER].[LNKMEDIASECTION] l 
Inner join [sis_stage].[Media] m on l.[MEDIANUMBER] = m.[Media_Number] 
Inner join [sis_stage].[MediaSection] pms on l.[SECTIONNUMBER] = [Section_Number] and pms.Media_ID = m.Media_ID 
Inner join [SISWEB_OWNER].[MASLANGUAGE] lg on l.[SECTIONLANGUAGEINDICATOR] = lg.[LANGUAGEINDICATOR] 
Inner join [sis_stage].[Language] ls on ls.Legacy_Language_Indicator = lg.LANGUAGEINDICATOR and ls.Default_Language=1 
 
--select 'MediaSection_Translation' Table_Name, @@RowCount Record_Count  
 
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'MediaSection_Translation Load', @DATAVALUE = @@RowCount; 

--=========================================================================================================================================================================
-- Loading Media Sequence
--=========================================================================================================================================================================

;with MediaSequenceCTE as  
(  
	SELECT Distinct 
		NULL AS [MediaSequence_ID] ,
		s.[MediaSection_ID] 
		,ie.IEPart_ID 
		,-1 IE_ID
		,l.[Sequence] 
		,l.SERVICEABILITYINDICATOR 
		,l.ARRANGEMENTINDICATOR 
		,l.TYPECHANGEINDICATOR
		,l.NPRINDICATOR
		,l.CCRINDICATOR
		,l.IESYSTEMCONTROLNUMBER
		,ISNULL(l.[PART], '1') [Part]
		,ISNULL(l.[OFPARTS], '1') [OFPARTS]
		,l.LASTMODIFIEDDATE
	FROM  
	( 
		Select *,  
		CASE
			WHEN IETYPE = 'L' THEN CASE BASEENGCONTROLNO
														WHEN '-' THEN IESYSTEMCONTROLNUMBER + '-' + MEDIANUMBER
														ELSE BASEENGCONTROLNO + '-' + MEDIANUMBER
														END
			ELSE CASE BASEENGCONTROLNO
					WHEN '-' THEN IESYSTEMCONTROLNUMBER
					ELSE BASEENGCONTROLNO
					END
		END BASEENGCONTROLNO_Mod  
		,case [BASEENGCONTROLNO]  
		when '-' then right(IESYSTEMCONTROLNUMBER,4) 
		else [IESEQUENCENUMBER]  
		end [Sequence] 
		from [SISWEB_OWNER].[LNKMEDIAIEPART] 
	) l 
	inner join [sis_stage].[Media] m on l.[MEDIANUMBER] = m.Media_Number 
	inner join [sis_stage].[MediaSection] s on l.[SECTIONNUMBER] = s.Section_Number and s.Media_ID = m.Media_ID 
	inner join [sis_stage].[IEPart] ie on l.BASEENGCONTROLNO_Mod = ie.Base_English_Control_Number -- and isnull(l.[PART], 1) = cast(ie.[Part] as varchar(50)) --There are non-numeric part values in source, but not in Authoring. 
)

INSERT INTO [sis_stage].[MediaSequence]
select A.* from  MediaSequenceCTE A
JOIN 
	(
		select [MediaSection_ID] ,
			[IEPart_ID] ,
			[Sequence], count(IESYSTEMCONTROLNUMBER) AS CNTA  from 
		MediaSequenceCTE
		GROUP BY      [MediaSection_ID] ,
			[IEPart_ID] ,
			[Sequence]
		HAVING COUNT(IESYSTEMCONTROLNUMBER)=1
	) B ON A.[MediaSection_ID] = B.[MediaSection_ID]
			AND A.[IEPart_ID]=B.[IEPart_ID]
			AND A.[Sequence]=B.[Sequence]
UNION
SELECT e.*
FROM  MediaSequenceCTE e
right join 
(
	select im.IESYSTEMCONTROLNUMBER,IR.IEPart_ID 
	from [sis].[Illustration] I
	left join [sis].[IEPart_Illustration_Relation] IR On IR.Illustration_ID = I.Illustration_ID
	JOIN [SISWEB_OWNER].[LNKIEIMAGE] im ON im.GRAPHICCONTROLNUMBER = I.Graphic_Control_Number
) I ON  e.IESYSTEMCONTROLNUMBER = I.IESYSTEMCONTROLNUMBER -- AND e.IEPart_ID=I.IEPart_ID 
	AND I.IESYSTEMCONTROLNUMBER IS NOT NULL
where  e.MediaSection_ID IS NOT NULL
UNION
SELECT Distinct 
	NULL, 
	s.[MediaSection_ID] 
	,-1 IEPart_ID 
	,i.IE_ID 
	,l.IETITLESEQNUMBER [Sequence] 
	,NULL SERVICEABILITYINDICATOR
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,'1'
	,'1'
	,NULL
FROM [SISWEB_OWNER].[LNKMEDIAIE] l
inner join [sis_stage].[Media] m on l.[MEDIANUMBER] = m.Media_Number 
inner join [sis_stage].[MediaSection] s on l.[SECTIONNUMBER] = s.Section_Number and s.Media_ID = m.Media_ID 
inner join [sis_stage].[IE] i on l.IESYSTEMCONTROLNUMBER = i.IESystemControlNumber
Option (force order)

 
--select 'MediaSequence' Table_Name, @@RowCount Record_Count  
 
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'MediaSequence Load', @DATAVALUE = @@RowCount; 
 
--Insert natural keys into key table 
Insert into [sis_stage].[MediaSequence_Key] ([MediaSection_ID], IEPart_ID, [IE_ID], Sequence_Number) 
Select s.[MediaSection_ID], s.IEPart_ID, s.IE_ID, s.Sequence_Number 
From [sis_stage].[MediaSequence] s 
Left outer join [sis_stage].[MediaSequence_Key] k on 
	s.[MediaSection_ID] = k.[MediaSection_ID] and 
	s.IEPart_ID = k.IEPart_ID and 
	s.IE_ID = k.IE_ID and 
	s.Sequence_Number = k.Sequence_Number 
Where k.[MediaSequence_ID] is null 
 
--Key table load 
 
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'MediaSequence Key Load', @DATAVALUE = @@RowCount; 
 
--Update stage table with surrogate keys from key table 
Update s 
Set [MediaSequence_ID] = k.[MediaSequence_ID] 
From [sis_stage].[MediaSequence] s 
inner join [sis_stage].[MediaSequence_Key] k on 
	s.[MediaSection_ID] = k.[MediaSection_ID] and 
	s.IEPart_ID = k.IEPart_ID and 
	s.IE_ID = k.IE_ID and 
	s.Sequence_Number = k.Sequence_Number 
where s.[MediaSequence_ID] is null 
 
--Surrogate Update 
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'MediaSequence Update Surrogate', @DATAVALUE = @@RowCount; 
 
--=========================================================================================================================================================================
-- Loading Media Sequence Translation
--=========================================================================================================================================================================

DROP TABLE IF EXISTS #LNKMEDIAIEPART;
DROP TABLE IF EXISTS #MediaSequence_Translation_01;
DECLARE @LANGUAGE_ID INT;
SELECT @LANGUAGE_ID = ls.Language_ID
  FROM sis_stage.Language AS ls
  WHERE
		ls.Legacy_Language_Indicator = 'E'
		AND ls.Default_Language = 1;

SELECT MEDIANUMBER
	  ,SECTIONNUMBER
	  ,CASE BASEENGCONTROLNO
		   WHEN '-' THEN RIGHT(IESYSTEMCONTROLNUMBER,4)
	   ELSE IESEQUENCENUMBER
	   END AS                           [Sequence]
	  ,LEFT(MAX(IEPARTMODIFIER),250) AS Modifier
	  ,LEFT(MAX(IECAPTION),4000) AS     Caption
INTO #LNKMEDIAIEPART
  FROM SISWEB_OWNER.LNKMEDIAIEPART
  GROUP BY MEDIANUMBER
		  ,SECTIONNUMBER
		  ,CASE BASEENGCONTROLNO
			   WHEN '-' THEN RIGHT(IESYSTEMCONTROLNUMBER,4)
		   ELSE IESEQUENCENUMBER
		   END;

CREATE CLUSTERED INDEX IX_LNKMEDIAIEPART ON #LNKMEDIAIEPART (MEDIANUMBER,SECTIONNUMBER,[Sequence]);

SELECT pmq.MediaSequence_ID
	  ,@LANGUAGE_ID AS Language_ID
	  ,Modifier
	  ,Caption
INTO #MediaSequence_Translation_01
  FROM #LNKMEDIAIEPART AS l
	   JOIN sis_stage.Media AS m ON l.MEDIANUMBER = m.Media_Number
	   JOIN sis_stage.MediaSection AS pms ON
											 l.SECTIONNUMBER = Section_Number
											 AND pms.Media_ID = m.Media_ID
	   JOIN sis_stage.MediaSequence AS pmq ON
											  pms.MediaSection_ID = pmq.MediaSection_ID
											  AND l.[Sequence] = pmq.Sequence_Number;

DROP TABLE IF EXISTS #LNKMEDIAIEPART;
DROP TABLE IF EXISTS #MediaSequence_Translation_02;

SELECT SEQ.MediaSequence_ID
	  ,Language_ID
	  ,IETITLE AS Title
INTO #MediaSequence_Translation_02
  FROM SISWEB_OWNER.LNKIETITLE AS l
	   JOIN sis_stage.IE AS IE ON IE.IESystemControlNumber = l.IESYSTEMCONTROLNUMBER
	   JOIN sis_stage.MediaSequence AS SEQ ON SEQ.IE_ID = IE.IE_ID
	   JOIN sis_stage.Language AS LAN ON
										 LAN.Legacy_Language_Indicator = IELANGUAGEINDICATOR
										 AND LAN.Default_Language = 1;

INSERT INTO sis_stage.MediaSequence_Translation
	   (MediaSequence_ID
	   ,Language_ID
	   ,Modifier
	   ,Caption
	   )
SELECT MediaSequence_ID
	  ,Language_ID
	  ,Modifier
	  ,Caption FROM #MediaSequence_Translation_01;

INSERT INTO sis_stage.MediaSequence_Translation
	   (MediaSequence_ID
	   ,Language_ID
	   ,Title
	   ) 
SELECT MediaSequence_ID
	  ,Language_ID
	  ,Title FROM #MediaSequence_Translation_02;

DROP TABLE IF EXISTS #MediaSequence_Translation_02;
DROP TABLE IF EXISTS #MediaSequence_Translation_01;
 
--select 'MediaSequence_Translation' Table_Name, @@RowCount Record_Count  
 
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'MediaSequence_Translation Load', @DATAVALUE = @@RowCount; 
 
--=========================================================================================================================================================================
-- Loading Media Sequence Effectivity
--=========================================================================================================================================================================

DROP TABLE IF EXISTS #MediaSequence_Effectivity_01;

SELECT IESYSTEMCONTROLNUMBER
	  ,MEDIANUMBER
	  ,SECTIONNUMBER
	  ,CASE
		   WHEN IETYPE = 'L' THEN CASE BASEENGCONTROLNO
									  WHEN '-' THEN IESYSTEMCONTROLNUMBER + '-' + MEDIANUMBER
								  ELSE BASEENGCONTROLNO + '-' + MEDIANUMBER
								  END
						 ELSE CASE BASEENGCONTROLNO
								  WHEN '-' THEN IESYSTEMCONTROLNUMBER
							  ELSE BASEENGCONTROLNO
							  END
	   END AS            BASEENGCONTROLNO_Mod
	  ,CASE BASEENGCONTROLNO
		   WHEN '-' THEN RIGHT(IESYSTEMCONTROLNUMBER,4)
			  ELSE IESEQUENCENUMBER
	   END AS            [Sequence]
INTO #MediaSequence_Effectivity_01
  FROM SISWEB_OWNER.LNKMEDIAIEPART;

CREATE NONCLUSTERED INDEX IX_MediaSequence_Effectivity_01 ON #MediaSequence_Effectivity_01 (BASEENGCONTROLNO_Mod) INCLUDE (IESYSTEMCONTROLNUMBER,MEDIANUMBER,SECTIONNUMBER);
--CREATE NONCLUSTERED INDEX IX_MediaSequence_IEPart_ID ON sis_stage.MediaSequence (IEPart_ID) INCLUDE (MediaSequence_ID);
--Parts Manual Sequence Effectivity (Part IE)
INSERT INTO sis_stage.MediaSequence_Effectivity 
	   (MediaSequence_ID
	   ,SerialNumberPrefix_ID
	   ,SerialNumberRange_ID
	   ,SerialNumberPrefix_Type
	   ) 
SELECT DISTINCT 
	   pmq.MediaSequence_ID
	  ,ssnp.SerialNumberPrefix_ID
	  ,ssnr.SerialNumberRange_ID
	  ,snp.SNPTYPE
--,m.Media_Number 
  FROM #MediaSequence_Effectivity_01 AS l
	   INNER JOIN SISWEB_OWNER.LNKPARTSIESNP AS snp ON l.IESYSTEMCONTROLNUMBER = snp.IESYSTEMCONTROLNUMBER
	   INNER JOIN sis_stage.SerialNumberPrefix AS ssnp ON ssnp.Serial_Number_Prefix = snp.SNP
	   INNER JOIN sis_stage.SerialNumberRange AS ssnr ON
														 ssnr.Start_Serial_Number = snp.BEGINNINGRANGE
														 AND ssnr.End_Serial_Number = snp.ENDRANGE
	   INNER JOIN sis_stage.Media AS m ON l.MEDIANUMBER = m.Media_Number
	   INNER JOIN sis_stage.MediaSection AS s ON
												 l.SECTIONNUMBER = s.Section_Number
												 AND s.Media_ID = m.Media_ID
	   INNER JOIN sis_stage.IEPart AS ie ON
											l.BASEENGCONTROLNO_Mod = ie.Base_English_Control_Number
											--AND l.PART = ie.Part
	   INNER JOIN sis_stage.MediaSequence AS pmq ON
													pmq.MediaSection_ID = s.MediaSection_ID
													AND ie.IEPart_ID = pmq.IEPart_ID
													AND l.IESYSTEMCONTROLNUMBER = pmq.IESYSTEMCONTROLNUMBER;
--Option (force order) 

DROP TABLE IF EXISTS #MediaSequence_Effectivity_01;
 
--Parts Manual Sequence Effectivity (Service IE)
INSERT INTO sis_stage.MediaSequence_Effectivity 
	   (MediaSequence_ID
	   ,SerialNumberPrefix_ID
	   ,SerialNumberRange_ID
	   ) 
SELECT DISTINCT 
	   pmq.MediaSequence_ID
	  ,ssnp.SerialNumberPrefix_ID
	  ,ssnr.SerialNumberRange_ID
  FROM SISWEB_OWNER.LNKMEDIAIE AS l
	   INNER JOIN SISWEB_OWNER.LNKIESNP AS snp ON
												  l.IESYSTEMCONTROLNUMBER = snp.IESYSTEMCONTROLNUMBER
												  AND l.MEDIANUMBER = snp.MEDIANUMBER
	   INNER JOIN sis_stage.SerialNumberPrefix AS ssnp ON ssnp.Serial_Number_Prefix = snp.SNP
	   INNER JOIN sis_stage.SerialNumberRange AS ssnr ON
														 ssnr.Start_Serial_Number = snp.BEGINNINGRANGE
														 AND ssnr.End_Serial_Number = snp.ENDRANGE
	   INNER JOIN sis_stage.Media AS m ON l.MEDIANUMBER = m.Media_Number
	   INNER JOIN sis_stage.MediaSection AS s ON
												 l.SECTIONNUMBER = s.Section_Number
												 AND s.Media_ID = m.Media_ID
	   INNER JOIN sis_stage.IE AS ie ON l.IESYSTEMCONTROLNUMBER = ie.IESystemControlNumber
	   INNER JOIN sis_stage.MediaSequence AS pmq ON
													pmq.MediaSection_ID = s.MediaSection_ID
													AND ie.IE_ID = pmq.IE_ID;

--select 'MediaSequence_Effectivity' Table_Name, @@RowCount Record_Count  
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'MediaSequence_Effectivity Load', @DATAVALUE = @@RowCount; 
 
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL; 
 
END TRY 
 
BEGIN CATCH  
 
	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(), 
			@ERRORLINE INT= ERROR_LINE(),
			@LOGMESSAGE VARCHAR(MAX);

	SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
	EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;

	-- Raise Error of level at least 16 so that the current sproc and any calling sproc fails with appropriate error
	RAISERROR ('Sproc [Media_Load] Failure', 16, 1) WITH NOWAIT;
 
END CATCH 
 
END
GO


