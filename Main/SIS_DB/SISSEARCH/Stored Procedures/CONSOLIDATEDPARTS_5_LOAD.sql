CREATE Procedure [SISSEARCH].[CONSOLIDATEDPARTS_5_LOAD] as
BEGIN

DECLARE @LAPSETIME BIGINT
BEGIN TRY

--Var
Declare @Sproc varchar(200) = 'SISSEARCH.CONSOLIDATEDPARTS_5_LOAD'
Declare @RowCount varchar(20)
Declare @TimeMarker datetime = getdate()
Declare @TotalTimeMarker datetime = getdate()

--Start
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Execution started';

/* Creating #consolidated temp table =========================================================================================================================================== */

EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Creating #consolidated temp table';

--Prep
DROP TABLE IF EXISTS #Consolidated /*If Object_ID('tempdb..#Consolidated') is not null Drop table #Consolidated*/

--Create Temp
CREATE TABLE #Consolidated (
    [ID] [varchar](50) NOT NULL PRIMARY KEY,
    [Iesystemcontrolnumber] [varchar](50) NULL,
    [INSERTDATE] [datetime] NULL,
	--[BeginRange] [varchar](10) NULL,
	--[EndRange] [varchar](10) NULL,
    [InformationType] [varchar](10) NULL,
    [Medianumber] [varchar](15) NULL,
    [IEupdatedate] [datetime2](0) NULL,
    [IEpart] [nvarchar](700) NULL,
    [PARTSMANUALMEDIANUMBER] [varchar](15) NULL,
    [IECAPTION] [nvarchar](2048) NULL,
    [CONSISTPART] [nvarchar](max) NULL,
    [SYSTEMPSID] [varchar](max) NULL,
    [PSID] [varchar](max) NULL,
    [smcs] [varchar](max) NULL,
    [SerialNumbers] [varchar](max) NULL,
    [ProductInstanceNumbers] [varchar](max) NULL,
    [isMedia] [bit] NULL,
    [Profile] varchar(max) NULL,
    [REMANCONSISTPART] [varchar](max) NULL,
    [REMANIEPART] [varchar](max) NULL,
    [YELLOWMARKCONSISTPART] [varchar](max) NULL,
    [YELLOWMARKIEPART] [varchar](max) NULL,
    [KITCONSISTPART] [varchar](max) NULL,
    [KITIEPART] [varchar](max) NULL,
    [PubDate] [datetime] NULL,
    [ControlNumber] [varchar](50) NULL,
    [GraphicControlNumber]   VARCHAR (MAX)  NULL,
    [familyCode] [varchar](max) NULL,
    [familySubFamilyCode] [varchar](max) NULL,
    [familySubFamilySalesModel] [varchar](max) NULL,
    [familySubFamilySalesModelSNP] [varchar](max) NULL,
    [IePartHistory] [varchar](max) NULL,
    [ConsistPartHistory] [varchar](max) NULL,
    [IePartReplacement] [varchar](max) NULL,
    [ConsistPartReplacement] [varchar](max) NULL,
    [IEPartName_es-ES] [nvarchar](150) NULL,
    [IEPartName_zh-CN] [nvarchar](150) NULL,
    [IEPartName_fr-FR] [nvarchar](150) NULL,
    [IEPartName_it-IT] [nvarchar](150) NULL,
    [IEPartName_de-DE] [nvarchar](150) NULL,
    [IEPartName_pt-BR] [nvarchar](150) NULL,
    [IEPartName_id-ID] [nvarchar](150) NULL,
    [IEPartName_ja-JP] [nvarchar](150) NULL,
    [IEPartName_ru-RU] [nvarchar](150) NULL,
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
    [orgCode] [varchar](12) NULL,
    [isExpandedMiningProduct] BIT NULL
)

--Set collation of temp
ALTER TABLE #Consolidated
ALTER COLUMN [ID] varchar(50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL

CREATE NONCLUSTERED INDEX IX_CONSOLIDATED
ON #Consolidated ([Iesystemcontrolnumber])
INCLUDE ([ID]);

/* =========================================================================================================================================== */

/* Populating #CONSISTPART and #CONSISTPARTHISTORY for loading EXPANDEDMININGPRODUCTPARTS_2=========================================================================================================================================== */

EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Populating #CONSISTPART and #CONSISTPARTHISTORY'

Set @TimeMarker = getdate()

DROP TABLE IF EXISTS #CONSISTPART
SELECT
    b.IESYSTEMCONTROLNUMBER,
    d.PARTNUMBER,
    d.ORGCODE,
    d.PARTNAME,
    b.LASTMODIFIEDDATE
INTO #CONSISTPART
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] b With(NolocK)
    inner join [SISWEB_OWNER].[MASMEDIA] e with(Nolock)
on e.MEDIANUMBER  =b.MEDIANUMBER and e.[MEDIASOURCE] in ('A', 'N')
    inner join [SISWEB_OWNER_SHADOW].LNKCONSISTLIST d With(Nolock)
on b.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER
WHERE b.LASTMODIFIEDDATE > '';

SET @RowCount= @@RowCount;

CREATE CLUSTERED INDEX IX_IESYSTEM_PARTNUMBER_ORGCODE ON #CONSISTPART (IESYSTEMCONTROLNUMBER, PARTNUMBER, ORGCODE)

SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Populated #CONSISTPART first part',  @DATAVALUE = @RowCount;

Set @TimeMarker = getdate()

INSERT INTO #CONSISTPART
SELECT
    b.IESYSTEMCONTROLNUMBER,
    d.PARTNUMBER,
    d.ORGCODE,
    d.PARTNAME,
    b.LASTMODIFIEDDATE
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] b With(NolocK)
    inner join [SISWEB_OWNER].[MASMEDIA] e with(Nolock)
on e.MEDIANUMBER=b.MEDIANUMBER and e.[MEDIASOURCE] ='C'
    inner join [SISWEB_OWNER_SHADOW].LNKCONSISTLIST d With(Nolock)
on d.IESYSTEMCONTROLNUMBER  = b.BASEENGCONTROLNO
WHERE b.LASTMODIFIEDDATE > '';

SET @RowCount= @@RowCount;
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Populated #CONSISTPART second part', @DATAVALUE = @RowCount;

Set @TimeMarker = getdate()

--Create Temp
DROP TABLE IF EXISTS #CONSISTPARTHISTORY
CREATE TABLE #CONSISTPARTHISTORY (
    [Iesystemcontrolnumber] [varchar](50),
    CONSISTPARTHISTORY [nvarchar](max) NULL,
    CONSISTPARTREPLACEMENT [nvarchar](max) NULL
    )
CREATE CLUSTERED INDEX IX_CONSISTPARTHISTORY_Iesystemcontrolnumber ON #CONSISTPARTHISTORY (Iesystemcontrolnumber)

DROP TABLE IF EXISTS #CONSISTPARTHISTORYORIGIN
SELECT *
INTO #CONSISTPARTHISTORYORIGIN
from [SISSEARCH].[vw_CONSISTPARTSHISTORY_ORIGIN]

CREATE CLUSTERED INDEX IX_CONSISTPARTHISTORYORIGIN_PARTNUMBER_ORGCODE ON #CONSISTPARTHISTORYORIGIN (Part_Number, Org_Code)

INSERT INTO #CONSISTPARTHISTORY
SELECT
    x.IESYSTEMCONTROLNUMBER as IESYSTEMCONTROLNUMBER,
    replace('["'+string_agg(TRIM('"' from h.CONSISTPARTHISTORY), '","')+'"]', '[""]', '') as CONSISTPARTHISTORY,
    replace('["'+string_agg(TRIM('"' from h.CONSISTPARTREPLACEMENT), '","')+'"]', '[""]', '') as CONSISTPARTREPLACEMENT
