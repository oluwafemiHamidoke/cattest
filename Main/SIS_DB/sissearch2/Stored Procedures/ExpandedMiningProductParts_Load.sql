CREATE Procedure [sissearch2].[ExpandedMiningProductParts_Load]
As
/*---------------
Date: 05-10-2022
Object Description:  Loading changed data into sissearch2.ExpandedMiningProductParts from base tables
Exec [sissearch2].[ExpandedMiningProductParts_Load]
Truncate table [sissearch2].[ExpandedMiningProductParts_Load]
---------------*/

Begin

BEGIN TRY
SET NOCOUNT ON

Declare @LastInsertDate Datetime
Declare @SPStartTime DATETIME,
		@StepStartTime DATETIME,
		@ProcName VARCHAR(200),
		@SPStartLogID BIGINT,
		@StepLogID BIGINT,
		@RowCount BIGINT,
		@LAPSETIME BIGINT

SET @SPStartTime= GETDATE()
SET @ProcName= OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)

--Identify Deleted Records From Source

EXEC @SPStartLogID = sissearch2.WriteLog @TIME = @SPStartTime, @NAMEOFSPROC = @ProcName;
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#DeletedRecords') is not null
  Begin
    Drop table #DeletedRecords
  End

Select Distinct IESystemControlNumber
into #DeletedRecords
From [sissearch2].[ExpandedMiningProductParts]
Except
Select MS.IESystemControlNumber
FROM [sis_shadow].[MediaSequence] MS
inner join [sis].[IEPart] IP on IP.IEPart_ID = MS.IEPart_ID

--This is created for checking non existing External PDF in EMP_STAGING partspdf and deleting that from EXPANDEDMININGPRODUCTPARTS
If Object_ID('Tempdb..#DeletedRecordsExternalPDF') is not null
  Begin
    Drop table #DeletedRecordsExternalPDF
  End

Select Distinct ID
into #DeletedRecordsExternalPDF
From [sissearch2].[ExpandedMiningProductParts] where isMedia = 1
Except
Select PARTSPDF_ID
From [SISWEB_OWNER_SHADOW].[PARTSPDF]

