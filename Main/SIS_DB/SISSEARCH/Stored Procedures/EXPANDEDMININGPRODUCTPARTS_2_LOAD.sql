CREATE Procedure [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2_LOAD]
As
/*---------------
Date: 26-05-2022
Object Description:  Loading changed data into SISSEARCH.EXPANDEDMININGPRODUCTPARTS_2 from base tables
Modified By: Kishor Padmanabhan
Modified On: 20221012
Modified Reason: Exclude Null values for InformationType and MediaNumber
Associated WI: 22910
Modified On:08312023 to implement function for repetitive logic and add additional logging
Exec [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2_LOAD]
Truncate table [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]
---------------*/

Begin

BEGIN TRY

SET NOCOUNT ON

Declare
@LastInsertDate Datetime

Declare
@SPStartTime DATETIME,
		@StepStartTime DATETIME,
		@ProcName VARCHAR(200),
		@SPStartLogID BIGINT,
		@StepLogID BIGINT,
		@RowCount BIGINT,
		@LAPSETIME BIGINT
SET @SPStartTime= GETDATE()
SET @ProcName= OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)

--Identify Deleted Records From Source. The table #DeletedRecords has details of the  Iesystemcontrolnumber which exist in [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2] but not present in [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART]

EXEC @SPStartLogID = SISSEARCH.WriteLog @TIME = @SPStartTime, @NAMEOFSPROC = @ProcName;

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#DeletedRecords') is not null
Begin
Drop table #DeletedRecords
End
Select distinct Iesystemcontrolnumber
into #DeletedRecords
from [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2] where Iesystemcontrolnumber is not null
Except
Select IESYSTEMCONTROLNUMBER
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART]

--Identify Deleted Parts PDF Records in [SISWEB_OWNER_SHADOW].[PARTSPDF] which exist in [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]
    If Object_ID('Tempdb..#DeletedRecordsPartsPDF') is not null
Begin
Drop table #DeletedRecordsPartsPDF
End
Select distinct ID
into #DeletedRecordsPartsPDF
from [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2] where isMedia=1
Except
Select PARTSPDF_ID
from [SISWEB_OWNER_SHADOW].[PARTSPDF]


SET @RowCount= @@RowCount
SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Records Identified',@DATAVALUE = @RowCount, @LOGID = @StepLogID