from #CONSISTPART x
         LEFT JOIN #CONSISTPARTHISTORYORIGIN h ON h.Part_Number=x.PARTNUMBER AND h.Org_Code = x.ORGCODE
group by x.IESYSTEMCONTROLNUMBER

    SET @RowCount= @@RowCount

DROP TABLE IF EXISTS #CONSISTPARTHISTORYORIGIN
DROP TABLE IF EXISTS #CONSISTPART;

SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Populated #CONSISTPARTHISTORY', @LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount;

/* ===========================================================================================================================================  #CONSISTPARTHISTORY is populated */

/* Populating #iepartshistory from SISSEARCH.vw_IEPARTSHISTORY =========================================================================================================================================== */

Set @TimeMarker = getdate();

SELECT *
INTO #iepartshistory
from SISSEARCH.vw_IEPARTSHISTORY

    SET @RowCount= @@RowCount

CREATE CLUSTERED INDEX IX_iepartshistory_PARTNUMBER_ORGCODE ON #iepartshistory (Part_Number, Org_Code)

SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Populated #iepartshistory ', @DATAVALUE = @RowCount;

/* =========================================================================================================================================== */

/* Creating and populating #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED =========================================================================================================================================== */

SET @TimeMarker = getdate();

DROP TABLE IF EXISTS #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED;
CREATE TABLE #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED (
                                                        ID [varchar](50) PRIMARY KEY,
                                                        INDEX IX_IDToUpdate_ID NONCLUSTERED (ID)
);

-- Inserting updated SISSEARCH.EXPANDEDMININGPRODUCTPARTS Ids.
INSERT INTO #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED
SELECT emp.ID FROM SISSEARCH.EXPANDEDMININGPRODUCTPARTS_2 as emp
                       LEFT JOIN #CONSISTPARTHISTORY o	on o.IESYSTEMCONTROLNUMBER = emp.ID
                       LEFT JOIN #iepartshistory p on coalesce(emp.[IEpartNumber], '') = p.Part_Number and emp.[orgCode] = p.Org_Code
                       LEFT join SISSEARCH.CONSOLIDATEDPARTS_5 tgt on emp.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED IDS on IDS.ID = emp.ID
where
    (
   [SISSEARCH].[fn_compare_source_target_columns] (tgt.[InformationType],emp.[InformationType],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[Medianumber],emp.[Medianumber],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[IEupdatedate],emp.[IEupdatedate],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[IEpart],emp.[IEpart],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[PARTSMANUALMEDIANUMBER],emp.[PARTSMANUALMEDIANUMBER],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[IECAPTION],emp.[IECAPTION],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[CONSISTPART],emp.[CONSISTPART],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[SYSTEM],emp.[SYSTEM],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[SYSTEMPSID],emp.[SYSTEMPSID],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[PSID],emp.[PSID],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[SerialNumbers],emp.[SerialNumbers],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ProductInstanceNumbers],nullif(nullif(emp.[ProductInstanceNumbers], '[""]'), ''),0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[isMedia],emp.[isMedia],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[PubDate],emp.[PubDate],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ControlNumber],emp.[ControlNumber],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[GraphicControlNumber],emp.[GraphicControlNumber],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[familyCode],emp.[familyCode],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[familySubFamilyCode],emp.[familySubFamilyCode],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[familySubFamilySalesModel],emp.[familySubFamilySalesModel],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[familySubFamilySalesModelSNP],emp.[familySubFamilySalesModelSNP],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartNames_es-ES],emp.[ConsistPartNames_es-ES],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartNames_fr-FR],emp.[ConsistPartNames_fr-FR],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartNames_it-IT],emp.[ConsistPartNames_it-IT],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartNames_de-DE],emp.[ConsistPartNames_de-DE],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartNames_pt-BR],emp.[ConsistPartNames_pt-BR],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartNames_id-ID],emp.[ConsistPartNames_id-ID],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartNames_ja-JP],emp.[ConsistPartNames_ja-JP],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartNames_ru-RU],emp.[ConsistPartNames_ru-RU],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[mediaOrigin],emp.[mediaOrigin],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[orgCode],emp.[orgCode],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[IEPartHistory],nullif(nullif(p.[IEPartHistory], '[""]'), ''),0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[IEPartReplacement],nullif(nullif(p.[IEPartReplacement], '[""]'), ''),0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartHistory],nullif(nullif(o.[ConsistPartHistory], '[""]'), ''),0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartReplacement],nullif(nullif(o.[ConsistPartReplacement], '[""]'), ''),0)=1
    
        )
  AND IDS.ID is null;


    SET @RowCount= @@RowCount

SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted updated SISSEARCH.EXPANDEDMININGPRODUCTPARTS Ids.', @DATAVALUE = @RowCount;

SET @TimeMarker = getdate();

-- Inserting updated SISSEARCH.BASICPARTS_2 Ids
INSERT INTO #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED
SELECT src.ID FROM SISSEARCH.BASICPARTS_2 AS src
                       left join SISSEARCH.CONSOLIDATEDPARTS_5 tgt on src.ID = tgt.ID
                       LEFT JOIN #iepartshistory p on coalesce(src.[IEpartNumber], '') = p.Part_Number and src.[orgCode] = p.Org_Code
                       LEFT JOIN #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED IDS on IDS.ID = src.ID
where
(
   [SISSEARCH].[fn_compare_source_target_columns] (tgt.[InformationType],src.[InformationType],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[Medianumber],src.[Medianumber],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[mediaOrigin],src.[mediaOrigin],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[IEupdatedate],src.[IEupdatedate],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[IEpart],src.[IEpart],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[PARTSMANUALMEDIANUMBER],src.[PARTSMANUALMEDIANUMBER],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[IECAPTION],src.[IECAPTION],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[isMedia],src.[isMedia],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[PubDate],src.[PubDate],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ControlNumber],src.[ControlNumber],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[GraphicControlNumber],src.[GraphicControlNumber],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[IEPartName_es-ES],src.[IEPartName_es-ES],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[IEPartName_zh-CN],src.[IEPartName_zh-CN],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[IEPartName_fr-FR],src.[IEPartName_fr-FR],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[IEPartName_it-IT],src.[IEPartName_it-IT],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[IEPartName_de-DE],src.[IEPartName_de-DE],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[IEPartName_pt-BR],src.[IEPartName_pt-BR],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[IEPartName_id-ID],src.[IEPartName_id-ID],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[IEPartName_ja-JP],src.[IEPartName_ja-JP],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[IEPartName_ru-RU],src.[IEPartName_ru-RU],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[orgCode],src.[orgCode],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[IEPartHistory],p.[IEPartHistory],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[IEPartReplacement],p.[IEPartReplacement],1)=1
    )
	AND IDS.ID is null;


    SET @RowCount= @@RowCount

SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted updated SISSEARCH.BASICPARTS_2 Ids', @DATAVALUE = @RowCount;

SET @TimeMarker = getdate();

-- Inserting updated SISSEARCH.CONSISTPARTS_2 Ids
INSERT INTO #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED
SELECT src.ID FROM SISSEARCH.CONSISTPARTS_2 AS src
                       left join SISSEARCH.CONSOLIDATEDPARTS_5 tgt on src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED IDS on IDS.ID = src.ID
where 
(
   [SISSEARCH].[fn_compare_source_target_columns] (tgt.[CONSISTPART],src.[CONSISTPART],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartNames_es-ES],src.[ConsistPartNames_es-ES],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartNames_fr-FR],src.[ConsistPartNames_fr-FR],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartNames_it-IT],src.[ConsistPartNames_it-IT],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartNames_de-DE],src.[ConsistPartNames_de-DE],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartNames_pt-BR],src.[ConsistPartNames_pt-BR],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartNames_id-ID],src.[ConsistPartNames_id-ID],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartNames_ja-JP],src.[ConsistPartNames_ja-JP],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartNames_ru-RU],src.[ConsistPartNames_ru-RU],1)=1
)
AND IDS.ID is null;

    SET @RowCount= @@RowCount


SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted updated SISSEARCH.CONSISTPARTS_2 Ids', @DATAVALUE = @RowCount;

SET @TimeMarker = getdate();

-- Inserting updated SISSEARCH.PRODUCTSTRUCTURE_2 Ids
INSERT INTO #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED
SELECT src.ID FROM SISSEARCH.PRODUCTSTRUCTURE_2 AS src
                       left join SISSEARCH.CONSOLIDATEDPARTS_5 tgt on src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED IDS on IDS.ID = src.ID
where 
(
   [SISSEARCH].[fn_compare_source_target_columns] (tgt.[SYSTEMPSID],src.[SYSTEMPSID],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[PSID],src.[PSID],1)=1
)
AND IDS.ID is null;

    SET @RowCount= @@RowCount


SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted updated SISSEARCH.PRODUCTSTRUCTURE_2 Ids', @DATAVALUE = @RowCount;

SET @TimeMarker = getdate();

-- Inserting updated SISSEARCH.SMCS_2 Ids
INSERT INTO #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED
SELECT src.ID FROM SISSEARCH.SMCS_2 AS src
                       left join SISSEARCH.CONSOLIDATEDPARTS_5 tgt on src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED IDS on IDS.ID = src.ID
where 
(
   [SISSEARCH].[fn_compare_source_target_columns] (tgt.[smcs],src.[smcs],1)=1
)
AND IDS.ID is null;

    SET @RowCount= @@RowCount


SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted updated SISSEARCH.SMCS_2 Ids', @DATAVALUE = @RowCount;

SET @TimeMarker = getdate();

-- Inserting updated SISSEARCH.SNP_4 Ids
INSERT INTO #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED
SELECT src.ID FROM SISSEARCH.SNP_4 AS src
                       left join SISSEARCH.CONSOLIDATEDPARTS_5 tgt on src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED IDS on IDS.ID = src.ID
where 
(
   [SISSEARCH].[fn_compare_source_target_columns] (tgt.[SerialNumbers],src.[SerialNumbers],1)=1
)
AND IDS.ID is null;


    SET @RowCount= @@RowCount


SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted updated SISSEARCH.SNP_4 Ids', @DATAVALUE = @RowCount;


SET @TimeMarker = getdate();

-- Inserting updated SISSEARCH.REMANCONSISTPARTS_2 Ids
INSERT INTO #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED
SELECT src.ID FROM SISSEARCH.REMANCONSISTPARTS_2 AS src
                       left join SISSEARCH.CONSOLIDATEDPARTS_5 tgt on src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED IDS on IDS.ID = src.ID
where 
(
   [SISSEARCH].[fn_compare_source_target_columns] (tgt.[REMANCONSISTPART],src.[REMANCONSISTPART],1)=1
)
AND IDS.ID is null;


      SET @RowCount= @@RowCount


SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted updated SISSEARCH.REMANCONSISTPARTS_2 Ids', @DATAVALUE = @RowCount;

SET @TimeMarker = getdate();

-- Inserting updated SISSEARCH.REMANIEPART_2 Ids
INSERT INTO #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED
SELECT src.ID FROM SISSEARCH.REMANIEPART_2 AS src
                       left join SISSEARCH.CONSOLIDATEDPARTS_5 tgt on src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED IDS on IDS.ID = src.ID
where 
(
   [SISSEARCH].[fn_compare_source_target_columns] (tgt.[REMANIEPART],src.[REMANIEPART],1)=1
)
AND IDS.ID is null;

    SET @RowCount= @@RowCount


SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted updated SISSEARCH.REMANIEPART_2 Ids', @DATAVALUE = @RowCount;

SET @TimeMarker = getdate();
-- Inserting updated SISSEARCH.YELLOWMARKCONSISTPARTS_2 Ids
INSERT INTO #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED
SELECT src.ID FROM SISSEARCH.YELLOWMARKCONSISTPARTS_2 AS src
                       left join SISSEARCH.CONSOLIDATEDPARTS_5 tgt on src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED IDS on IDS.ID = src.ID
where 
(
   [SISSEARCH].[fn_compare_source_target_columns] (tgt.[YELLOWMARKCONSISTPART],src.[YELLOWMARKCONSISTPART],1)=1
)
AND IDS.ID is null;

    SET @RowCount= @@RowCount


SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted updated SISSEARCH.YELLOWMARKCONSISTPARTS_2 Ids', @DATAVALUE = @RowCount;

SET @TimeMarker = getdate();

-- Inserting updated SISSEARCH.YELLOWMARKIEPART_2 Ids
INSERT INTO #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED
SELECT src.ID FROM SISSEARCH.YELLOWMARKIEPART_2 AS src
                       left join SISSEARCH.CONSOLIDATEDPARTS_5 tgt on src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED IDS on IDS.ID = src.ID
where 
(
   [SISSEARCH].[fn_compare_source_target_columns] (tgt.[YELLOWMARKIEPART],src.[YELLOWMARKIEPART],1)=1
)
AND IDS.ID is null;

    SET @RowCount= @@RowCount


SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserting updated SISSEARCH.YELLOWMARKIEPART_2 Ids', @DATAVALUE = @RowCount;


SET @TimeMarker = getdate();

-- Inserting updated SISSEARCH.KITCONSISTPARTS_2 Ids
INSERT INTO #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED
SELECT src.ID FROM SISSEARCH.KITCONSISTPARTS_2 AS src
                       left join SISSEARCH.CONSOLIDATEDPARTS_5 tgt on src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED IDS on IDS.ID = src.ID
where 
(
   [SISSEARCH].[fn_compare_source_target_columns] (tgt.[KITCONSISTPART],src.[KITCONSISTPART],1)=1
)
AND IDS.ID is null;

    SET @RowCount= @@RowCount


SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted updated SISSEARCH.KITCONSISTPARTS_2 Ids', @DATAVALUE = @RowCount;

SET @TimeMarker = getdate();


-- Inserting updated SISSEARCH.KITIEPART_2 Ids
INSERT INTO #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED
SELECT src.ID FROM SISSEARCH.KITIEPART_2 AS src
                       left join SISSEARCH.CONSOLIDATEDPARTS_5 tgt on src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED IDS on IDS.ID = src.ID
where 
(
   [SISSEARCH].[fn_compare_source_target_columns] (tgt.[KITIEPART],src.[KITIEPART],1)=1
)
AND IDS.ID is null;


    SET @RowCount= @@RowCount


SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted updated SISSEARCH.KITIEPART_2 Ids', @DATAVALUE = @RowCount;


SET @TimeMarker = getdate();

-- Inserting updated SISSEARCH.PRODUCTHIERARCHY_2 Ids
INSERT INTO #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED
SELECT src.ID FROM SISSEARCH.PRODUCTHIERARCHY_2 AS src
                       left join SISSEARCH.CONSOLIDATEDPARTS_5 tgt on src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED IDS on IDS.ID = src.ID
where
(
   [SISSEARCH].[fn_compare_source_target_columns] (tgt.[familyCode],src.[familyCode],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[familySubFamilyCode],src.[familySubFamilyCode],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[familySubFamilySalesModel],src.[familySubFamilySalesModel],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[familySubFamilySalesModelSNP],src.[familySubFamilySalesModelSNP],1)=1
)
AND IDS.ID is null;

    SET @RowCount= @@RowCount


SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserting updated SISSEARCH.PRODUCTHIERARCHY_2 Ids', @DATAVALUE = @RowCount;

SET @TimeMarker = getdate();

