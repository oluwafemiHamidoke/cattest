CREATE PROCEDURE [sissearch2].[Consolidated_Parts_Load]
AS
BEGIN

BEGIN TRY

--Var
DECLARE @LAPSETIME BIGINT
		,@Sproc VARCHAR(200) = 'sissearch2.Consolidated_Parts_Load'
		,@RowCount VARCHAR(20)
		,@TimeMarker DATETIME = GETDATE()
		,@TotalTimeMarker DATETIME = GETDATE()

--Start
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Execution started';

/* Creating #consolidated temp table =========================================================================================================================================== */

EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Creating #consolidated temp table';

--Prep
DROP TABLE IF EXISTS #Consolidated /*If Object_ID('tempdb..#Consolidated') is not null Drop table #Consolidated*/

--Create Temp
CREATE TABLE #Consolidated (
    [ID] [VARCHAR](50) NOT NULL PRIMARY KEY,
    [IESystemControlNumber] [VARCHAR](50) NULL,
    [InsertDate] [DATETIME] NULL,
    [InformationType] [VARCHAR](10) NULL,
    [MediaNumber] [VARCHAR](15) NULL,
    [IEUpdateDate] [DATETIME2](0) NULL,
    [IEPart] [NVARCHAR](700) NULL,
    [PartsManualMediaNumber] [VARCHAR](15) NULL,
    [IECaption] [NVARCHAR](2048) NULL,
    [ConsistPart] [NVARCHAR](MAX) NULL,
    [SystemPSID] [VARCHAR](MAX) NULL,
    [PSID] [VARCHAR](MAX) NULL,
    [smcs] [VARCHAR](MAX) NULL,
    [SerialNumbers] [VARCHAR](MAX) NULL,
    [ProductInstanceNumbers] [VARCHAR](MAX) NULL,
    [IsMedia] [bit] NULL,
    [Profile] [VARCHAR](MAX) NULL,
    [REMANConsistPart] [VARCHAR](MAX) NULL,
    [REMANIEPart] [VARCHAR](MAX) NULL,
    [YellowMarkConsistPart] [VARCHAR](MAX) NULL,
    [YellowMarkIEPart] [VARCHAR](MAX) NULL,
    [KITConsistPart] [VARCHAR](MAX) NULL,
    [KITIEPart] [VARCHAR](MAX) NULL,
    [PubDate] [DATETIME] NULL,
    [ControlNumber] [VARCHAR](50) NULL,
    [GraphicControlNumber]   VARCHAR (MAX)  NULL,
    [familyCode] [VARCHAR](MAX) NULL,
    [familySubFamilyCode] [VARCHAR](MAX) NULL,
    [familySubFamilySalesModel] [VARCHAR](MAX) NULL,
    [familySubFamilySalesModelSNP] [VARCHAR](MAX) NULL,
    [IEPartHistory] [VARCHAR](MAX) NULL,
    [ConsistPartHistory] [VARCHAR](MAX) NULL,
    [IEPartReplacement] [VARCHAR](MAX) NULL,
    [ConsistPartReplacement] [VARCHAR](MAX) NULL,
    [IEPartName_es-ES] [NVARCHAR](150) NULL,
    [IEPartName_zh-CN] [NVARCHAR](150) NULL,
    [IEPartName_fr-FR] [NVARCHAR](150) NULL,
    [IEPartName_it-IT] [NVARCHAR](150) NULL,
    [IEPartName_de-DE] [NVARCHAR](150) NULL,
    [IEPartName_pt-BR] [NVARCHAR](150) NULL,
    [IEPartName_id-ID] [NVARCHAR](150) NULL,
    [IEPartName_ja-JP] [NVARCHAR](150) NULL,
    [IEPartName_ru-RU] [NVARCHAR](150) NULL,
    [ConsistPartNames_es-ES] [NVARCHAR](MAX) NULL,
    [ConsistPartNames_zh-CN] [NVARCHAR](MAX) NULL,
    [ConsistPartNames_fr-FR] [NVARCHAR](MAX) NULL,
    [ConsistPartNames_it-IT] [NVARCHAR](MAX) NULL,
    [ConsistPartNames_de-DE] [NVARCHAR](MAX) NULL,
    [ConsistPartNames_pt-BR] [NVARCHAR](MAX) NULL,
    [ConsistPartNames_id-ID] [NVARCHAR](MAX) NULL,
    [ConsistPartNames_ja-JP] [NVARCHAR](MAX) NULL,
    [ConsistPartNames_ru-RU] [NVARCHAR](MAX) NULL,
    [MediaOrigin] [VARCHAR](2) NULL,
    [OrgCode] [VARCHAR](12) NULL,
    [IsExpandedMiningProduct] BIT NULL
)