-- Delete the Identified DeletedRecords in Target Table [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete
from
    [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]
where Iesystemcontrolnumber is not null and  Iesystemcontrolnumber in (Select Iesystemcontrolnumber From #DeletedRecords)

SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Identified Deleted Records were deleted from [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

-- Delete the Identified DeletedRecords in Target Table [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


Delete
from
    [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]
where isMedia=1 and ID in (Select ID From #DeletedRecordsPartsPDF)

SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Identified Deleted Records related to Parts PDF were deleted from [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Get Maximum insert date from Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select @LastInsertDate = coalesce(Max(INSERTDATE), '1900-01-01')
From [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
Declare @Logmessage as varchar(50) = 'Latest Insert Date in Target '+cast (@LastInsertDate as varchar(25))
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = @Logmessage , @LOGID = @StepLogID

--Identify Inserted records from Source (Records from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] created after the max date  in the table [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]) 

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#InsertRecords') is not null
Begin
Drop table #InsertRecords
End
Select IESYSTEMCONTROLNUMBER
into #InsertRecords
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART]
where LASTMODIFIEDDATE > @LastInsertDate

SET @RowCount= @@RowCount
SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Detected into  #InsertRecords',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Identify Inserted records from Source (Records from [SISWEB_OWNER_SHADOW].[PARTSPDF] created after the max date  in the table [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]) 

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

    If Object_ID('Tempdb..#InsertRecordsPartsPDF') is not null
Begin
Drop table #InsertRecordsPartsPDF
End
Select PARTSPDF_ID
into #InsertRecordsPartsPDF
from SISWEB_OWNER_SHADOW.PARTSPDF
where LASTMODIFIEDDATE > @LastInsertDate;

SET @RowCount= @@RowCount
SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Detected into  #InsertRecordsPartsPDF',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Creating Non-Clustered Index on temp table #InsertRecords
CREATE
NONCLUSTERED INDEX NIX_InsertRecords_iesystemcontrolnumber
    ON #InsertRecords(IESYSTEMCONTROLNUMBER)

--Delete Inserted records from Target in case an entry is present with the idea that the corresponding data will be loaded again in this procedure. 
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete
from [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]
where Iesystemcontrolnumber in
    (Select IESYSTEMCONTROLNUMBER from #InsertRecords)

SET @RowCount= @@RowCount
SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Inserted Records from [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Delete Parts PDF Inserted records from Target in case an entry is present with the idea that the corresponding data will be loaded again in this procedure. 
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


Delete
from [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]
where isMedia=1 and ID in
    (Select PARTSPDF_ID from #InsertRecordsPartsPDF)

SET @RowCount= @@RowCount
SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Parts PDF Inserted Records from [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


--Create Temp table and Load Basic Parts data that's specific to EMP

	DROP TABLE IF EXISTS #EMPBasicParts;
Select
    x.[IESYSTEMCONTROLNUMBER]
     , x.[InformationType]
     , x.[medianumber]
     , x.ieupdatedate
     , x.iepart
     , x.iepartnumber
     , x.[PARTSMANUALMEDIANUMBER]
     , x.[IECAPTION]
     , x.[InsertDate]
     , x.[PubDate]
     , 0 [isMedia]
		, x.ControlNumber
		, x.[mediaOrigin]
		, x.[orgCode]
into #EMPBasicParts
From
    (
    select distinct
    b.IESYSTEMCONTROLNUMBER as IESYSTEMCONTROLNUMBER,
    '[''5'']' As InformationType, -- Information type for EMP parts
     coalesce ('['+'"'+[SISSEARCH].[fn_replace_special_characters] (b.medianumber,0)+'"'+']', '')  as medianumber,
    isnull(d.dateupdated, '1900-01-01') as ieupdatedate,
	         [SISSEARCH].[fn_replace_special_characters] (isnull(b.iepartnumber, '')+':'+isnull(b.iepartname, '') +
    iif(isnull(b.iepartmodifier, '') != '', ' '+b.iepartmodifier, ''),0) as iepart,
    b.iepartnumber as iepartnumber,
     coalesce ('['+'"'+[SISSEARCH].[fn_replace_special_characters] (b.medianumber,0)+'"'+']', '') as PARTSMANUALMEDIANUMBER
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
    b.IECAPTION
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
        , '@@@@@', ' ') As IECAPTION
        , b.LASTMODIFIEDDATE InsertDate
        , row_number() over (Partition by cast (b.IESYSTEMCONTROLNUMBER as VARCHAR) order by isnull(d.dateupdated, '1900-01-01') desc, b.LASTMODIFIEDDATE desc) RowRank
        , d.IEPUBDATE as [PubDate]
        , case when len(trim (b.IECONTROLNUMBER)) = 0 then null else
         coalesce ('['+'"'+ [SISSEARCH].[fn_replace_special_characters] (b.IECONTROLNUMBER,0)+'"'+']', '') END  as ControlNumber,
    e.MEDIAORIGIN [mediaOrigin],
    coalesce (b.ORGCODE, '') [orgCode]
    from [SISWEB_OWNER_SHADOW].LNKMEDIAIEPART b
    inner join #InsertRecords c --Add filter to limit to changed records
    on c.IESYSTEMCONTROLNUMBER=b.IESYSTEMCONTROLNUMBER
    left outer join [SISWEB_OWNER].LNKIEDATE d
    on b.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER and d.LANGUAGEINDICATOR='E'
    inner join [SISWEB_OWNER].[MASMEDIA] e
    on e.MEDIANUMBER=b.MEDIANUMBER
    where e.MEDIASOURCE = 'N' and e.MEDIAORIGIN = 'EM'
    ) x where x.RowRank = 1

SET @RowCount= @@RowCount
SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Create Temp table and Load Basic Parts data thats specific to EMP',@DATAVALUE = @RowCount, @LOGID = @StepLogID

-- This is for adding Parts PDF

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

DROP TABLE IF EXISTS #EMPPartsPDF;
Select
    x.[PARTSPDFID]
     , x.[InformationType]
     , x.[medianumber]
     , x.[ieupdatedate]
     , x.[iepart]
     , x.[PARTSMANUALMEDIANUMBER]
     , x.[InsertDate]
     , 1 [isMedia]
     , x.[mediaOrigin]
     , x.[orgCode]
into #EMPPartsPDF
From
    (
    select distinct
    b.PARTSPDF_ID as PARTSPDFID,
    '[''5'']' As InformationType, -- Information type for EMP parts
    coalesce ('['+'"'+[SISSEARCH].[fn_replace_special_characters] (d.MEDIANUMBER,0)+'"'+']', '') as medianumber,
    '1900-01-01' as ieupdatedate,
    d.PDFFILENAME as iepart,
    coalesce ('['+'"'+[SISSEARCH].[fn_replace_special_characters] (d.MEDIANUMBER,0)+'"'+']', '') as PARTSMANUALMEDIANUMBER,
         d.LASTMODIFIEDDATE InsertDate
        , e.MEDIAORIGIN [mediaOrigin],
    'CAT' As orgCode
    from [SISWEB_OWNER_SHADOW].LNKPARTSPDFPSID b
    inner join #InsertRecordsPartsPDF c --Add filter to limit to changed records
    on c.PARTSPDF_ID=b.PARTSPDF_ID
    left outer join [SISWEB_OWNER_SHADOW].PARTSPDF d
    on b.PARTSPDF_ID = d.PARTSPDF_ID and d.LANGUAGEINDICATOR='E'
    inner join [SISWEB_OWNER].[MASMEDIA] e
    on e.MEDIANUMBER=d.MEDIANUMBER
    where e.MEDIASOURCE = 'N' and e.MEDIAORIGIN = 'EM'
    ) x

SET @RowCount= @@RowCount
SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Create Temp table and Load Basic Parts data thats specific Parts PDF',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Create Non-Clustered Indexes on temp tables 
CREATE NONCLUSTERED INDEX NIX_EMPPartsPDF_id
    ON #EMPPartsPDF(PARTSPDFID)

CREATE NONCLUSTERED INDEX NIX_EMPBasicParts_iesystemcontrolnumber
    ON #EMPBasicParts(IESYSTEMCONTROLNUMBER)



--Load Consist Parts data that's specific to EMP

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

DROP TABLE IF EXISTS #EMPConsistParts;
DROP TABLE IF EXISTS #PreEMPConsistParts;
DROP TABLE IF EXISTS #CPRecordsToString;

SELECT b.IESYSTEMCONTROLNUMBER
     , b.LASTMODIFIEDDATE AS      INSERTDATE
     , d.PARTNUMBER
     , d.PARTNAME
     , d.PARTMODIFIER
     , t.TRANSLATEDPARTNAME
     , t.LANGUAGEINDICATOR
INTO #CPRecordsToString
FROM SISWEB_OWNER_SHADOW.LNKMEDIAIEPART AS b
         INNER JOIN SISWEB_OWNER.MASMEDIA AS e ON
            e.MEDIANUMBER = b.MEDIANUMBER
        AND e.MEDIASOURCE = 'N' AND e.MEDIAORIGIN ='EM'
         JOIN SISWEB_OWNER_SHADOW.LNKCONSISTLIST AS d ON b.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER
         LEFT JOIN SISWEB_OWNER.LNKTRANSLATEDSPN AS t ON d.PARTNAME = t.PARTNAME
WHERE b.IESYSTEMCONTROLNUMBER IN(SELECT IESYSTEMCONTROLNUMBER
                                 FROM #InsertRecords);

SELECT IESYSTEMCONTROLNUMBER
     , INSERTDATE
     , replace(replace(replace(replace(replace(replace(replace(replace(replace (replace(ISNULL(PARTNUMBER,'') + ':' + ISNULL(PARTNAME,'') + IIF(ISNULL(PARTMODIFIER,'') != '',' ' + PARTMODIFIER,''), '\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'. ', ' '),'"','\"'),'/','\/') AS CONSISTPART
     ,[SISSEARCH].[fn_replace_special_characters] ([8],0) AS [consistPartNames_id-ID]
	 ,[SISSEARCH].[fn_replace_special_characters] (C,0) AS [consistPartNames_zh-CN]
	 ,[SISSEARCH].[fn_replace_special_characters] (F,0) AS [consistPartNames_fr-FR]
	 ,[SISSEARCH].[fn_replace_special_characters] (G,0) AS [consistPartNames_de-DE]
	 ,[SISSEARCH].[fn_replace_special_characters] (L,0) AS [consistPartNames_it-IT]
	 ,[SISSEARCH].[fn_replace_special_characters] (P,0) AS [consistPartNames_pt-BR]
	 ,[SISSEARCH].[fn_replace_special_characters] (S,0) AS [consistPartNames_es-ES]
	 ,[SISSEARCH].[fn_replace_special_characters] (R,0) AS [consistPartNames_ru-RU]
	 ,[SISSEARCH].[fn_replace_special_characters] (J,0) AS [consistPartNames_ja-JP]
INTO #PreEMPConsistParts
FROM #CPRecordsToString PIVOT(MAX(TRANSLATEDPARTNAME) FOR LANGUAGEINDICATOR IN([8]
        ,C
        ,F
        ,G
        ,L
        ,P
        ,S
        ,R
        ,J)) AS pvt;
DROP TABLE IF EXISTS #CPRecordsToString;

SELECT
    a.[IESYSTEMCONTROLNUMBER],
    COALESCE('["' + STRING_AGG(CAST(CONSISTPART AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS CONSISTPART,
    COALESCE('["' + STRING_AGG(CAST([consistPartNames_id-ID] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_id-ID],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_zh-CN] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_zh-CN],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_fr-FR] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_fr-FR],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_de-DE] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_de-DE],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_it-IT] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_it-IT],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_pt-BR] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_pt-BR],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_es-ES] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_es-ES],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_ru-RU] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_ru-RU],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_ja-JP] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_ja-JP],
	min(a.[INSERTDATE]) INSERTDATE
--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
Into #EMPConsistParts
FROM #PreEMPConsistParts a
GROUP BY
    a.IESYSTEMCONTROLNUMBER

DROP TABLE IF EXISTS #PreEMPConsistParts;

--Create Non-Clustered Index on temp table

CREATE NONCLUSTERED INDEX NIX_EMPConsistParts_iesystemcontrolnumber
    ON #EMPConsistParts(IESYSTEMCONTROLNUMBER)

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Load Consist Parts data thats specific to EMP Parts',@DATAVALUE = NULL, @LOGID = @StepLogID



--Load Product Hierarchy data that's specific to EMP parts

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

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
    [Iesystemcontrolnumber] VARCHAR (50) NOT NULL,
    [familyCode] VARCHAR (MAX) NULL,
    [familySubFamilyCode] VARCHAR (MAX) NULL,
    [familySubFamilySalesModel] VARCHAR (MAX) NULL,
    [familySubFamilySalesModelSNP] VARCHAR (MAX) NULL,
    [InsertDate] DATETIME NOT NULL,
    PRIMARY KEY CLUSTERED ([Iesystemcontrolnumber] ASC)
    );


select
    a.IESYSTEMCONTROLNUMBER,
    [SISSEARCH].[fn_replace_special_characters] (c.Family_Code,1) as Family_Code,
    [SISSEARCH].[fn_replace_special_characters] (c.Subfamily_Code,1) as Subfamily_Code,
    [SISSEARCH].[fn_replace_special_characters] (b.Model,1) as Sales_Model,
    [SISSEARCH].[fn_replace_special_characters] (b.SNP,1) as Serial_Number_Prefix,
    d.LASTMODIFIEDDATE INSERTDATE
into #PHRecordsToString
from SISWEB_OWNER_SHADOW.LNKIEPRODUCTINSTANCE a
         inner join SISWEB_OWNER_SHADOW.EMPPRODUCTINSTANCE b on a.EMPPRODUCTINSTANCE_ID = b.EMPPRODUCTINSTANCE_ID
         inner join sis.vw_Product c on b.SNP=c.Serial_Number_Prefix
         inner join SISWEB_OWNER_SHADOW.LNKMEDIAIEPART d on a.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER
         inner join [SISWEB_OWNER].[MASMEDIA] e on e.MEDIANUMBER=d.MEDIANUMBER
    inner join #InsertRecords i on i.IESYSTEMCONTROLNUMBER = a.IESYSTEMCONTROLNUMBER
--Add filter to limit to changed records
where e.MEDIASOURCE = 'N' and e.MEDIAORIGIN = 'EM'
order by a.IESYSTEMCONTROLNUMBER, isnull(c.Family_Code,''), isnull(c.Subfamily_Code,''), isnull(b.Model,''),    isnull(b.SNP,'')

SET @RowCount= @@RowCount
SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Load Product Hierarchy data thats specific to EMP parts',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Created NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_PHRecordsToString_IESystemControlNumber]
ON #PHRecordsToString (IESYSTEMCONTROLNUMBER ASC)
INCLUDE (Family_Code, Subfamily_Code, Sales_Model, Serial_Number_Prefix, INSERTDATE)
Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

--Load Product Hierarchy data thats specific to EMP Parts PDF

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

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


select
    a.PARTSPDF_ID as PARTSPDFID,
	[SISSEARCH].[fn_replace_special_characters] (c.Family_Code,1) as Family_Code,
    [SISSEARCH].[fn_replace_special_characters] (c.Subfamily_Code,1) as Subfamily_Code,
    [SISSEARCH].[fn_replace_special_characters] (b.Model,1) as Sales_Model,
    [SISSEARCH].[fn_replace_special_characters] (b.SNP,1) as Serial_Number_Prefix,
    d.LASTMODIFIEDDATE INSERTDATE
into #PHRecordsToStringPDF
from SISWEB_OWNER_SHADOW.LNKPDFPRODUCTINSTANCE a
         inner join SISWEB_OWNER_SHADOW.EMPPRODUCTINSTANCE b on a.EMPPRODUCTINSTANCE_ID = b.EMPPRODUCTINSTANCE_ID
         inner join sis.vw_Product c on b.SNP=c.Serial_Number_Prefix
         inner join SISWEB_OWNER_SHADOW.PARTSPDF d on a.PARTSPDF_ID = d.PARTSPDF_ID
         inner join [SISWEB_OWNER].[MASMEDIA] e on e.MEDIANUMBER=d.MEDIANUMBER
    inner join #InsertRecordsPartsPDF i on i.PARTSPDF_ID = a.PARTSPDF_ID
--Add filter to limit to changed records
where e.MEDIASOURCE = 'N' and e.MEDIAORIGIN = 'EM'
 order by a.PARTSPDF_ID, isnull(c.Family_Code,''), isnull(c.Subfamily_Code,''),    isnull(b.Model,''),    isnull(b.SNP,'')

SET @RowCount= @@RowCount
SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Load Product Hierarchy data thats specific to EMP Parts PDF',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Create Non-Clustered Index to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_PHRecordsToStringPDF_PARTSPDF]
ON #PHRecordsToStringPDF (PARTSPDFID ASC)
INCLUDE (Family_Code, Subfamily_Code, Sales_Model, Serial_Number_Prefix, INSERTDATE)
Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

--Create Temptables to populate familyCode in the table [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

-- Family_Code
Select
    IESYSTEMCONTROLNUMBER,
    Family_Code,
    max(INSERTDATE) INSERTDATE
Into #PHRecordsToString_FM
From #PHRecordsToString
Group by IESYSTEMCONTROLNUMBER, Family_Code
Order by IESYSTEMCONTROLNUMBER, Family_Code

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_IeSystemControlNumber_FM]
ON #PHRecordsToString_FM (IESYSTEMCONTROLNUMBER ASC)
INCLUDE (Family_Code, INSERTDATE)
Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Family_Code'

    -- Family_Code_PDF
Select
    PARTSPDFID as PARTSPDFID,
    Family_Code,
    max(INSERTDATE) INSERTDATE
Into #PHRecordsToStringPDF_FM
From #PHRecordsToStringPDF
Group by PARTSPDFID, Family_Code
Order by PARTSPDFID, Family_Code

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToStringPDF_ID_FM]
ON #PHRecordsToStringPDF_FM (PARTSPDFID ASC)
INCLUDE (Family_Code, INSERTDATE)
Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Family_Code'


Select
    a.IESYSTEMCONTROLNUMBER,
    '["' + string_agg(a.Family_Code,'","')  WITHIN GROUP (ORDER BY a.Family_Code)  + '"]'  As RecordsToString,
    min(a.INSERTDATE) INSERTDATE
--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into #PHRecordsToStringResult
from #PHRecordsToString_FM a
Group by
    a.IESYSTEMCONTROLNUMBER
Order by
    a.IESYSTEMCONTROLNUMBER

Select
    a.PARTSPDFID as PARTSPDFID,
    '["' + string_agg(a.Family_Code,'","')  WITHIN GROUP (ORDER BY a.Family_Code) + '"]'  As RecordsToString,
    min(a.INSERTDATE) INSERTDATE
--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into #PHRecordsToStringResultPDF
from #PHRecordsToStringPDF_FM a
Group by
    a.PARTSPDFID
Order by 
	a.PARTSPDFID

--Add pkey to result
Alter Table #PHRecordsToStringResult Alter Column IESYSTEMCONTROLNUMBER varchar(50) Not NULL
ALTER TABLE #PHRecordsToStringResult ADD PRIMARY KEY CLUSTERED (IESYSTEMCONTROLNUMBER)
    Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

    Insert into #EMPProductHierarchy
    (Iesystemcontrolnumber,familyCode,InsertDate)
Select IESYSTEMCONTROLNUMBER, RecordsToString, INSERTDATE
from #PHRecordsToStringResult

--Add pkey to result PDF
ALTER TABLE #PHRecordsToStringResultPDF ADD PRIMARY KEY CLUSTERED (PARTSPDFID)
    Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

    Insert into #EMPProductHierarchyPDF
    (PARTSPDFID,familyCode,InsertDate)
Select PARTSPDFID, RecordsToString, INSERTDATE
from #PHRecordsToStringResultPDF


--Drop temp
Drop table #PHRecordsToStringResult
Drop table #PHRecordsToString_FM
Drop table #PHRecordsToStringResultPDF
Drop table #PHRecordsToStringPDF_FM

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Create Temptables to populate familyCode in the table [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]',@DATAVALUE = NULL, @LOGID = @StepLogID

--Create Temp tables to populate familySubfamilyCode in the table [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

-- Subfamily_Code
Select
    IESYSTEMCONTROLNUMBER,
    cast(Family_Code + '_' + Subfamily_Code as varchar(MAX)) RTS,
    max(INSERTDATE) INSERTDATE
Into #PHRecordsToString_SF
From #PHRecordsToString
Group by IESYSTEMCONTROLNUMBER, Family_Code, Subfamily_Code
Order by IESYSTEMCONTROLNUMBER, Family_Code, Subfamily_Code

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_IESystemControlNumber_SF]
ON #PHRecordsToString_SF (IESYSTEMCONTROLNUMBER ASC)
INCLUDE (RTS, INSERTDATE)
Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Subfamily_Code'


-- Subfamily_Code_PDF
Select
    PARTSPDFID as PARTSPDFID,
    cast(Family_Code + '_' + Subfamily_Code as varchar(MAX)) RTS,
    max(INSERTDATE) INSERTDATE
Into #PHRecordsToStringPDF_SF
From #PHRecordsToStringPDF
Group by PARTSPDFID, Family_Code, Subfamily_Code
Order by PARTSPDFID, Family_Code, Subfamily_Code

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToStringPDF_ID_SF]
ON #PHRecordsToStringPDF_SF (PARTSPDFID ASC)
INCLUDE (RTS, INSERTDATE)
Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Subfamily_Code'

Select
    a.IESYSTEMCONTROLNUMBER,
    '["' + string_agg(a.RTS,'","') WITHIN GROUP (ORDER BY a.RTS) + '"]'  As RecordsToString,
    min(a.INSERTDATE) INSERTDATE
--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into #PHRecordsToStringResult_SF
from #PHRecordsToString_SF a
Group by
    a.IESYSTEMCONTROLNUMBER

--Add pkey to result
Alter Table  #PHRecordsToStringResult_SF Alter Column IESYSTEMCONTROLNUMBER varchar(50) Not NULL
ALTER TABLE  #PHRecordsToStringResult_SF ADD PRIMARY KEY CLUSTERED (IESYSTEMCONTROLNUMBER)
    Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

Update x
set familySubFamilyCode = y.RecordsToString
    From #EMPProductHierarchy  x
	inner join #PHRecordsToStringResult_SF y on x.IESYSTEMCONTROLNUMBER = y.IESYSTEMCONTROLNUMBER

Select
    a.PARTSPDFID as PARTSPDFID,
    '["' + string_agg(a.RTS,'","') WITHIN GROUP (ORDER BY a.RTS) + '"]'  As RecordsToString,
    min(a.INSERTDATE) INSERTDATE
--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into #PHRecordsToStringResultPDF_SF
from #PHRecordsToStringPDF_SF a
Group by
    a.PARTSPDFID

--Add pkey to result
Alter Table  #PHRecordsToStringResultPDF_SF Alter Column PARTSPDFID varchar(50) Not NULL
ALTER TABLE  #PHRecordsToStringResultPDF_SF ADD PRIMARY KEY CLUSTERED (PARTSPDFID)
    Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

Update x
set familySubFamilyCode = y.RecordsToString
    From #EMPProductHierarchyPDF  x
	inner join #PHRecordsToStringResultPDF_SF y on x.PARTSPDFID = y.PARTSPDFID

--Drop temp
Drop table #PHRecordsToStringResult_SF
Drop table #PHRecordsToString_SF
Drop table #PHRecordsToStringResultPDF_SF
Drop table #PHRecordsToStringPDF_SF

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Create Temp tables to populate familySubfamilyCode in the table [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]',@DATAVALUE = NULL, @LOGID = @StepLogID

--Create Temp tables to populate familySubfamilySalesModel in the table [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


Declare @LoopCount int = 0
Declare @BatchInsertCount int = 0
Declare @BatchProcessCount int = 0
Declare @BatchCount int = 100000
--Each loop will process this number of IDs
Declare @UpdateCount int = 0

-- Sales_Model
Select
    IESYSTEMCONTROLNUMBER,
    cast(Family_Code + '_' + Subfamily_Code + '_' + Sales_Model as varchar(MAX)) RTS,
    max(INSERTDATE) INSERTDATE
Into #PHRecordsToString_SM
From #PHRecordsToString
Group by IESYSTEMCONTROLNUMBER, Family_Code, Subfamily_Code, Sales_Model
ORDER BY IESYSTEMCONTROLNUMBER, Family_Code, Subfamily_Code, Sales_Model

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_IESystemControlNumber_SM]
ON #PHRecordsToString_SM (IESYSTEMCONTROLNUMBER ASC)
INCLUDE (RTS, INSERTDATE)
Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Sales_Model'

    -- Sales_Model_PDF
Select
    PARTSPDFID as PARTSPDFID,
    cast(Family_Code + '_' + Subfamily_Code + '_' + Sales_Model as varchar(MAX)) RTS,
    max(INSERTDATE) INSERTDATE
Into #PHRecordsToStringPDF_SM
From #PHRecordsToStringPDF
Group by PARTSPDFID, Family_Code, Subfamily_Code, Sales_Model
Order by PARTSPDFID, Family_Code, Subfamily_Code, Sales_Model

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToStringPDF_ID_SM]
ON #PHRecordsToStringPDF_SM (PARTSPDFID ASC)
INCLUDE (RTS, INSERTDATE)
Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Sales_Model'


Create table #PHRecordsToStringResult_SM
(
    IESYSTEMCONTROLNUMBER varchar(50) not null,
    RecordsToString varchar(max) null,
	INSERTDATE datetime not null
)

Create table #PHRecordsToStringResultPDF_SM
(
    PARTSPDFID varchar(50) not null,
    RecordsToString varchar(max) null,
	INSERTDATE datetime not null
)
--Add pkey to result
Alter Table  #PHRecordsToStringResult_SM Alter Column IESYSTEMCONTROLNUMBER varchar(50) Not NULL
ALTER TABLE  #PHRecordsToStringResult_SM ADD PRIMARY KEY CLUSTERED (IESYSTEMCONTROLNUMBER)
    Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

ALTER TABLE  #PHRecordsToStringResultPDF_SM ADD PRIMARY KEY CLUSTERED (PARTSPDFID)
    Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

    While (Select count(*)
    from #PHRecordsToString_SM) > 0
		Begin

			Insert into #PHRecordsToStringResult_SM
			Select
			a.IESYSTEMCONTROLNUMBER,
			'["' + string_agg(a.RTS,'","') WITHIN GROUP (ORDER BY a.RTS)  + '"]'  As RecordsToString,
			min(a.INSERTDATE) INSERTDATE
			--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
			from    (Select top (@BatchCount) With Ties
					*
					From #PHRecordsToString_SM
					order by IESYSTEMCONTROLNUMBER
					) a
			Group by
			a.IESYSTEMCONTROLNUMBER

			Set @BatchInsertCount = @@ROWCOUNT
			SET @RowCount= @RowCount + @BatchInsertCount
			Set @LoopCount = @LoopCount + 1

		    Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Sales_Model, Count: ' + Cast(@BatchInsertCount as varchar(50))

			Update x
			set familySubFamilySalesModel = y.RecordsToString
			From #EMPProductHierarchy  x
			inner join #PHRecordsToStringResult_SM y on x.IESYSTEMCONTROLNUMBER = y.IESYSTEMCONTROLNUMBER

			Delete a
			From #PHRecordsToString_SM a
			inner join (Select Distinct IESYSTEMCONTROLNUMBER
			From
				(Select top (@BatchCount) with Ties
					IESYSTEMCONTROLNUMBER
					From #PHRecordsToString_SM
					order by IESYSTEMCONTROLNUMBER) x
				) b 
			on a.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER

			Set @BatchProcessCount = @@ROWCOUNT
			Print cast(getdate() as varchar(50)) + ' - Total Update Count: ' + Cast(@RowCount as varchar(50)) + ' | Loop Count: ' + Cast(@LoopCount as varchar(50)) + ' | Batch Update Count: ' + Cast(@BatchInsertCount as varchar(50)) + ' | Batch Rows Processed: ' + Cast(@BatchProcessCount as varchar(50))

			Truncate table #PHRecordsToStringResult_SM

	End
--End of records to string loop

    While (Select count(*)
               from #PHRecordsToStringPDF_SM) > 0
		Begin

			Insert into #PHRecordsToStringResultPDF_SM
			Select
			a.PARTSPDFID,
			'["' + string_agg(a.RTS,'","')WITHIN GROUP (ORDER BY a.RTS)  + '"]'  As RecordsToString,
			min(a.INSERTDATE) INSERTDATE
			--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
			from (Select top (@BatchCount) With Ties
				*
			From #PHRecordsToStringPDF_SM
			order by PARTSPDFID) a
			Group by
			a.PARTSPDFID

			Set @BatchInsertCount = @@ROWCOUNT
			SET @RowCount= @RowCount + @BatchInsertCount
			Set @LoopCount = @LoopCount + 1

			Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Sales_Model, Count: ' + Cast(@BatchInsertCount as varchar(50))

			Update x
			set familySubFamilySalesModel = y.RecordsToString
			From #EMPProductHierarchyPDF  x
			inner join #PHRecordsToStringResultPDF_SM y on x.PARTSPDFID = y.PARTSPDFID

			Delete a
			From #PHRecordsToStringPDF_SM a
			inner join (Select Distinct PARTSPDFID
			From
			(Select top (@BatchCount) with Ties
				PARTSPDFID
			From #PHRecordsToStringPDF_SM
			order by PARTSPDFID) x
			) b 
			on a.PARTSPDFID = b.PARTSPDFID

			Set @BatchProcessCount = @@ROWCOUNT
			Print cast(getdate() as varchar(50)) + ' - Total Update Count: ' + Cast(@RowCount as varchar(50)) + ' | Loop Count: ' + Cast(@LoopCount as varchar(50)) + ' | Batch Update Count: ' + Cast(@BatchInsertCount as varchar(50)) + ' | Batch Rows Processed: ' + Cast(@BatchProcessCount as varchar(50))

			Truncate table #PHRecordsToStringResultPDF_SM
			
		End
		

--Drop temp
Drop table #PHRecordsToStringResult_SM
Drop table #PHRecordsToString_SM
Drop table #PHRecordsToStringResultPDF_SM
Drop table #PHRecordsToStringPDF_SM

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Create Temp tables to populate familySubfamilySalesModel in the table [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]',@DATAVALUE = NULL, @LOGID = @StepLogID


--Create Temp tables to populate familySubfamilySNP in the table [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

--SNP
Select
    IESYSTEMCONTROLNUMBER,
    cast(Family_Code + '_' + Subfamily_Code + '_' + Sales_Model + '_' + Serial_Number_Prefix as varchar(MAX)) RTS,
    max(INSERTDATE) INSERTDATE
Into #PHRecordsToString_SNP
From #PHRecordsToString
Group by IESYSTEMCONTROLNUMBER, Family_Code, Subfamily_Code, Sales_Model, Serial_Number_Prefix
Order by IESYSTEMCONTROLNUMBER, Family_Code, Subfamily_Code, Sales_Model, Serial_Number_Prefix

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_IESystemControlNumber_SNP]
ON #PHRecordsToString_SNP (IESYSTEMCONTROLNUMBER ASC)
INCLUDE (RTS, INSERTDATE)
Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Sales_Model'
SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Populated data and Nonclustered index added for #PHRecordsToString_SNP',@DATAVALUE = NULL, @LOGID = @StepLogID


SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

    --SNP-PDF
Select
    PARTSPDFID as PARTSPDFID,
    cast(Family_Code + '_' + Subfamily_Code + '_' + Sales_Model + '_' + Serial_Number_Prefix as varchar(MAX)) RTS,
    max(INSERTDATE) INSERTDATE
Into #PHRecordsToStringPDF_SNP
From #PHRecordsToStringPDF
Group by PARTSPDFID, Family_Code, Subfamily_Code, Sales_Model, Serial_Number_Prefix
Order by PARTSPDFID, Family_Code, Subfamily_Code, Sales_Model, Serial_Number_Prefix

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToStringPDF_ID_SNP]
ON #PHRecordsToStringPDF_SNP (PARTSPDFID ASC)
INCLUDE (RTS, INSERTDATE)
Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Sales_Model'

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Populated data and Nonclustered index added for #PHRecordsToStringPDF_SNP',@DATAVALUE = NULL, @LOGID = @StepLogID

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Create table #PHRecordsToStringResult_SNP
(
    IESYSTEMCONTROLNUMBER varchar(50) not null,
    RecordsToString varchar(max) null,
	INSERTDATE datetime not null
)

--Add pkey to result
Alter Table  #PHRecordsToStringResult_SNP Alter Column IESYSTEMCONTROLNUMBER varchar(50) Not NULL
ALTER TABLE  #PHRecordsToStringResult_SNP ADD PRIMARY KEY CLUSTERED (IESYSTEMCONTROLNUMBER)
    Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

    While (Select count(*)
		from #PHRecordsToString_SNP) > 0
		Begin

			Insert into #PHRecordsToStringResult_SNP
			Select
			a.IESYSTEMCONTROLNUMBER,
			'["' + string_agg(a.RTS,'","') WITHIN GROUP (ORDER BY a.RTS) + '"]'  As RecordsToString,
			min(a.INSERTDATE) INSERTDATE
			--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
			from (Select top (@BatchCount) With Ties
				*
			From #PHRecordsToString_SNP
			order by IESYSTEMCONTROLNUMBER) a
			Group by
			a.IESYSTEMCONTROLNUMBER

			Set @BatchInsertCount = @@ROWCOUNT
			SET @RowCount= @RowCount + @BatchInsertCount
			Set @LoopCount = @LoopCount + 1

		    Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Serial_Number_Prefix, Count: ' + Cast(@BatchInsertCount as varchar(50))

			Update x
			set familySubFamilySalesModelSNP = y.RecordsToString
			From #EMPProductHierarchy  x
			inner join #PHRecordsToStringResult_SNP y on x.IESYSTEMCONTROLNUMBER = y.IESYSTEMCONTROLNUMBER

			Delete a
			From #PHRecordsToString_SNP a
			inner join (Select Distinct IESYSTEMCONTROLNUMBER
			From (
			Select top (@BatchCount) with Ties
			IESYSTEMCONTROLNUMBER
			From #PHRecordsToString_SNP
			order by IESYSTEMCONTROLNUMBER
			) x ) b 
			on a.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER

			Set @BatchProcessCount = @@ROWCOUNT
			Print cast(getdate() as varchar(50)) + ' - Total Update Count: ' + Cast(@RowCount as varchar(50)) + ' | Loop Count: ' + Cast(@LoopCount as varchar(50)) + ' | Batch Update Count: ' + Cast(@BatchInsertCount as varchar(50)) + ' | Batch Rows Processed: ' + Cast(@BatchProcessCount as varchar(50))

			Truncate table #PHRecordsToStringResult_SNP

		End
--End of records to string loop

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Populated #PHRecordsToStringResult_SNP and updated #EMPProductHierarchy',@DATAVALUE = NULL, @LOGID = @StepLogID

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Create table #PHRecordsToStringResultPDF_SNP
(
    PARTSPDFID varchar(50) not null,
    RecordsToString varchar(max) null,
	INSERTDATE datetime not null
)

--Add pkey to result
ALTER TABLE  #PHRecordsToStringResultPDF_SNP ADD PRIMARY KEY CLUSTERED (PARTSPDFID)
    Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

    While (Select count(*)
		from #PHRecordsToString_SNP) > 0
		Begin

			Insert into #PHRecordsToStringResultPDF_SNP
			Select
			a.PARTSPDFID as PARTSPDFID,
			'["' + string_agg(a.RTS,'","') WITHIN GROUP (ORDER BY a.RTS) + '"]'  As RecordsToString,
			min(a.INSERTDATE) INSERTDATE
			--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
			from (Select top (@BatchCount) With Ties
				*
			From #PHRecordsToStringPDF_SNP
			order by PARTSPDFID) a
			Group by
			a.PARTSPDFID

			Set @BatchInsertCount = @@ROWCOUNT
			SET @RowCount= @RowCount + @BatchInsertCount
			Set @LoopCount = @LoopCount + 1

		    Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Serial_Number_Prefix, Count: ' + Cast(@BatchInsertCount as varchar(50))

			Update x
			set familySubFamilySalesModelSNP = y.RecordsToString
			From #EMPProductHierarchyPDF  x
			inner join #PHRecordsToStringResultPDF_SNP y on x.PARTSPDFID = y.PARTSPDFID

			Delete a
			From #PHRecordsToStringPDF_SNP a
			inner join (Select Distinct PARTSPDFID
			From (
			Select top (@BatchCount) with Ties
				PARTSPDFID
			From #PHRecordsToStringPDF_SNP
			order by PARTSPDFID
			) x 
			) b on a.PARTSPDFID = b.PARTSPDFID

			Set @BatchProcessCount = @@ROWCOUNT
			Print cast(getdate() as varchar(50)) + ' - Total Update Count: ' + Cast(@RowCount as varchar(50)) + ' | Loop Count: ' + Cast(@LoopCount as varchar(50)) + ' | Batch Update Count: ' + Cast(@BatchInsertCount as varchar(50)) + ' | Batch Rows Processed: ' + Cast(@BatchProcessCount as varchar(50))
	
			Truncate table #PHRecordsToStringResultPDF_SNP

		End
--End of records to string loop
SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Update #EMPProductHierarchyPDF',@DATAVALUE = NULL, @LOGID = @StepLogID

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

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Create Temp tables to populate familySubfamilySNP in the table [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2]',@DATAVALUE = NULL, @LOGID = @StepLogID

--Load EMP Product Structure Data 

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

CREATE TABLE #EMPProductStructure
(
    [Iesystemcontrolnumber] VARCHAR (50) NOT NULL,
    [SYSTEMPSID] VARCHAR (MAX) NULL,
    [PSID] VARCHAR (MAX) NULL,
    [InsertDate] DATETIME NOT NULL,
    PRIMARY KEY CLUSTERED ([Iesystemcontrolnumber] ASC)
    );
;with
     CTE_PRODUCTSTRUCTURE_2
         as
         (
             SELECT distinct c.IESYSTEMCONTROLNUMBER,
                             CASE
                                 WHEN b.PARENTPRODUCTSTRUCTUREID <> '00000000'
                                     THEN cast(b.PARENTPRODUCTSTRUCTUREID as varchar) + '_' + cast(a.PSID As varchar)
                                 ELSE cast(a.PSID As varchar) + '_' + cast(a.PSID As varchar)
                                 END as [PSID],
     CASE
     WHEN b.PARENTPRODUCTSTRUCTUREID <> '00000000'
     THEN cast (b.PARENTPRODUCTSTRUCTUREID as varchar)
     ELSE cast (a.PSID As varchar)
END
as [SYSTEMPSID],
			e.LASTMODIFIEDDATE [InsertDate]
		From [SISWEB_OWNER_SHADOW].LNKIEPSID a With(NolocK)
			inner join #InsertRecords f --Add filter to limit to changed records
			    on a.IESYSTEMCONTROLNUMBER=f.IESYSTEMCONTROLNUMBER
			inner join [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] e  With(NolocK)
			on e.MEDIANUMBER=a.MEDIANUMBER and a.IESYSTEMCONTROLNUMBER=e.IESYSTEMCONTROLNUMBER
			inner join [SISWEB_OWNER_SHADOW].[LNKIEPRODUCTINSTANCE] c With(NolocK)
			on c.IESYSTEMCONTROLNUMBER=e.IESYSTEMCONTROLNUMBER and c.MEDIANUMBER=e.MEDIANUMBER
			inner join [SISWEB_OWNER].MASPRODUCTSTRUCTURE b With(NolocK)
			on a.PSID=b.PRODUCTSTRUCTUREID and b.LANGUAGEINDICATOR='E'
			inner join [SISWEB_OWNER].[MASMEDIA] g With(NolocK)
			on g.MEDIANUMBER=e.MEDIANUMBER and g.MEDIASOURCE = 'N' and g.MEDIAORIGIN = 'EM'
	)

Select IESYSTEMCONTROLNUMBER ,
	[SISSEARCH].[fn_replace_special_characters] (PSID,1) as PSID,
    [SISSEARCH].[fn_replace_special_characters] (SYSTEMPSID,1) as SYSTEMPSID,
	[InsertDate]
into #PSRecordsToString
From CTE_PRODUCTSTRUCTURE_2
ORDER BY isnull([SYSTEMPSID], ''),isnull(PSID, '');

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_EMPProductStructure_IESystemControlNumber]
ON #PSRecordsToString ([IESYSTEMCONTROLNUMBER] ASC)
INCLUDE ([PSID],[SYSTEMPSID],[InsertDate])
Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

Insert into #EMPProductStructure
	(Iesystemcontrolnumber,[PSID],InsertDate)
Select
    a.IESYSTEMCONTROLNUMBER as [IESYSTEMCONTROLNUMBER],
	coalesce(f.PSID,'') As [PSID],
	min(a.InsertDate) InsertDate
--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from #PSRecordsToString a
    cross apply
    (
    SELECT '[' + stuff
    (
    (SELECT '","'  + cast([PSID] as varchar(MAX))
    FROM #PSRecordsToString as b
    where a.IESYSTEMCONTROLNUMBER=b.IESYSTEMCONTROLNUMBER
    order by b.IESYSTEMCONTROLNUMBER,cast([PSID] as varchar(MAX))
    FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
        ,1,2,'') + '"'+']'
    ) f (PSID)
Group by
    a.IESYSTEMCONTROLNUMBER,
    f.PSID
Order by 
    a.IESYSTEMCONTROLNUMBER,
    f.PSID
SET @RowCount= @@RowCount
    Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

Select distinct IESYSTEMCONTROLNUMBER,[SYSTEMPSID]
into #PSRecordsToStringSystem
From #PSRecordsToString
ORDER BY IESYSTEMCONTROLNUMBER,[SYSTEMPSID]

DROP TABLE IF EXISTS #SYSTEMPSID
Select
    a.IESYSTEMCONTROLNUMBER,
    coalesce(f.[SYSTEMPSID],'') As [SYSTEMPSID]
into #SYSTEMPSID
from #PSRecordsToString a
    cross apply
    (
    SELECT '[' + stuff
    (
    (SELECT '","'  + cast([SYSTEMPSID] as varchar(MAX))
    FROM #PSRecordsToStringSystem as b
    where a.IESYSTEMCONTROLNUMBER=b.IESYSTEMCONTROLNUMBER
    order by b.IESYSTEMCONTROLNUMBER,cast([SYSTEMPSID] as varchar(MAX))
    FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
        ,1,2,'') + '"'+']'
    ) f ([SYSTEMPSID])
Group by
    a.IESYSTEMCONTROLNUMBER,
    f.[SYSTEMPSID]
Order by     
	a.IESYSTEMCONTROLNUMBER,
    f.[SYSTEMPSID]

Update t
Set t.[SYSTEMPSID] = s.[SYSTEMPSID]
    From #EMPProductStructure t
	Inner join #SYSTEMPSID s on t.[IESYSTEMCONTROLNUMBER] = s.[IESYSTEMCONTROLNUMBER]

DROP TABLE IF EXISTS #SYSTEMPSID

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Create Temp tables to populate EMP Product Structure Data',@DATAVALUE = NULL, @LOGID = @StepLogID


--Load EMP Product Structure Data for Parts PDF

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

CREATE TABLE #EMPProductStructurePDF
(
    [PARTSPDFID] VARCHAR (50) NOT NULL,
    [SYSTEMPSID] VARCHAR (MAX) NULL,
    [PSID] VARCHAR (MAX) NULL,
    [InsertDate] DATETIME NOT NULL,
    PRIMARY KEY CLUSTERED ([PARTSPDFID] ASC)
    );
;with
     CTE_PRODUCTSTRUCTUREPDF_2
         as
         (
             SELECT distinct c.PARTSPDF_ID,
                             CASE
                                 WHEN b.PARENTPRODUCTSTRUCTUREID <> '00000000'
                                     THEN cast(b.PARENTPRODUCTSTRUCTUREID as varchar) + '_' + cast(a.PSID As varchar)
                                 ELSE cast(a.PSID As varchar) + '_' + cast(a.PSID As varchar)
                                 END as [PSID],
     CASE
     WHEN b.PARENTPRODUCTSTRUCTUREID <> '00000000'
     THEN cast (b.PARENTPRODUCTSTRUCTUREID as varchar)
     ELSE cast (a.PSID As varchar)
END
as [SYSTEMPSID],
			e.LASTMODIFIEDDATE [InsertDate]
		From SISWEB_OWNER_SHADOW.LNKPARTSPDFPSID a With(NolocK)
			inner join #InsertRecordsPartsPDF f --Add filter to limit to changed records
			    on a.PARTSPDF_ID=f.PARTSPDF_ID
			inner join [SISWEB_OWNER_SHADOW].[PARTSPDF] e  With(NolocK)
			on e.PARTSPDF_ID=a.PARTSPDF_ID
			inner join [SISWEB_OWNER_SHADOW].[LNKPDFPRODUCTINSTANCE] c With(NolocK)
			on c.PARTSPDF_ID=e.PARTSPDF_ID
			inner join [SISWEB_OWNER].MASPRODUCTSTRUCTURE b With(NolocK)
			on a.PSID=b.PRODUCTSTRUCTUREID and b.LANGUAGEINDICATOR='E'
			inner join [SISWEB_OWNER].[MASMEDIA] g With(NolocK)
			on g.MEDIANUMBER=e.MEDIANUMBER and g.MEDIASOURCE = 'N' and g.MEDIAORIGIN = 'EM'
	)

Select PARTSPDF_ID as PARTSPDFID,
	[SISSEARCH].[fn_replace_special_characters] (PSID,1) as PSID,
    [SISSEARCH].[fn_replace_special_characters] (SYSTEMPSID,1) as SYSTEMPSID,
	[InsertDate]
into #PSRecordsToStringPDF
From CTE_PRODUCTSTRUCTUREPDF_2
ORDER BY isnull([SYSTEMPSID], '');

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_EMPProductStructurePDF_PARTSPDF_ID]
ON #PSRecordsToStringPDF ([PARTSPDFID] ASC)
INCLUDE ([PSID],[SYSTEMPSID],[InsertDate])
Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

Insert into #EMPProductStructurePDF
	(PARTSPDFID,[PSID],InsertDate)
Select
    a.PARTSPDFID as [PARTSPDFID],
	coalesce(f.PSID,'') As [PSID],
	min(a.InsertDate) InsertDate
--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from #PSRecordsToStringPDF a
    cross apply
    (
    SELECT '[' + stuff
    (
    (SELECT '","'  + cast([PSID] as varchar(MAX))
    FROM #PSRecordsToStringPDF as b
    where a.PARTSPDFID=b.PARTSPDFID
    order by b.PARTSPDFID
    FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
        ,1,2,'') + '"'+']'
    ) f (PSID)
Group by
    a.PARTSPDFID,
    f.PSID
ORDER by
    a.PARTSPDFID,
    f.PSID
SET @RowCount= @@RowCount
    Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

Select distinct PARTSPDFID,[SYSTEMPSID]
into #PSRecordsToStringSystemPDF
From #PSRecordsToStringPDF
ORDER BY PARTSPDFID,[SYSTEMPSID]

DROP TABLE IF EXISTS #SYSTEMPSIDPDF
Select
    a.PARTSPDFID,
    coalesce(f.[SYSTEMPSID],'') As [SYSTEMPSID]
into #SYSTEMPSIDPDF
from #PSRecordsToStringPDF a
    cross apply
    (
    SELECT '[' + stuff
    (
    (SELECT '","'  + cast([SYSTEMPSID] as varchar(MAX))
    FROM #PSRecordsToStringSystemPDF as b
    where a.PARTSPDFID=b.PARTSPDFID
    order by b.PARTSPDFID
    FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
        ,1,2,'') + '"'+']'
    ) f ([SYSTEMPSID])
Group by
    a.PARTSPDFID,
    f.[SYSTEMPSID]
ORDER by
    a.PARTSPDFID,
    f.[SYSTEMPSID]

Update t
Set t.[SYSTEMPSID] = s.[SYSTEMPSID]
    From #EMPProductStructurePDF t
	Inner join #SYSTEMPSIDPDF s on t.[PARTSPDFID] = s.[PARTSPDFID]

DROP TABLE IF EXISTS #SYSTEMPSIDPDF

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Create Temp tables to populate EMP Product Structure Data for Parts PDF',@DATAVALUE = NULL, @LOGID = @StepLogID

--Load SNP data that's specific to EMP
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

DROP TABLE IF EXISTS #SNPRecordsToString;
DROP TABLE IF EXISTS #SNPRecordsToString_Ranked;
DROP TABLE IF EXISTS #EMPSerialNumberPrefixes;
DROP TABLE IF EXISTS #SNPArray

;with
     CTE_SNP_4
         as
         (
             Select distinct
                 a.IESYSTEMCONTROLNUMBER,
                 a.SNP,
                 c.LASTMODIFIEDDATE InsertDate,
                 a.PRODUCTINSTANCENUMBERS
             FROM (
                      select IESYSTEMCONTROLNUMBER, SNP,
                             ISNULL('"' + STRING_AGG(cast(epi.NUMBER as varchar(max)),'","') WITHIN GROUP (ORDER BY epi.NUMBER ) + '"', '') AS [ProductInstanceNumbers]
                      from [SISWEB_OWNER_SHADOW].[LNKIEPRODUCTINSTANCE] lpi
                          inner join SISWEB_OWNER_SHADOW.EMPPRODUCTINSTANCE epi on epi.EMPPRODUCTINSTANCE_ID = lpi.EMPPRODUCTINSTANCE_ID
                      group by IESYSTEMCONTROLNUMBER, SNP

                  ) a
                      inner join [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] c With(NolocK) --3M
 on a.IESYSTEMCONTROLNUMBER =c.IESYSTEMCONTROLNUMBER
     inner join #InsertRecords d --Add filter to limit to changed records
     on c.IESYSTEMCONTROLNUMBER=d.IESYSTEMCONTROLNUMBER
     inner join [SISWEB_OWNER].[MASMEDIA] b With(NolocK) --90K
 on b.MEDIANUMBER = c.MEDIANUMBER
 where b.MEDIASOURCE = 'N' and b.MEDIAORIGIN = 'EM'
     )
Select IESYSTEMCONTROLNUMBER,
	[SISSEARCH].[fn_replace_special_characters] (SNP,1) as SNP,
       InsertDate,
       PRODUCTINSTANCENUMBERS
into #SNPRecordsToString
From CTE_SNP_4;

Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

Select

    x.IESYSTEMCONTROLNUMBER,
    r.SNP,

    r.InsertDate,
    r.PRODUCTINSTANCENUMBERS
Into #SNPRecordsToString_Ranked
From
    (
        --Get
        Select
            IESYSTEMCONTROLNUMBER
        From #SNPRecordsToString
        Group by IESYSTEMCONTROLNUMBER
    ) x
        --Get the SNP & InsertDate
        Inner Join #SNPRecordsToString r on
            x.IESYSTEMCONTROLNUMBER = r.IESYSTEMCONTROLNUMBER


SELECT
    IESYSTEMCONTROLNUMBER,
    ISNULL('["' + STRING_AGG(cast(SNP as varchar(max)),'","') WITHIN GROUP (ORDER BY SNP,PRODUCTINSTANCENUMBERS) + '"]','[]') AS [serialNumbers.serialNumberPrefixes],
	ISNULL('[' + STRING_AGG(cast(PRODUCTINSTANCENUMBERS as varchar(max)),',') WITHIN GROUP (ORDER BY SNP,PRODUCTINSTANCENUMBERS)+ ']','[]') AS [ProductInstanceNumbers],
	max(InsertDate) [InsertDate]
Into #SNPArray
FROM #SNPRecordsToString_Ranked
GROUP BY
    IESYSTEMCONTROLNUMBER


SELECT
    IESYSTEMCONTROLNUMBER,
    (
        Select
            JSON_Query(b.[serialNumbers.serialNumberPrefixes]) [serialNumberPrefixes]
        From #SNPArray b
        where a.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER
        For JSON Path
        ) SerialNumbers,
    (
Select
    PRODUCTINSTANCENUMBERS as [ProductInstanceNumbers]
from #SNPArray c
where a.IESYSTEMCONTROLNUMBER = c.IESYSTEMCONTROLNUMBER
    ) ProductInstanceNumbers,
    max(InsertDate) InsertDate
into #EMPSerialNumberPrefixes
FROM #SNPArray a
GROUP BY
    IESYSTEMCONTROLNUMBER

DROP TABLE IF EXISTS #SNPRecordsToString;
DROP TABLE IF EXISTS #SNPRecordsToString_Ranked;
DROP TABLE IF EXISTS #SNPArray

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Create Temp tables to populate SNP Data EMP',@DATAVALUE = NULL, @LOGID = @StepLogID

--Load SNP data that's specific to EMP PDF

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

DROP TABLE IF EXISTS #SNPRecordsToStringPDF;
DROP TABLE IF EXISTS #SNPRecordsToString_RankedPDF;
DROP TABLE IF EXISTS #EMPSerialNumberPrefixesPDF;
DROP TABLE IF EXISTS #SNPArrayPDF

;with
     CTE_SNP_4_PDF
         as
         (
             Select distinct
                 a.PARTSPDF_ID,
                 a.SNP,
                 c.LASTMODIFIEDDATE InsertDate,
                 a.PRODUCTINSTANCENUMBERS
             FROM (
                      select PARTSPDF_ID, SNP,
                             ISNULL('"' + STRING_AGG(cast(epi.NUMBER as varchar(max)),'","') WITHIN GROUP (ORDER BY epi.NUMBER) + '"', '') AS [ProductInstanceNumbers]
                      from SISWEB_OWNER_SHADOW.LNKPDFPRODUCTINSTANCE lpi
                          inner join SISWEB_OWNER_SHADOW.EMPPRODUCTINSTANCE epi on epi.EMPPRODUCTINSTANCE_ID = lpi.EMPPRODUCTINSTANCE_ID
                      group by PARTSPDF_ID, SNP

                  ) a
                      inner join [SISWEB_OWNER_SHADOW].[PARTSPDF] c With(NolocK) --3M
 on a.PARTSPDF_ID =c.PARTSPDF_ID
     inner join #InsertRecordsPartsPDF d --Add filter to limit to changed records
     on c.PARTSPDF_ID=d.PARTSPDF_ID
     inner join [SISWEB_OWNER].[MASMEDIA] b With(NolocK) --90K
 on b.MEDIANUMBER = c.MEDIANUMBER
 where b.MEDIASOURCE = 'N' and b.MEDIAORIGIN = 'EM'
     )
Select PARTSPDF_ID as PARTSPDFID,
	   [SISSEARCH].[fn_replace_special_characters] (SNP,1) as SNP,
       InsertDate,
       PRODUCTINSTANCENUMBERS
into #SNPRecordsToStringPDF
From CTE_SNP_4_PDF;

Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

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
        Inner Join #SNPRecordsToStringPDF r on
            x.PARTSPDFID = r.PARTSPDFID


SELECT
    PARTSPDFID,
    ISNULL('["' + STRING_AGG(cast(SNP as varchar(max)),'","') WITHIN GROUP (ORDER BY SNP,PRODUCTINSTANCENUMBERS) + '"]','[]') AS [serialNumbers.serialNumberPrefixes],
	ISNULL('[' + STRING_AGG(cast(PRODUCTINSTANCENUMBERS as varchar(max)),',') WITHIN GROUP (ORDER BY SNP,PRODUCTINSTANCENUMBERS) + ']','[]') AS [ProductInstanceNumbers],
	max(InsertDate) [InsertDate]
Into #SNPArrayPDF
FROM #SNPRecordsToString_RankedPDF
GROUP BY
    PARTSPDFID


SELECT
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
from #SNPArrayPDF c
where a.PARTSPDFID = c.PARTSPDFID
    ) ProductInstanceNumbers,
    max(InsertDate) InsertDate
into #EMPSerialNumberPrefixesPDF
FROM #SNPArrayPDF a
GROUP BY
    PARTSPDFID

DROP TABLE IF EXISTS #SNPRecordsToStringPDF;
DROP TABLE IF EXISTS #SNPRecordsToString_RankedPDF;
DROP TABLE IF EXISTS #SNPArrayPDF

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Create Temp tables to populate SNP Data for External EMP PDF',@DATAVALUE = NULL, @LOGID = @StepLogID

--Create Temp Tables, Indexes and Collation to Load to final EMP table

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

--Prep
DROP TABLE IF EXISTS #ConsolidatedEMP
DROP TABLE IF EXISTS #ConsolidatedPDF

--Create Temp
CREATE TABLE #ConsolidatedEMP (
    [ID] [varchar](50) NOT NULL,
    [Iesystemcontrolnumber] [varchar](50) NULL,
    [INSERTDATE] [datetime] NULL,
    [InformationType] [varchar](10) NULL,
    [Medianumber] [varchar](15) NULL,
    [IEupdatedate] [datetime2](0) NULL,
    [IEpart] [nvarchar](700) NULL,
    [IEpartNumber] [varchar](40) NULL,
    [PARTSMANUALMEDIANUMBER] [varchar](15) NULL,
    [IECAPTION] [nvarchar](2048) NULL,
    [CONSISTPART] [nvarchar](max) NULL,
    [SYSTEMPSID] [varchar](max) NULL,
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
-- 	[IePartHistory] [varchar](max) NULL,
-- 	[ConsistPartHistory] [varchar](max) NULL,
-- 	[IePartReplacement] [varchar](max) NULL,
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
    [mediaOrigin] [varchar](2) NULL,
    [orgCode] [varchar](12)   NULL
);

--Create Temp
CREATE TABLE #ConsolidatedPDF (
    [ID] [varchar](50) NOT NULL,
    [INSERTDATE] [datetime] NULL,
    [InformationType] [varchar](10) NULL,
    [Medianumber] [varchar](15) NULL,
    [IEupdatedate] [datetime2](0) NULL,
    [IEpart] [nvarchar](700) NULL,
    [PARTSMANUALMEDIANUMBER] [varchar](15) NULL,
    [SYSTEMPSID] [varchar](max) NULL,
    [PSID] [varchar](max) NULL,
    [SerialNumbers] [varchar](max) NULL,
    [ProductInstanceNumbers] [varchar](max) NULL,
    [isMedia] [bit] NULL,
    [familyCode] [varchar](max) NULL,
    [familySubFamilyCode] [varchar](max) NULL,
    [familySubFamilySalesModel] [varchar](max) NULL,
    [familySubFamilySalesModelSNP] [varchar](max) NULL,
    [mediaOrigin] [varchar](2) NULL,
    [orgCode] [varchar](12)   NULL
);

--Set collation of temp
ALTER TABLE #ConsolidatedEMP
ALTER COLUMN [ID] varchar(50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL

CREATE NONCLUSTERED INDEX IX_CONSOLIDATEDEMP
ON #ConsolidatedEMP ([Iesystemcontrolnumber])
INCLUDE ([ID],[INSERTDATE],[InformationType],[Medianumber],[IEupdatedate],
	[IEpart],[IEpartNumber],[PARTSMANUALMEDIANUMBER],[IECAPTION],[CONSISTPART],[SYSTEMPSID],[PSID],
	[isMedia],[PubDate],[ControlNumber],[familyCode],[familySubFamilyCode],
	[familySubFamilySalesModel],[familySubFamilySalesModelSNP],[ConsistPartNames_es-ES],
	[ConsistPartNames_zh-CN],[ConsistPartNames_fr-FR],[ConsistPartNames_it-IT],[ConsistPartNames_de-DE],
	[ConsistPartNames_pt-BR],[ConsistPartNames_id-ID],[ConsistPartNames_ja-JP],[ConsistPartNames_ru-RU],[mediaOrigin],
    [orgCode]);



ALTER TABLE #ConsolidatedPDF
ALTER COLUMN [ID] varchar(50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL

CREATE NONCLUSTERED INDEX IX_CONSOLIDATEDPDF
ON #ConsolidatedPDF ([ID])
INCLUDE ([INSERTDATE],[InformationType],[Medianumber],[IEupdatedate],
	[IEpart],[PARTSMANUALMEDIANUMBER],[SYSTEMPSID],[PSID],
	[isMedia],[familyCode],[familySubFamilyCode],
	[familySubFamilySalesModel],[familySubFamilySalesModelSNP],[mediaOrigin],
    [orgCode]);

DROP TABLE IF EXISTS #CONSOLIDATEDPARTS_4_IESYSTEMCONTROLNUMBERS;
CREATE TABLE #CONSOLIDATEDPARTS_4_IESYSTEMCONTROLNUMBERS (IESYSTEMCONTROLNUMBER VARCHAR(50) NOT NULL PRIMARY KEY);

DROP TABLE IF EXISTS #CONSOLIDATEDPARTS_4_PARTSPDF;
CREATE TABLE #CONSOLIDATEDPARTS_4_PARTSPDF (PARTSPDFID VARCHAR(50) NOT NULL PRIMARY KEY);

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Create Temp Tables, Indexes and Collation to Load to final EMP table',@DATAVALUE = NULL, @LOGID = @StepLogID

--Create Temp table with IESYSTEMCONTROLNUMBER's from Both EMP and PDF tables and load updated data in the Temp Tables 

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

INSERT INTO #CONSOLIDATEDPARTS_4_IESYSTEMCONTROLNUMBERS
SELECT IESYSTEMCONTROLNUMBER
FROM(SELECT IESYSTEMCONTROLNUMBER FROM #EMPBasicParts AS bp
     UNION
     SELECT IESYSTEMCONTROLNUMBER FROM #EMPConsistParts AS cp
     UNION
     SELECT IESYSTEMCONTROLNUMBER FROM #EMPProductStructure AS ps
     UNION
     SELECT IESYSTEMCONTROLNUMBER FROM #EMPSerialNumberPrefixes AS snp
     UNION
     SELECT IESYSTEMCONTROLNUMBER FROM #EMPProductHierarchy AS ph

    ) AS T
;

INSERT INTO #CONSOLIDATEDPARTS_4_PARTSPDF
SELECT PARTSPDFID
FROM(SELECT PARTSPDFID FROM #EMPPartsPDF AS bp
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
    cast(IESYSTEMCONTROLNUMBERS.IESYSTEMCONTROLNUMBER as VARCHAR) As ID
     ,coalesce(bp.[Iesystemcontrolnumber], cp.IESYSTEMCONTROLNUMBER, ps.[Iesystemcontrolnumber]
    , snp.[Iesystemcontrolnumber], ph.[Iesystemcontrolnumber]) [Iesystemcontrolnumber]
     ,coalesce(bp.InsertDate, cp.[INSERTDATE], ps.InsertDate, snp.InsertDate, ph.InsertDate) [INSERTDATE]
     ,nullif(nullif(bp.[InformationType], '[""]'), '') [InformationType]
     ,nullif(nullif(bp.[Medianumber], '[""]'), '') [Medianumber]
     ,bp.[IEupdatedate]
     ,bp.[IEpart]
     ,bp.[IEpartNumber]
     ,nullif(nullif(bp.[PARTSMANUALMEDIANUMBER], '[""]'), '') [PARTSMANUALMEDIANUMBER]
     ,bp.[IECAPTION]
     --ConsistParts
     ,nullif(nullif(cp.[CONSISTPART], '[""]'), '') [CONSISTPART]
     --ProductStructure

     ,nullif(nullif(ps.[SYSTEMPSID], '[""]'), '') [SYSTEMPSID]
     ,nullif(nullif(ps.[PSID], '[""]'), '') [PSID]

     --SNP
     ,nullif(nullif(snp.[SerialNumbers], '[""]'), '') [SerialNumbers]
     ,nullif(nullif(snp.[ProductInstanceNumbers], '[""]'), '') [ProductInstanceNumbers]
     ,bp.[isMedia]

     ,bp.[PubDate]
     ,nullif(nullif(bp.[ControlNumber], '[""]'), '') [ControlNumber]
     ,nullif(nullif(ph.[familyCode], '[""]'), '') familyCode
     ,nullif(nullif(ph.[familySubFamilyCode], '[""]'), '') familySubFamilyCode
     ,nullif(nullif(ph.[familySubFamilySalesModel], '[""]'), '') familySubFamilySalesModel
     ,nullif(nullif(ph.[familySubFamilySalesModelSNP], '[""]'), '') familySubFamilySalesModelSNP

     ,nullif(nullif(cp.[ConsistPartNames_es-ES], '[""]'), '') [ConsistPartNames_es-ES]
     ,nullif(nullif(cp.[ConsistPartNames_fr-FR], '[""]'), '') [ConsistPartNames_zh-CN]
     ,nullif(nullif(cp.[ConsistPartNames_fr-FR], '[""]'), '') [ConsistPartNames_fr-FR]
     ,nullif(nullif(cp.[ConsistPartNames_it-IT], '[""]'), '') [ConsistPartNames_it-IT]
     ,nullif(nullif(cp.[ConsistPartNames_de-DE], '[""]'), '') [ConsistPartNames_de-DE]
     ,nullif(nullif(cp.[ConsistPartNames_pt-BR], '[""]'), '') [ConsistPartNames_pt-BR]
     ,nullif(nullif(cp.[ConsistPartNames_id-ID], '[""]'), '') [ConsistPartNames_id-ID]
     ,nullif(nullif(cp.[ConsistPartNames_ja-JP], '[""]'), '') [ConsistPartNames_ja-JP]
     ,nullif(nullif(cp.[ConsistPartNames_ru-RU], '[""]'), '') [ConsistPartNames_ru-RU]
     ,mediaOrigin
     ,bp.orgCode [orgCode]


FROM #CONSOLIDATEDPARTS_4_IESYSTEMCONTROLNUMBERS AS IESYSTEMCONTROLNUMBERS
         LEFT JOIN #EMPBasicParts AS bp ON bp.IESYSTEMCONTROLNUMBER = IESYSTEMCONTROLNUMBERS.IESYSTEMCONTROLNUMBER
         LEFT JOIN #EMPConsistParts AS cp ON cp.IESYSTEMCONTROLNUMBER = IESYSTEMCONTROLNUMBERS.IESYSTEMCONTROLNUMBER
         LEFT JOIN #EMPProductStructure AS ps ON ps.IESYSTEMCONTROLNUMBER = IESYSTEMCONTROLNUMBERS.IESYSTEMCONTROLNUMBER
         LEFT JOIN #EMPSerialNumberPrefixes AS snp ON snp.IESYSTEMCONTROLNUMBER = IESYSTEMCONTROLNUMBERS.IESYSTEMCONTROLNUMBER
         LEFT JOIN #EMPProductHierarchy AS ph ON ph.IESYSTEMCONTROLNUMBER = IESYSTEMCONTROLNUMBERS.IESYSTEMCONTROLNUMBER;



--Insert updated source into temp PDF
Insert into #ConsolidatedPDF
SELECT
    cast(PARTSPDF.PARTSPDFID as VARCHAR) As ID
     ,coalesce(bp.InsertDate, ps.InsertDate, snp.InsertDate, ph.InsertDate) [INSERTDATE]
     ,nullif(nullif(bp.[InformationType], '[""]'), '') [InformationType]
     ,nullif(nullif(bp.[Medianumber], '[""]'), '') [Medianumber]
     ,bp.[IEupdatedate]
     ,bp.[IEpart]
     ,nullif(nullif(bp.[PARTSMANUALMEDIANUMBER], '[""]'), '') [PARTSMANUALMEDIANUMBER]
     --ProductStructure

     ,nullif(nullif(ps.[SYSTEMPSID], '[""]'), '') [SYSTEMPSID]
     ,nullif(nullif(ps.[PSID], '[""]'), '') [PSID]

     --SNP
     ,nullif(nullif(snp.[SerialNumbers], '[""]'), '') [SerialNumbers]
     ,nullif(nullif(snp.[ProductInstanceNumbers], '[""]'), '') [ProductInstanceNumbers]
     ,bp.[isMedia]
     ,nullif(nullif(ph.[familyCode], '[""]'), '') familyCode
     ,nullif(nullif(ph.[familySubFamilyCode], '[""]'), '') familySubFamilyCode
     ,nullif(nullif(ph.[familySubFamilySalesModel], '[""]'), '') familySubFamilySalesModel
     ,nullif(nullif(ph.[familySubFamilySalesModelSNP], '[""]'), '') familySubFamilySalesModelSNP
     ,mediaOrigin
     ,bp.orgCode [orgCode]


FROM #CONSOLIDATEDPARTS_4_PARTSPDF AS PARTSPDF
         LEFT JOIN #EMPPartsPDF AS bp ON bp.PARTSPDFID = PARTSPDF.PARTSPDFID
         LEFT JOIN #EMPProductStructurePDF AS ps ON ps.PARTSPDFID = PARTSPDF.PARTSPDFID
         LEFT JOIN #EMPSerialNumberPrefixesPDF AS snp ON snp.PARTSPDFID = PARTSPDF.PARTSPDFID
         LEFT JOIN #EMPProductHierarchyPDF AS ph ON ph.PARTSPDFID = PARTSPDF.PARTSPDFID;

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Create Temp table with IESYSTEMCONTROLNUMBERs from Both EMP and PDF tables and load updated data in the Temp Tables',@DATAVALUE = NULL, @LOGID = @StepLogID

--Update Final Table SISSEARCH.EXPANDEDMININGPRODUCTPARTS_2 with data from Temp Table for existing EMP records with new data 

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


Update tgt
Set
    tgt.[INSERTDATE] = src.[INSERTDATE]
  ,tgt.[InformationType] = src.[InformationType]
  ,tgt.[Medianumber] = src.[Medianumber]
  ,tgt.[IEupdatedate] = src.[IEupdatedate]
  ,tgt.[IEpart] = src.[IEpart]
  ,tgt.[IEpartNumber] = src.[IEpartNumber]
  ,tgt.[PARTSMANUALMEDIANUMBER] = src.[PARTSMANUALMEDIANUMBER]
  ,tgt.[IECAPTION] = src.[IECAPTION]
  ,tgt.[CONSISTPART] = src.[CONSISTPART]
  ,tgt.[SYSTEM] = src.[SYSTEMPSID]
  ,tgt.[SYSTEMPSID] = src.[SYSTEMPSID]
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
  ,tgt.[mediaOrigin]= src.[mediaOrigin]
  ,tgt.[orgCode]= src.[orgCode]

    From SISSEARCH.EXPANDEDMININGPRODUCTPARTS_2 tgt
Inner join #ConsolidatedEMP src on tgt.[ID] = src.[ID] --Existing
Where src.[INSERTDATE] > tgt.[INSERTDATE] --Updated in source
   or (tgt. [InformationType] <> src. [InformationType] or (tgt. [InformationType] is null and src. [InformationType] is not null) or (tgt. [InformationType] is not null and src. [InformationType] is null))
   or (tgt. [Medianumber] <> src. [Medianumber] or (tgt. [Medianumber] is null and src. [Medianumber] is not null) or (tgt. [Medianumber] is not null and src. [Medianumber] is null))
   or (tgt. [IEupdatedate] <> src. [IEupdatedate] or (tgt. [IEupdatedate] is null and src. [IEupdatedate] is not null) or (tgt. [IEupdatedate] is not null and src. [IEupdatedate] is null))
   or (tgt. [IEpart] <> src. [IEpart] or (tgt. [IEpart] is null and src. [IEpart] is not null) or (tgt. [IEpart] is not null and src. [IEpart] is null))
   or (tgt. [IEpartNumber] <> src. [IEpartNumber] or (tgt. [IEpartNumber] is null and src. [IEpartNumber] is not null) or (tgt. [IEpartNumber] is not null and src. [IEpartNumber] is null))
   or (tgt. [PARTSMANUALMEDIANUMBER] <> src. [PARTSMANUALMEDIANUMBER] or (tgt. [PARTSMANUALMEDIANUMBER] is null and src. [PARTSMANUALMEDIANUMBER] is not null) or (tgt. [PARTSMANUALMEDIANUMBER] is not null and src. [PARTSMANUALMEDIANUMBER] is null))
   or (tgt. [IECAPTION] <> src. [IECAPTION] or (tgt. [IECAPTION] is null and src. [IECAPTION] is not null) or (tgt. [IECAPTION] is not null and src. [IECAPTION] is null))
   or (tgt. [CONSISTPART] <> src. [CONSISTPART] or (tgt. [CONSISTPART] is null and src. [CONSISTPART] is not null) or (tgt. [CONSISTPART] is not null and src. [CONSISTPART] is null))
   or (tgt. [SYSTEM] <> src. [SYSTEMPSID] or (tgt. [SYSTEM] is null and src. [SYSTEMPSID] is not null) or (tgt. [SYSTEM] is not null and src. [SYSTEMPSID] is null))
   or (tgt. [SYSTEMPSID] <> src. [SYSTEMPSID] or (tgt. [SYSTEMPSID] is null and src. [SYSTEMPSID] is not null) or (tgt. [SYSTEMPSID] is not null and src. [SYSTEMPSID] is null))
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
   or (tgt. [mediaOrigin] <> src. [mediaOrigin] or (tgt. [mediaOrigin] is null and src. [mediaOrigin] is not null) or (tgt. [mediaOrigin] is not null and src. [mediaOrigin] is null))
   or (tgt. [orgCode] <> src. [orgCode] or (tgt. [orgCode] is null and src. [orgCode] is not null) or (tgt. [orgCode] is not null and src. [orgCode] is null))


SET @RowCount= @@RowCount
SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Update Final Table SISSEARCH.EXPANDEDMININGPRODUCTPARTS_2 with data from Temp Table for existing records with new data ',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Update Final Table SISSEARCH.EXPANDEDMININGPRODUCTPARTS_2 with data from Temp Table for existing EMP Parts PDF records with new data 

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;



Update tgt
Set
    tgt.[INSERTDATE] = src.[INSERTDATE]
  ,tgt.[InformationType] = src.[InformationType]
  ,tgt.[Medianumber] = src.[Medianumber]
  ,tgt.[IEupdatedate] = src.[IEupdatedate]
  ,tgt.[IEpart] = src.[IEpart]
  ,tgt.[PARTSMANUALMEDIANUMBER] = src.[PARTSMANUALMEDIANUMBER]
  ,tgt.[SYSTEM] = src.[SYSTEMPSID]
  ,tgt.[SYSTEMPSID] = src.[SYSTEMPSID]
  ,tgt.[PSID] = src.[PSID]
  ,tgt.[SerialNumbers] = src.[SerialNumbers]
  ,tgt.[ProductInstanceNumbers] = src.[ProductInstanceNumbers]
  ,tgt.[isMedia] = src.[isMedia]
  ,tgt.[familyCode] = src.[familyCode]
  ,tgt.[familySubFamilyCode] = src.[familySubFamilyCode]
  ,tgt.[familySubFamilySalesModel] = src.[familySubFamilySalesModel]
  ,tgt.[familySubFamilySalesModelSNP] = src.[familySubFamilySalesModelSNP]
  ,tgt.[mediaOrigin]= src.[mediaOrigin]
  ,tgt.[orgCode]= src.[orgCode]

    From SISSEARCH.EXPANDEDMININGPRODUCTPARTS_2 tgt
Inner join #ConsolidatedPDF src on tgt.[ID] = src.[ID] --Existing
Where src.[INSERTDATE] > tgt.[INSERTDATE] --Updated in source
   or (tgt. [InformationType] <> src. [InformationType] or (tgt. [InformationType] is null and src. [InformationType] is not null) or (tgt. [InformationType] is not null and src. [InformationType] is null))
   or (tgt. [Medianumber] <> src. [Medianumber] or (tgt. [Medianumber] is null and src. [Medianumber] is not null) or (tgt. [Medianumber] is not null and src. [Medianumber] is null))
   or (tgt. [IEupdatedate] <> src. [IEupdatedate] or (tgt. [IEupdatedate] is null and src. [IEupdatedate] is not null) or (tgt. [IEupdatedate] is not null and src. [IEupdatedate] is null))
   or (tgt. [IEpart] <> src. [IEpart] or (tgt. [IEpart] is null and src. [IEpart] is not null) or (tgt. [IEpart] is not null and src. [IEpart] is null))
   or (tgt. [PARTSMANUALMEDIANUMBER] <> src. [PARTSMANUALMEDIANUMBER] or (tgt. [PARTSMANUALMEDIANUMBER] is null and src. [PARTSMANUALMEDIANUMBER] is not null) or (tgt. [PARTSMANUALMEDIANUMBER] is not null and src. [PARTSMANUALMEDIANUMBER] is null))
   or (tgt. [SYSTEM] <> src. [SYSTEMPSID] or (tgt. [SYSTEM] is null and src. [SYSTEMPSID] is not null) or (tgt. [SYSTEM] is not null and src. [SYSTEMPSID] is null))
   or (tgt. [SYSTEMPSID] <> src. [SYSTEMPSID] or (tgt. [SYSTEMPSID] is null and src. [SYSTEMPSID] is not null) or (tgt. [SYSTEMPSID] is not null and src. [SYSTEMPSID] is null))
   or (tgt. [PSID] <> src. [PSID] or (tgt. [PSID] is null and src. [PSID] is not null) or (tgt. [PSID] is not null and src. [PSID] is null))
   or (tgt. [SerialNumbers] <> src. [SerialNumbers] or (tgt. [SerialNumbers] is null and src. [SerialNumbers] is not null) or (tgt. [SerialNumbers] is not null and src. [SerialNumbers] is null))
   or (tgt. [ProductInstanceNumbers] <> src. [ProductInstanceNumbers] or (tgt. [ProductInstanceNumbers] is null and src. [ProductInstanceNumbers] is not null) or (tgt. [ProductInstanceNumbers] is not null and src. [ProductInstanceNumbers] is null))
   or (tgt. [isMedia] <> src. [isMedia] or (tgt. [isMedia] is null and src. [isMedia] is not null) or (tgt. [isMedia] is not null and src. [isMedia] is null))
   or (tgt. [familyCode] <> src. [familyCode] or (tgt. [familyCode] is null and src. [familyCode] is not null) or (tgt. [familyCode] is not null and src. [familyCode] is null))
   or (tgt. [familySubFamilyCode] <> src. [familySubFamilyCode] or (tgt. [familySubFamilyCode] is null and src. [familySubFamilyCode] is not null) or (tgt. [familySubFamilyCode] is not null and src. [familySubFamilyCode] is null))
   or (tgt. [familySubFamilySalesModel] <> src. [familySubFamilySalesModel] or (tgt. [familySubFamilySalesModel] is null and src. [familySubFamilySalesModel] is not null) or (tgt. [familySubFamilySalesModel] is not null and src. [familySubFamilySalesModel] is null))
   or (tgt. [familySubFamilySalesModelSNP] <> src. [familySubFamilySalesModelSNP] or (tgt. [familySubFamilySalesModelSNP] is null and src. [familySubFamilySalesModelSNP] is not null) or (tgt. [familySubFamilySalesModelSNP] is not null and src. [familySubFamilySalesModelSNP] is null))
   or (tgt. [mediaOrigin] <> src. [mediaOrigin] or (tgt. [mediaOrigin] is null and src. [mediaOrigin] is not null) or (tgt. [mediaOrigin] is not null and src. [mediaOrigin] is null))
   or (tgt. [orgCode] <> src. [orgCode] or (tgt. [orgCode] is null and src. [orgCode] is not null) or (tgt. [orgCode] is not null and src. [orgCode] is null))



SET @RowCount= @@RowCount
SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Update Final Table SISSEARCH.EXPANDEDMININGPRODUCTPARTS_2 with data from Temp Table for existing EMP Parts PDF records with new data ',@DATAVALUE = @RowCount, @LOGID = @StepLogID


--Insert Records in the Final Table SISSEARCH.EXPANDEDMININGPRODUCTPARTS_2 with the data from Temp Tables for EMP data. 
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


INSERT SISSEARCH.EXPANDEDMININGPRODUCTPARTS_2
(
[ID]
,[Iesystemcontrolnumber]
,[INSERTDATE]
,[InformationType]
,[Medianumber]
,[IEupdatedate]
,[IEpart]
,[IEpartNumber]
,[PARTSMANUALMEDIANUMBER]
,[IECAPTION]
,[CONSISTPART]
,[SYSTEM]
,[SYSTEMPSID]
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
,[mediaOrigin]
,[orgCode]
)
Select
    s.[ID]
     ,s.[Iesystemcontrolnumber]
     ,s.[INSERTDATE]
     ,s.[InformationType]
     ,s.[Medianumber]
     ,s.[IEupdatedate]
     ,s.[IEpart]
     ,s.[IEpartNumber]
     ,s.[PARTSMANUALMEDIANUMBER]
     ,s.[IECAPTION]
     ,s.[CONSISTPART]
     ,s.[SYSTEMPSID]
     ,s.[SYSTEMPSID]
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
     ,s.[mediaOrigin]
     ,s.[orgCode]
From #ConsolidatedEMP s
         Left outer join SISSEARCH.EXPANDEDMININGPRODUCTPARTS_2 t on s.[ID] = t.[ID]
Where t.[ID] is null --Does not exist in target


SET @RowCount= @@RowCount
SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Insert Records in the Final Table SISSEARCH.EXPANDEDMININGPRODUCTPARTS_2 with the data from Temp Tables for EMP data',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Insert Records in the Final Table SISSEARCH.EXPANDEDMININGPRODUCTPARTS_2 with the data from Temp Tables for EMP Parts PDF data

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

--Insert new ID's
    INSERT SISSEARCH.EXPANDEDMININGPRODUCTPARTS_2
(
[ID]
,[INSERTDATE]
,[InformationType]
,[Medianumber]
,[IEupdatedate]
,[IEpart]
,[PARTSMANUALMEDIANUMBER]
,[SYSTEM]
,[SYSTEMPSID]
,[PSID]
,[SerialNumbers]
,[ProductInstanceNumbers]
,[isMedia]
,[familyCode]
,[familySubFamilyCode]
,[familySubFamilySalesModel]
,[familySubFamilySalesModelSNP]
,[mediaOrigin]
,[orgCode]
)
Select
    s.[ID]
     ,s.[INSERTDATE]
     ,s.[InformationType]
     ,s.[Medianumber]
     ,s.[IEupdatedate]
     ,s.[IEpart]
     ,s.[PARTSMANUALMEDIANUMBER]
     ,s.[SYSTEMPSID]
     ,s.[SYSTEMPSID]
     ,s.[PSID]
     ,s.[SerialNumbers]
     ,s.[ProductInstanceNumbers]
     ,s.[isMedia]
     ,s.[familyCode]
     ,s.[familySubFamilyCode]
     ,s.[familySubFamilySalesModel]
     ,s.[familySubFamilySalesModelSNP]
     ,s.[mediaOrigin]
     ,s.[orgCode]
From #ConsolidatedPDF s
         Left outer join SISSEARCH.EXPANDEDMININGPRODUCTPARTS_2 t on s.[ID] = t.[ID]
Where t.[ID] is null --Does not exist in target

SET @RowCount= @@RowCount
SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Insert Records in the Final Table SISSEARCH.EXPANDEDMININGPRODUCTPARTS_2 with the data from Temp Tables for EMP Parts PDF data',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Graphic control number logic
--Array of GraphicControlNumber
--All IDs have been inserted. Next we need to get an array of GraphicControlNumbers and update the GraphicControlNumber field.

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString_GCN') is not null
  Begin
     Drop table #RecordsToString_GCN
  End;

  Select a.IESYSTEMCONTROLNUMBER As ID, b.GRAPHICCONTROLNUMBER As GraphicControlNumber
  into #RecordsToString_GCN
  from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART]  a
  inner join [SISWEB_OWNER_SHADOW].[LNKIEIMAGE] b on a.IESYSTEMCONTROLNUMBER=b.IESYSTEMCONTROLNUMBER
  inner join [SISWEB_OWNER].[MASMEDIA] c on a.MEDIANUMBER= c.MEDIANUMBER and c.MEDIAORIGIN='EM'
  where a.LASTMODIFIEDDATE > @LastInsertDate

SET @RowCount = @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Loaded to Temp #RecordsToString_GCN (GraphicControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID]
ON #RecordsToString_GCN ([ID] ASC)
INCLUDE (GraphicControlNumber)

--Records to String
SET @StepStartTime = GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

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
                WHERE    a.ID = b.ID
                ORDER BY b.ID, cast(GraphicControlNumber as varchar(MAX))
				FOR xml path(''), type).value('.', 'varchar(max)') ,1,2,''
			) + '"'+']'
	) f (GraphicControlNumberString)
Group By [ID], f.GraphicControlNumberString

SET @RowCount = @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Temp RecordsToStringResult_GCN (GraphicControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--Add pkey to result
Alter Table #RecordsToStringResult_GCN Alter Column ID varchar(50) Not NULL
ALTER TABLE #RecordsToStringResult_GCN ADD PRIMARY KEY CLUSTERED (ID)

--Insert result into target
SET @StepStartTime = GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

--All IDs have been inserted already.  Update with ControlNumber Array.
Update EMP
Set EMP.GraphicControlNumber = nullif(nullif(R.GraphicControlNumber, ''), '[""]')
From SISSEARCH.[EXPANDEDMININGPRODUCTPARTS_2] EMP
Inner join #RecordsToStringResult_GCN R on EMP.ID = R.ID

SET @RowCount = @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated Target [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_2] (GraphicControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--End graphic control number logic

SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LOGID = @SPStartLogID, @DATAVALUE = @RowCount

/*---------------
End of EXPANDEDMININGPRODUCTPARTS table load, total time including all sub-tables ~ 12 Min
  Note: Metrics were calculated on SB2 Database
 ----------------*/


END TRY

BEGIN CATCH
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT= ERROR_LINE()

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC SISSEARCH.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error

END CATCH


END