-- Inserting updated SISSEARCH.PRODUCTHIERARCHY_2 Ids
INSERT INTO #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED
SELECT src.IESYSTEMCONTROLNUMBER FROM #CONSISTPARTHISTORY AS src
                                          left join SISSEARCH.CONSOLIDATEDPARTS_5 tgt on src.IESYSTEMCONTROLNUMBER = tgt.ID
                                          LEFT JOIN #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED IDS on IDS.ID = src.IESYSTEMCONTROLNUMBER
where
(
   [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartHistory],src.[ConsistPartHistory],1)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ConsistPartReplacement],src.[ConsistPartReplacement],1)=1
)
AND IDS.ID is null;


      SET @RowCount= @@RowCount


SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserting updated SISSEARCH.PRODUCTHIERARCHY_2 Ids', @DATAVALUE = @RowCount;

SET @TimeMarker = GETDATE();

DELETE T
FROM
(
SELECT *
, DupRank = ROW_NUMBER() OVER (
              PARTITION BY ID
              ORDER BY (SELECT NULL)
            )
FROM #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED
) AS T
WHERE DupRank > 1

select @RowCount = @@ROWCOUNT;
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Removed duplicate Ids if any from #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATE', @DATAVALUE = @RowCount;
/* =========================================================================================================================================== */

/* Populating #Consolidated from #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATE =========================================================================================================================================== */

Set @TimeMarker = getdate()

-- Insert EMP specific records into #Consolidated temp table first as it has higher priority than other tables
Insert into #Consolidated
SELECT
    emp.ID AS ID
     ,emp.[Iesystemcontrolnumber] [Iesystemcontrolnumber]
     ,emp.InsertDate [INSERTDATE]
     ,emp.[InformationType] [InformationType]
     ,emp.[Medianumber] [Medianumber]
     ,emp.[IEupdatedate]
     ,emp.[IEpart]
     ,emp.[PARTSMANUALMEDIANUMBER] [PARTSMANUALMEDIANUMBER]
     ,emp.[IECAPTION]
     ,emp.[CONSISTPART] [CONSISTPART]
     ,emp.[SYSTEMPSID] [SYSTEMPSID]
     ,emp.[PSID] [PSID]
     ,NULL [smcs]
	,emp.[SerialNumbers] [SerialNumbers]
	,nullif(nullif(emp.[ProductInstanceNumbers], '[""]'), '') [ProductInstanceNumbers]
	,emp.[isMedia]
	,NULL

	,NULL [REMANCONSISTPART]
	,NULL [REMANIEPART]
	,NULL [YELLOWMARKCONSISTPART]
	,NULL [YELLOWMARKIEPART]
	,NULL [KITCONSISTPART]
	,NULL [KITIEPART]
	,emp.[PubDate]
	,emp.[ControlNumber] [ControlNumber]
    ,emp.[GraphicControlNumber] [GraphicControlNumber]
	,emp.[familyCode] familyCode
	,emp.[familySubFamilyCode] familySubFamilyCode
	,emp.[familySubFamilySalesModel] familySubFamilySalesModel
	,emp.[familySubFamilySalesModelSNP] familySubFamilySalesModelSNP

	,nullif(nullif(p.[IEPartHistory]			, '[""]'), '') [IEPartHistory]
	,nullif(nullif(o.[ConsistPartHistory]		, '[""]'), '') [ConsistPartHistory]
	,nullif(nullif(p.[IEPartReplacement]		, '[""]'), '') [IEPartReplacement]
	,nullif(nullif(o.[ConsistPartReplacement]	, '[""]'), '') [ConsistPartReplacement]

	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL

	,emp.[ConsistPartNames_es-ES] [ConsistPartNames_es-ES]
	,emp.[ConsistPartNames_fr-FR] [ConsistPartNames_zh-CN]
	,emp.[ConsistPartNames_fr-FR] [ConsistPartNames_fr-FR]
	,emp.[ConsistPartNames_it-IT] [ConsistPartNames_it-IT]
	,emp.[ConsistPartNames_de-DE] [ConsistPartNames_de-DE]
	,emp.[ConsistPartNames_pt-BR] [ConsistPartNames_pt-BR]
	,emp.[ConsistPartNames_id-ID] [ConsistPartNames_id-ID]
	,emp.[ConsistPartNames_ja-JP] [ConsistPartNames_ja-JP]
	,emp.[ConsistPartNames_ru-RU] [ConsistPartNames_ru-RU]
	,emp.mediaOrigin
	,emp.orgCode [orgCode]
	,1 [isExpandedMiningProduct]

FROM #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED AS IDS
    JOIN SISSEARCH.EXPANDEDMININGPRODUCTPARTS_2 AS emp on emp.ID = IDS.ID
    LEFT JOIN #CONSISTPARTHISTORY o	on o.IESYSTEMCONTROLNUMBER = emp.ID
    LEFT JOIN #iepartshistory p on coalesce(emp.[IEpartNumber], '') = p.Part_Number and emp.[orgCode] = p.Org_Code;

select @RowCount = @@ROWCOUNT;
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Populated Mining Product Parts into #Consolidated', @DATAVALUE = @RowCount;

Set @TimeMarker = getdate()