SET @RowCount = @@RowCount
--  Print cast (getdate() as varchar (50)) + ' - Deleted Records Detected Count: ' + cast (@RowCount as varchar (50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Records Detected', @DATAVALUE = @RowCount, @LOGID = @StepLogID

-- Delete Idenified Deleted Records in Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete From [sissearch2].[ExpandedMiningProductParts]
Where IESystemControlNumber Is Not Null
AND IESystemControlNumber  IN (Select IESystemControlNumber From #DeletedRecords)

Delete From [sissearch2].[ExpandedMiningProductParts]
Where isMedia = 1 AND ID in (Select ID From #DeletedRecordsExternalPDF)

SET @RowCount = @@RowCount
--	Print cast (getdate() as varchar (50)) + ' - Deleted Records from Target Count: ' + cast (@RowCount as varchar (50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Records from Target [sissearch2].[ExpandedMiningProductParts]', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--Get Maximum insert date from Target
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select @LastInsertDate = coalesce(Max(InsertDate), '1900-01-01')
From [sissearch2].[ExpandedMiningProductParts]
    --Print cast (getdate() as varchar (50)) + ' - Latest Insert Date in Target: ' + cast (@LastInsertDate as varchar (50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
Declare @Logmessage as varchar(50) = 'Latest Insert Date in Target '+cast (@LastInsertDate as varchar(25))
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = @Logmessage , @LOGID = @StepLogID

--Identify Inserted records from Source

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

--Query for InsertRecord
If Object_ID('Tempdb..#InsertRecords') is not null
Begin
    Drop table #InsertRecords
End

Select Distinct MS.IESystemControlNumber,
CASE WHEN MS.LastModified_Date > IP.LastModified_Date THEN MS.LastModified_Date
ELSE IP.LastModified_Date END AS LastModified_Date	
into #InsertRecords
FROM [sis_shadow].[MediaSequence] MS
INNER JOIN [sis].[IEPart] IP ON IP.IEPart_ID = MS.IEPart_ID
WHERE MS.LastModified_Date > @LastInsertDate OR IP.LastModified_Date > @LastInsertDate

-- This need to ask scott how can I track new records
If Object_ID('Tempdb..#InsertRecordsExternalPDF') is not null
Begin
    Drop table #InsertRecordsExternalPDF
End

Select PARTSPDF_ID
into #InsertRecordsExternalPDF
from SISWEB_OWNER_SHADOW.PARTSPDF
where LASTMODIFIEDDATE > @LastInsertDate;

SET @RowCount = @@RowCount
--	Print cast (getdate() as varchar (50)) + ' - Inserted Records Detected Count: ' + cast (@RowCount as varchar (50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Detected into  #InsertRecords', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_IESystemControlNumber ON #InsertRecords(IESystemControlNumber)

--Delete Inserted records from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete From [sissearch2].[ExpandedMiningProductParts]
Where IESystemControlNumber in (Select IESystemControlNumber from #InsertRecords)

Delete From [sissearch2].[ExpandedMiningProductParts]
Where isMedia = 1 and ID in (Select PARTSPDF_ID from #InsertRecordsExternalPDF)

SET @RowCount = @@RowCount
--	Print cast (getdate() as varchar (50)) + ' - Deleted Inserted Records from Target Count: ' + cast (@RowCount as varchar (50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Inserted Records from [sissearch2].[ExpandedMiningProductParts]', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

--Load Basic Parts data that's specific to EMP

DROP TABLE IF EXISTS #EMPBasicParts;
Select
    x.[IESystemControlNumber]
    , x.[InformationType]
    , x.[MediaNumber]
    , x.IEUpdateDate
    , x.IEPart
    , x.IEPartnumber
    , x.[PartsManualMediaNumber]
    , x.[IECaption]
    , x.[InsertDate]
    , x.[PubDate]
    , 0 [isMedia]
	, x.ControlNumber
    , x.[MediaOrigin]
	, x.[OrgCode]
into #EMPBasicParts
From
    (
    select distinct
    MS.IESystemControlNumber as IESystemControlNumber,
    '[''5'']' As InformationType, -- Information type for EMP parts
    coalesce ('['+'"'+replace(    --escape /
    replace(                      --escape "
    replace(                      --replace carriage return (ascii 13)
    replace(                      --replace form feed (ascii 12)
    replace(                      --replace vertical tab (ascii 11)
    replace(                      --replace line feed (ascii 10)
    replace(                      --replace horizontal tab (ascii 09)
    replace(                      --replace backspace (ascii 08)
    replace(                      --escape \
    M.Media_Number
        , '\', '\\')
        , char (8), ' ')
        , char (9), ' ')
        , char (10), ' ')
        , char (11), ' ')
        , char (12), ' ')
        , char (13), ' ')
        , '"', '\"')
        , '/', '\/')+'"'+']', '') as MediaNumber,
    isnull(IP.Update_Date, '1900-01-01') as IEUpdateDate,
    replace(                      --escape /
    replace(                      --escape "
    replace(                      --replace carriage return (ascii 13)
    replace(                      --replace form feed (ascii 12)
    replace(                      --replace vertical tab (ascii 11)
    replace(                      --replace line feed (ascii 10)
    replace(                      --replace horizontal tab (ascii 09)
    replace(                      --replace backspace (ascii 08)
    replace(                      --escape \
    isnull(P.Part_Number, '')+':'+isnull(PT.Part_Name, '') +
    iif(isnull(MST.Modifier, '') != '', ' '+MST.Modifier, '')
        , '\', '\\')
        , char (8), ' ')
        , char (9), ' ')
        , char (10), ' ')
        , char (11), ' ')
        , char (12), ' ')
        , char (13), ' ')
        , '"', '\"')
        , '/', '\/') as IEPart,
    P.Part_Number as IEPartnumber,
    coalesce ('['+'"'+replace(    --escape /
    replace(                      --escape "
    replace(                      --replace carriage return (ascii 13)
    replace(                      --replace form feed (ascii 12)
    replace(                      --replace vertical tab (ascii 11)
    replace(                      --replace line feed (ascii 10)
    replace(                      --replace horizontal tab (ascii 09)
    replace(                      --replace backspace (ascii 08)
    replace(                      --escape \
    M.Media_Number
        , '\', '\\')
        , char (8), ' ')
        , char (9), ' ')
        , char (10), ' ')
        , char (11), ' ')
        , char (12), ' ')
        , char (13), ' ')
        , '"', '\"')
        , '/', '\/')+'"'+']', '') as PartsManualMediaNumber
        , Replace(
    Replace(
    Replace(
    Replace(
    Replace(
    Replace(
    Replace(
    Replace(
    Replace(
    Replace(
    Replace(
    Replace(
    Replace(
    Replace(
    MST.Caption
        , '<I>', ' ')
        , '</I>', ' ')
        , '<BR>', ' ')
        , '<TABLE BORDER=0>', ' ')
        , '<TR>', ' ')
        , '<TD COLSPAN=3 ALIGN=CENTER>', ' ')
        , '</TABLE>', ' ')
        , '<B>', ' ')
        , '</B>', ' ')
        , '<TD>', ' ')
        , '</TD>', ' ')
        , '<TR>', ' ')
        , '</TR>', ' ')
        , '@@@@@', ' ') As IECaption
        , IR.LastModified_Date As InsertDate
        , row_number() over (Partition by cast (MS.IESystemControlNumber as VARCHAR) order by isnull(IP.Update_Date, '1900-01-01') desc, MS.IESystemControlNumber desc) RowRank
        , IP.Publish_Date as [PubDate]
        , case when len(trim (IP.IE_Control_Number)) = 0 then null else
    coalesce ('['+'"'+replace(    --escape /
    replace(                      --escape "
    replace(                      --replace carriage return (ascii 13)
    replace(                      --replace form feed (ascii 12)
    replace(                      --replace vertical tab (ascii 11)
    replace(                      --replace line feed (ascii 10)
    replace(                      --replace horizontal tab (ascii 09)
    replace(                      --replace backspace (ascii 08)
    replace(                      --escape \
    IP.IE_Control_Number
        , '\', '\\')
        , char (8), ' ')
        , char (9), ' ')
        , char (10), ' ')
        , char (11), ' ')
        , char (12), ' ')
        , char (13), ' ')
        , '"', '\"')
        , '/', '\/')+'"'+']', '')
    end as ControlNumber,
    MT.Media_Origin [MediaOrigin],
    coalesce (P.Org_Code, '') [OrgCode]
    From [sis_shadow].[MediaSequence] MS
    inner join [sis].[IEPart] IP on IP.IEPart_ID = MS.IEPart_ID
    inner join #InsertRecords IR on IR.IESystemControlNumber = MS.IESystemControlNumber
    inner join [sis].[MediaSection] MSec on MSec.MediaSection_ID = MS.MediaSection_ID
    inner join [sis].[Media] M on M.Media_ID = MSec.Media_ID and M.Source = 'N'
    inner join [sis].[Media_Translation] MT on MT.Media_ID = M.Media_ID and MT.Media_Origin = 'EM'
    left outer join [sis].[Part] P on P.Part_ID = IP.Part_ID and P.Org_Code is not null
    left outer join [sis].[Part_Translation] PT on PT.Part_ID = P.Part_ID AND PT.Language_ID = 38 -- english 
    left outer join [sis].[MediaSequence_Translation] MST on MST.MediaSequence_ID = MS.MediaSequence_ID
    left outer join [sis].[Language] L on L.Language_ID = MST.Language_ID and L.Legacy_Language_Indicator = 'E'
    ) x where x.RowRank = 1

-- This is for adding external PDF

DROP TABLE IF EXISTS #EMPExternalPDF;
Select
    x.[PARTSPDFID]
    , x.[InformationType]
    , x.[MediaNumber]
    , x.[IEUpdateDate]
    , x.[IEPart]
    , x.[PartsManualMediaNumber]
    , x.[InsertDate]
    , 1 [isMedia]
    , x.[MediaOrigin]
    , x.[OrgCode]
into #EMPExternalPDF
From
    (
    select distinct
    b.PARTSPDF_ID as PARTSPDFID,
    '[''5'']' As InformationType, -- Information type for EMP parts
    coalesce ('['+'"'+replace(    --escape /
    replace(                      --escape "
    replace(                      --replace carriage return (ascii 13)
    replace(                      --replace form feed (ascii 12)
    replace(                      --replace vertical tab (ascii 11)
    replace(                      --replace line feed (ascii 10)
    replace(                      --replace horizontal tab (ascii 09)
    replace(                      --replace backspace (ascii 08)
    replace(                      --escape \
    d.MediaNumber
        , '\', '\\')
        , char (8), ' ')
        , char (9), ' ')
        , char (10), ' ')
        , char (11), ' ')
        , char (12), ' ')
        , char (13), ' ')
        , '"', '\"')
        , '/', '\/')+'"'+']', '') as MediaNumber,
    '1900-01-01' as IEUpdateDate,
    d.PDFFILENAME as IEPart,
    coalesce ('['+'"'+replace(    --escape /
    replace(                      --escape "
    replace(                      --replace carriage return (ascii 13)
    replace(                      --replace form feed (ascii 12)
    replace(                      --replace vertical tab (ascii 11)
    replace(                      --replace line feed (ascii 10)
    replace(                      --replace horizontal tab (ascii 09)
    replace(                      --replace backspace (ascii 08)
    replace(                      --escape \
    d.MediaNumber
        , '\', '\\')
        , char (8), ' ')
        , char (9), ' ')
        , char (10), ' ')
        , char (11), ' ')
        , char (12), ' ')
        , char (13), ' ')
        , '"', '\"')
        , '/', '\/')+'"'+']', '') as PartsManualMediaNumber
        , d.LASTMODIFIEDDATE InsertDate
        , MT.Media_Origin [MediaOrigin],
    'CAT' As OrgCode
    from [SISWEB_OWNER_SHADOW].LNKPARTSPDFPSID b
    inner join #InsertRecordsExternalPDF c on c.PARTSPDF_ID = b.PARTSPDF_ID --Add filter to limit to changed records
    left outer join [SISWEB_OWNER_SHADOW].PARTSPDF d on b.PARTSPDF_ID = d.PARTSPDF_ID and d.LANGUAGEINDICATOR = 'E'
    inner join [sis].[Media] M ON M.Media_Number = d.MediaNumber AND M.Source = 'N'
    inner join [sis].[Media_Translation] MT on MT.Media_ID = M.Media_ID And MT.Media_Origin = 'EM'
    ) x

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_EMPExternalPDF_id ON #EMPExternalPDF(PARTSPDFID)

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_EMPBasicParts_IESystemControlNumber ON #EMPBasicParts(IESystemControlNumber)

/*---------------
Metrics calculated on SB2 Database:
 lnkieproductinstance distinct 1,124,639 ( ~16 Seconds)
 lnkieproductinstance + lnkmediaIEPart + lnkiedate + MASMEDIA Distinct 1,124,639 ( ~46 Seconds )
 Total 1 Min
End of EMP Basic Parts load
---------------*/

--Load Consist Parts data that's specific to EMP

DROP TABLE IF EXISTS #EMPConsistParts;
DROP TABLE IF EXISTS #PreEMPConsistParts;
DROP TABLE IF EXISTS #CPRecordsToString;

SELECT MS.IESystemControlNumber
     , IR.LastModified_Date AS InsertDate
     , P.Part_Number AS PARTNUMBER
     , PIRT.Part_IEPart_Name AS PARTNAME
     , PIRT.Part_IEPart_Modifier AS PARTMODIFIER
     , PT.Part_Name AS TRANSLATEDPARTNAME
     , L.Legacy_Language_Indicator AS LANGUAGEINDICATOR
INTO #CPRecordsToString
FROM [sis_shadow].[MediaSequence] AS MS
    inner join #InsertRecords IR ON IR.IESystemControlNumber = MS.IESystemControlNumber
    inner join [sis].[MediaSection] MSec ON MSec.MediaSection_ID = MS.MediaSection_ID
    inner join [sis].[Media] M ON M.Media_ID = MSec.Media_ID AND M.Source='N'
    inner join [sis].[Media_Translation] MT on MT.Media_ID = M.Media_ID And MT.Media_Origin = 'EM'
    inner join [sis].[Part_IEPart_Relation] PIR ON PIR.IEPart_ID = MS.IEPart_ID
    inner join [sis].[Part] P ON P.Part_ID = PIR.Part_ID
    inner join [sis].[Part_IEPart_Relation_Translation] PIRT ON PIRT.Part_IEPart_Relation_ID = PIR.Part_IEPart_Relation_ID
    inner join [sis].[Part_Translation] PT ON PT.Part_ID = PIR.Part_ID
    inner join [sis].[Language] L ON L.Language_ID = PT.Language_ID

SELECT IESystemControlNumber
     , InsertDate
     , replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(ISNULL(PARTNUMBER,'') + ':' + ISNULL(PARTNAME,'') + IIF(ISNULL(PARTMODIFIER,'') != '',' ' + PARTMODIFIER,''),'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'. ', ' '),'"','\"'),'/','\/') AS ConsistPart
     , replace(replace(replace(replace(replace(replace(replace(replace(replace([8],'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                          [ConsistPartNames_id-ID]
	  , replace(replace(replace(replace(replace(replace(replace(replace(replace(C,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [ConsistPartNames_zh-CN]
	  , replace(replace(replace(replace(replace(replace(replace(replace(replace(F,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [ConsistPartNames_fr-FR]
	  , replace(replace(replace(replace(replace(replace(replace(replace(replace(G,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [ConsistPartNames_de-DE]
	  , replace(replace(replace(replace(replace(replace(replace(replace(replace(L,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [ConsistPartNames_it-IT]
	  , replace(replace(replace(replace(replace(replace(replace(replace(replace(P,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [ConsistPartNames_pt-BR]
	  , replace(replace(replace(replace(replace(replace(replace(replace(replace(S,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [ConsistPartNames_es-ES]
	  , replace(replace(replace(replace(replace(replace(replace(replace(replace(R,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [ConsistPartNames_ru-RU]
	  , replace(replace(replace(replace(replace(replace(replace(replace(replace(J,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [ConsistPartNames_ja-JP]
INTO #PreEMPConsistParts
FROM #CPRecordsToString
PIVOT(MAX(TRANSLATEDPARTNAME) FOR LANGUAGEINDICATOR IN([8], C, F, G, L, P, S, R, J)) AS pvt;

DROP TABLE IF EXISTS #CPRecordsToString;

SELECT
    a.[IESystemControlNumber],
    COALESCE('["' + STRING_AGG(CAST(ConsistPart AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY ConsistPart) + '"]','') AS ConsistPart,
    COALESCE('["' + STRING_AGG(CAST([ConsistPartNames_id-ID] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY ConsistPart) + '"]','') AS [ConsistPartNames_id-ID],
	COALESCE('["' + STRING_AGG(CAST([ConsistPartNames_zh-CN] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY ConsistPart) + '"]','') AS [ConsistPartNames_zh-CN],
	COALESCE('["' + STRING_AGG(CAST([ConsistPartNames_fr-FR] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY ConsistPart) + '"]','') AS [ConsistPartNames_fr-FR],
	COALESCE('["' + STRING_AGG(CAST([ConsistPartNames_de-DE] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY ConsistPart) + '"]','') AS [ConsistPartNames_de-DE],
	COALESCE('["' + STRING_AGG(CAST([ConsistPartNames_it-IT] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY ConsistPart) + '"]','') AS [ConsistPartNames_it-IT],
	COALESCE('["' + STRING_AGG(CAST([ConsistPartNames_pt-BR] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY ConsistPart) + '"]','') AS [ConsistPartNames_pt-BR],
	COALESCE('["' + STRING_AGG(CAST([ConsistPartNames_es-ES] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY ConsistPart) + '"]','') AS [ConsistPartNames_es-ES],
	COALESCE('["' + STRING_AGG(CAST([ConsistPartNames_ru-RU] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY ConsistPart) + '"]','') AS [ConsistPartNames_ru-RU],
	COALESCE('["' + STRING_AGG(CAST([ConsistPartNames_ja-JP] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY ConsistPart) + '"]','') AS [ConsistPartNames_ja-JP],
	min(a.[InsertDate]) InsertDate
--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
Into #EMPConsistParts
FROM #PreEMPConsistParts a
GROUP BY a.IESystemControlNumber

DROP TABLE IF EXISTS #PreEMPConsistParts;

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_EMPConsistParts_IESystemControlNumber
    ON #EMPConsistParts(IESystemControlNumber)

/*---------------
Metrics calculated on SB2 Database:
 #CPRecordsToString insert 7,640,804  ( ~12 Seconds)
 #PreEMPConsistParts insert 1,872,814  ( ~1.14 Min )
 #EMPConsistParts insert (pivot + translations) on  114,368   ( ~1.30 Min )
 Total (Basic Parts + Consist Parts) ~2.46 Min
End of EMP Consist Parts load
---------------*/

--Load Product Hierarchy data that's specific to EMP parts

DROP TABLE IF EXISTS #EMPProductHierarchy;
DROP TABLE IF EXISTS #EMPProductHierarchyPDF;
DROP TABLE IF EXISTS #PreEMPProductHierarchy;
DROP TABLE IF EXISTS #PHRecordsToString;
DROP TABLE IF EXISTS #PHRecordsToString_FM
DROP TABLE IF EXISTS #PHRecordsToStringPDF;
DROP TABLE IF EXISTS #PHRecordsToStringPDF_FM;
DROP TABLE IF EXISTS #PHRecordsToStringResult
DROP TABLE IF EXISTS #PHRecordsToStringResult_SF
DROP TABLE IF EXISTS #PHRecordsToStringResultPDF
DROP TABLE IF EXISTS #PHRecordsToStringResultPDF_SF
DROP TABLE IF EXISTS #PHRecordsToString_SF
DROP TABLE IF EXISTS #PHRecordsToString_SNP
DROP TABLE IF EXISTS #PHRecordsToStringResult_SNP
DROP TABLE IF EXISTS #PHRecordsToStringPDF_SF
DROP TABLE IF EXISTS #PHRecordsToStringPDF_SNP
DROP TABLE IF EXISTS #PHRecordsToStringResultPDF_SNP

CREATE TABLE #EMPProductHierarchy
(
    [IESystemControlNumber] VARCHAR (50) NOT NULL,
    [familyCode] VARCHAR (MAX) NULL,
    [familySubFamilyCode] VARCHAR (MAX) NULL,
    [familySubFamilySalesModel] VARCHAR (MAX) NULL,
    [familySubFamilySalesModelSNP] VARCHAR (MAX) NULL,
    [InsertDate] DATETIME NOT NULL,
    PRIMARY KEY CLUSTERED ([IESystemControlNumber] ASC)
    );

Select
    MS.IESystemControlNumber,
    replace( --escape /
            replace( --escape "
                    replace( --replace carriage return (ascii 13)
                            replace( --replace form feed (ascii 12)
                                    replace( --replace vertical tab (ascii 11)
                                            replace( --replace line feed (ascii 10)
                                                    replace( --replace horizontal tab (ascii 09)
                                                            replace( --replace backspace (ascii 08)
                                                                    replace( --escape \
                                                                            isnull(c.Family_Code,'')
                                                                        ,'\', '\\')
                                                                ,char(8), ' ')
                                                        ,char(9), ' ')
                                                ,char(10), ' ')
                                        ,char(11), ' ')
                                ,char(12), ' ')
                        ,char(13), ' ')
                ,'"', '\"')
        ,'/', '\/') as Family_Code,
    replace( --escape /
            replace( --escape "
                    replace( --replace carriage return (ascii 13)
                            replace( --replace form feed (ascii 12)
                                    replace( --replace vertical tab (ascii 11)
                                            replace( --replace line feed (ascii 10)
                                                    replace( --replace horizontal tab (ascii 09)
                                                            replace( --replace backspace (ascii 08)
                                                                    replace( --escape \
                                                                            isnull(c.Subfamily_Code,'')
                                                                        ,'\', '\\')
                                                                ,char(8), ' ')
                                                        ,char(9), ' ')
                                                ,char(10), ' ')
                                        ,char(11), ' ')
                                ,char(12), ' ')
                        ,char(13), ' ')
                ,'"', '\"')
        ,'/', '\/') as Subfamily_Code,
    replace( --escape /
            replace( --escape "
                    replace( --replace carriage return (ascii 13)
                            replace( --replace form feed (ascii 12)
                                    replace( --replace vertical tab (ascii 11)
                                            replace( --replace line feed (ascii 10)
                                                    replace( --replace horizontal tab (ascii 09)
                                                            replace( --replace backspace (ascii 08)
                                                                    replace( --escape \
                                                                            isnull(b.Model,'')
                                                                        ,'\', '\\')
                                                                ,char(8), ' ')
                                                        ,char(9), ' ')
                                                ,char(10), ' ')
                                        ,char(11), ' ')
                                ,char(12), ' ')
                        ,char(13), ' ')
                ,'"', '\"')
        ,'/', '\/') as Sales_Model,
    replace( --escape /
            replace( --escape "
                    replace( --replace carriage return (ascii 13)
                            replace( --replace form feed (ascii 12)
                                    replace( --replace vertical tab (ascii 11)
                                            replace( --replace line feed (ascii 10)
                                                    replace( --replace horizontal tab (ascii 09)
                                                            replace( --replace backspace (ascii 08)
                                                                    replace( --escape \
                                                                            isnull(b.SNP,'')
                                                                        ,'\', '\\')
                                                                ,char(8), ' ')
                                                        ,char(9), ' ')
                                                ,char(10), ' ')
                                        ,char(11), ' ')
                                ,char(12), ' ')
                        ,char(13), ' ')
                ,'"', '\"')
        ,'/', '\/') as Serial_Number_Prefix,
    IR.LastModified_Date InsertDate
into #PHRecordsToString
From SISWEB_OWNER_SHADOW.LNKIEPRODUCTINSTANCE a
inner join SISWEB_OWNER_SHADOW.EMPPRODUCTINSTANCE b on a.EMPPRODUCTINSTANCE_ID = b.EMPPRODUCTINSTANCE_ID
inner join sis.vw_Product c on b.SNP=c.Serial_Number_Prefix
inner join [sis_shadow].[MediaSequence] AS MS ON MS.IESystemControlNumber = a.IESystemControlNumber
inner join #InsertRecords IR ON IR.IESystemControlNumber = MS.IESystemControlNumber
inner join [sis].[MediaSection] MSec ON MSec.MediaSection_ID = MS.MediaSection_ID
inner join [sis].[Media] M ON M.Media_ID = MSec.Media_ID AND M.Source = 'N'
inner join [sis].[Media_Translation] MT on MT.Media_ID = M.Media_ID And MT.Media_Origin = 'EM'

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_PHRecordsToString_IESystemControlNumber]
ON #PHRecordsToString (IESystemControlNumber ASC)
INCLUDE (Family_Code, Subfamily_Code, Sales_Model, Serial_Number_Prefix, InsertDate)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

CREATE TABLE #EMPProductHierarchyPDF
(
    [PARTSPDFID] VARCHAR (50) NOT NULL,
    [familyCode] VARCHAR (MAX) NULL,
    [familySubFamilyCode] VARCHAR (MAX) NULL,
    [familySubFamilySalesModel] VARCHAR (MAX) NULL,
    [familySubFamilySalesModelSNP] VARCHAR (MAX) NULL,
    [InsertDate] DATETIME NOT NULL,
    PRIMARY KEY CLUSTERED ([PARTSPDFID] ASC)
 );

Select
    a.PARTSPDF_ID as PARTSPDFID,
    replace( --escape /
            replace( --escape "
                    replace( --replace carriage return (ascii 13)
                            replace( --replace form feed (ascii 12)
                                    replace( --replace vertical tab (ascii 11)
                                            replace( --replace line feed (ascii 10)
                                                    replace( --replace horizontal tab (ascii 09)
                                                            replace( --replace backspace (ascii 08)
                                                                    replace( --escape \
                                                                            isnull(c.Family_Code,'')
                                                                        ,'\', '\\')
                                                                ,char(8), ' ')
                                                        ,char(9), ' ')
                                                ,char(10), ' ')
                                        ,char(11), ' ')
                                ,char(12), ' ')
                        ,char(13), ' ')
                ,'"', '\"')
        ,'/', '\/') as Family_Code,
    replace( --escape /
            replace( --escape "
                    replace( --replace carriage return (ascii 13)
                            replace( --replace form feed (ascii 12)
                                    replace( --replace vertical tab (ascii 11)
                                            replace( --replace line feed (ascii 10)
                                                    replace( --replace horizontal tab (ascii 09)
                                                            replace( --replace backspace (ascii 08)
                                                                    replace( --escape \
                                                                            isnull(c.Subfamily_Code,'')
                                                                        ,'\', '\\')
                                                                ,char(8), ' ')
                                                        ,char(9), ' ')
                                                ,char(10), ' ')
                                        ,char(11), ' ')
                                ,char(12), ' ')
                        ,char(13), ' ')
                ,'"', '\"')
        ,'/', '\/') as Subfamily_Code,
    replace( --escape /
            replace( --escape "
                    replace( --replace carriage return (ascii 13)
                            replace( --replace form feed (ascii 12)
                                    replace( --replace vertical tab (ascii 11)
                                            replace( --replace line feed (ascii 10)
                                                    replace( --replace horizontal tab (ascii 09)
                                                            replace( --replace backspace (ascii 08)
                                                                    replace( --escape \
                                                                            isnull(b.Model,'')
                                                                        ,'\', '\\')
                                                                ,char(8), ' ')
                                                        ,char(9), ' ')
                                                ,char(10), ' ')
                                        ,char(11), ' ')
                                ,char(12), ' ')
                        ,char(13), ' ')
                ,'"', '\"')
        ,'/', '\/') as Sales_Model,
    replace( --escape /
            replace( --escape "
                    replace( --replace carriage return (ascii 13)
                            replace( --replace form feed (ascii 12)
                                    replace( --replace vertical tab (ascii 11)
                                            replace( --replace line feed (ascii 10)
                                                    replace( --replace horizontal tab (ascii 09)
                                                            replace( --replace backspace (ascii 08)
                                                                    replace( --escape \
                                                                            isnull(b.SNP,'')
                                                                        ,'\', '\\')
                                                                ,char(8), ' ')
                                                        ,char(9), ' ')
                                                ,char(10), ' ')
                                        ,char(11), ' ')
                                ,char(12), ' ')
                        ,char(13), ' ')
                ,'"', '\"')
        ,'/', '\/') as Serial_Number_Prefix,
    d.LASTMODIFIEDDATE InsertDate
into #PHRecordsToStringPDF
From SISWEB_OWNER_SHADOW.LNKPDFPRODUCTINSTANCE a
inner join SISWEB_OWNER_SHADOW.EMPPRODUCTINSTANCE b on a.EMPPRODUCTINSTANCE_ID = b.EMPPRODUCTINSTANCE_ID
inner join sis.vw_Product c on b.SNP = c.Serial_Number_Prefix
inner join SISWEB_OWNER_SHADOW.PARTSPDF d on a.PARTSPDF_ID = d.PARTSPDF_ID
inner join [sis].[Media] M ON M.Media_Number = d.MediaNumber AND M.Source='N'
inner join [sis].[Media_Translation] MT on MT.Media_ID = M.Media_ID And MT.Media_Origin = 'EM'
inner join #InsertRecordsExternalPDF i on i.PARTSPDF_ID = a.PARTSPDF_ID

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_PHRecordsToStringPDF_PARTSPDF]
ON #PHRecordsToStringPDF (PARTSPDFID ASC)
INCLUDE (Family_Code, Subfamily_Code, Sales_Model, Serial_Number_Prefix, InsertDate)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

-- Family_Code
Select
    IESystemControlNumber,
    Family_Code,
    max(InsertDate) InsertDate
Into #PHRecordsToString_FM
From #PHRecordsToString
Group by IESystemControlNumber, Family_Code

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_IESystemControlNumber_FM]
ON #PHRecordsToString_FM (IESystemControlNumber ASC)
INCLUDE (Family_Code, InsertDate)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Family_Code'

-- Family_Code_PDF
Select
    PARTSPDFID as PARTSPDFID,
    Family_Code,
    max(InsertDate) InsertDate
Into #PHRecordsToStringPDF_FM
From #PHRecordsToStringPDF
Group by PARTSPDFID, Family_Code

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToStringPDF_ID_FM]
ON #PHRecordsToStringPDF_FM (PARTSPDFID ASC)
INCLUDE (Family_Code, InsertDate)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Family_Code'

Select
    a.IESystemControlNumber,
    '["' + string_agg(a.Family_Code,'","') + '"]'  As RecordsToString,
    min(a.InsertDate) InsertDate
--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into #PHRecordsToStringResult
From #PHRecordsToString_FM a
Group by a.IESystemControlNumber


Select
    a.PARTSPDFID as PARTSPDFID,
    '["' + string_agg(a.Family_Code,'","') + '"]'  As RecordsToString,
    min(a.InsertDate) InsertDate
--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into #PHRecordsToStringResultPDF
From #PHRecordsToStringPDF_FM a
Group by a.PARTSPDFID

--Add pkey to result
Alter Table #PHRecordsToStringResult Alter Column IESystemControlNumber varchar(50) Not NULL
ALTER TABLE #PHRecordsToStringResult ADD PRIMARY KEY CLUSTERED (IESystemControlNumber)
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

Insert into #EMPProductHierarchy
    (IESystemControlNumber,familyCode,InsertDate)
Select IESystemControlNumber, RecordsToString, InsertDate
From #PHRecordsToStringResult

--Add pkey to result PDF
ALTER TABLE #PHRecordsToStringResultPDF ADD PRIMARY KEY CLUSTERED (PARTSPDFID)
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

Insert into #EMPProductHierarchyPDF
    (PARTSPDFID,familyCode,InsertDate)
Select PARTSPDFID, RecordsToString, InsertDate
From #PHRecordsToStringResultPDF

--Drop temp
Drop table #PHRecordsToStringResult
Drop table #PHRecordsToString_FM
Drop table #PHRecordsToStringResultPDF
Drop table #PHRecordsToStringPDF_FM

-- Subfamily_Code
Select
    IESystemControlNumber,
    cast(Family_Code + '_' + Subfamily_Code as varchar(MAX)) RTS,
    max(InsertDate) InsertDate
Into #PHRecordsToString_SF
From #PHRecordsToString
Group by IESystemControlNumber, Family_Code, Subfamily_Code

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_IESystemControlNumber_SF]
ON #PHRecordsToString_SF (IESystemControlNumber ASC)
INCLUDE (RTS, InsertDate)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Subfamily_Code'

-- Subfamily_Code_PDF
Select
    PARTSPDFID as PARTSPDFID,
    cast(Family_Code + '_' + Subfamily_Code as varchar(MAX)) RTS,
    max(InsertDate) InsertDate
Into #PHRecordsToStringPDF_SF
From #PHRecordsToStringPDF
Group by PARTSPDFID, Family_Code, Subfamily_Code

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToStringPDF_ID_SF]
ON #PHRecordsToStringPDF_SF (PARTSPDFID ASC)
INCLUDE (RTS, InsertDate)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Subfamily_Code'

Select
    a.IESystemControlNumber,
    '["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
    min(a.InsertDate) InsertDate
--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into #PHRecordsToStringResult_SF
from #PHRecordsToString_SF a
Group by a.IESystemControlNumber

--Add pkey to result
Alter Table  #PHRecordsToStringResult_SF Alter Column IESystemControlNumber varchar(50) Not NULL
ALTER TABLE  #PHRecordsToStringResult_SF ADD PRIMARY KEY CLUSTERED (IESystemControlNumber)
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

Update x
Set familySubFamilyCode = y.RecordsToString
From #EMPProductHierarchy  x
inner join #PHRecordsToStringResult_SF y on x.IESystemControlNumber = y.IESystemControlNumber

Select
    a.PARTSPDFID as PARTSPDFID,
    '["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
    min(a.InsertDate) InsertDate
--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into #PHRecordsToStringResultPDF_SF
From #PHRecordsToStringPDF_SF a
Group by a.PARTSPDFID

--Add pkey to result
Alter Table  #PHRecordsToStringResultPDF_SF Alter Column PARTSPDFID varchar(50) Not NULL
ALTER TABLE  #PHRecordsToStringResultPDF_SF ADD PRIMARY KEY CLUSTERED (PARTSPDFID)
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

Update x
Set familySubFamilyCode = y.RecordsToString
From #EMPProductHierarchyPDF  x
inner join #PHRecordsToStringResultPDF_SF y on x.PARTSPDFID = y.PARTSPDFID

--Drop temp
Drop table #PHRecordsToStringResult_SF
Drop table #PHRecordsToString_SF
Drop table #PHRecordsToStringResultPDF_SF
Drop table #PHRecordsToStringPDF_SF

Declare @LoopCount int = 0
Declare @BatchInsertCount int = 0
Declare @BatchProcessCount int = 0
Declare @BatchCount int = 100000
--Each loop will process this number of IDs
Declare @UpdateCount int = 0

-- Sales_Model
Select
    IESystemControlNumber,
    cast(Family_Code + '_' + Subfamily_Code + '_' + Sales_Model as varchar(MAX)) RTS,
    max(InsertDate) InsertDate
Into #PHRecordsToString_SM
From #PHRecordsToString
Group by IESystemControlNumber, Family_Code, Subfamily_Code, Sales_Model

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_IESystemControlNumber_SM]
ON #PHRecordsToString_SM (IESystemControlNumber ASC)
INCLUDE (RTS, InsertDate)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Sales_Model'

-- Sales_Model_PDF
Select
    PARTSPDFID as PARTSPDFID,
    cast(Family_Code + '_' + Subfamily_Code + '_' + Sales_Model as varchar(MAX)) RTS,
    max(InsertDate) InsertDate
Into #PHRecordsToStringPDF_SM
From #PHRecordsToStringPDF
Group by PARTSPDFID, Family_Code, Subfamily_Code, Sales_Model

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToStringPDF_ID_SM]
ON #PHRecordsToStringPDF_SM (PARTSPDFID ASC)
INCLUDE (RTS, InsertDate)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Sales_Model'

Create table #PHRecordsToStringResult_SM
(
    IESystemControlNumber varchar(50) not null,
    RecordsToString varchar(max) null,
	InsertDate datetime not null
)

Create table #PHRecordsToStringResultPDF_SM
(
    PARTSPDFID varchar(50) not null,
    RecordsToString varchar(max) null,
	InsertDate datetime not null
)
--Add pkey to result
Alter Table  #PHRecordsToStringResult_SM Alter Column IESystemControlNumber varchar(50) Not NULL
ALTER TABLE  #PHRecordsToStringResult_SM ADD PRIMARY KEY CLUSTERED (IESystemControlNumber)
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

ALTER TABLE  #PHRecordsToStringResultPDF_SM ADD PRIMARY KEY CLUSTERED (PARTSPDFID)
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

While (Select count(*) from #PHRecordsToString_SM) > 0
    Begin

        Insert into #PHRecordsToStringResult_SM
        Select
            a.IESystemControlNumber,
            '["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
            min(a.InsertDate) InsertDate
            --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
        from (Select top (@BatchCount) With Ties
                    *
              From #PHRecordsToString_SM
              order by IESystemControlNumber) a
        Group by a.IESystemControlNumber

        --SET @BatchInsertCount = @@ROWCOUNT
        --SET @RowCount= @RowCount + @BatchInsertCount
        --SET @LoopCount = @LoopCount + 1
        --Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Sales_Model, Count: ' + Cast(@BatchInsertCount as varchar(50))

        Update x
        Set familySubFamilySalesModel = y.RecordsToString
        From #EMPProductHierarchy  x
        inner join #PHRecordsToStringResult_SM y on x.IESystemControlNumber = y.IESystemControlNumber

        Delete a
        From #PHRecordsToString_SM a
        inner join (
            Select Distinct IESystemControlNumber
            From (
                  Select top (@BatchCount) with Ties IESystemControlNumber
                  From #PHRecordsToString_SM
                  order by IESystemControlNumber ) x
            ) b on a.IESystemControlNumber = b.IESystemControlNumber

        --Set @BatchProcessCount = @@ROWCOUNT
        --Print cast(getdate() as varchar(50)) + ' - Total Update Count: ' + Cast(@RowCount as varchar(50)) + ' | Loop Count: ' + Cast(@LoopCount as varchar(50)) + ' | Batch Update Count: ' + Cast(@BatchInsertCount as varchar(50)) + ' | Batch Rows Processed: ' + Cast(@BatchProcessCount as varchar(50))

        Truncate table #PHRecordsToStringResult_SM

    End
--End of records to string loop

While (Select count(*) from #PHRecordsToStringPDF_SM) > 0
    Begin

        Insert into #PHRecordsToStringResultPDF_SM
        Select
            a.PARTSPDFID,
            '["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
            min(a.InsertDate) InsertDate
            --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
        from (Select top (@BatchCount) With Ties
                    *
              From #PHRecordsToStringPDF_SM
              order by PARTSPDFID) a
        Group by a.PARTSPDFID

        --SET @BatchInsertCount = @@ROWCOUNT
        --SET @RowCount= @RowCount + @BatchInsertCount
        --SET @LoopCount = @LoopCount + 1
        --Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Sales_Model, Count: ' + Cast(@BatchInsertCount as varchar(50))

        Update x
        SET familySubFamilySalesModel = y.RecordsToString
        From #EMPProductHierarchyPDF  x
        inner join #PHRecordsToStringResultPDF_SM y on x.PARTSPDFID = y.PARTSPDFID

        Delete a
        From #PHRecordsToStringPDF_SM a
        inner join (
            Select Distinct PARTSPDFID
            From
                (Select top (@BatchCount) with Ties PARTSPDFID
                 From #PHRecordsToStringPDF_SM
                 order by PARTSPDFID ) x
        ) b on a.PARTSPDFID = b.PARTSPDFID

        --Set @BatchProcessCount = @@ROWCOUNT
        --Print cast(getdate() as varchar(50)) + ' - Total Update Count: ' + Cast(@RowCount as varchar(50)) + ' | Loop Count: ' + Cast(@LoopCount as varchar(50)) + ' | Batch Update Count: ' + Cast(@BatchInsertCount as varchar(50)) + ' | Batch Rows Processed: ' + Cast(@BatchProcessCount as varchar(50))

        Truncate table #PHRecordsToStringResultPDF_SM

	End

--Drop temp
Drop table #PHRecordsToStringResult_SM
Drop table #PHRecordsToString_SM
Drop table #PHRecordsToStringResultPDF_SM
Drop table #PHRecordsToStringPDF_SM

--SNP
Select
    IESystemControlNumber,
    cast(Family_Code + '_' + Subfamily_Code + '_' + Sales_Model + '_' + Serial_Number_Prefix as varchar(MAX)) RTS,
    max(InsertDate) InsertDate
Into #PHRecordsToString_SNP
From #PHRecordsToString
Group by IESystemControlNumber, Family_Code, Subfamily_Code, Sales_Model, Serial_Number_Prefix

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_IESystemControlNumber_SNP]
ON #PHRecordsToString_SNP (IESystemControlNumber ASC)
INCLUDE (RTS, InsertDate)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Sales_Model'

    --SNP-PDF
Select
    PARTSPDFID as PARTSPDFID,
    cast(Family_Code + '_' + Subfamily_Code + '_' + Sales_Model + '_' + Serial_Number_Prefix as varchar(MAX)) RTS,
    max(InsertDate) InsertDate
Into #PHRecordsToStringPDF_SNP
From #PHRecordsToStringPDF
Group by PARTSPDFID, Family_Code, Subfamily_Code, Sales_Model, Serial_Number_Prefix

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToStringPDF_ID_SNP]
ON #PHRecordsToStringPDF_SNP (PARTSPDFID ASC)
INCLUDE (RTS, InsertDate)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Sales_Model'

Create table #PHRecordsToStringResult_SNP
(
    IESystemControlNumber varchar(50) not null,
    RecordsToString varchar(max) null,
	InsertDate datetime not null
)

--Add pkey to result
Alter Table  #PHRecordsToStringResult_SNP Alter Column IESystemControlNumber varchar(50) Not NULL
ALTER TABLE  #PHRecordsToStringResult_SNP ADD PRIMARY KEY CLUSTERED (IESystemControlNumber)
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

While (Select count(*) from #PHRecordsToString_SNP) > 0
    Begin

        Insert into #PHRecordsToStringResult_SNP
        Select
            a.IESystemControlNumber,
            '["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
            min(a.InsertDate) InsertDate
            --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
        From (Select top (@BatchCount) With Ties
                    *
              From #PHRecordsToString_SNP
              order by IESystemControlNumber) a
        Group by a.IESystemControlNumber

        --SET @BatchInsertCount = @@ROWCOUNT
        --SET @RowCount= @RowCount + @BatchInsertCount
        --SET @LoopCount = @LoopCount + 1
        --Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Serial_Number_Prefix, Count: ' + Cast(@BatchInsertCount as varchar(50))

        Update x
        Set familySubFamilySalesModelSNP = y.RecordsToString
        From #EMPProductHierarchy  x
        inner join #PHRecordsToStringResult_SNP y on x.IESystemControlNumber = y.IESystemControlNumber

        Delete a
        From #PHRecordsToString_SNP a
        inner join (
            Select Distinct IESystemControlNumber
            From (
                Select top (@BatchCount) with Ties IESystemControlNumber
                From #PHRecordsToString_SNP
                order by IESystemControlNumber ) x
            ) b on a.IESystemControlNumber = b.IESystemControlNumber


        --Set @BatchProcessCount = @@ROWCOUNT
        --Print cast(getdate() as varchar(50)) + ' - Total Update Count: ' + Cast(@RowCount as varchar(50)) + ' | Loop Count: ' + Cast(@LoopCount as varchar(50)) + ' | Batch Update Count: ' + Cast(@BatchInsertCount as varchar(50)) + ' | Batch Rows Processed: ' + Cast(@BatchProcessCount as varchar(50))

        Truncate table #PHRecordsToStringResult_SNP

    End
--End of records to string loop

Create table #PHRecordsToStringResultPDF_SNP
(
    PARTSPDFID varchar(50) not null,
    RecordsToString varchar(max) null,
	InsertDate datetime not null
)

--Add pkey to result
ALTER TABLE  #PHRecordsToStringResultPDF_SNP ADD PRIMARY KEY CLUSTERED (PARTSPDFID)
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

While (Select count(*) from #PHRecordsToStringPDF_SNP) > 0
    Begin

        Insert into #PHRecordsToStringResultPDF_SNP
        Select
            a.PARTSPDFID as PARTSPDFID,
            '["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
            min(a.InsertDate) InsertDate
            --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
        From (Select top (@BatchCount) With Ties
                    *
              From #PHRecordsToStringPDF_SNP
              order by PARTSPDFID) a
        Group by a.PARTSPDFID

        --SET @BatchInsertCount = @@ROWCOUNT
        --SET @RowCount= @RowCount + @BatchInsertCount
        --SET @LoopCount = @LoopCount + 1
        --Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Serial_Number_Prefix, Count: ' + Cast(@BatchInsertCount as varchar(50))

        Update x
        SET familySubFamilySalesModelSNP = y.RecordsToString
        From #EMPProductHierarchyPDF  x
        inner join #PHRecordsToStringResultPDF_SNP y on x.PARTSPDFID = y.PARTSPDFID

        Delete a
        From #PHRecordsToStringPDF_SNP a
        inner join (
            Select Distinct PARTSPDFID
            From (
                Select top (@BatchCount) with Ties PARTSPDFID
                From #PHRecordsToStringPDF_SNP
                order by PARTSPDFID ) x
            ) b on a.PARTSPDFID = b.PARTSPDFID

        --Set @BatchProcessCount = @@ROWCOUNT
        --Print cast(getdate() as varchar(50)) + ' - Total Update Count: ' + Cast(@RowCount as varchar(50)) + ' | Loop Count: ' + Cast(@LoopCount as varchar(50)) + ' | Batch Update Count: ' + Cast(@BatchInsertCount as varchar(50)) + ' | Batch Rows Processed: ' + Cast(@BatchProcessCount as varchar(50))

        Truncate table #PHRecordsToStringResultPDF_SNP

    End
--End of records to string loop

--Drop temp
Drop table  #PHRecordsToStringResult_SNP
Drop table #PHRecordsToString_SNP
Drop table  #PHRecordsToStringResultPDF_SNP
Drop table #PHRecordsToStringPDF_SNP

/*
Metrics calculated on SB2 Database:
	#PHRecordsToString insert 13,594,560 ( ~15 Seconds)
	#EMPProductHierarchy insert after conversions 111,424 ( ~4.20 Seconds )
	Total (Basic Parts + Consist Parts + Product Hierarchy) ~ 7.12 Min
 */
--End of EMP Product Hierarchy load

--Load Product Structure data that's specific to EMP

DROP TABLE IF EXISTS #EMPProductStructure
DROP TABLE IF EXISTS #PSRecordsToString
DROP TABLE IF EXISTS #PSRecordsToStringSystem
DROP TABLE IF EXISTS #EMPProductStructurePDF
DROP TABLE IF EXISTS #PSRecordsToStringPDF
DROP TABLE IF EXISTS #PSRecordsToStringSystemPDF

CREATE TABLE #EMPProductStructure
(
    [IESystemControlNumber] VARCHAR (50) NOT NULL,
    [SystemPSID] VARCHAR (MAX) NULL,
    [PSID] VARCHAR (MAX) NULL,
    [InsertDate] DATETIME NOT NULL,
    PRIMARY KEY CLUSTERED ([IESystemControlNumber] ASC)
    );

;with CTE_PRODUCTSTRUCTURE_2 as (
    SELECT distinct MS.IESystemControlNumber,
        CASE
            WHEN ISNULL(PS.ParentProductStructure_ID,0) <> 0
                 THEN CAST(PS.ParentProductStructure_ID AS VARCHAR) +'_'+ CAST(PSR.ProductStructure_ID AS VARCHAR)
            ELSE CAST(PSR.ProductStructure_ID AS VARCHAR) +'_'+ CAST(PSR.ProductStructure_ID AS VARCHAR)
        END AS [PSID],
        CASE
            WHEN ISNULL(PS.ParentProductStructure_ID,0) <> 0
                THEN PS.ParentProductStructure_ID
                ELSE PSR.ProductStructure_ID
        END as [SYSTEMPSID],
		IR.LastModified_Date [InsertDate]
	FROM [sis_shadow].[MediaSequence] MS
	inner join [sis].[MediaSection] MSE ON MSE.MediaSection_ID = MS.MediaSection_ID
	inner join [sis].[Media] ME on ME.Media_ID=MSE.Media_ID  AND ME.Source='N'
	inner join [sis].[Media_Translation] MT on MT.Media_ID = ME.Media_ID And MT.Media_Origin = 'EM'
	inner join [sis].[ProductStructure_IEPart_Relation] PSR ON PSR.IEPart_ID = MS.IEPart_ID
    	AND PSR.Media_ID = MSE.Media_ID
	inner join [SISWEB_OWNER_SHADOW].[LNKIEPRODUCTINSTANCE] c With(NolocK)
		on c.IESystemControlNumber=MS.IESystemControlNumber and c.MediaNumber=ME.Media_Number
	inner join #InsertRecords IR  ON IR.IESystemControlNumber=c.IESystemControlNumber --Add filter to limit to changed records
	inner join [sis].[ProductStructure] PS ON PS.ProductStructure_ID = PSR.ProductStructure_ID
	inner join [sis].[ProductStructure_Translation] PT ON PT.ProductStructure_ID = PS.ProductStructure_ID
	inner join [sis].[Language] L ON L.Language_ID= PT.Language_ID AND L.Language_Tag='en-US'
	)

Select IESystemControlNumber ,
        isnull(PSID, '') as PSID,
       isnull([SystemPSID], '') as [SystemPSID],
	[InsertDate]
into #PSRecordsToString
From CTE_PRODUCTSTRUCTURE_2;

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_EMPProductStructure_IESystemControlNumber]
ON #PSRecordsToString ([IESystemControlNumber] ASC)
INCLUDE ([PSID],[SystemPSID],[InsertDate])
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

Insert into #EMPProductStructure
	(IESystemControlNumber,[PSID],InsertDate)
Select
    a.IESystemControlNumber as [IESystemControlNumber],
	coalesce(f.PSID,'') As [PSID],
	min(a.InsertDate) InsertDate
--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
From #PSRecordsToString a
CROSS apply
    (
        SELECT '[' + stuff (
            (
                SELECT '","'  + cast([PSID] as varchar(MAX))
                FROM #PSRecordsToString as b
                where a.IESystemControlNumber = b.IESystemControlNumber
                order by b.IESystemControlNumber
                FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
                    ,1,2,''
            ) + '"'+']'
    ) f (PSID)
Group by a.IESystemControlNumber, f.PSID

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

Select distinct IESystemControlNumber,[SystemPSID]
into #PSRecordsToStringSystem
From #PSRecordsToString

DROP TABLE IF EXISTS #SystemPSID
Select
    a.IESystemControlNumber,
    coalesce(f.[SystemPSID],'') As [SystemPSID]
into #SystemPSID
from #PSRecordsToString a
CROSS apply
    (
        SELECT '[' + stuff (
            (
                SELECT '","'  + cast([SystemPSID] as varchar(MAX))
                FROM #PSRecordsToStringSystem as b
                Where a.IESystemControlNumber = b.IESystemControlNumber
                order by b.IESystemControlNumber
                FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
                    ,1,2,''
            ) + '"'+']'
    ) f ([SystemPSID])
Group by a.IESystemControlNumber, f.[SystemPSID]

Update t
Set t.[SystemPSID] = s.[SystemPSID]
From #EMPProductStructure t
inner join #SystemPSID s on t.[IESystemControlNumber] = s.[IESystemControlNumber]

DROP TABLE IF EXISTS #SystemPSID

CREATE TABLE #EMPProductStructurePDF
(
    [PARTSPDFID] VARCHAR (50) NOT NULL,
    [SystemPSID] VARCHAR (MAX) NULL,
    [PSID] VARCHAR (MAX) NULL,
    [InsertDate] DATETIME NOT NULL,
    PRIMARY KEY CLUSTERED ([PARTSPDFID] ASC)
    );
;

with CTE_PRODUCTSTRUCTUREPDF_2 as
(
    SELECT Distinct c.PARTSPDF_ID,
       CASE
            WHEN ISNULL(b.ParentProductStructure_ID,0) <> 0
                THEN cast(b.ParentProductStructure_ID as varchar) + '_' + CAST(TRY_CAST(a.PSID AS INT) As varchar)
                ELSE CAST(TRY_CAST(a.PSID AS INT) As varchar) + '_' + CAST(TRY_CAST(a.PSID AS INT) As varchar)
            END as [PSID],
        CASE
            WHEN ISNULL(b.ParentProductStructure_ID,0) <> 0
                THEN b.ParentProductStructure_ID
                ELSE TRY_CAST(a.PSID AS INT)
            END as [SystemPSID],
	    e.LASTMODIFIEDDATE [InsertDate]
		From SISWEB_OWNER_SHADOW.LNKPARTSPDFPSID a With(NolocK)
		inner join #InsertRecordsExternalPDF f on a.PARTSPDF_ID = f.PARTSPDF_ID --Add filter to limit to changed records
		inner join [SISWEB_OWNER_SHADOW].[PARTSPDF] e With(NolocK) on e.PARTSPDF_ID = a.PARTSPDF_ID
		inner join [SISWEB_OWNER_SHADOW].[LNKPDFPRODUCTINSTANCE] c With(NolocK) on c.PARTSPDF_ID = e.PARTSPDF_ID
		inner join [sis].[ProductStructure] b ON b.ProductStructure_ID = a.PSID
		inner join [sis].[ProductStructure_Translation] PT ON PT.ProductStructure_ID = b.ProductStructure_ID
		inner join [sis].[Language] L ON L.Language_ID= PT.Language_ID AND L.Language_Tag='en-US'
		inner join [sis].[Media] M ON M.Media_Number = e.MediaNumber AND M.Source = 'N'
        inner join [sis].[Media_Translation] MT on MT.Media_ID = M.Media_ID And MT.Media_Origin = 'EM'
)

Select PARTSPDF_ID as PARTSPDFID,
       isnull(PSID, '') as PSID,
       isnull([SystemPSID], '')as [SystemPSID],
	[InsertDate]
into #PSRecordsToStringPDF
From CTE_PRODUCTSTRUCTUREPDF_2;

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_EMPProductStructurePDF_PARTSPDF_ID]
ON #PSRecordsToStringPDF ([PARTSPDFID] ASC)
INCLUDE ([PSID], [SystemPSID], [InsertDate])
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

Insert into #EMPProductStructurePDF
	(PARTSPDFID,[PSID],InsertDate)
Select
    a.PARTSPDFID as [PARTSPDFID],
	coalesce(f.PSID,'') As [PSID],
	min(a.InsertDate) InsertDate
--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
From #PSRecordsToStringPDF a
CROSS apply
    (
        SELECT '[' + stuff (
            (
                SELECT '","'  + cast([PSID] as varchar(MAX))
                FROM #PSRecordsToStringPDF as b
                where a.PARTSPDFID=b.PARTSPDFID
                order by b.PARTSPDFID
                FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
                    ,1,2,''
            ) + '"'+']'
    ) f (PSID)
Group by a.PARTSPDFID, f.PSID

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

Select distinct PARTSPDFID,[SystemPSID]
into #PSRecordsToStringSystemPDF
From #PSRecordsToStringPDF

DROP TABLE IF EXISTS #SystemPSIDPDF
Select
    a.PARTSPDFID,
    coalesce(f.[SystemPSID],'') As [SystemPSID]
into #SystemPSIDPDF
From #PSRecordsToStringPDF a
CROSS apply
    (
        SELECT '[' + stuff (
            (
                SELECT '","'  + cast([SystemPSID] as varchar(MAX))
                FROM #PSRecordsToStringSystemPDF as b
                where a.PARTSPDFID=b.PARTSPDFID
                order by b.PARTSPDFID
                FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
                    ,1,2,'') + '"'+']'
    ) f ([SystemPSID])
Group by a.PARTSPDFID, f.[SystemPSID]

Update t
Set t.[SystemPSID] = s.[SystemPSID]
From #EMPProductStructurePDF t
inner join #SystemPSIDPDF s on t.[PARTSPDFID] = s.[PARTSPDFID]

DROP TABLE IF EXISTS #SystemPSIDPDF

/*
Metrics calculated on SB2 Database:
	#EMPProductStructure insert 111,424 ( ~2 Seconds)
	Total (Basic Parts + Consist Parts + Product Hierarchy + Product Structure) ~ 7.34 Min
 */
--End of EMP Product Structure load

--Load SNP data that's specific to EMP

DROP TABLE IF EXISTS #SNPRecordsToString;
DROP TABLE IF EXISTS #SNPRecordsToString_Ranked;
DROP TABLE IF EXISTS #EMPSerialNumberPrefixes;
DROP TABLE IF EXISTS #SNPArray


;with CTE_SNP_4 as
(
    Select Distinct
        MS.IESystemControlNumber as IESystemControlNumber ,
        a.SNP,
        MS.LastModified_Date InsertDate,
        a.PRODUCTINSTANCENUMBERS
    FROM (
            Select IESystemControlNumber, SNP,
                   ISNULL('"' + STRING_AGG(cast(epi.NUMBER as varchar(max)),'","') + '"', '') AS [ProductInstanceNumbers]
            From [SISWEB_OWNER_SHADOW].[LNKIEPRODUCTINSTANCE] lpi
            inner join SISWEB_OWNER_SHADOW.EMPPRODUCTINSTANCE epi on epi.EMPPRODUCTINSTANCE_ID = lpi.EMPPRODUCTINSTANCE_ID
            Group by IESystemControlNumber, SNP

         ) a
    inner join [sis_shadow].[MediaSequence] MS on MS.IESystemControlNumber = a.IESystemControlNumber --Add filter to limit to changed records
    inner join [sis].[MediaSection] MSE ON MSE.MediaSection_ID = MS.MediaSection_ID
    inner join [sis].[Media] ME  on ME.Media_ID = MSE.Media_ID
    inner join [sis].[Media_Translation] MT on MT.Media_ID = ME.Media_ID
    where ME.Source='N' and MT.Media_Origin = 'EM'
)

Select CTE_4.IESystemControlNumber,
       replace( --escape /
               replace( --escape "
                       replace( --escape carriage return (ascii 13)
                               replace( --escape form feed (ascii 12)
                                       replace( --escape vertical tab (ascii 11)
                                               replace( --escape line feed (ascii 10)
                                                       replace( --escape horizontal tab (ascii 09)
                                                               replace( --escape backspace (ascii 08)
                                                                       replace( --escape \
                                                                               isnull(CTE_4.SNP,'')
                                                                           ,'\', '\\')
                                                                   ,char(8), ' ')
                                                           ,char(9), ' ')
                                                   ,char(10), ' ')
                                           ,char(11), ' ')
                                   ,char(12), ' ')
                           ,char(13), ' ')
                   ,'"', '\"')
           ,'/', '\/') as SNP,
       d.LastModified_Date AS InsertDate,
       CTE_4.PRODUCTINSTANCENUMBERS
into #SNPRecordsToString
From CTE_SNP_4 as CTE_4
inner join #InsertRecords d on d.IESystemControlNumber = CTE_4.IESystemControlNumber;

--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

Select
    x.IESystemControlNumber,
    r.SNP,
    r.InsertDate,
    r.PRODUCTINSTANCENUMBERS
Into #SNPRecordsToString_Ranked
From
    (
        --Get
        Select IESystemControlNumber
        From #SNPRecordsToString
        Group by IESystemControlNumber
    ) x
--Get the SNP & InsertDate
inner join #SNPRecordsToString r on x.IESystemControlNumber = r.IESystemControlNumber


SELECT
    IESystemControlNumber,
    ISNULL('["' + STRING_AGG(cast(SNP as varchar(max)),'","') WITHIN GROUP (ORDER BY SNP) + '"]','[]') AS [serialNumbers.serialNumberPrefixes],
	ISNULL('[' + STRING_AGG(cast(PRODUCTINSTANCENUMBERS as varchar(max)),',') + ']','[]') AS [ProductInstanceNumbers],
	max(InsertDate) [InsertDate]
Into #SNPArray
FROM #SNPRecordsToString_Ranked
GROUP BY IESystemControlNumber


Select
    IESystemControlNumber,
    (
        Select
            JSON_Query(b.[serialNumbers.serialNumberPrefixes]) [serialNumberPrefixes]
        From #SNPArray b
        where a.IESystemControlNumber = b.IESystemControlNumber
        For JSON Path
    ) SerialNumbers,
    (
        Select
            PRODUCTINSTANCENUMBERS as [ProductInstanceNumbers]
        From #SNPArray c
        Where a.IESystemControlNumber = c.IESystemControlNumber
    ) ProductInstanceNumbers,
    max(InsertDate) InsertDate
into #EMPSerialNumberPrefixes
From #SNPArray a
Group By IESystemControlNumber

DROP TABLE IF EXISTS #SNPRecordsToString;
DROP TABLE IF EXISTS #SNPRecordsToString_Ranked;
DROP TABLE IF EXISTS #SNPArray

--Load SNP data that's specific to EMP PDF

DROP TABLE IF EXISTS #SNPRecordsToStringPDF;
DROP TABLE IF EXISTS #SNPRecordsToString_RankedPDF;
DROP TABLE IF EXISTS #EMPSerialNumberPrefixesPDF;
DROP TABLE IF EXISTS #SNPArrayPDF

;with CTE_SNP_4_PDF as
(
    Select Distinct
        a.PARTSPDF_ID,
        a.SNP,
        c.LASTMODIFIEDDATE InsertDate,
        a.PRODUCTINSTANCENUMBERS
    FROM (
        Select PARTSPDF_ID, SNP,
            ISNULL('"' + STRING_AGG(cast(epi.NUMBER as varchar(max)),'","') + '"', '') AS [ProductInstanceNumbers]
        From SISWEB_OWNER_SHADOW.LNKPDFPRODUCTINSTANCE lpi
        inner join SISWEB_OWNER_SHADOW.EMPPRODUCTINSTANCE epi on epi.EMPPRODUCTINSTANCE_ID = lpi.EMPPRODUCTINSTANCE_ID
        Group by PARTSPDF_ID, SNP
        ) a
    inner join [SISWEB_OWNER_SHADOW].[PARTSPDF] c With(NolocK) on a.PARTSPDF_ID = c.PARTSPDF_ID
    inner join #InsertRecordsExternalPDF d on c.PARTSPDF_ID=d.PARTSPDF_ID --Add filter to limit to changed records
    inner join [sis].[Media] M ON M.Media_Number = c.MediaNumber AND M.Source='N'
    inner join [sis].[Media_Translation] MT on MT.Media_ID = M.Media_ID And MT.Media_Origin = 'EM'
)

Select PARTSPDF_ID as PARTSPDFID,
       replace( --escape /
               replace( --escape "
                       replace( --escape carriage return (ascii 13)
                               replace( --escape form feed (ascii 12)
                                       replace( --escape vertical tab (ascii 11)
                                               replace( --escape line feed (ascii 10)
                                                       replace( --escape horizontal tab (ascii 09)
                                                               replace( --escape backspace (ascii 08)
                                                                       replace( --escape \
                                                                               isnull(SNP,'')
                                                                           ,'\', '\\')
                                                                   ,char(8), ' ')
                                                           ,char(9), ' ')
                                                   ,char(10), ' ')
                                           ,char(11), ' ')
                                   ,char(12), ' ')
                           ,char(13), ' ')
                   ,'"', '\"')
           ,'/', '\/') as SNP,
       InsertDate,
       PRODUCTINSTANCENUMBERS
into #SNPRecordsToStringPDF
From CTE_SNP_4_PDF;

--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

Select
    x.PARTSPDFID as PARTSPDFID,
    r.SNP,
    r.InsertDate,
    r.PRODUCTINSTANCENUMBERS
Into #SNPRecordsToString_RankedPDF
From
    (
        --Get
        Select
            PARTSPDFID
        From #SNPRecordsToStringPDF
        Group by PARTSPDFID
    ) x
--Get the SNP & InsertDate
inner join #SNPRecordsToStringPDF r on x.PARTSPDFID = r.PARTSPDFID


SELECT
    PARTSPDFID,
    ISNULL('["' + STRING_AGG(cast(SNP as varchar(max)),'","') WITHIN GROUP (ORDER BY SNP) + '"]','[]') AS [serialNumbers.serialNumberPrefixes],
	ISNULL('[' + STRING_AGG(cast(PRODUCTINSTANCENUMBERS as varchar(max)),',') + ']','[]') AS [ProductInstanceNumbers],
	max(InsertDate) [InsertDate]
Into #SNPArrayPDF
FROM #SNPRecordsToString_RankedPDF
GROUP BY PARTSPDFID


Select
    PARTSPDFID as PARTSPDFID,
    (
        Select
            JSON_Query(b.[serialNumbers.serialNumberPrefixes]) [serialNumberPrefixes]
        From #SNPArrayPDF b
        where a.PARTSPDFID = b.PARTSPDFID
        For JSON Path
    ) SerialNumbers,
    (
        Select
            PRODUCTINSTANCENUMBERS as [ProductInstanceNumbers]
        From #SNPArrayPDF c
        Where a.PARTSPDFID = c.PARTSPDFID
    ) ProductInstanceNumbers,
    max(InsertDate) InsertDate
into #EMPSerialNumberPrefixesPDF
From #SNPArrayPDF a
Group By PARTSPDFID

DROP TABLE IF EXISTS #SNPRecordsToStringPDF;
DROP TABLE IF EXISTS #SNPRecordsToString_RankedPDF;
DROP TABLE IF EXISTS #SNPArrayPDF


/*
Metrics calculated on SB2 Database:
	#EMPSerialNumberPrefixes insert 111,424 ( ~15 Seconds)
	Total (Basic Parts + Consist Parts + Product Hierarchy + Product Structure
			Serial Number Prefixes ) ~ 8.18 Min
 */
--End of EMP Serial Number Prefixes load

--Load to final EMP table

--Prep
DROP TABLE IF EXISTS #ConsolidatedEMP
DROP TABLE IF EXISTS #ConsolidatedPDF

--Create Temp
CREATE TABLE #ConsolidatedEMP (
    [ID] [varchar](50) NOT NULL,
    [IESystemControlNumber] [varchar](50) NULL,
    [InsertDate] [datetime] NULL,
    [InformationType] [varchar](10) NULL,
    [MediaNumber] [varchar](15) NULL,
    [IEUpdateDate] [datetime2](0) NULL,
    [IEPart] [nvarchar](700) NULL,
    [IEPartNumber] [varchar](40) NULL,
    [PartsManualMediaNumber] [varchar](15) NULL,
    [IECaption] [nvarchar](2048) NULL,
    [ConsistPart] [nvarchar](max) NULL,
    [SystemPSID] [varchar](max) NULL,
    [PSID] [varchar](max) NULL,
    [SerialNumbers] [varchar](max) NULL,
    [ProductInstanceNumbers] [varchar](max) NULL,
    [isMedia] [bit] NULL,
-- 	[Profile] varchar(max) NULL,
    [PubDate] [datetime] NULL,
    [ControlNumber] [varchar](50) NULL,
    [familyCode] [varchar](max) NULL,
    [familySubFamilyCode] [varchar](max) NULL,
    [familySubFamilySalesModel] [varchar](max) NULL,
    [familySubFamilySalesModelSNP] [varchar](max) NULL,
-- 	[IEPartHistory] [varchar](max) NULL,
-- 	[ConsistPartHistory] [varchar](max) NULL,
-- 	[IEPartReplacement] [varchar](max) NULL,
-- 	[ConsistPartReplacement] [varchar](max) NULL,
    [ConsistPartNames_es-ES] [nvarchar](max) NULL,
    [ConsistPartNames_zh-CN] [nvarchar](max) NULL,
    [ConsistPartNames_fr-FR] [nvarchar](max) NULL,
    [ConsistPartNames_it-IT] [nvarchar](max) NULL,
    [ConsistPartNames_de-DE] [nvarchar](max) NULL,
    [ConsistPartNames_pt-BR] [nvarchar](max) NULL,
    [ConsistPartNames_id-ID] [nvarchar](max) NULL,
    [ConsistPartNames_ja-JP] [nvarchar](max) NULL,
    [ConsistPartNames_ru-RU] [nvarchar](max) NULL,
    [MediaOrigin] [varchar](2) NULL,
    [OrgCode] [varchar](12)   NULL
);

--Create Temp
CREATE TABLE #ConsolidatedPDF (
    [ID] [varchar](50) NOT NULL,
    [InsertDate] [datetime] NULL,
    [InformationType] [varchar](10) NULL,
    [MediaNumber] [varchar](15) NULL,
    [IEUpdateDate] [datetime2](0) NULL,
    [IEPart] [nvarchar](700) NULL,
    [PartsManualMediaNumber] [varchar](15) NULL,
    [SystemPSID] [varchar](max) NULL,
    [PSID] [varchar](max) NULL,
    [SerialNumbers] [varchar](max) NULL,
    [ProductInstanceNumbers] [varchar](max) NULL,
    [isMedia] [bit] NULL,
    [familyCode] [varchar](max) NULL,
    [familySubFamilyCode] [varchar](max) NULL,
    [familySubFamilySalesModel] [varchar](max) NULL,
    [familySubFamilySalesModelSNP] [varchar](max) NULL,
    [MediaOrigin] [varchar](2) NULL,
    [OrgCode] [varchar](12)   NULL
);

--Set collation of temp
ALTER TABLE #ConsolidatedEMP
ALTER COLUMN [ID] varchar(50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL

CREATE NONCLUSTERED INDEX IX_CONSOLIDATEDEMP ON #ConsolidatedEMP ([IESystemControlNumber])
INCLUDE ([ID],[InsertDate],[InformationType],[MediaNumber],[IEUpdateDate],
	[IEPart],[IEPartNumber],[PartsManualMediaNumber],[IECaption],[ConsistPart],[SystemPSID],[PSID],
	[isMedia],[PubDate],[ControlNumber],[familyCode],[familySubFamilyCode],
	[familySubFamilySalesModel],[familySubFamilySalesModelSNP],[ConsistPartNames_es-ES],
	[ConsistPartNames_zh-CN],[ConsistPartNames_fr-FR],[ConsistPartNames_it-IT],[ConsistPartNames_de-DE],
	[ConsistPartNames_pt-BR],[ConsistPartNames_id-ID],[ConsistPartNames_ja-JP],[ConsistPartNames_ru-RU],[MediaOrigin],
    [OrgCode]);

ALTER TABLE #ConsolidatedPDF
ALTER COLUMN [ID] varchar(50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL

CREATE NONCLUSTERED INDEX IX_CONSOLIDATEDPDF
ON #ConsolidatedPDF ([ID])
INCLUDE ([InsertDate],[InformationType],[MediaNumber],[IEUpdateDate],
	[IEPart],[PartsManualMediaNumber],[SystemPSID],[PSID],
	[isMedia],[familyCode],[familySubFamilyCode],
	[familySubFamilySalesModel],[familySubFamilySalesModelSNP],[MediaOrigin],
    [OrgCode]);

DROP TABLE IF EXISTS #CONSOLIDATEDPARTS_4_IESystemControlNumberS;
CREATE TABLE #CONSOLIDATEDPARTS_4_IESystemControlNumberS (IESystemControlNumber VARCHAR(50) NOT NULL PRIMARY KEY);

DROP TABLE IF EXISTS #CONSOLIDATEDPARTS_4_PARTSPDF;
CREATE TABLE #CONSOLIDATEDPARTS_4_PARTSPDF (PARTSPDFID VARCHAR(50) NOT NULL PRIMARY KEY);


INSERT INTO #CONSOLIDATEDPARTS_4_IESystemControlNumberS
SELECT IESystemControlNumber
FROM(SELECT IESystemControlNumber FROM #EMPBasicParts AS bp
     UNION
     SELECT IESystemControlNumber FROM #EMPConsistParts AS cp
     UNION
     SELECT IESystemControlNumber FROM #EMPProductStructure AS ps
     UNION
     SELECT IESystemControlNumber FROM #EMPSerialNumberPrefixes AS snp
     UNION
     SELECT IESystemControlNumber FROM #EMPProductHierarchy AS ph

    ) AS T
;

INSERT INTO #CONSOLIDATEDPARTS_4_PARTSPDF
SELECT PARTSPDFID
FROM(SELECT PARTSPDFID FROM #EMPExternalPDF AS bp
     UNION
     SELECT PARTSPDFID FROM #EMPProductStructurePDF AS ps
     UNION
     SELECT PARTSPDFID FROM #EMPSerialNumberPrefixesPDF AS snp
     UNION
     SELECT PARTSPDFID FROM #EMPProductHierarchyPDF AS ph

    ) AS P
;

--Insert updated source into temp
Insert into #ConsolidatedEMP
SELECT
    cast(IESystemControlNumberS.IESystemControlNumber as VARCHAR) As ID
    , coalesce(bp.[IESystemControlNumber], cp.IESystemControlNumber, ps.[IESystemControlNumber]
    , snp.[IESystemControlNumber], ph.[IESystemControlNumber]) [IESystemControlNumber]
    , coalesce(bp.InsertDate, cp.[InsertDate], ps.InsertDate, snp.InsertDate, ph.InsertDate) [InsertDate]
    , nullif(nullif(bp.[InformationType], '[""]'), '') [InformationType]
    , nullif(nullif(bp.[MediaNumber], '[""]'), '') [MediaNumber]
    , bp.[IEUpdateDate]
    , bp.[IEPart]
    , bp.[IEPartNumber]
    , nullif(nullif(bp.[PartsManualMediaNumber], '[""]'), '') [PartsManualMediaNumber]
    , bp.[IECaption]
     --ConsistParts
    , nullif(nullif(cp.[ConsistPart], '[""]'), '') [ConsistPart]
     --ProductStructure
    , nullif(nullif(ps.[SystemPSID], '[""]'), '') [SystemPSID]
    , nullif(nullif(ps.[PSID], '[""]'), '') [PSID]
     --SNP
    , nullif(nullif(snp.[SerialNumbers], '[""]'), '') [SerialNumbers]
    , nullif(nullif(snp.[ProductInstanceNumbers], '[""]'), '') [ProductInstanceNumbers]
    , bp.[isMedia]
    , bp.[PubDate]
    , nullif(nullif(bp.[ControlNumber], '[""]'), '') [ControlNumber]
    , nullif(nullif(ph.[familyCode], '[""]'), '') familyCode
    , nullif(nullif(ph.[familySubFamilyCode], '[""]'), '') familySubFamilyCode
    , nullif(nullif(ph.[familySubFamilySalesModel], '[""]'), '') familySubFamilySalesModel
    , nullif(nullif(ph.[familySubFamilySalesModelSNP], '[""]'), '') familySubFamilySalesModelSNP
    , nullif(nullif(cp.[ConsistPartNames_es-ES], '[""]'), '') [ConsistPartNames_es-ES]
    , nullif(nullif(cp.[ConsistPartNames_fr-FR], '[""]'), '') [ConsistPartNames_zh-CN]
    , nullif(nullif(cp.[ConsistPartNames_fr-FR], '[""]'), '') [ConsistPartNames_fr-FR]
    , nullif(nullif(cp.[ConsistPartNames_it-IT], '[""]'), '') [ConsistPartNames_it-IT]
    , nullif(nullif(cp.[ConsistPartNames_de-DE], '[""]'), '') [ConsistPartNames_de-DE]
    , nullif(nullif(cp.[ConsistPartNames_pt-BR], '[""]'), '') [ConsistPartNames_pt-BR]
    , nullif(nullif(cp.[ConsistPartNames_id-ID], '[""]'), '') [ConsistPartNames_id-ID]
    , nullif(nullif(cp.[ConsistPartNames_ja-JP], '[""]'), '') [ConsistPartNames_ja-JP]
    , nullif(nullif(cp.[ConsistPartNames_ru-RU], '[""]'), '') [ConsistPartNames_ru-RU]
    , MediaOrigin
    , bp.OrgCode [OrgCode]
FROM #CONSOLIDATEDPARTS_4_IESystemControlNumberS AS IESystemControlNumberS
LEFT JOIN #EMPBasicParts AS bp ON bp.IESystemControlNumber = IESystemControlNumberS.IESystemControlNumber
LEFT JOIN #EMPConsistParts AS cp ON cp.IESystemControlNumber = IESystemControlNumberS.IESystemControlNumber
LEFT JOIN #EMPProductStructure AS ps ON ps.IESystemControlNumber = IESystemControlNumberS.IESystemControlNumber
LEFT JOIN #EMPSerialNumberPrefixes AS snp ON snp.IESystemControlNumber = IESystemControlNumberS.IESystemControlNumber
LEFT JOIN #EMPProductHierarchy AS ph ON ph.IESystemControlNumber = IESystemControlNumberS.IESystemControlNumber;

--Insert updated source into temp PDF
Insert into #ConsolidatedPDF
SELECT
    cast(PARTSPDF.PARTSPDFID as VARCHAR) As ID
     ,coalesce(bp.InsertDate, ps.InsertDate, snp.InsertDate, ph.InsertDate) [InsertDate]
     ,nullif(nullif(bp.[InformationType], '[""]'), '') [InformationType]
     ,nullif(nullif(bp.[MediaNumber], '[""]'), '') [MediaNumber]
     ,bp.[IEUpdateDate]
     ,bp.[IEPart]
     ,nullif(nullif(bp.[PartsManualMediaNumber], '[""]'), '') [PartsManualMediaNumber]
     --ProductStructure
     ,nullif(nullif(ps.[SystemPSID], '[""]'), '') [SystemPSID]
     ,nullif(nullif(ps.[PSID], '[""]'), '') [PSID]
     --SNP
     ,nullif(nullif(snp.[SerialNumbers], '[""]'), '') [SerialNumbers]
     ,nullif(nullif(snp.[ProductInstanceNumbers], '[""]'), '') [ProductInstanceNumbers]
     ,bp.[isMedia]
     ,nullif(nullif(ph.[familyCode], '[""]'), '') familyCode
     ,nullif(nullif(ph.[familySubFamilyCode], '[""]'), '') familySubFamilyCode
     ,nullif(nullif(ph.[familySubFamilySalesModel], '[""]'), '') familySubFamilySalesModel
     ,nullif(nullif(ph.[familySubFamilySalesModelSNP], '[""]'), '') familySubFamilySalesModelSNP
     ,MediaOrigin
     ,bp.OrgCode [OrgCode]
FROM #CONSOLIDATEDPARTS_4_PARTSPDF AS PARTSPDF
LEFT JOIN #EMPExternalPDF AS bp ON bp.PARTSPDFID = PARTSPDF.PARTSPDFID
LEFT JOIN #EMPProductStructurePDF AS ps ON ps.PARTSPDFID = PARTSPDF.PARTSPDFID
LEFT JOIN #EMPSerialNumberPrefixesPDF AS snp ON snp.PARTSPDFID = PARTSPDF.PARTSPDFID
LEFT JOIN #EMPProductHierarchyPDF AS ph ON ph.PARTSPDFID = PARTSPDF.PARTSPDFID;


Update tgt
Set
   tgt.[InsertDate] = src.[InsertDate]
  ,tgt.[InformationType] = src.[InformationType]
  ,tgt.[MediaNumber] = src.[MediaNumber]
  ,tgt.[IEUpdateDate] = src.[IEUpdateDate]
  ,tgt.[IEPart] = src.[IEPart]
  ,tgt.[IEPartNumber] = src.[IEPartNumber]
  ,tgt.[PartsManualMediaNumber] = src.[PartsManualMediaNumber]
  ,tgt.[IECaption] = src.[IECaption]
  ,tgt.[ConsistPart] = src.[ConsistPart]
  ,tgt.[System] = src.[SystemPSID]
  ,tgt.[SystemPSID] = src.[SystemPSID]
  ,tgt.[PSID] = src.[PSID]
  ,tgt.[SerialNumbers] = src.[SerialNumbers]
  ,tgt.[ProductInstanceNumbers] = src.[ProductInstanceNumbers]
  ,tgt.[isMedia] = src.[isMedia]
  ,tgt.[PubDate] = src.[PubDate]
  ,tgt.[ControlNumber] = src.[ControlNumber]
  ,tgt.[familyCode] = src.[familyCode]
  ,tgt.[familySubFamilyCode] = src.[familySubFamilyCode]
  ,tgt.[familySubFamilySalesModel] = src.[familySubFamilySalesModel]
  ,tgt.familySubFamilySalesModelSNP = src.[familySubFamilySalesModelSNP]
  ,tgt.[ConsistPartNames_es-ES] = src.[ConsistPartNames_es-ES]
  ,tgt.[ConsistPartNames_zh-CN] = src.[ConsistPartNames_zh-CN]
  ,tgt.[ConsistPartNames_fr-FR] = src.[ConsistPartNames_fr-FR]
  ,tgt.[ConsistPartNames_it-IT] = src.[ConsistPartNames_it-IT]
  ,tgt.[ConsistPartNames_de-DE] = src.[ConsistPartNames_de-DE]
  ,tgt.[ConsistPartNames_pt-BR] = src.[ConsistPartNames_pt-BR]
  ,tgt.[ConsistPartNames_id-ID] = src.[ConsistPartNames_id-ID]
  ,tgt.[ConsistPartNames_ja-JP] = src.[ConsistPartNames_ja-JP]
  ,tgt.[ConsistPartNames_ru-RU] = src.[ConsistPartNames_ru-RU]
  ,tgt.[MediaOrigin]= src.[MediaOrigin]
  ,tgt.[OrgCode]= src.[OrgCode]

From sissearch2.ExpandedMiningProductParts tgt
inner join #ConsolidatedEMP src on tgt.[ID] = src.[ID] --Existing
Where src.[InsertDate] > tgt.[InsertDate] --Updated in source
   or (tgt. [InformationType] <> src. [InformationType] or (tgt. [InformationType] is null and src. [InformationType] is not null) or (tgt. [InformationType] is not null and src. [InformationType] is null))
   or (tgt. [MediaNumber] <> src. [MediaNumber] or (tgt. [MediaNumber] is null and src. [MediaNumber] is not null) or (tgt. [MediaNumber] is not null and src. [MediaNumber] is null))
   or (tgt. [IEUpdateDate] <> src. [IEUpdateDate] or (tgt. [IEUpdateDate] is null and src. [IEUpdateDate] is not null) or (tgt. [IEUpdateDate] is not null and src. [IEUpdateDate] is null))
   or (tgt. [IEPart] <> src. [IEPart] or (tgt. [IEPart] is null and src. [IEPart] is not null) or (tgt. [IEPart] is not null and src. [IEPart] is null))
   or (tgt. [IEPartNumber] <> src. [IEPartNumber] or (tgt. [IEPartNumber] is null and src. [IEPartNumber] is not null) or (tgt. [IEPartNumber] is not null and src. [IEPartNumber] is null))
   or (tgt. [PartsManualMediaNumber] <> src. [PartsManualMediaNumber] or (tgt. [PartsManualMediaNumber] is null and src. [PartsManualMediaNumber] is not null) or (tgt. [PartsManualMediaNumber] is not null and src. [PartsManualMediaNumber] is null))
   or (tgt. [IECaption] <> src. [IECaption] or (tgt. [IECaption] is null and src. [IECaption] is not null) or (tgt. [IECaption] is not null and src. [IECaption] is null))
   or (tgt. [ConsistPart] <> src. [ConsistPart] or (tgt. [ConsistPart] is null and src. [ConsistPart] is not null) or (tgt. [ConsistPart] is not null and src. [ConsistPart] is null))
   or (tgt. [System] <> src. [SystemPSID] or (tgt. [System] is null and src. [SystemPSID] is not null) or (tgt. [System] is not null and src. [SystemPSID] is null))
   or (tgt. [SystemPSID] <> src. [SystemPSID] or (tgt. [SystemPSID] is null and src. [SystemPSID] is not null) or (tgt. [SystemPSID] is not null and src. [SystemPSID] is null))
   or (tgt. [PSID] <> src. [PSID] or (tgt. [PSID] is null and src. [PSID] is not null) or (tgt. [PSID] is not null and src. [PSID] is null))
   or (tgt. [SerialNumbers] <> src. [SerialNumbers] or (tgt. [SerialNumbers] is null and src. [SerialNumbers] is not null) or (tgt. [SerialNumbers] is not null and src. [SerialNumbers] is null))
   or (tgt. [ProductInstanceNumbers] <> src. [ProductInstanceNumbers] or (tgt. [ProductInstanceNumbers] is null and src. [ProductInstanceNumbers] is not null) or (tgt. [ProductInstanceNumbers] is not null and src. [ProductInstanceNumbers] is null))
   or (tgt. [isMedia] <> src. [isMedia] or (tgt. [isMedia] is null and src. [isMedia] is not null) or (tgt. [isMedia] is not null and src. [isMedia] is null))
   or (tgt. [PubDate] <> src. [PubDate] or (tgt. [PubDate] is null and src. [PubDate] is not null) or (tgt. [PubDate] is not null and src. [PubDate] is null))
   or (tgt. [ControlNumber] <> src. [ControlNumber] or (tgt. [ControlNumber] is null and src. [ControlNumber] is not null) or (tgt. [ControlNumber] is not null and src. [ControlNumber] is null))
   or (tgt. [familyCode] <> src. [familyCode] or (tgt. [familyCode] is null and src. [familyCode] is not null) or (tgt. [familyCode] is not null and src. [familyCode] is null))
   or (tgt. [familySubFamilyCode] <> src. [familySubFamilyCode] or (tgt. [familySubFamilyCode] is null and src. [familySubFamilyCode] is not null) or (tgt. [familySubFamilyCode] is not null and src. [familySubFamilyCode] is null))
   or (tgt. [familySubFamilySalesModel] <> src. [familySubFamilySalesModel] or (tgt. [familySubFamilySalesModel] is null and src. [familySubFamilySalesModel] is not null) or (tgt. [familySubFamilySalesModel] is not null and src. [familySubFamilySalesModel] is null))
   or (tgt. [familySubFamilySalesModelSNP] <> src. [familySubFamilySalesModelSNP] or (tgt. [familySubFamilySalesModelSNP] is null and src. [familySubFamilySalesModelSNP] is not null) or (tgt. [familySubFamilySalesModelSNP] is not null and src. [familySubFamilySalesModelSNP] is null))
   or (tgt. [ConsistPartNames_es-ES] <> src. [ConsistPartNames_es-ES] or (tgt. [ConsistPartNames_es-ES] is null and src. [ConsistPartNames_es-ES] is not null) or (tgt. [ConsistPartNames_es-ES] is not null and src. [ConsistPartNames_es-ES] is null))
   or (tgt. [ConsistPartNames_zh-CN] <> src. [ConsistPartNames_zh-CN] or (tgt. [ConsistPartNames_zh-CN] is null and src. [ConsistPartNames_zh-CN] is not null) or (tgt. [ConsistPartNames_zh-CN] is not null and src. [ConsistPartNames_zh-CN] is null))
   or (tgt. [ConsistPartNames_fr-FR] <> src. [ConsistPartNames_fr-FR] or (tgt. [ConsistPartNames_fr-FR] is null and src. [ConsistPartNames_fr-FR] is not null) or (tgt. [ConsistPartNames_fr-FR] is not null and src. [ConsistPartNames_fr-FR] is null))
   or (tgt. [ConsistPartNames_it-IT] <> src. [ConsistPartNames_it-IT] or (tgt. [ConsistPartNames_it-IT] is null and src. [ConsistPartNames_it-IT] is not null) or (tgt. [ConsistPartNames_it-IT] is not null and src. [ConsistPartNames_it-IT] is null))
   or (tgt. [ConsistPartNames_de-DE] <> src. [ConsistPartNames_de-DE] or (tgt. [ConsistPartNames_de-DE] is null and src. [ConsistPartNames_de-DE] is not null) or (tgt. [ConsistPartNames_de-DE] is not null and src. [ConsistPartNames_de-DE] is null))
   or (tgt. [ConsistPartNames_pt-BR] <> src. [ConsistPartNames_pt-BR] or (tgt. [ConsistPartNames_pt-BR] is null and src. [ConsistPartNames_pt-BR] is not null) or (tgt. [ConsistPartNames_pt-BR] is not null and src. [ConsistPartNames_pt-BR] is null))
   or (tgt. [ConsistPartNames_id-ID] <> src. [ConsistPartNames_id-ID] or (tgt. [ConsistPartNames_id-ID] is null and src. [ConsistPartNames_id-ID] is not null) or (tgt. [ConsistPartNames_id-ID] is not null and src. [ConsistPartNames_id-ID] is null))
   or (tgt. [ConsistPartNames_ja-JP] <> src. [ConsistPartNames_ja-JP] or (tgt. [ConsistPartNames_ja-JP] is null and src. [ConsistPartNames_ja-JP] is not null) or (tgt. [ConsistPartNames_ja-JP] is not null and src. [ConsistPartNames_ja-JP] is null))
   or (tgt. [ConsistPartNames_ru-RU] <> src. [ConsistPartNames_ru-RU] or (tgt. [ConsistPartNames_ru-RU] is null and src. [ConsistPartNames_ru-RU] is not null) or (tgt. [ConsistPartNames_ru-RU] is not null and src. [ConsistPartNames_ru-RU] is null))
   or (tgt. [MediaOrigin] <> src. [MediaOrigin] or (tgt. [MediaOrigin] is null and src. [MediaOrigin] is not null) or (tgt. [MediaOrigin] is not null and src. [MediaOrigin] is null))
   or (tgt. [OrgCode] <> src. [OrgCode] or (tgt. [OrgCode] is null and src. [OrgCode] is not null) or (tgt. [OrgCode] is not null and src. [OrgCode] is null))


Update tgt
Set
    tgt.[InsertDate] = src.[InsertDate]
  ,tgt.[InformationType] = src.[InformationType]
  ,tgt.[MediaNumber] = src.[MediaNumber]
  ,tgt.[IEUpdateDate] = src.[IEUpdateDate]
  ,tgt.[IEPart] = src.[IEPart]
  ,tgt.[PartsManualMediaNumber] = src.[PartsManualMediaNumber]
  ,tgt.[System] = src.[SystemPSID]
  ,tgt.[SystemPSID] = src.[SystemPSID]
  ,tgt.[PSID] = src.[PSID]
  ,tgt.[SerialNumbers] = src.[SerialNumbers]
  ,tgt.[ProductInstanceNumbers] = src.[ProductInstanceNumbers]
  ,tgt.[isMedia] = src.[isMedia]
  ,tgt.[familyCode] = src.[familyCode]
  ,tgt.[familySubFamilyCode] = src.[familySubFamilyCode]
  ,tgt.[familySubFamilySalesModel] = src.[familySubFamilySalesModel]
  ,tgt.[familySubFamilySalesModelSNP] = src.[familySubFamilySalesModelSNP]
  ,tgt.[MediaOrigin]= src.[MediaOrigin]
  ,tgt.[OrgCode]= src.[OrgCode]
From sissearch2.ExpandedMiningProductParts tgt
inner join #ConsolidatedPDF src on tgt.[ID] = src.[ID] --Existing
Where src.[InsertDate] > tgt.[InsertDate] --Updated in source
   or (tgt. [InformationType] <> src. [InformationType] or (tgt. [InformationType] is null and src. [InformationType] is not null) or (tgt. [InformationType] is not null and src. [InformationType] is null))
   or (tgt. [MediaNumber] <> src. [MediaNumber] or (tgt. [MediaNumber] is null and src. [MediaNumber] is not null) or (tgt. [MediaNumber] is not null and src. [MediaNumber] is null))
   or (tgt. [IEUpdateDate] <> src. [IEUpdateDate] or (tgt. [IEUpdateDate] is null and src. [IEUpdateDate] is not null) or (tgt. [IEUpdateDate] is not null and src. [IEUpdateDate] is null))
   or (tgt. [IEPart] <> src. [IEPart] or (tgt. [IEPart] is null and src. [IEPart] is not null) or (tgt. [IEPart] is not null and src. [IEPart] is null))
   or (tgt. [PartsManualMediaNumber] <> src. [PartsManualMediaNumber] or (tgt. [PartsManualMediaNumber] is null and src. [PartsManualMediaNumber] is not null) or (tgt. [PartsManualMediaNumber] is not null and src. [PartsManualMediaNumber] is null))
   or (tgt. [System] <> src. [SystemPSID] or (tgt. [System] is null and src. [SystemPSID] is not null) or (tgt. [System] is not null and src. [SystemPSID] is null))
   or (tgt. [SystemPSID] <> src. [SystemPSID] or (tgt. [SystemPSID] is null and src. [SystemPSID] is not null) or (tgt. [SystemPSID] is not null and src. [SystemPSID] is null))
   or (tgt. [PSID] <> src. [PSID] or (tgt. [PSID] is null and src. [PSID] is not null) or (tgt. [PSID] is not null and src. [PSID] is null))
   or (tgt. [SerialNumbers] <> src. [SerialNumbers] or (tgt. [SerialNumbers] is null and src. [SerialNumbers] is not null) or (tgt. [SerialNumbers] is not null and src. [SerialNumbers] is null))
   or (tgt. [ProductInstanceNumbers] <> src. [ProductInstanceNumbers] or (tgt. [ProductInstanceNumbers] is null and src. [ProductInstanceNumbers] is not null) or (tgt. [ProductInstanceNumbers] is not null and src. [ProductInstanceNumbers] is null))
   or (tgt. [isMedia] <> src. [isMedia] or (tgt. [isMedia] is null and src. [isMedia] is not null) or (tgt. [isMedia] is not null and src. [isMedia] is null))
   or (tgt. [familyCode] <> src. [familyCode] or (tgt. [familyCode] is null and src. [familyCode] is not null) or (tgt. [familyCode] is not null and src. [familyCode] is null))
   or (tgt. [familySubFamilyCode] <> src. [familySubFamilyCode] or (tgt. [familySubFamilyCode] is null and src. [familySubFamilyCode] is not null) or (tgt. [familySubFamilyCode] is not null and src. [familySubFamilyCode] is null))
   or (tgt. [familySubFamilySalesModel] <> src. [familySubFamilySalesModel] or (tgt. [familySubFamilySalesModel] is null and src. [familySubFamilySalesModel] is not null) or (tgt. [familySubFamilySalesModel] is not null and src. [familySubFamilySalesModel] is null))
   or (tgt. [familySubFamilySalesModelSNP] <> src. [familySubFamilySalesModelSNP] or (tgt. [familySubFamilySalesModelSNP] is null and src. [familySubFamilySalesModelSNP] is not null) or (tgt. [familySubFamilySalesModelSNP] is not null and src. [familySubFamilySalesModelSNP] is null))
   or (tgt. [MediaOrigin] <> src. [MediaOrigin] or (tgt. [MediaOrigin] is null and src. [MediaOrigin] is not null) or (tgt. [MediaOrigin] is not null and src. [MediaOrigin] is null))
   or (tgt. [OrgCode] <> src. [OrgCode] or (tgt. [OrgCode] is null and src. [OrgCode] is not null) or (tgt. [OrgCode] is not null and src. [OrgCode] is null))


--Insert new ID's
INSERT sissearch2.ExpandedMiningProductParts (
    [ID]
    ,[IESystemControlNumber]
    ,[InsertDate]
    ,[InformationType]
    ,[MediaNumber]
    ,[IEUpdateDate]
    ,[IEPart]
    ,[IEPartNumber]
    ,[PartsManualMediaNumber]
    ,[IECaption]
    ,[ConsistPart]
    ,[System]
    ,[SystemPSID]
    ,[PSID]
    ,[SerialNumbers]
    ,[ProductInstanceNumbers]
    ,[isMedia]
    ,[PubDate]
    ,[ControlNumber]
    ,[familyCode]
    ,[familySubFamilyCode]
    ,[familySubFamilySalesModel]
    ,[familySubFamilySalesModelSNP]
    ,[ConsistPartNames_es-ES]
    ,[ConsistPartNames_zh-CN]
    ,[ConsistPartNames_fr-FR]
    ,[ConsistPartNames_it-IT]
    ,[ConsistPartNames_de-DE]
    ,[ConsistPartNames_pt-BR]
    ,[ConsistPartNames_id-ID]
    ,[ConsistPartNames_ja-JP]
    ,[ConsistPartNames_ru-RU]
    ,[MediaOrigin]
    ,[OrgCode]
)
Select
    s.[ID]
    ,s.[IESystemControlNumber]
    ,s.[InsertDate]
    ,s.[InformationType]
    ,s.[MediaNumber]
    ,s.[IEUpdateDate]
    ,s.[IEPart]
    ,s.[IEPartNumber]
    ,s.[PartsManualMediaNumber]
    ,s.[IECaption]
    ,s.[ConsistPart]
    ,s.[SystemPSID]
    ,s.[SystemPSID]
    ,s.[PSID]
    ,s.[SerialNumbers]
    ,s.[ProductInstanceNumbers]
    ,s.[isMedia]
    ,s.[PubDate]
    ,s.[ControlNumber]
    ,s.[familyCode]
    ,s.[familySubFamilyCode]
    ,s.[familySubFamilySalesModel]
    ,s.[familySubFamilySalesModelSNP]
    ,s.[ConsistPartNames_es-ES]
    ,s.[ConsistPartNames_zh-CN]
    ,s.[ConsistPartNames_fr-FR]
    ,s.[ConsistPartNames_it-IT]
    ,s.[ConsistPartNames_de-DE]
    ,s.[ConsistPartNames_pt-BR]
    ,s.[ConsistPartNames_id-ID]
    ,s.[ConsistPartNames_ja-JP]
    ,s.[ConsistPartNames_ru-RU]
    ,s.[MediaOrigin]
    ,s.[OrgCode]
From #ConsolidatedEMP s
Left outer join sissearch2.ExpandedMiningProductParts t on s.[ID] = t.[ID]
Where t.[ID] is null --Does not exist in target

--Insert new ID's
INSERT sissearch2.ExpandedMiningProductParts (
    [ID]
    ,[InsertDate]
    ,[InformationType]
    ,[MediaNumber]
    ,[IEUpdateDate]
    ,[IEPart]
    ,[PartsManualMediaNumber]
    ,[System]
    ,[SystemPSID]
    ,[PSID]
    ,[SerialNumbers]
    ,[ProductInstanceNumbers]
    ,[isMedia]
    ,[familyCode]
    ,[familySubFamilyCode]
    ,[familySubFamilySalesModel]
    ,[familySubFamilySalesModelSNP]
    ,[MediaOrigin]
    ,[OrgCode]
    )
Select
    s.[ID]
     ,s.[InsertDate]
     ,s.[InformationType]
     ,s.[MediaNumber]
     ,s.[IEUpdateDate]
     ,s.[IEPart]
     ,s.[PartsManualMediaNumber]
     ,s.[SystemPSID]
     ,s.[SystemPSID]
     ,s.[PSID]
     ,s.[SerialNumbers]
     ,s.[ProductInstanceNumbers]
     ,s.[isMedia]
     ,s.[familyCode]
     ,s.[familySubFamilyCode]
     ,s.[familySubFamilySalesModel]
     ,s.[familySubFamilySalesModelSNP]
     ,s.[MediaOrigin]
     ,s.[OrgCode]
From #ConsolidatedPDF s
Left Outer join sissearch2.ExpandedMiningProductParts t on s.[ID] = t.[ID]
Where t.[ID] is null --Does not exist in target

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Target [sissearch2].[ExpandedMiningProductParts_LOAD]', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--Array of GraphicControlNumber
--All IDs have been inserted. Next we need to get an array of GraphicControlNumbers and update the GraphicControlNumber field.

If Object_ID('Tempdb..#RecordsToString_GCN') is not null
  Begin
     Drop table #RecordsToString_GCN
  End;

Select MS.IESystemControlNumber As ID,
    I.Graphic_Control_Number As GraphicControlNumber
into #RecordsToString_GCN
From [sis_shadow].[MediaSequence] MS
inner join [sis].[IEPart] IP on IP.IEPart_ID = MS.IEPart_ID
inner join #InsertRecords IR on IR.IESystemControlNumber = MS.IESystemControlNumber
inner join [sis].[MediaSection] MSec on MSec.MediaSection_ID = MS.MediaSection_ID
inner join [sis].[Media] M on M.Media_ID = MSec.Media_ID and M.Source = 'N'
inner join [sis].[Media_Translation] MT on MT.Media_ID = M.Media_ID and MT.Media_Origin = 'EM'
inner join sis.IEPart_Illustration_Relation IIR ON IIR.IEPart_ID = MS.IEPart_ID
inner join sis.Illustration I ON I.Illustration_ID = IIR.Illustration_ID
Group By MS.IESystemControlNumber, I.Graphic_Control_Number

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count (GraphicControlNumber): ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Loaded to Temp #RecordsToString_GCN (GraphicControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID]
ON #RecordsToString_GCN ([ID] ASC)
INCLUDE (GraphicControlNumber)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp (GraphicControlNumber)'

--Records to String
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToStringResult_GCN') is not null
  Begin
     Drop table #RecordsToStringResult_GCN
  End;

Select [ID],
    coalesce(f.GraphicControlNumberString,'') As [GraphicControlNumber]
into #RecordsToStringResult_GCN
From #RecordsToString_GCN a
CROSS apply
	(
		SELECT '[' + stuff (
			(
				SELECT  '","' + cast(GraphicControlNumber AS varchar(max))
				FROM	#RecordsToString_GCN AS b
                WHERE    a.Id = b.Id
                ORDER BY b.Id, cast(GraphicControlNumber as varchar(MAX))
				FOR xml path(''), type).value('.', 'varchar(max)') ,1,2,''
			) + '"'+']'
	) f (GraphicControlNumberString)
Group By [ID], f.GraphicControlNumberString

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult_GCN Count (GraphicControlNumber): ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Temp RecordsToStringResult_GCN (GraphicControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--Add pkey to result
Alter Table #RecordsToStringResult_GCN Alter Column ID varchar(50) Not NULL
ALTER TABLE #RecordsToStringResult_GCN ADD PRIMARY KEY CLUSTERED (ID)
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult_GCN (GraphicControlNumber)'

--Insert result into target
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

--All IDs have been inserted already.  Update with ControlNumber Array.
Update EMP
Set EMP.GraphicControlNumber = nullif(nullif(R.GraphicControlNumber, ''), '[""]')
From [sissearch2].[ExpandedMiningProductParts] EMP
Inner join #RecordsToStringResult_GCN R on EMP.ID = R.ID

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Updated Target Count (GraphicControlNumber): ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated Target [sissearch2].[ExpandedMiningProductParts] (GraphicControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LOGID = @SPStartLogID, @DATAVALUE = @RowCount

/*---------------
End of EXPANDEDMININGPRODUCTPARTS table load, total time including all sub-tables ~ 12 Min
  Note: Metrics were calculated on SB2 Database
 ----------------*/

END TRY

BEGIN CATCH
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT= ERROR_LINE()

Declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC sissearch2.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error

END CATCH

End