--Set collation of temp
ALTER TABLE #Consolidated
ALTER COLUMN [ID] varchar(50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL

CREATE NONCLUSTERED INDEX IX_CONSOLIDATED
ON #Consolidated ([IESystemControlNumber])
INCLUDE ([ID]);

/* =========================================================================================================================================== */

/* Populating #ConsistPart and #ConsistPartHISTORY for loading EXPANDEDMININGPRODUCTPARTS===================================================== */

EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Populating #ConsistPart and #ConsistPartHISTORY'

Set @TimeMarker = GETDATE()

DROP TABLE IF EXISTS #ConsistPart

SELECT
    MS.IESystemControlNumber,
    P.Part_Number AS PARTNUMBER,
    P.Org_Code AS OrgCode,
    PIRT.Part_IEPart_Name AS PARTNAME,
    MS.LastModified_Date AS LASTMODIFIEDDATE
INTO #ConsistPart
FROM [sis_shadow].[MediaSequence] MS
INNER JOIN [sis].[MediaSection] MSE ON MS.MediaSection_ID = MSE.MediaSection_ID
INNER JOIN [sis].[Media] M ON M.Media_ID = MSE.Media_ID AND M.[Source] IN ('A','N')
INNER JOIN [sis].[Part_IEPart_Relation] PIR ON PIR.IEPart_ID = MS.IEPart_ID
INNER JOIN [sis].[Part_IEPart_Relation_Translation] PIRT ON PIR.Part_IEPart_Relation_ID = PIRT.Part_IEPart_Relation_ID
INNER JOIN [sis].[Part] P ON P.Part_ID = PIR.Part_ID
WHERE MS.LastModified_Date> ''

SET @RowCount= @@ROWCOUNT;

CREATE CLUSTERED INDEX IX_IESYSTEM_PARTNUMBER_OrgCode ON #ConsistPart (IESystemControlNumber, PARTNUMBER, OrgCode)

SET @LAPSETIME = DATEDIFF(SS, @TimeMarker, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Populated #ConsistPart first part',  @DATAVALUE = @RowCount;

SET @TimeMarker = GETDATE();

INSERT INTO #ConsistPart
SELECT
    MS.IESystemControlNumber,
    P.Part_Number AS PARTNUMBER,
    P.Org_Code AS OrgCode,
    PIRT.Part_IEPart_Name AS PARTNAME,
    MS.LastModified_Date AS LASTMODIFIEDDATE
FROM [sis_shadow].[MediaSequence] MS
INNER JOIN [sis].[MediaSection] MSE ON MS.MediaSection_ID = MSE.MediaSection_ID
INNER JOIN [sis].[Media] M ON M.Media_ID = MSE.Media_ID AND M.[Source] IN ('C')
INNER JOIN [sis].[Part_IEPart_Relation] PIR ON PIR.IEPart_ID = MS.IEPart_ID
INNER JOIN [sis].[Part_IEPart_Relation_Translation] PIRT ON PIR.Part_IEPart_Relation_ID = PIRT.Part_IEPart_Relation_ID
INNER JOIN [sis].[Part] P ON P.Part_ID = PIR.Part_ID
WHERE MS.LastModified_Date> ''

SET @RowCount= @@ROWCOUNT;
SET @LAPSETIME = DATEDIFF(SS, @TimeMarker, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Populated #ConsistPart second part', @DATAVALUE = @RowCount;

SET @TimeMarker = GETDATE();

--Create Temp
DROP TABLE IF EXISTS #ConsistPartHISTORY;

CREATE TABLE #ConsistPartHISTORY
(
    [IESystemControlNumber] [VARCHAR](50),
    ConsistPartHISTORY [NVARCHAR](MAX) NULL,
    ConsistPartREPLACEMENT [NVARCHAR](MAX) NULL
)
CREATE CLUSTERED INDEX IX_ConsistPartHISTORY_IESystemControlNumber ON #ConsistPartHISTORY (IESystemControlNumber)

DROP TABLE IF EXISTS #ConsistPartHISTORYORIGIN;

SELECT *
INTO #ConsistPartHISTORYORIGIN
FROM [SISSEARCH].[vw_ConsistPartSHISTORY_ORIGIN]

CREATE CLUSTERED INDEX IX_ConsistPartHISTORYORIGIN_PARTNUMBER_OrgCode ON #ConsistPartHISTORYORIGIN (Part_Number, Org_Code)

INSERT INTO #ConsistPartHISTORY
SELECT
    x.IESystemControlNumber AS IESystemControlNumber,
    REPLACE('["'+STRING_AGG(TRIM('"' FROM h.ConsistPartHISTORY), '","')+'"]', '[""]', '') AS ConsistPartHISTORY,
    REPLACE('["'+STRING_AGG(TRIM('"' FROM h.ConsistPartREPLACEMENT), '","')+'"]', '[""]', '') AS ConsistPartREPLACEMENT
FROM #ConsistPart x
         LEFT JOIN #ConsistPartHISTORYORIGIN h ON h.Part_Number=x.PARTNUMBER AND h.Org_Code = x.OrgCode
GROUP BY x.IESystemControlNumber

SET @RowCount= @@ROWCOUNT

DROP TABLE IF EXISTS #ConsistPartHISTORYORIGIN
DROP TABLE IF EXISTS #ConsistPart;

SET @LAPSETIME = DATEDIFF(SS, @TimeMarker, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Populated #ConsistPartHISTORY', @LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount;

/* ===========================================================================================================================================  #ConsistPartHISTORY is populated */

/* Populating #IEPartsHistory from sissearch.vw_IEPartSHISTORY =========================================================================================================================================== */

Set @TimeMarker = GETDATE();

SELECT *
INTO #IEPartsHistory
FROM SISSEARCH.vw_IEPartSHISTORY

    SET @RowCount= @@ROWCOUNT

CREATE CLUSTERED INDEX IX_IEPartshistory_PARTNUMBER_OrgCode ON #IEPartsHistory (Part_Number, Org_Code)

SET @LAPSETIME = DATEDIFF(SS, @TimeMarker, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Populated #IEPartsHistory ', @DATAVALUE = @RowCount;

/* =========================================================================================================================================== */

/* Creating and populating #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED =========================================================================================================================================== */

SET @TimeMarker = GETDATE();

DROP TABLE IF EXISTS #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED;
CREATE TABLE #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED
(
    ID [VARCHAR](50) PRIMARY KEY,
    INDEX IX_IDToUpdate_ID NONCLUSTERED (ID)
);

-- Inserting updated sissearch2.EXPANDEDMININGPRODUCTPARTS Ids.
INSERT INTO #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED
SELECT emp.ID FROM sissearch2.ExpandedMiningProductParts AS emp
                       LEFT JOIN #ConsistPartHISTORY o	ON o.IESystemControlNumber = emp.ID
                       LEFT JOIN #IEPartsHistory p ON COALESCE(emp.[IEPartNumber], '') = p.Part_Number and emp.[OrgCode] = p.Org_Code
                       LEFT JOIN sissearch2.Consolidated_Parts tgt ON emp.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED IDS ON IDS.ID = emp.ID
WHERE
    (
            (
                        tgt.[InformationType] <> emp. [InformationType]
                    OR (tgt.[InformationType] IS NULL AND emp. [InformationType] IS NOT NULL)
                    OR (tgt.[InformationType] IS NOT NULL AND emp. [InformationType] IS NULL)
                )
            OR
            (
                        tgt.[MediaNumber] <> emp. [MediaNumber]
                    OR (tgt.[MediaNumber] IS NULL AND emp. [MediaNumber] IS NOT NULL)
                    OR (tgt.[MediaNumber] IS NOT NULL AND emp. [MediaNumber] IS NULL)
                )
            OR
            (
                        tgt.[IEUpdateDate] <> emp. [IEUpdateDate]
                    OR (tgt.[IEUpdateDate] IS NULL AND emp. [IEUpdateDate] IS NOT NULL)
                    OR (tgt.[IEUpdateDate] IS NOT NULL AND emp. [IEUpdateDate] IS NULL)
                )
            OR
            (
                        tgt.[IEPart] <> emp. [IEPart]
                    OR (tgt.[IEPart] IS NULL AND emp. [IEPart] IS NOT NULL)
                    OR (tgt.[IEPart] IS NOT NULL AND emp. [IEPart] IS NULL)
                )
            OR
            (
                        tgt.[PartsManualMediaNumber] <> emp. [PartsManualMediaNumber]
                    OR (tgt.[PartsManualMediaNumber] IS NULL AND emp. [PartsManualMediaNumber] IS NOT NULL)
                    OR (tgt.[PartsManualMediaNumber] IS NOT NULL AND emp. [PartsManualMediaNumber] IS NULL)
                )
            OR
            (
                        tgt.[IECaption] <> emp. [IECaption]
                    OR (tgt.[IECaption] IS NULL AND emp. [IECaption] IS NOT NULL)
                    OR (tgt.[IECaption] IS NOT NULL AND emp. [IECaption] IS NULL)
                )
            OR
            (
                        tgt.[ConsistPart] <> emp. [ConsistPart]
                    OR (tgt.[ConsistPart] IS NULL AND emp. [ConsistPart] IS NOT NULL)
                    OR (tgt.[ConsistPart] IS NOT NULL AND emp. [ConsistPart] IS NULL)
                )
            OR
            (
                        tgt.[System] <> emp. [SYSTEM]
                    OR (tgt.[System] IS NULL AND emp. [SYSTEM] IS NOT NULL)
                    OR (tgt.[System] IS NOT NULL AND emp. [SYSTEM] IS NULL)
                )
            OR
            (
                        tgt.[SystemPSID] <> emp. [SystemPSID]
                    OR (tgt.[SystemPSID] IS NULL AND emp. [SystemPSID] IS NOT NULL)
                    OR (tgt.[SystemPSID] IS NOT NULL AND emp. [SystemPSID] IS NULL)
                )
            OR
            (
                        tgt.[PSID] <> emp. [PSID]
                    OR (tgt.[PSID] IS NULL AND emp. [PSID] IS NOT NULL)
                    OR (tgt.[PSID] IS NOT NULL AND emp. [PSID] IS NULL)
                )
            OR
            (
                        tgt.[SerialNumbers] <> emp. [SerialNumbers]
                    OR (tgt.[SerialNumbers] IS NULL AND emp. [SerialNumbers] IS NOT NULL)
                    OR (tgt.[SerialNumbers] IS NOT NULL AND emp. [SerialNumbers] IS NULL)
                )
            OR
            (
                        tgt.[ProductInstanceNumbers] <> NULLIF(NULLIF(emp.[ProductInstanceNumbers], '[""]'), '')
                    OR (tgt.[ProductInstanceNumbers] IS NULL AND NULLIF(NULLIF(emp.[ProductInstanceNumbers], '[""]'), '') IS NOT NULL)
                    OR (tgt.[ProductInstanceNumbers] IS NOT NULL AND NULLIF(NULLIF(emp.[ProductInstanceNumbers], '[""]'), '') IS NULL)
                )
            OR
            (
                        tgt.[IsMedia] <> emp. [IsMedia]
                    OR (tgt.[IsMedia] IS NULL AND emp. [IsMedia] IS NOT NULL)
                    OR (tgt.[IsMedia] IS NOT NULL AND emp. [IsMedia] IS NULL)
                )
            OR
            (
                        tgt.[PubDate] <> emp. [PubDate]
                    OR (tgt.[PubDate] IS NULL AND emp. [PubDate] IS NOT NULL)
                    OR (tgt.[PubDate] IS NOT NULL AND emp. [PubDate] IS NULL)
                )
            OR
            (
                        tgt.[ControlNumber] <> emp. [ControlNumber]
                    OR (tgt.[ControlNumber] IS NULL AND emp. [ControlNumber] IS NOT NULL)
                    OR (tgt.[ControlNumber] IS NOT NULL AND emp. [ControlNumber] IS NULL)
                )
           OR
            (
                        tgt.[GraphicControlNumber] <> emp. [GraphicControlNumber]
                    OR (tgt.[GraphicControlNumber] IS NULL AND emp. [GraphicControlNumber] IS NOT NULL)
                    OR (tgt.[GraphicControlNumber] IS NOT NULL AND emp. [GraphicControlNumber] IS NULL)
                )
            OR
            (
                        tgt.[FamilyCode] <> emp. [familyCode]
                    OR (tgt.[FamilyCode] IS NULL AND emp. [familyCode] IS NOT NULL)
                    OR (tgt.[FamilyCode] IS NOT NULL AND emp. [familyCode] IS NULL)
                )
            OR
            (
                        tgt.[FamilySubFamilyCode] <> emp. [familySubFamilyCode]
                    OR (tgt.[FamilySubFamilyCode] IS NULL AND emp. [familySubFamilyCode] IS NOT NULL)
                    OR (tgt.[FamilySubFamilyCode] IS NOT NULL AND emp. [familySubFamilyCode] IS NULL)
                )
            OR
            (
                        tgt.[FamilySubFamilySalesModel] <> emp. [familySubFamilySalesModel]
                    OR (tgt.[FamilySubFamilySalesModel] IS NULL AND emp. [familySubFamilySalesModel] IS NOT NULL)
                    OR (tgt.[FamilySubFamilySalesModel] IS NOT NULL AND emp. [familySubFamilySalesModel] IS NULL)
                )
            OR
            (
                        tgt.[FamilySubFamilySalesModelSNP] <> emp. [familySubFamilySalesModelSNP]
                    OR (tgt.[FamilySubFamilySalesModelSNP] IS NULL AND emp. [familySubFamilySalesModelSNP] IS NOT NULL)
                    OR (tgt.[FamilySubFamilySalesModelSNP] IS NOT NULL AND emp. [familySubFamilySalesModelSNP] IS NULL)
                )
            OR
            (
                        tgt.[ConsistPartNames_es-ES] <> emp. [ConsistPartNames_es-ES]
                    OR (tgt.[ConsistPartNames_es-ES] IS NULL AND emp. [ConsistPartNames_es-ES] IS NOT NULL)
                    OR (tgt.[ConsistPartNames_es-ES] IS NOT NULL AND emp. [ConsistPartNames_es-ES] IS NULL)
            )
            -- ignoring zh-CN locale as we do not update it in consolidatedparts_5
            -- OR
            -- (
            -- 	tgt.[ConsistPartNames_zh-CN] <> emp. [ConsistPartNames_zh-CN]
            -- 	OR (tgt.[ConsistPartNames_zh-CN] IS NULL AND emp. [ConsistPartNames_zh-CN] IS NOT NULL)
            -- 	OR (tgt.[ConsistPartNames_zh-CN] IS NOT NULL AND emp. [ConsistPartNames_zh-CN] IS NULL)
            -- )
            OR
            (
                        tgt.[ConsistPartNames_fr-FR] <> emp. [ConsistPartNames_fr-FR]
                    OR (tgt.[ConsistPartNames_fr-FR] IS NULL AND emp. [ConsistPartNames_fr-FR] IS NOT NULL)
                    OR (tgt.[ConsistPartNames_fr-FR] IS NOT NULL AND emp. [ConsistPartNames_fr-FR] IS NULL)
                )
            OR
            (
                        tgt.[ConsistPartNames_it-IT] <> emp. [ConsistPartNames_it-IT]
                    OR (tgt.[ConsistPartNames_it-IT] IS NULL AND emp. [ConsistPartNames_it-IT] IS NOT NULL)
                    OR (tgt.[ConsistPartNames_it-IT] IS NOT NULL AND emp. [ConsistPartNames_it-IT] IS NULL)
                )
            OR
            (
                        tgt.[ConsistPartNames_de-DE] <> emp. [ConsistPartNames_de-DE]
                    OR (tgt.[ConsistPartNames_de-DE] IS NULL AND emp. [ConsistPartNames_de-DE] IS NOT NULL)
                    OR (tgt.[ConsistPartNames_de-DE] IS NOT NULL AND emp. [ConsistPartNames_de-DE] IS NULL)
                )
            OR
            (
                        tgt.[ConsistPartNames_pt-BR] <> emp. [ConsistPartNames_pt-BR]
                    OR (tgt.[ConsistPartNames_pt-BR] IS NULL AND emp. [ConsistPartNames_pt-BR] IS NOT NULL)
                    OR (tgt.[ConsistPartNames_pt-BR] IS NOT NULL AND emp. [ConsistPartNames_pt-BR] IS NULL)
                )
            OR
            (
                        tgt.[ConsistPartNames_id-ID] <> emp. [ConsistPartNames_id-ID]
                    OR (tgt.[ConsistPartNames_id-ID] IS NULL AND emp. [ConsistPartNames_id-ID] IS NOT NULL)
                    OR (tgt.[ConsistPartNames_id-ID] IS NOT NULL AND emp. [ConsistPartNames_id-ID] IS NULL)
                )
            OR
            (
                        tgt.[ConsistPartNames_ja-JP] <> emp. [ConsistPartNames_ja-JP]
                    OR (tgt.[ConsistPartNames_ja-JP] IS NULL AND emp. [ConsistPartNames_ja-JP] IS NOT NULL)
                    OR (tgt.[ConsistPartNames_ja-JP] IS NOT NULL AND emp. [ConsistPartNames_ja-JP] IS NULL)
                )
            OR
            (
                        tgt.[ConsistPartNames_ru-RU] <> emp. [ConsistPartNames_ru-RU]
                    OR (tgt.[ConsistPartNames_ru-RU] IS NULL AND emp. [ConsistPartNames_ru-RU] IS NOT NULL)
                    OR (tgt.[ConsistPartNames_ru-RU] IS NOT NULL AND emp. [ConsistPartNames_ru-RU] IS NULL)
                )
            OR
            (
                        tgt.[MediaOrigin] <> emp. [MediaOrigin]
                    OR (tgt.[MediaOrigin] IS NULL AND emp. [MediaOrigin] IS NOT NULL)
                    OR (tgt.[MediaOrigin] IS NOT NULL AND emp. [MediaOrigin] IS NULL)
                )
            OR
            (
                        tgt.[OrgCode] <> emp. [OrgCode]
                    OR (tgt.[OrgCode] IS NULL AND emp. [OrgCode] IS NOT NULL)
                    OR (tgt.[OrgCode] IS NOT NULL AND emp. [OrgCode] IS NULL)
                )
            OR
            (
                        tgt.[IEPartHistory] <> NULLIF(NULLIF(p.[IEPartHistory], '[""]'), '')
                    OR (tgt.[IEPartHistory] IS NULL AND NULLIF(NULLIF(p.[IEPartHistory], '[""]'), '') IS NOT NULL)
                    OR (tgt.[IEPartHistory] IS NOT NULL AND NULLIF(NULLIF(p.[IEPartHistory], '[""]'), '') IS NULL)
                )
            OR
            (
                        tgt.[IEPartReplacement] <> NULLIF(NULLIF(p.[IEPartReplacement], '[""]'), '')
                    OR (tgt.[IEPartReplacement] IS NULL AND NULLIF(NULLIF(p.[IEPartReplacement], '[""]'), '') IS NOT NULL)
                    OR (tgt.[IEPartReplacement] IS NOT NULL AND NULLIF(NULLIF(p.[IEPartReplacement], '[""]'), '') IS NULL)
                )
            OR
            (
                        tgt.[ConsistPartHistory] <> NULLIF(NULLIF(o.[ConsistPartHistory], '[""]'), '')
                    OR (tgt.[ConsistPartHistory] IS NULL AND NULLIF(NULLIF(o.[ConsistPartHistory], '[""]'), '') IS NOT NULL)
                    OR (tgt.[ConsistPartHistory] IS NOT NULL AND NULLIF(NULLIF(o.[ConsistPartHistory], '[""]'), '') IS NULL)
                )
            OR
            (
                        tgt.[ConsistPartReplacement] <> NULLIF(NULLIF(o.[ConsistPartReplacement], '[""]'), '')
                    OR (tgt.[ConsistPartReplacement] IS NULL AND NULLIF(NULLIF(o.[ConsistPartReplacement], '[""]'), '') IS NOT NULL)
                    OR (tgt.[ConsistPartReplacement] IS NOT NULL AND NULLIF(NULLIF(o.[ConsistPartReplacement], '[""]'), '') IS NULL)
                )
        )
  AND IDS.ID IS NULL;


-- Inserting updated sissearch2.BASICPARTS_2 Ids
INSERT INTO #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED
SELECT src.ID FROM sissearch2.Basic_Parts AS src
                       LEFT JOIN sissearch2.Consolidated_Parts tgt ON src.ID = tgt.ID
                       LEFT JOIN #IEPartsHistory p ON COALESCE(src.[IEPartNumber], '') = p.Part_Number and src.[OrgCode] = p.Org_Code
                       LEFT JOIN #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED IDS ON IDS.ID = src.ID
WHERE
    (
            (
                    NOT(tgt.[InformationType] IS NULL AND src.[InformationType] = '')
                    AND (
                                tgt.[InformationType] <> src.[InformationType]
                            OR (tgt.[InformationType] IS NULL AND src.[InformationType] IS NOT NULL)
                            OR (tgt.[InformationType] IS NOT NULL AND src.[InformationType] IS NULL)
                        )
                )
            OR
            (
                    NOT(tgt.[MediaNumber] IS NULL AND src.[MediaNumber] = '')
                    AND (
                                tgt.[MediaNumber] <> src.[MediaNumber]
                            OR (tgt.[MediaNumber] IS NULL AND src.[MediaNumber] IS NOT NULL)
                            OR (tgt.[MediaNumber] IS NOT NULL AND src.[MediaNumber] IS NULL)
                        )
                )
            OR
            (
                        tgt.[MediaOrigin] <> src.[MediaOrigin]
                    OR (tgt.[MediaOrigin] IS NULL AND src.[MediaOrigin] IS NOT NULL)
                    OR (tgt.[MediaOrigin] IS NOT NULL AND src.[MediaOrigin] IS NULL)
                )
            OR
            (
                        tgt.[IEUpdateDate] <> src.[IEUpdateDate]
                    OR (tgt.[IEUpdateDate] IS NULL AND src.[IEUpdateDate] IS NOT NULL)
                    OR (tgt.[IEUpdateDate] IS NOT NULL AND src.[IEUpdateDate] IS NULL)
                )
            OR
            (
                        tgt.[IEPart] <> src.[IEPart]
                    OR (tgt.[IEPart] IS NULL AND src.[IEPart] IS NOT NULL)
                    OR (tgt.[IEPart] IS NOT NULL AND src.[IEPart] IS NULL)
                )
            OR
            (
                    NOT(tgt.[PartsManualMediaNumber] IS NULL AND src.[PartsManualMediaNumber] = '')
                    AND (
                                tgt.[PartsManualMediaNumber] <> src.[PartsManualMediaNumber]
                            OR (tgt.[PartsManualMediaNumber] IS NULL AND src.[PartsManualMediaNumber] IS NOT NULL)
                            OR (tgt.[PartsManualMediaNumber] IS NOT NULL AND src.[PartsManualMediaNumber] IS NULL)
                        )
                )
            OR
            (
                        tgt.[IECaption] <> src.[IECaption]
                    OR (tgt.[IECaption] IS NULL AND src.[IECaption] IS NOT NULL)
                    OR (tgt.[IECaption] IS NOT NULL AND src.[IECaption] IS NULL)
                )
            OR
            (
                        tgt.[IsMedia] <> src.[IsMedia]
                    OR (tgt.[IsMedia] IS NULL AND src.[IsMedia] IS NOT NULL)
                    OR (tgt.[IsMedia] IS NOT NULL AND src.[IsMedia] IS NULL))
            OR
            (
                        tgt.[PubDate] <> src.[PubDate]
                    OR (tgt.[PubDate] IS NULL AND src.[PubDate] IS NOT NULL)
                    OR (tgt.[PubDate] IS NOT NULL AND src.[PubDate] IS NULL)
                )
            OR
            (
                    NOT(tgt.[ControlNumber] IS NULL AND src.[ControlNumber] = '')
                    AND (
                                tgt.[ControlNumber] <> src.[ControlNumber]
                            OR (tgt.[ControlNumber] IS NULL AND src.[ControlNumber] IS NOT NULL)
                            OR (tgt.[ControlNumber] IS NOT NULL AND src.[ControlNumber] IS NULL)
                        )
                )
            OR
            (
                    NOT(tgt.[GraphicControlNumber] IS NULL AND src.[GraphicControlNumber] = '')
                    AND (
                                tgt.[GraphicControlNumber] <> src.[GraphicControlNumber]
                            OR (tgt.[GraphicControlNumber] IS NULL AND src.[GraphicControlNumber] IS NOT NULL)
                            OR (tgt.[GraphicControlNumber] IS NOT NULL AND src.[GraphicControlNumber] IS NULL)
                        )
                )
            OR
            (
                        tgt.[IEPartName_es-ES] <> src.[IEPartName_es-ES]
                    OR (tgt.[IEPartName_es-ES] IS NULL AND src.[IEPartName_es-ES] IS NOT NULL)
                    OR (tgt.[IEPartName_es-ES] IS NOT NULL AND src.[IEPartName_es-ES] IS NULL)
                )
            OR
            (
                        tgt.[IEPartName_zh-CN] <> src.[IEPartName_zh-CN]
                    OR (tgt.[IEPartName_zh-CN] IS NULL AND src.[IEPartName_zh-CN] IS NOT NULL)
                    OR (tgt.[IEPartName_zh-CN] IS NOT NULL AND src.[IEPartName_zh-CN] IS NULL)
                )
            OR
            (
                        tgt.[IEPartName_fr-FR] <> src.[IEPartName_fr-FR]
                    OR (tgt.[IEPartName_fr-FR] IS NULL AND src.[IEPartName_fr-FR] IS NOT NULL)
                    OR (tgt.[IEPartName_fr-FR] IS NOT NULL AND src.[IEPartName_fr-FR] IS NULL)
                )
            OR
            (
                        tgt.[IEPartName_it-IT] <> src.[IEPartName_it-IT]
                    OR (tgt.[IEPartName_it-IT] IS NULL AND src.[IEPartName_it-IT] IS NOT NULL)
                    OR (tgt.[IEPartName_it-IT] IS NOT NULL AND src.[IEPartName_it-IT] IS NULL)
                )
            OR
            (
                        tgt.[IEPartName_de-DE] <> src.[IEPartName_de-DE]
                    OR (tgt.[IEPartName_de-DE] IS NULL AND src.[IEPartName_de-DE] IS NOT NULL)
                    OR (tgt.[IEPartName_de-DE] IS NOT NULL AND src.[IEPartName_de-DE] IS NULL)
                )
            OR
            (
                        tgt.[IEPartName_pt-BR] <> src.[IEPartName_pt-BR]
                    OR (tgt.[IEPartName_pt-BR] IS NULL AND src.[IEPartName_pt-BR] IS NOT NULL)
                    OR (tgt.[IEPartName_pt-BR] IS NOT NULL AND src.[IEPartName_pt-BR] IS NULL)
                )
            OR
            (
                        tgt.[IEPartName_id-ID] <> src.[IEPartName_id-ID]
                    OR (tgt.[IEPartName_id-ID] IS NULL AND src.[IEPartName_id-ID] IS NOT NULL)
                    OR (tgt.[IEPartName_id-ID] IS NOT NULL AND src.[IEPartName_id-ID] IS NULL)
                )
            OR
            (
                        tgt.[IEPartName_ja-JP] <> src.[IEPartName_ja-JP]
                    OR (tgt.[IEPartName_ja-JP] IS NULL AND src.[IEPartName_ja-JP] IS NOT NULL)
                    OR (tgt.[IEPartName_ja-JP] IS NOT NULL AND src.[IEPartName_ja-JP] IS NULL)
                )
            OR
            (
                        tgt.[IEPartName_ru-RU] <> src.[IEPartName_ru-RU]
                    OR (tgt.[IEPartName_ru-RU] IS NULL AND src.[IEPartName_ru-RU] IS NOT NULL)
                    OR (tgt.[IEPartName_ru-RU] IS NOT NULL AND src.[IEPartName_ru-RU] IS NULL)
                )
            OR
            (
                    NOT(tgt.[OrgCode] IS NULL AND src.[OrgCode] = '')
                    AND (
                                tgt.[OrgCode] <> src.[OrgCode]
                            OR (tgt.[OrgCode] IS NULL AND src.[OrgCode] IS NOT NULL)
                            OR (tgt.[OrgCode] IS NOT NULL AND src.[OrgCode] IS NULL)
                        )
                )
            OR
            (
                    NOT(tgt.[IEPartHistory] IS NULL AND p. [IEPartHistory] = '')
                    AND (
                                tgt.[IEPartHistory] <> p.[IEPartHistory]
                            OR (tgt.[IEPartHistory] IS NULL AND p.[IEPartHistory] IS NOT NULL)
                            OR (tgt.[IEPartHistory] IS NOT NULL AND p.[IEPartHistory] IS NULL)
                        )
                )
            OR
            (
                    NOT(tgt.[IEPartReplacement] IS NULL AND p. [IEPartReplacement] = '')
                    AND (
                                tgt.[IEPartReplacement] <> p.[IEPartReplacement]
                            OR (tgt.[IEPartReplacement] IS NULL AND p.[IEPartReplacement] IS NOT NULL)
                            OR (tgt.[IEPartReplacement] IS NOT NULL AND p.[IEPartReplacement] IS NULL)
                        )
                )
        )
  AND IDS.ID IS NULL;

-- Inserting updated sissearch2.ConsistPartS_2 Ids
INSERT INTO #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED
SELECT src.ID FROM sissearch2.ConsistParts AS src
                       LEFT JOIN sissearch2.Consolidated_Parts tgt ON src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED IDS ON IDS.ID = src.ID
WHERE
    (
            (
                    NOT(tgt.[ConsistPart] IS NULL AND src.[ConsistPart] = '')
                    AND (
                                tgt.[ConsistPart] <> src.[ConsistPart]
                            OR (tgt.[ConsistPart] IS NULL AND src.[ConsistPart] IS NOT NULL)
                            OR (tgt.[ConsistPart] IS NOT NULL AND src.[ConsistPart] IS NULL)
                        )
                )
            OR
            (
                    NOT(tgt.[ConsistPartNames_es-ES] IS NULL AND src.[ConsistPartNames_es-ES] = '')
                    AND (
                                tgt.[ConsistPartNames_es-ES] <> src.[ConsistPartNames_es-ES]
                            OR (tgt.[ConsistPartNames_es-ES] IS NULL AND src.[ConsistPartNames_es-ES] IS NOT NULL)
                            OR (tgt.[ConsistPartNames_es-ES] IS NOT NULL AND src.[ConsistPartNames_es-ES] IS NULL)
                        )
                )
            -- Commenting this out as we are not updating zh-CN locale in consolidatedParts
            -- OR
            --  (
            -- 	NOT(tgt.[ConsistPartNames_es-ES] IS NULL AND src.[ConsistPartNames_es-ES] = '')
            -- 	AND (
            -- 		 tgt.[ConsistPartNames_zh-CN] <> src.[ConsistPartNames_zh-CN]
            -- 		 OR (tgt.[ConsistPartNames_zh-CN] IS NULL AND src.[ConsistPartNames_zh-CN] IS NOT NULL)
            -- 		 OR (tgt.[ConsistPartNames_zh-CN] IS NOT NULL AND src.[ConsistPartNames_zh-CN] IS NULL)
            -- 	)
            --  )
            OR
            (
                    NOT(tgt.[ConsistPartNames_fr-FR] IS NULL AND src.[ConsistPartNames_fr-FR] = '')
                    AND (
                                tgt.[ConsistPartNames_fr-FR] <> src.[ConsistPartNames_fr-FR]
                            OR (tgt.[ConsistPartNames_fr-FR] IS NULL AND src.[ConsistPartNames_fr-FR] IS NOT NULL)
                            OR (tgt.[ConsistPartNames_fr-FR] IS NOT NULL AND src.[ConsistPartNames_fr-FR] IS NULL)
                        )
                )
            OR
            (
                    NOT(tgt.[ConsistPartNames_it-IT] IS NULL AND src.[ConsistPartNames_it-IT] = '')
                    AND (
                                tgt.[ConsistPartNames_it-IT] <> src.[ConsistPartNames_it-IT]
                            OR (tgt.[ConsistPartNames_it-IT] IS NULL AND src.[ConsistPartNames_it-IT] IS NOT NULL)
                            OR (tgt.[ConsistPartNames_it-IT] IS NOT NULL AND src.[ConsistPartNames_it-IT] IS NULL)
                        )
                )
            OR
            (
                    NOT(tgt.[ConsistPartNames_de-DE] IS NULL AND src.[ConsistPartNames_de-DE] = '')
                    AND (
                                tgt.[ConsistPartNames_de-DE] <> src.[ConsistPartNames_de-DE]
                            OR (tgt.[ConsistPartNames_de-DE] IS NULL AND src.[ConsistPartNames_de-DE] IS NOT NULL)
                            OR (tgt.[ConsistPartNames_de-DE] IS NOT NULL AND src.[ConsistPartNames_de-DE] IS NULL)
                        )
                )
            OR
            (
                    NOT(tgt.[ConsistPartNames_pt-BR] IS NULL AND src.[ConsistPartNames_pt-BR] = '')
                    AND (
                                tgt.[ConsistPartNames_pt-BR] <> src.[ConsistPartNames_pt-BR]
                            OR (tgt.[ConsistPartNames_pt-BR] IS NULL AND src.[ConsistPartNames_pt-BR] IS NOT NULL)
                            OR (tgt.[ConsistPartNames_pt-BR] IS NOT NULL AND src.[ConsistPartNames_pt-BR] IS NULL)
                        )
                )
            OR
            (
                    NOT(tgt.[ConsistPartNames_id-ID] IS NULL AND src.[ConsistPartNames_id-ID] = '')
                    AND (
                                tgt.[ConsistPartNames_id-ID] <> src.[ConsistPartNames_id-ID]
                            OR (tgt.[ConsistPartNames_id-ID] IS NULL AND src.[ConsistPartNames_id-ID] IS NOT NULL)
                            OR (tgt.[ConsistPartNames_id-ID] IS NOT NULL AND src.[ConsistPartNames_id-ID] IS NULL)
                        )
                )
            OR
            (
                    NOT(tgt.[ConsistPartNames_ja-JP] IS NULL AND src.[ConsistPartNames_ja-JP] = '')
                    AND (
                                tgt.[ConsistPartNames_ja-JP] <> src.[ConsistPartNames_ja-JP]
                            OR (tgt.[ConsistPartNames_ja-JP] IS NULL AND src.[ConsistPartNames_ja-JP] IS NOT NULL)
                            OR (tgt.[ConsistPartNames_ja-JP] IS NOT NULL AND src.[ConsistPartNames_ja-JP] IS NULL)
                        )
                )
            OR
            (
                    NOT(tgt.[ConsistPartNames_ru-RU] IS NULL AND src.[ConsistPartNames_ru-RU] = '')
                    AND (
                                tgt.[ConsistPartNames_ru-RU] <> src.[ConsistPartNames_ru-RU]
                            OR (tgt.[ConsistPartNames_ru-RU] IS NULL AND src.[ConsistPartNames_ru-RU] IS NOT NULL)
                            OR (tgt.[ConsistPartNames_ru-RU] IS NOT NULL AND src.[ConsistPartNames_ru-RU] IS NULL)
                        )
                )
        )
  AND IDS.ID IS NULL;

-- Inserting updated sissearch2.PRODUCTSTRUCTURE_2 Ids
INSERT INTO #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED
SELECT src.ID FROM sissearch2.ProductStructure AS src
                       LEFT JOIN sissearch2.Consolidated_Parts tgt ON src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED IDS ON IDS.ID = src.ID
WHERE
    (
            (
                    NOT(tgt.[SystemPSID] IS NULL AND src.[SystemPSID] = '')
                    AND (
                                tgt.[SystemPSID] <> src.[SystemPSID]
                            OR (tgt.[SystemPSID] IS NULL AND src.[SystemPSID] IS NOT NULL)
                            OR (tgt.[SystemPSID] IS NOT NULL AND src.[SystemPSID] IS NULL)
                        )
                )
            OR
            (
                    NOT(tgt.[PSID] IS NULL AND src.[PSID] = '')
                    AND (
                                tgt.[PSID] <> src.[PSID]
                            OR (tgt.[PSID] IS NULL AND src.[PSID] IS NOT NULL)
                            OR (tgt.[PSID] IS NOT NULL AND src.[PSID] IS NULL)
                        )
                )
        )
  AND IDS.ID IS NULL;

-- Inserting updated sissearch2.SMCS Ids
INSERT INTO #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED
SELECT src.ID FROM sissearch2.SMCS AS src
                       LEFT JOIN sissearch2.Consolidated_Parts tgt ON src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED IDS ON IDS.ID = src.ID
WHERE
    (
        (
                NOT(tgt.[SMCS] IS NULL AND src.[SMCS] = '')
                AND (
                            tgt.[SMCS] <> src.[SMCS]
                        OR (tgt.[SMCS] IS NULL AND src.[SMCS] IS NOT NULL)
                        OR (tgt.[SMCS] IS NOT NULL AND src.[SMCS] IS NULL)
                    )
            )
        )
  AND IDS.ID IS NULL;

-- Inserting updated sissearch2.SNP Ids
INSERT INTO #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED
SELECT src.ID FROM sissearch2.SNP AS src
                       LEFT JOIN sissearch2.Consolidated_Parts tgt ON src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED IDS ON IDS.ID = src.ID
WHERE
    (
        (
                NOT(tgt.[SerialNumbers] IS NULL AND src.[SerialNumbers] = '')
                AND (
                            tgt.[SerialNumbers] <> src.[SerialNumbers]
                        OR (tgt.[SerialNumbers] IS NULL AND src.[SerialNumbers] IS NOT NULL)
                        OR (tgt.[SerialNumbers] IS NOT NULL AND src.[SerialNumbers] IS NULL)
                    )
            )
        )
  AND IDS.ID IS NULL;

-- Inserting updated sissearch2.REMANConsistPartS_2 Ids
INSERT INTO #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED
SELECT src.ID FROM sissearch2.RemanConsistParts AS src
                       LEFT JOIN sissearch2.Consolidated_Parts tgt ON src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED IDS ON IDS.ID = src.ID
WHERE
    (
        (
                NOT(tgt.[RemanConsistPart] IS NULL AND src.[RemanConsistPart] = '')
                AND (
                            tgt.[RemanConsistPart] <> src.[RemanConsistPart]
                        OR (tgt.[RemanConsistPart] IS NULL AND src.[RemanConsistPart] IS NOT NULL)
                        OR (tgt.[RemanConsistPart] IS NOT NULL AND src.[RemanConsistPart] IS NULL)
                    )
            )
        )
  AND IDS.ID IS NULL;

-- Inserting updated sissearch2.REMANIEPart Ids
INSERT INTO #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED
SELECT src.ID FROM sissearch2.RemanIEPart AS src
                       LEFT JOIN sissearch2.Consolidated_Parts tgt ON src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED IDS ON IDS.ID = src.ID
WHERE
    (
        (
                NOT(tgt.[RemanIEPart] IS NULL AND src.[RemanIEPart] = '')
                AND (
                            tgt.[RemanIEPart] <> src.[RemanIEPart]
                        OR (tgt.[RemanIEPart] IS NULL AND src.[RemanIEPart] IS NOT NULL)
                        OR (tgt.[RemanIEPart] IS NOT NULL AND src.[RemanIEPart] IS NULL)
                    )
            )
        )
  AND IDS.ID IS NULL;

-- Inserting updated sissearch2.YELLOWMARKConsistPartS Ids
INSERT INTO #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED
SELECT src.ID FROM sissearch2.YellowmarkConsistParts AS src
                       LEFT JOIN sissearch2.Consolidated_Parts tgt ON src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED IDS ON IDS.ID = src.ID
WHERE
    (
        (
                NOT(tgt.[YellowMarkConsistPart] IS NULL AND src.[YELLOWMARKConsistPart] = '')
                AND (
                            tgt.[YellowMarkConsistPart] <> src.[YELLOWMARKConsistPart]
                        OR (tgt.[YellowMarkConsistPart] IS NULL AND src.[YELLOWMARKConsistPart] IS NOT NULL)
                        OR (tgt.[YellowMarkConsistPart] IS NOT NULL AND src.[YELLOWMARKConsistPart] IS NULL)
                    )
            )
        )
  AND IDS.ID IS NULL;

-- Inserting updated sissearch2.YELLOWMARKIEPart Ids
INSERT INTO #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED
SELECT src.ID FROM sissearch2.YellowmarkIEPart AS src
                       LEFT JOIN sissearch2.Consolidated_Parts tgt ON src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED IDS ON IDS.ID = src.ID
WHERE
    (
        (
                NOT(tgt.[YellowMarkIEPart] IS NULL AND src.[YELLOWMARKIEPart] = '')
                AND (
                            tgt.[YellowMarkIEPart] <> src.[YELLOWMARKIEPart]
                        OR (tgt.[YellowMarkIEPart] IS NULL AND src.[YELLOWMARKIEPart] IS NOT NULL)
                        OR (tgt.[YellowMarkIEPart] IS NOT NULL AND src.[YELLOWMARKIEPart] IS NULL)
                    )
            )
        )
  AND IDS.ID IS NULL;

-- Inserting updated sissearch2.KITConsistPartS Ids
INSERT INTO #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED
SELECT src.ID FROM sissearch2.KitConsistParts AS src
                       LEFT JOIN sissearch2.Consolidated_Parts tgt ON src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED IDS ON IDS.ID = src.ID
WHERE
    (
        (
                NOT(tgt.[KITConsistPart] IS NULL AND src.[KITConsistPart] = '')
                AND (
                            tgt.[KITConsistPart] <> src.[KITConsistPart]
                        OR (tgt.[KITConsistPart] IS NULL AND src.[KITConsistPart] IS NOT NULL)
                        OR (tgt.[KITConsistPart] IS NOT NULL AND src.[KITConsistPart] IS NULL)
                    )
            )
        )
  AND IDS.ID IS NULL;

-- Inserting updated sissearch2.KITIEPart Ids
INSERT INTO #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED
SELECT src.ID FROM sissearch2.KitIEPart AS src
                       LEFT JOIN sissearch2.Consolidated_Parts tgt ON src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED IDS ON IDS.ID = src.ID
WHERE
    (
        (
                NOT(tgt.[KITIEPart] IS NULL AND src.[KITIEPart] = '')
                AND (
                            tgt.[KITIEPart] <> src.[KITIEPart]
                        OR (tgt.[KITIEPart] IS NULL AND src.[KITIEPart] IS NOT NULL)
                        OR (tgt.[KITIEPart] IS NOT NULL AND src.[KITIEPart] IS NULL)
                    )
            )
        )
  AND IDS.ID IS NULL;

-- Inserting updated sissearch2.PRODUCTHIERARCHY Ids
INSERT INTO #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED
SELECT src.ID FROM sissearch2.ProductHierarchy AS src
                       LEFT JOIN sissearch2.Consolidated_Parts tgt ON src.ID = tgt.ID
                       LEFT JOIN #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED IDS ON IDS.ID = src.ID
WHERE
    (
            (
                    NOT(tgt.[FamilyCode] IS NULL AND src.[familyCode] = '')
                    AND (
                                tgt.[FamilyCode] <> src.[familyCode]
                            OR (tgt.[FamilyCode] IS NULL AND src.[familyCode] IS NOT NULL)
                            OR (tgt.[FamilyCode] IS NOT NULL AND src.[familyCode] IS NULL)
                        )
                )
            OR
            (
                    NOT(tgt.[FamilySubFamilyCode] IS NULL AND src.[familySubFamilyCode] = '')
                    AND (
                                tgt.[FamilySubFamilyCode] <> src.[familySubFamilyCode]
                            OR (tgt.[FamilySubFamilyCode] IS NULL AND src.[familySubFamilyCode] IS NOT NULL)
                            OR (tgt.[FamilySubFamilyCode] IS NOT NULL AND src.[familySubFamilyCode] IS NULL)
                        )
                )
            OR
            (
                    NOT(tgt.[FamilySubFamilySalesModel] IS NULL AND src.[familySubFamilySalesModel] = '')
                    AND (
                                tgt.[FamilySubFamilySalesModel] <> src.[familySubFamilySalesModel]
                            OR (tgt.[FamilySubFamilySalesModel] IS NULL AND src.[familySubFamilySalesModel] IS NOT NULL)
                            OR (tgt.[FamilySubFamilySalesModel] IS NOT NULL AND src.[familySubFamilySalesModel] IS NULL)
                        )
                )
            OR
            (
                    NOT(tgt.[FamilySubFamilySalesModelSNP] IS NULL AND src.[familySubFamilySalesModelSNP] = '')
                    AND (
                                tgt.[FamilySubFamilySalesModelSNP] <> src.[familySubFamilySalesModelSNP]
                            OR (tgt.[FamilySubFamilySalesModelSNP] IS NULL AND src.[familySubFamilySalesModelSNP] IS NOT NULL)
                            OR (tgt.[FamilySubFamilySalesModelSNP] IS NOT NULL AND src.[familySubFamilySalesModelSNP] IS NULL)
                        )
                )
        )
  AND IDS.ID IS NULL;

-- Inserting updated sissearch2.PRODUCTHIERARCHY Ids
INSERT INTO #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED
SELECT src.IESystemControlNumber
FROM #ConsistPartHISTORY AS src
LEFT JOIN sissearch2.Consolidated_Parts tgt ON src.IESystemControlNumber = tgt.ID
LEFT JOIN #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED IDS ON IDS.ID = src.IESystemControlNumber
WHERE
    (
            (
                    NOT(tgt.[ConsistPartHistory] IS NULL AND src.[ConsistPartHistory] = '')
                    AND (
                                tgt.[ConsistPartHistory] <> src.[ConsistPartHistory]
                            OR (tgt.[ConsistPartHistory] IS NULL AND src.[ConsistPartHistory] IS NOT NULL)
                            OR (tgt.[ConsistPartHistory] IS NOT NULL AND src.[ConsistPartHistory] IS NULL)
                        )
                )
            OR
            (
                    NOT(tgt.[ConsistPartReplacement] IS NULL AND src.[ConsistPartReplacement] = '')
                    AND (
                                tgt.[ConsistPartReplacement] <> src.[ConsistPartReplacement]
                            OR (tgt.[ConsistPartReplacement] IS NULL AND src.[ConsistPartReplacement] IS NOT NULL)
                            OR (tgt.[ConsistPartReplacement] IS NOT NULL AND src.[ConsistPartReplacement] IS NULL)
                        )
                )
        )
AND IDS.ID IS NULL;

SELECT @RowCount = COUNT(*) FROM #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED;
SET @LAPSETIME = DATEDIFF(SS, @TimeMarker, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Populated #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATE', @DATAVALUE = @RowCount;

SET @TimeMarker = GETDATE();

DELETE T
FROM
(
SELECT *
, DupRank = ROW_NUMBER() OVER (
              PARTITION BY ID
              ORDER BY (SELECT NULL)
            )
FROM #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED
) AS T
WHERE DupRank > 1

SELECT @RowCount = @@ROWCOUNT;
SET @LAPSETIME = DATEDIFF(SS, @TimeMarker, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Removed duplicate Ids if any from #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATE', @DATAVALUE = @RowCount;
/* =========================================================================================================================================== */

/* Populating #Consolidated from #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATE =========================================================================================================================================== */

SET @TimeMarker = GETDATE()

-- Insert EMP specific records into #Consolidated temp table first as it has higher priority than other tables
INSERT INTO #Consolidated
SELECT
    emp.ID AS ID
     ,emp.[IESystemControlNumber] [IESystemControlNumber]
     ,emp.InsertDate [INSERTDATE]
     ,emp.[InformationType] [InformationType]
     ,emp.[Medianumber] [Medianumber]
     ,emp.[IEUpdateDate]
     ,emp.[IEPart]
     ,emp.[PartsManualMediaNumber] [PartsManualMediaNumber]
     ,emp.[IECaption]
     ,emp.[ConsistPart] [ConsistPart]
     ,emp.[SystemPSID] [SystemPSID]
     ,emp.[PSID] [PSID]
     ,NULL [smcs]
	,emp.[SerialNumbers] [SerialNumbers]
	,NULLIF(NULLIF(emp.[ProductInstanceNumbers], '[""]'), '') [ProductInstanceNumbers]
	,emp.[IsMedia]
	,NULL

	,NULL [REMANConsistPart]
	,NULL [REMANIEPart]
	,NULL [YELLOWMARKConsistPart]
	,NULL [YELLOWMARKIEPart]
	,NULL [KITConsistPart]
	,NULL [KITIEPart]
	,emp.[PubDate]
	,emp.[ControlNumber] [ControlNumber]
	,emp.[GraphicControlNumber] [GraphicControlNumber]
	,emp.[familyCode] familyCode
	,emp.[familySubFamilyCode] familySubFamilyCode
	,emp.[familySubFamilySalesModel] familySubFamilySalesModel
	,emp.[familySubFamilySalesModelSNP] familySubFamilySalesModelSNP

	,NULLIF(NULLIF(p.[IEPartHistory]			, '[""]'), '') [IEPartHistory]
	,NULLIF(NULLIF(o.[ConsistPartHistory]		, '[""]'), '') [ConsistPartHistory]
	,NULLIF(NULLIF(p.[IEPartReplacement]		, '[""]'), '') [IEPartReplacement]
	,NULLIF(NULLIF(o.[ConsistPartReplacement]	, '[""]'), '') [ConsistPartReplacement]

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
	,emp.MediaOrigin
	,emp.OrgCode [OrgCode]
	,1 [isExpandedMiningProduct]

FROM #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED AS IDS
JOIN sissearch2.ExpandedMiningProductParts AS emp ON emp.ID = IDS.ID
LEFT JOIN #ConsistPartHISTORY o	ON o.IESystemControlNumber = emp.ID
LEFT JOIN #IEPartsHistory p ON COALESCE(emp.[IEPartNumber], '') = p.Part_Number and emp.[OrgCode] = p.Org_Code;

SELECT @RowCount = @@ROWCOUNT;
SET @LAPSETIME = DATEDIFF(SS, @TimeMarker, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Populated Mining Product Parts into #Consolidated', @DATAVALUE = @RowCount;

SET @TimeMarker = GETDATE()

-- Insert other ids source into temp
INSERT INTO #Consolidated
SELECT --coalesce(bp.[ID], cp.[ID], ps.[ID], smcs.[ID], snp.[ID], rm.ID, rmi.ID, ym.ID, ymi.ID, kt.ID, kti.ID, ph.ID) ID
    IDS.ID AS ID
    ,COALESCE(
		bp.[IESystemControlNumber],
		cp.IESystemControlNumber,
		ps.[IESystemControlNumber],
		smcs.[IESystemControlNumber],
		snp.[IESystemControlNumber],
		rm.[IESystemControlNumber],
		rmi.[IESystemControlNumber],
		ym.[IESystemControlNumber],
		ymi.[IESystemControlNumber],
		kt.[IESystemControlNumber],
		kti.[IESystemControlNumber],
		ph.[IESystemControlNumber]) [IESystemControlNumber]
    ,COALESCE(
		bp.InsertDate,
		cp.[INSERTDATE],
		ps.InsertDate,
		smcs.InsertDate,
		snp.InsertDate,
		rm.[INSERTDATE],
		rmi.[INSERTDATE],
		ym.[INSERTDATE],
		ymi.[INSERTDATE],
		kt.[INSERTDATE],
		kti.[INSERTDATE],
		ph.InsertDate) [INSERTDATE]
     --Basic Parts
     --,bp.[BeginRange]
     --,bp.[EndRange]
    ,NULLIF(NULLIF(bp.[InformationType], '[""]'), '') [InformationType]
    ,NULLIF(NULLIF(bp.[MediaNumber], '[""]'), '') [Medianumber]
    ,bp.[IEUpdateDate]
    ,bp.[IEPart]
    ,NULLIF(NULLIF(bp.[PartsManualMediaNumber], '[""]'), '') [PartsManualMediaNumber]
    ,bp.[IECaption]
    --ConsistParts
    ,NULLIF(NULLIF(cp.[ConsistPart], '[""]'), '') [ConsistPart]
    --ProductStructure
    ,NULLIF(NULLIF(ps.[SystemPSID], '[""]'), '') [SystemPSID]
    ,NULLIF(NULLIF(ps.[PSID], '[""]'), '') [PSID]
    --SMCS
    ,NULLIF(NULLIF(smcs.[smcs], '[""]'), '') [smcs]
    --SNP
    ,NULLIF(NULLIF(snp.[SerialNumbers], '[""]'), '') [SerialNumbers]
    ,NULL [ProductInstanceNumbers]
	,bp.[IsMedia]
	,NULL
	,NULLIF(NULLIF(rm.[REMANConsistPart], '[""]'), '') [REMANConsistPart]
	,NULLIF(NULLIF(rmi.[REMANIEPart], '[""]'), '') [REMANIEPart]
	,NULLIF(NULLIF(ym.[YELLOWMARKConsistPart], '[""]'), '') [YELLOWMARKConsistPart]
	,NULLIF(NULLIF(ymi.[YELLOWMARKIEPart], '[""]'), '') [YELLOWMARKIEPart]
	,NULLIF(NULLIF(kt.[KITConsistPart], '[""]'), '') [KITConsistPart]
	,NULLIF(NULLIF(kti.[KITIEPart], '[""]'), '') [KITIEPart]
	,bp.[PubDate]
	,NULLIF(NULLIF(bp.[ControlNumber], '[""]'), '') [ControlNumber]
	,NULLIF(NULLIF(bp.[GraphicControlNumber], '[""]'), '') [GraphicControlNumber]
	,NULLIF(NULLIF(ph.[familyCode], '[""]'), '') familyCode
	,NULLIF(NULLIF(ph.[familySubFamilyCode], '[""]'), '') familySubFamilyCode
	,NULLIF(NULLIF(ph.[familySubFamilySalesModel], '[""]'), '') familySubFamilySalesModel
	,NULLIF(NULLIF(ph.[familySubFamilySalesModelSNP], '[""]'), '') familySubFamilySalesModelSNP
	,NULLIF(NULLIF(p.[IEPartHistory]			, '[""]'), '') [IEPartHistory]
	,NULLIF(NULLIF(o.[ConsistPartHistory]		, '[""]'), '') [ConsistPartHistory]
	,NULLIF(NULLIF(p.[IEPartReplacement]		, '[""]'), '') [IEPartReplacement]
	,NULLIF(NULLIF(o.[ConsistPartReplacement]	, '[""]'), '') [ConsistPartReplacement]
	,bp.[IEPartName_es-ES]
	,bp.[IEPartName_zh-CN]
	,bp.[IEPartName_fr-FR]
	,bp.[IEPartName_it-IT]
	,bp.[IEPartName_de-DE]
	,bp.[IEPartName_pt-BR]
	,bp.[IEPartName_id-ID]
	,bp.[IEPartName_ja-JP]
	,bp.[IEPartName_ru-RU]
	,NULLIF(NULLIF(cp.[ConsistPartNames_es-ES], '[""]'), '') [ConsistPartNames_es-ES]
	,NULLIF(NULLIF(cp.[ConsistPartNames_fr-FR], '[""]'), '') [ConsistPartNames_zh-CN]
	,NULLIF(NULLIF(cp.[ConsistPartNames_fr-FR], '[""]'), '') [ConsistPartNames_fr-FR]
	,NULLIF(NULLIF(cp.[ConsistPartNames_it-IT], '[""]'), '') [ConsistPartNames_it-IT]
	,NULLIF(NULLIF(cp.[ConsistPartNames_de-DE], '[""]'), '') [ConsistPartNames_de-DE]
	,NULLIF(NULLIF(cp.[ConsistPartNames_pt-BR], '[""]'), '') [ConsistPartNames_pt-BR]
	,NULLIF(NULLIF(cp.[ConsistPartNames_id-ID], '[""]'), '') [ConsistPartNames_id-ID]
	,NULLIF(NULLIF(cp.[ConsistPartNames_ja-JP], '[""]'), '') [ConsistPartNames_ja-JP]
	,NULLIF(NULLIF(cp.[ConsistPartNames_ru-RU], '[""]'), '') [ConsistPartNames_ru-RU]
	,bp.MediaOrigin
	,NULLIF(bp.OrgCode, '') [OrgCode]
	,0  [isExpandedMiningProduct]
FROM
    (
		SELECT updated.ID from #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATED updated
		LEFT JOIN #Consolidated tgt ON tgt.ID = updated.ID
		WHERE tgt.ID IS NULL-- ignoring already inserted rows from sissearch2.EXPANDEDMININGPRODUCTPARTS_2
    ) AS IDS
LEFT JOIN sissearch2.Basic_Parts AS bp ON bp.ID = IDS.ID
LEFT JOIN sissearch2.ConsistParts AS cp ON cp.ID = IDS.ID
LEFT JOIN sissearch2.ProductStructure AS ps ON ps.ID = IDS.ID
LEFT JOIN sissearch2.SMCS AS smcs ON smcs.ID = IDS.ID
LEFT JOIN sissearch2.SNP AS snp ON snp.ID = IDS.ID
LEFT JOIN sissearch2.RemanConsistParts AS rm ON rm.ID = IDS.ID
LEFT JOIN sissearch2.RemanIEPart AS rmi ON rmi.ID = IDS.ID
LEFT JOIN sissearch2.YellowmarkConsistParts AS ym ON ym.ID = IDS.ID
LEFT JOIN sissearch2.YellowmarkIEPart AS ymi ON ymi.ID = IDS.ID
LEFT JOIN sissearch2.KitConsistParts AS kt ON kt.ID = IDS.ID
LEFT JOIN sissearch2.KitIEPart AS kti ON kti.ID = IDS.ID
LEFT JOIN sissearch2.ProductHierarchy AS ph ON ph.ID = IDS.ID
LEFT JOIN #ConsistPartHISTORY o	ON o.IESystemControlNumber = IDS.ID
LEFT JOIN #IEPartsHistory p ON COALESCE(bp.[IEPartNumber], '') = p.Part_Number and bp.[OrgCode] = p.Org_Code;

SELECT @RowCount = @@ROWCOUNT;

-- drop temp tables
DROP TABLE IF EXISTS #ConsistPartHISTORY;
DROP TABLE IF EXISTS #IEPartsHistory;

SET @LAPSETIME = DATEDIFF(SS, @TimeMarker, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Populated other parts into #Consolidated from #CONSOLIDATEDPARTS_IDS_TO_BE_UPDATE', @DATAVALUE = @RowCount;

/* =========================================================================================================================================== #Consolidated should be having all updated parts */

/* Update #Consolidated Suffixed IDs =========================================================================================================================================== */

SET @TimeMarker = GETDATE()

UPDATE tgt
SET tgt.[IESystemControlNumber] = src.[IESystemControlNumber]
  ,tgt.[INSERTDATE] = src.[INSERTDATE]
  ,tgt.[InformationType] = src.[InformationType]
  ,tgt.[Medianumber] = src.[Medianumber]
  ,tgt.[IEUpdateDate] = src.[IEUpdateDate]
  ,tgt.[IEPart] = src.[IEPart]
  ,tgt.[PartsManualMediaNumber] = src.[PartsManualMediaNumber]
  ,tgt.[IECaption] = src.[IECaption]
  ,tgt.[ConsistPart] = src.[ConsistPart]
  ,tgt.[SystemPSID] = src.[SystemPSID]
  ,tgt.[PSID] = src.[PSID]
  ,tgt.[smcs] = src.[smcs]
  --,tgt.[SerialNumbers] = src.[SerialNumbers]
  ,tgt.[IsMedia] = src.[IsMedia]
  ,tgt.[REMANConsistPart] = src.[REMANConsistPart]
  ,tgt.[REMANIEPart] = src.[REMANIEPart]
  ,tgt.[YELLOWMARKConsistPart] = src.[YELLOWMARKConsistPart]
  ,tgt.[YELLOWMARKIEPart] = src.[YELLOWMARKIEPart]
  ,tgt.[KITConsistPart] = src.[KITConsistPart]
  ,tgt.[KITIEPart] = src.[KITIEPart]
  ,tgt.[PubDate] = src.[PubDate]
  ,tgt.[ControlNumber] = src.[ControlNumber]
  ,tgt.[GraphicControlNumber] = src.[GraphicControlNumber]
  ,tgt.[familyCode] = src.[familyCode]
  ,tgt.[familySubFamilyCode] = src.[familySubFamilyCode]
  ,tgt.[familySubFamilySalesModel] = src.[familySubFamilySalesModel]
  ,tgt.familySubFamilySalesModelSNP = src.[familySubFamilySalesModelSNP]

  ,tgt.[IEPartHistory]			=src.[IEPartHistory]
  ,tgt.[ConsistPartHistory] 		=src.[ConsistPartHistory]
  ,tgt.[IEPartReplacement] 		=src.[IEPartReplacement]
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

  ,tgt.MediaOrigin = src.MediaOrigin
  ,tgt.OrgCode = src.OrgCode
  ,tgt.isExpandedMiningProduct = src.isExpandedMiningProduct

FROM #Consolidated tgt
INNER JOIN --Get all attributes from the first version of the ID (no suffix) which matches the natural key.
(
	SELECT *
	FROM #Consolidated
	WHERE [IESystemControlNumber] = ID
) src ON src.[IESystemControlNumber] = tgt.[IESystemControlNumber]
WHERE tgt.ID like '%[_]%' --Only update IDs with suffix.  These suffixed records are being created to get around an Azure json object limit.

SET @RowCount= @@ROWCOUNT
SET @LAPSETIME = DATEDIFF(SS, @TimeMarker, GETDATE())
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated #Consolidated Suffixed IDs', @DATAVALUE = @RowCount;

/* =========================================================================================================================================== */

/* Update sissearch2.Consolidated_Parts from #Consolidated =========================================================================================================================================== */

SET @TimeMarker = GETDATE()

--Update target where ID exist in source and newer inserted datetime
UPDATE tgt
SET
    tgt.[InsertDate] = src.[INSERTDATE]
  --,tgt.[BeginRange] = src.[BeginRange]
  --,tgt.[EndRange] = src.[EndRange]
  ,tgt.[InformationType] = src.[InformationType]
  ,tgt.[MediaNumber] = src.[Medianumber]
  ,tgt.[IEUpdateDate] = src.[IEUpdateDate]
  ,tgt.[IEPart] = src.[IEPart]
  ,tgt.[PartsManualMediaNumber] = src.[PartsManualMediaNumber]
  ,tgt.[IECaption] = src.[IECaption]
  ,tgt.[ConsistPart] = src.[ConsistPart]
  ,tgt.[System] = src.[SystemPSID]
  ,tgt.[SystemPSID] = src.[SystemPSID]
  ,tgt.[PSID] = src.[PSID]
  ,tgt.[SMCS] = src.[smcs]
  ,tgt.[SerialNumbers] = src.[SerialNumbers]
  ,tgt.[ProductInstanceNumbers] = src.[ProductInstanceNumbers]
  ,tgt.[IsMedia] = src.[IsMedia]
  ,tgt.[REMANConsistPart] = src.[REMANConsistPart]
  ,tgt.[REMANIEPart] = src.[REMANIEPart]
  ,tgt.[YellowMarkConsistPart] = src.[YELLOWMARKConsistPart]
  ,tgt.[YellowMarkIEPart] = src.[YELLOWMARKIEPart]
  ,tgt.[KITConsistPart] = src.[KITConsistPart]
  ,tgt.[KITIEPart] = src.[KITIEPart]
  ,tgt.[PubDate] = src.[PubDate]
  ,tgt.[ControlNumber] = src.[ControlNumber]
  ,tgt.[GraphicControlNumber] = src.[GraphicControlNumber]
  ,tgt.[FamilyCode] = src.[familyCode]
  ,tgt.[FamilySubFamilyCode] = src.[familySubFamilyCode]
  ,tgt.[FamilySubFamilySalesModel] = src.[familySubFamilySalesModel]
  ,tgt.[FamilySubFamilySalesModelSNP] = src.[familySubFamilySalesModelSNP]

  ,tgt.[IEPartHistory]			=src.[IEPartHistory]
  ,tgt.[ConsistPartHistory] 		=src.[ConsistPartHistory]
  ,tgt.[IEPartReplacement] 		=src.[IEPartReplacement]
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
  ,tgt.[MediaOrigin]= src.[MediaOrigin]
  ,tgt.[OrgCode] = src.[OrgCode]
  ,tgt.[IsExpandedMiningProduct] = src.[isExpandedMiningProduct]

FROM sissearch2.Consolidated_Parts tgt
INNER JOIN #Consolidated src ON tgt.[ID] = src.[ID];

SET @RowCount= @@ROWCOUNT
SET @LAPSETIME = DATEDIFF(SS, @TimeMarker, GETDATE())
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated records in sissearch2.Consolidated_Parts', @DATAVALUE = @RowCount;

/* =========================================================================================================================================== */

/* delete from sissearch2.Consolidated_Parts that are not present in source =========================================================================================================================================== */

SET @TimeMarker = GETDATE()

--Delete from target
DELETE sissearch2.Consolidated_Parts
FROM  sissearch2.Consolidated_Parts tgt
LEFT OUTER JOIN (
	SELECT ID
	  FROM (
			SELECT ID FROM sissearch2.Basic_Parts AS bp
			UNION
			SELECT  ID FROM sissearch2.ConsistParts AS cp
			UNION
			SELECT ID FROM sissearch2.ProductStructure AS ps
			UNION
			SELECT ID FROM sissearch2.SMCS AS smcs
			UNION
			SELECT ID FROM sissearch2.SNP AS snp
			UNION
			SELECT ID FROM sissearch2.RemanConsistParts AS rm
			UNION
			SELECT ID FROM sissearch2.RemanIEPart AS rmi
			UNION
			SELECT ID FROM sissearch2.YellowmarkConsistParts AS ym
			UNION
			SELECT ID FROM sissearch2.YellowmarkIEPart AS ymi
			UNION
			SELECT ID FROM sissearch2.KitConsistParts AS kt
			UNION
			SELECT ID FROM sissearch2.KitIEPart AS kti
			UNION
			SELECT ID FROM sissearch2.ProductHierarchy AS ph
			UNION
			SELECT ID FROM sissearch2.ExpandedMiningProductParts AS emp
		   ) t
	) AS src ON tgt.[ID] = src.[ID]
WHERE src.[ID] IS NULL --Does not exist in source

SET @RowCount= @@ROWCOUNT
SET @LAPSETIME = DATEDIFF(SS, @TimeMarker, GETDATE())

EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted records from sissearch2.Consolidated_Parts', @DATAVALUE = @RowCount;

/* =========================================================================================================================================== */

/* Insert new ids to sissearch2.Consolidated_Parts from #Consolidated =========================================================================================================================================== */

SET @TimeMarker = GETDATE();

--Insert new ID's
INSERT sissearch2.Consolidated_Parts
(
	[ID]
	,[IESystemControlNumber]
	,[InsertDate]
	,[InformationType]
	,[MediaNumber]
	,[IEUpdateDate]
	,[IEPart]
	,[PartsManualMediaNumber]
	,[IECaption]
	,[ConsistPart]
	,[System]
	,[SystemPSID]
	,[PSID]
	,[SMCS]
	,[SerialNumbers]
	,[ProductInstanceNumbers]
	,[IsMedia]
	,[Profile]
	,[PubDate]
	,[REMANConsistPart]
	,[REMANIEPart]
	,[YellowMarkConsistPart]
	,[YellowMarkIEPart]
	,[KITConsistPart]
	,[KITIEPart]
	,[ControlNumber]
	,[GraphicControlNumber]
	,[FamilyCode]
	,[FamilySubFamilyCode]
	,[FamilySubFamilySalesModel]
	,[FamilySubFamilySalesModelSNP]
	,[IEPartHistory]
	,[ConsistPartHistory]
	,[IEPartReplacement]
	,[ConsistPartReplacement]
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
	,[MediaOrigin]
	,[OrgCode]
	,[IsExpandedMiningProduct]
)
SELECT    
	s.[ID]
    ,s.[IESystemControlNumber]
    ,s.[INSERTDATE]
    ,s.[InformationType]
    ,s.[Medianumber]
    ,s.[IEUpdateDate]
    ,s.[IEPart]
    ,s.[PartsManualMediaNumber]
    ,s.[IECaption]
    ,s.[ConsistPart]
    ,s.[SystemPSID]
    ,s.[SystemPSID]
    ,s.[PSID]
    ,s.[smcs]
    ,s.[SerialNumbers]
    ,s.[ProductInstanceNumbers]
    ,s.[IsMedia]
    ,s.[Profile]
    ,s.[PubDate]
    ,s.[REMANConsistPart]
    ,s.[REMANIEPart]
    ,s.[YELLOWMARKConsistPart]
    ,s.[YELLOWMARKIEPart]
    ,s.[KITConsistPart]
    ,s.[KITIEPart]
    ,s.[ControlNumber]
    ,s.[GraphicControlNumber]
    ,s.[familyCode]
    ,s.[familySubFamilyCode]
    ,s.[familySubFamilySalesModel]
    ,s.[familySubFamilySalesModelSNP]
    ,s.[IEPartHistory]
    ,s.[ConsistPartHistory]
    ,s.[IEPartReplacement]
    ,s.[ConsistPartReplacement]
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
    ,s.[MediaOrigin]
    ,s.[OrgCode]
    ,s.[isExpandedMiningProduct]
FROM #Consolidated s
LEFT OUTER JOIN sissearch2.Consolidated_Parts t ON s.[ID] = t.[ID]
WHERE t.[ID] IS NULL --Does not exist in target

SET @RowCount= @@ROWCOUNT
SET @LAPSETIME = DATEDIFF(SS, @TimeMarker, GETDATE())
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted records into sissearch2.Consolidated_Parts', @DATAVALUE = @RowCount;

/* =========================================================================================================================================== */

/* Some other update =========================================================================================================================================== */

SET @TimeMarker = GETDATE()

UPDATE sissearch2.Consolidated_Parts
SET
    [IEPartHistory] = s.[IEPartHistory],
    [IEPartReplacement] =s.[IEPartReplacement],
    [ConsistPartHistory]=s.[ConsistPartHistory],
    [ConsistPartReplacement]=s.[ConsistPartReplacement]
FROM #Consolidated s
WHERE Consolidated_Parts.ID = s.[ID] AND (
    Consolidated_Parts.[IEPartHistory]<> s.[IEPartHistory] OR
    Consolidated_Parts.[IEPartReplacement]<>s.[IEPartReplacement] OR
    Consolidated_Parts.[ConsistPartHistory]<>s.[ConsistPartHistory] OR
    Consolidated_Parts.[ConsistPartReplacement]<>s.[ConsistPartReplacement]
    )

SET @RowCount= @@ROWCOUNT
SET @LAPSETIME = DATEDIFF(SS, @TimeMarker, GETDATE())
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Some other update in sissearch2.Consolidated_Parts', @DATAVALUE = @RowCount;

/* =========================================================================================================================================== */

/* Updating profile permissions for consolidatedParts =========================================================================================================================================== */

EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Populating and Updating profile permissions for consolidatedParts';

SET @TimeMarker = GETDATE();
-- update profile

DECLARE @PROFILE_MUST_INCLUDE INT = 1,
		@PROFILE_MUST_EXCLUDE INT = 0;
DECLARE @PROFILE_INCLUDE_ALL INT = 0,
		@PROFILE_EXCLUDE_ALL INT = -1;

-- read permission values
DECLARE @prodFamilyID INT, @snpID INT, @infoTypeID INT;

SELECT @prodFamilyID = PermissionType_ID FROM [admin].Permission WHERE PermissionType_Description='productFamily'
SELECT @snpID = PermissionType_ID FROM [admin].Permission WHERE PermissionType_Description='serialNumberPrefix'
SELECT @infoTypeID = PermissionType_ID FROM [admin].Permission WHERE PermissionType_Description='informationType'

--
-- Create a temp table with detailed PermissionType(family,snp,infotype) for
-- each Part_ID
--
DROP TABLE IF EXISTS #PartsProdNSNP

SELECT
    MSE.IESystemControlNumber AS Part_ID,
	@snpID AS PermissionType_ID,
	p.SerialNumberPrefix_ID  AS Permission_Detail_ID
INTO #PartsProdNSNP
FROM [sis_shadow].[MediaSequence] MSE
INNER JOIN [sis].[MediaSection] MS ON MS.MediaSection_ID = MSE.MediaSection_ID
INNER JOIN [sis].[Media] M ON M.Media_ID = MS.Media_ID
INNER JOIN [sis].MediaSequence_Effectivity MSEE ON MSEE.MediaSequence_ID = MSE.MediaSequence_ID
INNER JOIN [sis].IEPart_Effectivity IE ON M.Media_ID = IE.Media_ID AND MSE.IEPart_ID = IE.IEPart_ID 
	AND MSEE.SerialNumberRange_ID = IE.SerialNumberRange_ID
	AND IE.SerialNumberPrefix_ID = MSEE.SerialNumberPrefix_ID
	AND IE.SerialNumberPrefix_Type IN('P','C')
INNER JOIN sis.SerialNumberPrefix p ON IE.SerialNumberPrefix_ID = p.SerialNumberPrefix_ID 
INNER JOIN sis.SerialNumberRange SR ON SR.SerialNumberRange_ID = IE.SerialNumberRange_ID
UNION
SELECT
	MSE.IESystemControlNumber AS Part_ID,
	@prodFamilyID AS PermissionType_ID,
	pf.ProductFamily_ID AS Permission_Detail_ID
FROM [sis_shadow].[MediaSequence] MSE
	INNER JOIN [sis].[MediaSection] MS ON MS.MediaSection_ID = MSE.MediaSection_ID
	INNER JOIN [sis].[Media] M ON M.Media_ID = MS.Media_ID
	INNER JOIN [sis].MediaSequence_Effectivity MSEE ON MSEE.MediaSequence_ID = MSE.MediaSequence_ID
	INNER JOIN [sis].IEPart_Effectivity IE ON M.Media_ID = IE.Media_ID AND MSE.IEPart_ID = IE.IEPart_ID 
		AND MSEE.SerialNumberRange_ID = IE.SerialNumberRange_ID
		AND IE.SerialNumberPrefix_ID = MSEE.SerialNumberPrefix_ID
		AND IE.SerialNumberPrefix_Type = 'P'
	INNER JOIN sis.SerialNumberPrefix p ON IE.SerialNumberPrefix_ID = p.SerialNumberPrefix_ID 
	INNER JOIN sis.SerialNumberRange SR ON SR.SerialNumberRange_ID = IE.SerialNumberRange_ID
	INNER JOIN [sis].[Product_Relation] PR ON PR.SerialNumberPrefix_ID = IE.SerialNumberPrefix_ID
	INNER JOIN [sis].[ProductFamily] pf ON PR.ProductFamily_ID = pf.ProductFamily_ID
UNION
SELECT
	lnk.IESYSTEMCONTROLNUMBER AS Part_ID,
	@snpID as PermissionType_ID,
	snp.SerialNumberPrefix_ID AS Permission_Detail_ID
FROM SISWEB_OWNER_SHADOW.LNKIEPRODUCTINSTANCE lnk
INNER JOIN SISWEB_OWNER_SHADOW.EMPPRODUCTINSTANCE emp ON lnk.EMPPRODUCTINSTANCE_ID = emp.EMPPRODUCTINSTANCE_ID
INNER JOIN sis.SerialNumberPrefix snp ON snp.Serial_Number_Prefix = emp.SNP
UNION
SELECT
	CAST(PARTSPDF_ID AS VARCHAR(20)) AS Part_ID,
	@snpID AS PermissionType_ID,
	snp.SerialNumberPrefix_ID AS Permission_Detail_ID
FROM SISWEB_OWNER_SHADOW.LNKPDFPRODUCTINSTANCE lnk
INNER JOIN SISWEB_OWNER_SHADOW.EMPPRODUCTINSTANCE emp ON lnk.EMPPRODUCTINSTANCE_ID = emp.EMPPRODUCTINSTANCE_ID
INNER JOIN sis.SerialNumberPrefix snp ON snp.Serial_Number_Prefix = emp.SNP


DROP TABLE IF EXISTS #PartsInfoType;

SELECT
    lnk.IESystemControlNumber AS Part_ID,
    @infoTypeID AS PermissionType_ID,
    5 AS Permission_Detail_ID
INTO #PartsInfoType
FROM (
         SELECT IESystemControlNumber FROM [sis_shadow].[MediaSequence]
         UNION
         SELECT IESystemControlNumber FROM SISWEB_OWNER_SHADOW.LNKIEPRODUCTINSTANCE
         UNION
         SELECT CAST(PARTSPDF_ID AS VARCHAR(20)) AS IESystemControlNumber FROM SISWEB_OWNER_SHADOW.LNKPDFPRODUCTINSTANCE
     ) lnk
GROUP BY lnk.IESystemControlNumber

CREATE NONCLUSTERED INDEX PartsProdNSNP_Part_ID ON #PartsProdNSNP ([PermissionType_ID]) INCLUDE ([Part_ID],[Permission_Detail_ID])
CREATE NONCLUSTERED INDEX PartsInfoType_Part_ID ON #PartsInfoType ([PermissionType_ID]) INCLUDE ([Part_ID],[Permission_Detail_ID])


DROP TABLE IF EXISTS #AccessProdSNP
SELECT m.Part_ID, e.Profile_ID
INTO #AccessProdSNP
FROM #PartsProdNSNP m
INNER JOIN [admin].AccessProfile_Permission_Relation e ON
    m.PermissionType_ID=e.PermissionType_ID AND
    (
        e.Include_Exclude=@PROFILE_MUST_INCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_INCLUDE_ALL)
    )
    AND NOT (e.Include_Exclude=@PROFILE_MUST_EXCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_EXCLUDE_ALL))
-- use GROUP BY to remove duplicates
GROUP BY m.Part_ID, e.Profile_ID


DROP TABLE IF EXISTS #AccessInfoType
SELECT m.Part_ID, e.Profile_ID
INTO #AccessInfoType
FROM #PartsInfoType m
INNER JOIN [admin].AccessProfile_Permission_Relation e ON
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

DROP TABLE IF EXISTS #PartProfile
SELECT Part_ID as ID, '['+STRING_AGG(Profile_ID, ',') WITHIN GROUP (ORDER BY Profile_ID ASC)+']' AS [Profile]
INTO #PartProfile
FROM (
    SELECT ps.Part_ID, ps.Profile_ID
    FROM #AccessInfoType it
    INNER JOIN #AccessProdSNP ps ON ps.Part_ID=it.Part_ID AND ps.Profile_ID=it.Profile_ID
    GROUP BY ps.Part_ID, ps.Profile_ID
    ) z
GROUP BY Part_ID

CREATE INDEX PartProfile_ID ON #PartProfile (ID) INCLUDE ([Profile])

DROP TABLE IF EXISTS #AccessProdSNP
DROP TABLE IF EXISTS #AccessInfoType

UPDATE sissearch2.Consolidated_Parts
SET [Profile] = src.[Profile]
FROM #PartProfile src
WHERE Consolidated_Parts.ID = src.ID AND
    (
    Consolidated_Parts.[Profile] <> src.[Profile]
   OR (Consolidated_Parts.[Profile] IS NULL AND src.[Profile] IS NOT NULL)
   OR (Consolidated_Parts.[Profile] IS NOT NULL AND src.[Profile] IS NULL)
    )

SET @RowCount= @@ROWCOUNT

DROP TABLE IF EXISTS #PartProfile

SET @LAPSETIME = DATEDIFF(SS, @TimeMarker, GETDATE())
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated profile permissions in sissearch2.Consolidated_Parts', @DATAVALUE = @RowCount;

/* =========================================================================================================================================== */

DROP TABLE IF EXISTS #Consolidated;

SET @LAPSETIME = DATEDIFF(SS, @TotalTimeMarker, GETDATE())
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Execution completed'

END TRY
BEGIN CATCH
	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(), @ERROELINE INT= ERROR_LINE()
	DECLARE @error NVARCHAR(MAX) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
	EXEC sissearch2.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @Sproc, @LOGMESSAGE = @error
END CATCH

END
GO