-- Insert other ids source into temp
Insert into #Consolidated
SELECT --coalesce(bp.[ID], cp.[ID], ps.[ID], smcs.[ID], snp.[ID], rm.ID, rmi.ID, ym.ID, ymi.ID, kt.ID, kti.ID, ph.ID) ID
    IDS.ID AS ID
     ,coalesce(bp.[Iesystemcontrolnumber], cp.IESYSTEMCONTROLNUMBER, ps.[Iesystemcontrolnumber], smcs.[Iesystemcontrolnumber], snp.[Iesystemcontrolnumber]
    ,rm.[IESYSTEMCONTROLNUMBER], rmi.[IESYSTEMCONTROLNUMBER], ym.[IESYSTEMCONTROLNUMBER],
               ymi.[IESYSTEMCONTROLNUMBER], kt.[IESYSTEMCONTROLNUMBER], kti.[IESYSTEMCONTROLNUMBER], ph.[Iesystemcontrolnumber]) [Iesystemcontrolnumber]
     ,coalesce(bp.InsertDate, cp.[INSERTDATE], ps.InsertDate, smcs.InsertDate, snp.InsertDate
    ,rm.[INSERTDATE], rmi.[INSERTDATE], ym.[INSERTDATE], ymi.[INSERTDATE], kt.[INSERTDATE], kti.[INSERTDATE], ph.InsertDate) [INSERTDATE]
     --Basic Parts
     --,bp.[BeginRange]
     --,bp.[EndRange]
     ,nullif(nullif(bp.[InformationType], '[""]'), '') [InformationType]
     ,nullif(nullif(bp.[Medianumber], '[""]'), '') [Medianumber]
     ,bp.[IEupdatedate]
     ,bp.[IEpart]
     ,nullif(nullif(bp.[PARTSMANUALMEDIANUMBER], '[""]'), '') [PARTSMANUALMEDIANUMBER]
     ,bp.[IECAPTION]
     --ConsistParts
     ,nullif(nullif(cp.[CONSISTPART], '[""]'), '') [CONSISTPART]
     --ProductStructure

     ,nullif(nullif(ps.[SYSTEMPSID], '[""]'), '') [SYSTEMPSID]
     ,nullif(nullif(ps.[PSID], '[""]'), '') [PSID]
     --SMCS
     ,nullif(nullif(smcs.[smcs], '[""]'), '') [smcs]
     --SNP
     ,nullif(nullif(snp.[SerialNumbers], '[""]'), '') [SerialNumbers]
     ,NULL [ProductInstanceNumbers]
	,bp.[isMedia]
	,NULL

	,nullif(nullif(rm.[REMANCONSISTPART], '[""]'), '') [REMANCONSISTPART]
	,nullif(nullif(rmi.[REMANIEPART], '[""]'), '') [REMANIEPART]
	,nullif(nullif(ym.[YELLOWMARKCONSISTPART], '[""]'), '') [YELLOWMARKCONSISTPART]
	,nullif(nullif(ymi.[YELLOWMARKIEPART], '[""]'), '') [YELLOWMARKIEPART]
	,nullif(nullif(kt.[KITCONSISTPART], '[""]'), '') [KITCONSISTPART]
	,nullif(nullif(kti.[KITIEPART], '[""]'), '') [KITIEPART]
	,bp.[PubDate]
	,nullif(nullif(bp.[ControlNumber], '[""]'), '') [ControlNumber]
    ,NULLIF(NULLIF(bp.[GraphicControlNumber], '[""]'), '') [GraphicControlNumber]
	,nullif(nullif(ph.[familyCode], '[""]'), '') familyCode
	,nullif(nullif(ph.[familySubFamilyCode], '[""]'), '') familySubFamilyCode
	,nullif(nullif(ph.[familySubFamilySalesModel], '[""]'), '') familySubFamilySalesModel
	,nullif(nullif(ph.[familySubFamilySalesModelSNP], '[""]'), '') familySubFamilySalesModelSNP

	,nullif(nullif(p.[IEPartHistory]			, '[""]'), '') [IEPartHistory]
	,nullif(nullif(o.[ConsistPartHistory]		, '[""]'), '') [ConsistPartHistory]
	,nullif(nullif(p.[IEPartReplacement]		, '[""]'), '') [IEPartReplacement]
	,nullif(nullif(o.[ConsistPartReplacement]	, '[""]'), '') [ConsistPartReplacement]

	,bp.[IEPartName_es-ES]
	,bp.[IEPartName_zh-CN]
	,bp.[IEPartName_fr-FR]
	,bp.[IEPartName_it-IT]
	,bp.[IEPartName_de-DE]
	,bp.[IEPartName_pt-BR]
	,bp.[IEPartName_id-ID]
	,bp.[IEPartName_ja-JP]
	,bp.[IEPartName_ru-RU]

	,nullif(nullif(cp.[ConsistPartNames_es-ES], '[""]'), '') [ConsistPartNames_es-ES]
	,nullif(nullif(cp.[ConsistPartNames_fr-FR], '[""]'), '') [ConsistPartNames_zh-CN]
	,nullif(nullif(cp.[ConsistPartNames_fr-FR], '[""]'), '') [ConsistPartNames_fr-FR]
	,nullif(nullif(cp.[ConsistPartNames_it-IT], '[""]'), '') [ConsistPartNames_it-IT]
	,nullif(nullif(cp.[ConsistPartNames_de-DE], '[""]'), '') [ConsistPartNames_de-DE]
	,nullif(nullif(cp.[ConsistPartNames_pt-BR], '[""]'), '') [ConsistPartNames_pt-BR]
	,nullif(nullif(cp.[ConsistPartNames_id-ID], '[""]'), '') [ConsistPartNames_id-ID]
	,nullif(nullif(cp.[ConsistPartNames_ja-JP], '[""]'), '') [ConsistPartNames_ja-JP]
	,nullif(nullif(cp.[ConsistPartNames_ru-RU], '[""]'), '') [ConsistPartNames_ru-RU]
	,bp.mediaOrigin
	,nullif(bp.orgCode, '') [orgCode]
	,0  [isExpandedMiningProduct]

FROM
    (
    select updated.ID from #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATED updated
    LEFT JOIN #Consolidated tgt on tgt.ID = updated.ID
    where tgt.ID is null-- ignoring already inserted rows from SISSEARCH.EXPANDEDMININGPRODUCTPARTS_2
    ) as IDS
    LEFT JOIN SISSEARCH.BASICPARTS_2 AS bp ON bp.ID = IDS.ID
    LEFT JOIN SISSEARCH.CONSISTPARTS_2 AS cp ON cp.ID = IDS.ID
    LEFT JOIN SISSEARCH.PRODUCTSTRUCTURE_2 AS ps ON ps.ID = IDS.ID
    LEFT JOIN SISSEARCH.SMCS_2 AS smcs ON smcs.ID = IDS.ID
    LEFT JOIN SISSEARCH.SNP_4 AS snp ON snp.ID = IDS.ID
    LEFT JOIN SISSEARCH.REMANCONSISTPARTS_2 AS rm ON rm.ID = IDS.ID
    LEFT JOIN SISSEARCH.REMANIEPART_2 AS rmi ON rmi.ID = IDS.ID
    LEFT JOIN SISSEARCH.YELLOWMARKCONSISTPARTS_2 AS ym ON ym.ID = IDS.ID
    LEFT JOIN SISSEARCH.YELLOWMARKIEPART_2 AS ymi ON ymi.ID = IDS.ID
    LEFT JOIN SISSEARCH.KITCONSISTPARTS_2 AS kt ON kt.ID = IDS.ID
    LEFT JOIN SISSEARCH.KITIEPART_2 AS kti ON kti.ID = IDS.ID
    LEFT JOIN SISSEARCH.PRODUCTHIERARCHY_2 AS ph ON ph.ID = IDS.ID
    LEFT JOIN #CONSISTPARTHISTORY o	on o.IESYSTEMCONTROLNUMBER = IDS.ID
    LEFT JOIN #iepartshistory p on coalesce(bp.[IEpartNumber], '') = p.Part_Number and bp.[orgCode] = p.Org_Code;

select @RowCount = @@ROWCOUNT;

-- drop temp tables
DROP TABLE IF EXISTS #CONSISTPARTHISTORY;
DROP TABLE IF EXISTS #iepartshistory;

SET @LAPSETIME = datediff(SS, @TimeMarker, getdate());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Populated other parts into #Consolidated from #CONSOLIDATEDPARTS_5_IDS_TO_BE_UPDATE', @DATAVALUE = @RowCount;

/* =========================================================================================================================================== #Consolidated should be having all updated parts */

/* Update #Consolidated Suffixed IDs =========================================================================================================================================== */

Set @TimeMarker = getdate()

Update tgt
Set tgt.[Iesystemcontrolnumber] = src.[Iesystemcontrolnumber]
  ,tgt.[INSERTDATE] = src.[INSERTDATE]
  ,tgt.[InformationType] = src.[InformationType]
  ,tgt.[Medianumber] = src.[Medianumber]
  ,tgt.[IEupdatedate] = src.[IEupdatedate]
  ,tgt.[IEpart] = src.[IEpart]
  ,tgt.[PARTSMANUALMEDIANUMBER] = src.[PARTSMANUALMEDIANUMBER]
  ,tgt.[IECAPTION] = src.[IECAPTION]
  ,tgt.[CONSISTPART] = src.[CONSISTPART]
  ,tgt.[SYSTEMPSID] = src.[SYSTEMPSID]
  ,tgt.[PSID] = src.[PSID]
  ,tgt.[smcs] = src.[smcs]
  --,tgt.[SerialNumbers] = src.[SerialNumbers]
  ,tgt.[isMedia] = src.[isMedia]
  ,tgt.[REMANCONSISTPART] = src.[REMANCONSISTPART]
  ,tgt.[REMANIEPART] = src.[REMANIEPART]
  ,tgt.[YELLOWMARKCONSISTPART] = src.[YELLOWMARKCONSISTPART]
  ,tgt.[YELLOWMARKIEPART] = src.[YELLOWMARKIEPART]
  ,tgt.[KITCONSISTPART] = src.[KITCONSISTPART]
  ,tgt.[KITIEPART] = src.[KITIEPART]
  ,tgt.[PubDate] = src.[PubDate]
  ,tgt.[ControlNumber] = src.[ControlNumber]
  ,tgt.[GraphicControlNumber] = src.[GraphicControlNumber]
  ,tgt.[familyCode] = src.[familyCode]
  ,tgt.[familySubFamilyCode] = src.[familySubFamilyCode]
  ,tgt.[familySubFamilySalesModel] = src.[familySubFamilySalesModel]
  ,tgt.familySubFamilySalesModelSNP = src.[familySubFamilySalesModelSNP]

  ,tgt.[IePartHistory]			=src.[IePartHistory]
  ,tgt.[ConsistPartHistory] 		=src.[ConsistPartHistory]
  ,tgt.[IePartReplacement] 		=src.[IePartReplacement]
  ,tgt.[ConsistPartReplacement] 	=src.[ConsistPartReplacement]

  ,tgt.[IEPartName_es-ES] = src.[IEPartName_es-ES]
  ,tgt.[IEPartName_zh-CN] = src.[IEPartName_zh-CN]
  ,tgt.[IEPartName_fr-FR] = src.[IEPartName_fr-FR]
  ,tgt.[IEPartName_it-IT] = src.[IEPartName_it-IT]
  ,tgt.[IEPartName_de-DE] = src.[IEPartName_de-DE]
  ,tgt.[IEPartName_pt-BR] = src.[IEPartName_pt-BR]
  ,tgt.[IEPartName_id-ID] = src.[IEPartName_id-ID]
  ,tgt.[IEPartName_ja-JP] = src.[IEPartName_ja-JP]
  ,tgt.[IEPartName_ru-RU] = src.[IEPartName_ru-RU]
  ,tgt.[ConsistPartNames_es-ES] = src.[ConsistPartNames_es-ES]
  ,tgt.[ConsistPartNames_zh-CN] = src.[ConsistPartNames_zh-CN]
  ,tgt.[ConsistPartNames_fr-FR] = src.[ConsistPartNames_fr-FR]
  ,tgt.[ConsistPartNames_it-IT] = src.[ConsistPartNames_it-IT]
  ,tgt.[ConsistPartNames_de-DE] = src.[ConsistPartNames_de-DE]
  ,tgt.[ConsistPartNames_pt-BR] = src.[ConsistPartNames_pt-BR]
  ,tgt.[ConsistPartNames_id-ID] = src.[ConsistPartNames_id-ID]
  ,tgt.[ConsistPartNames_ja-JP] = src.[ConsistPartNames_ja-JP]
  ,tgt.[ConsistPartNames_ru-RU] = src.[ConsistPartNames_ru-RU]

  ,tgt.mediaOrigin = src.mediaOrigin
  ,tgt.orgCode = src.orgCode
  ,tgt.isExpandedMiningProduct = src.isExpandedMiningProduct

    From #Consolidated tgt
Inner join --Get all attributes from the first version of the ID (no suffix) which matches the natural key.
(
	Select *
	From #Consolidated
	Where [Iesystemcontrolnumber] = ID
) src on src.[Iesystemcontrolnumber] = tgt.[Iesystemcontrolnumber]
where tgt.ID like '%[_]%' --Only update IDs with suffix.  These suffixed records are being created to get around an Azure json object limit.

SET @RowCount= @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
    EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated #Consolidated Suffixed IDs', @DATAVALUE = @RowCount;

/* =========================================================================================================================================== */

/* Update SISSEARCH.CONSOLIDATEDPARTS_5 from #Consolidated =========================================================================================================================================== */

Set @TimeMarker = getdate()

--Update target where ID exist in source and newer inserted datetime
Update tgt
Set
    tgt.[INSERTDATE] = src.[INSERTDATE]
  --,tgt.[BeginRange] = src.[BeginRange]
  --,tgt.[EndRange] = src.[EndRange]
  ,tgt.[InformationType] = src.[InformationType]
  ,tgt.[Medianumber] = src.[Medianumber]
  ,tgt.[IEupdatedate] = src.[IEupdatedate]
  ,tgt.[IEpart] = src.[IEpart]
  ,tgt.[PARTSMANUALMEDIANUMBER] = src.[PARTSMANUALMEDIANUMBER]
  ,tgt.[IECAPTION] = src.[IECAPTION]
  ,tgt.[CONSISTPART] = src.[CONSISTPART]
  ,tgt.[SYSTEM] = src.[SYSTEMPSID]
  ,tgt.[SYSTEMPSID] = src.[SYSTEMPSID]
  ,tgt.[PSID] = src.[PSID]
  ,tgt.[smcs] = src.[smcs]
  ,tgt.[SerialNumbers] = src.[SerialNumbers]
  ,tgt.[ProductInstanceNumbers] = src.[ProductInstanceNumbers]
  ,tgt.[isMedia] = src.[isMedia]
  ,tgt.[REMANCONSISTPART] = src.[REMANCONSISTPART]
  ,tgt.[REMANIEPART] = src.[REMANIEPART]
  ,tgt.[YELLOWMARKCONSISTPART] = src.[YELLOWMARKCONSISTPART]
  ,tgt.[YELLOWMARKIEPART] = src.[YELLOWMARKIEPART]
  ,tgt.[KITCONSISTPART] = src.[KITCONSISTPART]
  ,tgt.[KITIEPART] = src.[KITIEPART]
  ,tgt.[PubDate] = src.[PubDate]
  ,tgt.[ControlNumber] = src.[ControlNumber]
  ,tgt.[GraphicControlNumber] = src.[GraphicControlNumber]
  ,tgt.[familyCode] = src.[familyCode]
  ,tgt.[familySubFamilyCode] = src.[familySubFamilyCode]
  ,tgt.[familySubFamilySalesModel] = src.[familySubFamilySalesModel]
  ,tgt.familySubFamilySalesModelSNP = src.[familySubFamilySalesModelSNP]

  ,tgt.[IePartHistory]			=src.[IePartHistory]
  ,tgt.[ConsistPartHistory] 		=src.[ConsistPartHistory]
  ,tgt.[IePartReplacement] 		=src.[IePartReplacement]
  ,tgt.[ConsistPartReplacement] 	=src.[ConsistPartReplacement]

  ,tgt.[IEPartName_es-ES] = src.[IEPartName_es-ES]
  ,tgt.[IEPartName_zh-CN] = src.[IEPartName_zh-CN]
  ,tgt.[IEPartName_fr-FR] = src.[IEPartName_fr-FR]
  ,tgt.[IEPartName_it-IT] = src.[IEPartName_it-IT]
  ,tgt.[IEPartName_de-DE] = src.[IEPartName_de-DE]
  ,tgt.[IEPartName_pt-BR] = src.[IEPartName_pt-BR]
  ,tgt.[IEPartName_id-ID] = src.[IEPartName_id-ID]
  ,tgt.[IEPartName_ja-JP] = src.[IEPartName_ja-JP]
  ,tgt.[IEPartName_ru-RU] = src.[IEPartName_ru-RU]
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
  ,tgt.[orgCode] = src.[orgCode]
  ,tgt.[isExpandedMiningProduct] = src.[isExpandedMiningProduct]

    From SISSEARCH.CONSOLIDATEDPARTS_5 tgt
Inner join #Consolidated src on tgt.[ID] = src.[ID];

SET @RowCount= @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated records in SISSEARCH.CONSOLIDATEDPARTS_5', @DATAVALUE = @RowCount;

/* =========================================================================================================================================== */

/* delete from SISSEARCH.CONSOLIDATEDPARTS_5 that are not present in source =========================================================================================================================================== */

Set @TimeMarker = getdate()

--Delete from target
Delete SISSEARCH.CONSOLIDATEDPARTS_5
From  SISSEARCH.CONSOLIDATEDPARTS_5 tgt
Left outer join (
	SELECT ID
	  FROM (
			SELECT ID FROM SISSEARCH.BASICPARTS_2 AS bp
			UNION
			SELECT  ID FROM SISSEARCH.CONSISTPARTS_2 AS cp
			UNION
			SELECT ID FROM SISSEARCH.PRODUCTSTRUCTURE_2 AS ps
			UNION
			SELECT ID FROM SISSEARCH.SMCS_2 AS smcs
			UNION
			SELECT ID FROM SISSEARCH.SNP_4 AS snp
			UNION
			SELECT ID FROM SISSEARCH.REMANCONSISTPARTS_2 AS rm
			UNION
			SELECT ID FROM SISSEARCH.REMANIEPART_2 AS rmi
			UNION
			SELECT ID FROM SISSEARCH.YELLOWMARKCONSISTPARTS_2 AS ym
			UNION
			SELECT ID FROM SISSEARCH.YELLOWMARKIEPART_2 AS ymi
			UNION
			SELECT ID FROM SISSEARCH.KITCONSISTPARTS_2 AS kt
			UNION
			SELECT ID FROM SISSEARCH.KITIEPART_2 AS kti
			UNION
			SELECT ID FROM SISSEARCH.PRODUCTHIERARCHY_2 AS ph
			UNION
			SELECT ID FROM SISSEARCH.EXPANDEDMININGPRODUCTPARTS_2 AS emp
		   ) t
	) AS src on tgt.[ID] = src.[ID]
Where src.[ID] is null --Does not exist in source

SET @RowCount= @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())

EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted records from SISSEARCH.CONSOLIDATEDPARTS_5', @DATAVALUE = @RowCount;

/* =========================================================================================================================================== */

/* Insert new ids to SISSEARCH.CONSOLIDATEDPARTS_5 from #Consolidated =========================================================================================================================================== */

Set @TimeMarker = getdate();

--Insert new ID's
INSERT SISSEARCH.CONSOLIDATEDPARTS_5
(
	[ID]
	,[Iesystemcontrolnumber]
	,[INSERTDATE]
	,[InformationType]
	,[Medianumber]
	,[IEupdatedate]
	,[IEpart]
	,[IePartHistory]
	,[IePartReplacement]
	,[PARTSMANUALMEDIANUMBER]
	,[IECAPTION]
	,[CONSISTPART]
	,[ConsistPartHistory]
	,[ConsistPartReplacement]
	,[SYSTEM]
    ,[SYSTEMPSID]
	,[PSID]
	,[smcs]
	,[SerialNumbers]
	,[ProductInstanceNumbers]
	,[isMedia]
	,[Profile]
	,[PubDate]
	,[REMANCONSISTPART]
	,[REMANIEPART]
	,[YELLOWMARKCONSISTPART]
	,[YELLOWMARKIEPART]
	,[KITCONSISTPART]
	,[KITIEPART]
	,[ControlNumber]
    ,[GraphicControlNumber]
	,[familyCode]
	,[familySubFamilyCode]
	,[familySubFamilySalesModel]
	,[familySubFamilySalesModelSNP]
	,[IEPartName_es-ES]
	,[IEPartName_zh-CN]
	,[IEPartName_fr-FR]
	,[IEPartName_it-IT]
	,[IEPartName_de-DE]
	,[IEPartName_pt-BR]
	,[IEPartName_id-ID]
	,[IEPartName_ja-JP]
	,[IEPartName_ru-RU]
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
	,[isExpandedMiningProduct]
	)
Select
    s.[ID]
     ,s.[Iesystemcontrolnumber]
     ,s.[INSERTDATE]
     ,s.[InformationType]
     ,s.[Medianumber]
     ,s.[IEupdatedate]
     ,s.[IEpart]
     ,s.[IEPartHistory]
     ,s.[IEPartReplacement]
     ,s.[PARTSMANUALMEDIANUMBER]
     ,s.[IECAPTION]
     ,s.[CONSISTPART]
     ,s.[ConsistPartHistory]
     ,s.[ConsistPartReplacement]
     ,s.[SYSTEMPSID]
     ,s.[SYSTEMPSID]
     ,s.[PSID]
     ,s.[smcs]
     ,s.[SerialNumbers]
     ,s.[ProductInstanceNumbers]
     ,s.[isMedia]
     ,s.[Profile]
     ,s.[PubDate]
     ,s.[REMANCONSISTPART]
     ,s.[REMANIEPART]
     ,s.[YELLOWMARKCONSISTPART]
     ,s.[YELLOWMARKIEPART]
     ,s.[KITCONSISTPART]
     ,s.[KITIEPART]
     ,s.[ControlNumber]
     ,s.[GraphicControlNumber]
     ,s.[familyCode]
     ,s.[familySubFamilyCode]
     ,s.[familySubFamilySalesModel]
     ,s.[familySubFamilySalesModelSNP]

     ,s.[IEPartName_es-ES]
     ,s.[IEPartName_zh-CN]
     ,s.[IEPartName_fr-FR]
     ,s.[IEPartName_it-IT]
     ,s.[IEPartName_de-DE]
     ,s.[IEPartName_pt-BR]
     ,s.[IEPartName_id-ID]
     ,s.[IEPartName_ja-JP]
     ,s.[IEPartName_ru-RU]
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
     ,s.[isExpandedMiningProduct]
From #Consolidated s
         Left outer join SISSEARCH.CONSOLIDATEDPARTS_5 t on s.[ID] = t.[ID]
Where t.[ID] is null --Does not exist in target

    SET @RowCount= @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
    EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted records into SISSEARCH.CONSOLIDATEDPARTS_5', @DATAVALUE = @RowCount;

/* =========================================================================================================================================== */

/* PartHistory and PartReplacement update =========================================================================================================================================== */

Set @TimeMarker = getdate()

UPDATE SISSEARCH.CONSOLIDATEDPARTS_5
SET
    IePartHistory = s.[IEPartHistory],
    IePartReplacement =s.[IEPartReplacement],
    [ConsistPartHistory]=s.[ConsistPartHistory],
    [ConsistPartReplacement]=s.[ConsistPartReplacement]
FROM #Consolidated s
WHERE CONSOLIDATEDPARTS_5.ID = s.[ID] AND (
    CONSOLIDATEDPARTS_5.[IePartHistory]<> s.[IEPartHistory] OR
    CONSOLIDATEDPARTS_5.[IePartReplacement]<>s.[IEPartReplacement] OR
    CONSOLIDATEDPARTS_5.[ConsistPartHistory]<>s.[ConsistPartHistory] OR
    CONSOLIDATEDPARTS_5.[ConsistPartReplacement]<>s.[ConsistPartReplacement]
    )

SET @RowCount= @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
    EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'PartHistory and PartReplacement update in SISSEARCH.CONSOLIDATEDPARTS_5', @DATAVALUE = @RowCount;

/* =========================================================================================================================================== */

/* Updating profile permissions for consolidatedParts =========================================================================================================================================== */

EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Populating and Updating profile permissions for consolidatedParts';

Set @TimeMarker = getdate();
-- update profile

declare @PROFILE_MUST_INCLUDE int = 1,
	@PROFILE_MUST_EXCLUDE int = 0;
declare @PROFILE_INCLUDE_ALL int = 0,
	@PROFILE_EXCLUDE_ALL int = -1;

-- read permission values
declare @prodFamilyID int, @snpID int, @infoTypeID int;

select @prodFamilyID = PermissionType_ID from admin.Permission where PermissionType_Description='productFamily'
select @snpID = PermissionType_ID from admin.Permission where PermissionType_Description='serialNumberPrefix'
select @infoTypeID = PermissionType_ID from admin.Permission where PermissionType_Description='informationType'

--
-- Create a temp table with detailed PermissionType(family,snp,infotype) for
-- each Part_ID
--
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Creating and Populating Temp Table #PartsProdNSNP';

DROP TABLE IF EXISTS #PartsProdNSNP
Select
    lnk.IESYSTEMCONTROLNUMBER as Part_ID,  @snpID as PermissionType_ID, p.SerialNumberPrefix_ID  as Permission_Detail_ID
into #PartsProdNSNP
from SISWEB_OWNER_SHADOW.LNKPARTSIESNP lnk
         inner join sis.SerialNumberPrefix p ON p.Serial_Number_Prefix=lnk.SNP AND lnk.SNPTYPE='P'
union
select lnk.IESYSTEMCONTROLNUMBER as Part_ID, @prodFamilyID as PermissionType_ID, pf.ProductFamily_ID as Permission_Detail_ID
from SISWEB_OWNER_SHADOW.LNKPARTSIESNP lnk
         inner join sis.SerialNumberPrefix s ON s.Serial_Number_Prefix = lnk.SNP AND lnk.SNPTYPE='P'
         inner join SISWEB_OWNER.LNKPRODUCT p ON p.SNP = s.Serial_Number_Prefix
         inner join sis.ProductFamily pf on pf.Family_Code = p.PRODUCTCODE
union
select
    lnk.IESYSTEMCONTROLNUMBER as Part_ID, @snpID as PermissionType_ID, p.SerialNumberPrefix_ID as Permission_Detail_ID
from SISWEB_OWNER_SHADOW.LNKPARTSIESNP lnk
         inner join sis.SerialNumberPrefix p ON p.Serial_Number_Prefix=lnk.SNP AND lnk.SNPTYPE='C'
union select
          lnk.IESYSTEMCONTROLNUMBER as Part_ID, @snpID as PermissionType_ID, snp.SerialNumberPrefix_ID as Permission_Detail_ID
from SISWEB_OWNER_SHADOW.LNKIEPRODUCTINSTANCE lnk
         inner join SISWEB_OWNER_SHADOW.EMPPRODUCTINSTANCE emp ON lnk.EMPPRODUCTINSTANCE_ID = emp.EMPPRODUCTINSTANCE_ID
         inner join sis.SerialNumberPrefix snp ON snp.Serial_Number_Prefix = emp.SNP
union select
          cast(PARTSPDF_ID as varchar(20)) as Part_ID, @snpID as PermissionType_ID, snp.SerialNumberPrefix_ID as Permission_Detail_ID
from SISWEB_OWNER_SHADOW.LNKPDFPRODUCTINSTANCE lnk
         inner join SISWEB_OWNER_SHADOW.EMPPRODUCTINSTANCE emp ON lnk.EMPPRODUCTINSTANCE_ID = emp.EMPPRODUCTINSTANCE_ID
         inner join sis.SerialNumberPrefix snp ON snp.Serial_Number_Prefix = emp.SNP

EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Creating and Populating Temp Table #PartsInfoType';

DROP TABLE IF EXISTS #PartsInfoType
select
    lnk.IESYSTEMCONTROLNUMBER as Part_ID,
    @infoTypeID as PermissionType_ID,
    5 as Permission_Detail_ID
into #PartsInfoType
from (
         select IESYSTEMCONTROLNUMBER from SISWEB_OWNER_SHADOW.LNKPARTSIESNP
         union
         select IESYSTEMCONTROLNUMBER from SISWEB_OWNER_SHADOW.LNKIEPRODUCTINSTANCE
         union
         select cast(PARTSPDF_ID as varchar(20)) as IESYSTEMCONTROLNUMBER from SISWEB_OWNER_SHADOW.LNKPDFPRODUCTINSTANCE
     ) lnk
group by lnk.IESYSTEMCONTROLNUMBER

CREATE NONCLUSTERED INDEX PartsProdNSNP_Part_ID ON #PartsProdNSNP ([PermissionType_ID]) INCLUDE ([Part_ID],[Permission_Detail_ID])
CREATE NONCLUSTERED INDEX PartsInfoType_Part_ID ON #PartsInfoType ([PermissionType_ID]) INCLUDE ([Part_ID],[Permission_Detail_ID])

EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Creating and Populating Temp Table #AccessProdSNP';

DROP TABLE IF EXISTS #AccessProdSNP
select m.Part_ID, e.Profile_ID
into #AccessProdSNP
from #PartsProdNSNP m
         inner join admin.AccessProfile_Permission_Relation e ON
            m.PermissionType_ID=e.PermissionType_ID AND
            (
                        e.Include_Exclude=@PROFILE_MUST_INCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_INCLUDE_ALL)
                )
        AND NOT (e.Include_Exclude=@PROFILE_MUST_EXCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_EXCLUDE_ALL))
-- use GROUP BY to remove duplicates
GROUP BY m.Part_ID, e.Profile_ID

EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Creating and Populating Temp Table #AccessInfoType';

DROP TABLE IF EXISTS #AccessInfoType
select m.Part_ID, e.Profile_ID
into #AccessInfoType
from #PartsInfoType m
         inner join admin.AccessProfile_Permission_Relation e ON
            m.PermissionType_ID=e.PermissionType_ID AND
            (
                        e.Include_Exclude=@PROFILE_MUST_INCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_INCLUDE_ALL)
                )
        AND NOT (e.Include_Exclude=@PROFILE_MUST_EXCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_EXCLUDE_ALL))
-- use GROUP BY to remove duplicates
GROUP BY m.Part_ID, e.Profile_ID

DROP TABLE IF EXISTS #PartsProdNSNP
DROP TABLE IF EXISTS #PartsInfoType


CREATE NONCLUSTERED INDEX AccessProdSNP_Part_ID ON #AccessProdSNP ([Part_ID],[Profile_ID])
CREATE NONCLUSTERED INDEX AccessInfoType_Part_ID ON #AccessInfoType ([Part_ID],[Profile_ID])

EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Creating and Populating Temp Table #PartProfile';

DROP TABLE IF EXISTS #PartProfile
select Part_ID as ID, '['+string_agg(Profile_ID, ',') WITHIN GROUP (ORDER BY Profile_ID ASC)+']' as Profile
into #PartProfile
from (
    select ps.Part_ID, ps.Profile_ID
    from #AccessInfoType it
    inner join #AccessProdSNP ps on ps.Part_ID=it.Part_ID and ps.Profile_ID=it.Profile_ID
    group by ps.Part_ID, ps.Profile_ID
    ) z
GROUP BY Part_ID

CREATE INDEX PartProfile_ID ON #PartProfile (ID) INCLUDE (Profile)

DROP TABLE IF EXISTS #AccessProdSNP
DROP TABLE IF EXISTS #AccessInfoType

EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Update SISSEARCH.CONSOLIDATEDPARTS_5 Profile column';

UPDATE SISSEARCH.CONSOLIDATEDPARTS_5
SET Profile = src.Profile
    FROM #PartProfile src
WHERE CONSOLIDATEDPARTS_5.ID = src.ID and
    (
    CONSOLIDATEDPARTS_5.Profile <> src.Profile
   or (CONSOLIDATEDPARTS_5.Profile is null and src.Profile is not null)
   or (CONSOLIDATEDPARTS_5.Profile is not null and src.Profile is null)
    )

SET @RowCount= @@RowCount

DROP TABLE IF EXISTS #PartProfile

    SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
    EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated profile permissions in SISSEARCH.CONSOLIDATEDPARTS_5', @DATAVALUE = @RowCount;

/* =========================================================================================================================================== */

DROP TABLE IF EXISTS #Consolidated;

SET @LAPSETIME = datediff(SS, @TotalTimeMarker, getdate())
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Execution completed'

END TRY

BEGIN CATCH
DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(), @ERROELINE INT= ERROR_LINE()


declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC SISSEARCH.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @Sproc, @LOGMESSAGE = @error


END CATCH

END
