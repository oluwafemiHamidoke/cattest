CREATE PROCEDURE [SISSEARCH].[CONSOLIDATEDSERVICEIE_4_LOAD] as 
/*
Modifiy Date: 20210310 - Davide. Changed DATEUPDATED to LASTMODDIFIEDDATE, see: https://dev.azure.com/sis-cat-com/sis2-ui/_workitems/edit/9566/
Exec  [SISSEARCH].[CONSOLIDATEDSERVICEIE_4_LOAD]
*/
BEGIN 

BEGIN TRY

--Start
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = 'SISSEARCH.CONSOLIDATEDSERVICEIE_4_LOAD', @LOGMESSAGE = 'Execution started';


--Prep
If OBJECT_ID('tempdb..#Consolidated') IS NOT NULL DROP TABLE #Consolidated

--Create Temp
CREATE TABLE #Consolidated (
	[ID] [VARCHAR](50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
	[IESystemControlNumber] [VARCHAR](15) NOT NULL,
	[InfoType] [VARCHAR](4000) NULL,
	[MediaNumbers] [VARCHAR](MAX) NULL,
	[UpdatedDate] [DATE] NULL,
	[SerialNumbers] [VARCHAR](MAX) NULL,
	[SMCSCodes] [VARCHAR](MAX) NULL,
	[ProductStructureSystemIDs] [VARCHAR](MAX) NULL,
	[Title_en] [NVARCHAR](4000) NULL,
	[isMedia] [bit] NULL,
	[Profile] [VARCHAR](MAX) NULL,
	[ProductCodes] [VARCHAR](MAX) NULL,
	[InsertDate] [DATETIME] NOT NULL,
	[PubDate] [DATETIME2] NULL,
	[ControlNumber] [VARCHAR](4000) NULL,
	[GraphicControlNumber] [VARCHAR] (MAX) NULL,
	[familyCode] [VARCHAR](MAX) NULL,
	[familySubFamilyCode] [VARCHAR](MAX) NULL,
	[familySubFamilySalesModel] [VARCHAR](MAX) NULL,
	[familySubFamilySalesModelSNP] [VARCHAR](MAX) NULL,
	[Title_es-ES] [NVARCHAR](4000) NULL,
	[Title_zh-CN] [NVARCHAR](4000) NULL,
	[Title_fr-FR] [NVARCHAR](4000) NULL,
	[Title_it-IT] [NVARCHAR](4000) NULL,
	[Title_de-DE] [NVARCHAR](4000) NULL,
	[Title_pt-BR] [NVARCHAR](4000) NULL,
	[Title_id-ID] [NVARCHAR](4000) NULL,
	[Title_ja-JP] [NVARCHAR](4000) NULL,
	[Title_ru-RU] [NVARCHAR](4000) NULL,
	[PubDate_es-ES] [DATETIME2](7) NULL,
	[PubDate_zh-CN] [DATETIME2](7) NULL,
	[PubDate_fr-FR] [DATETIME2](7) NULL,
	[PubDate_it-IT] [DATETIME2](7) NULL,
	[PubDate_de-DE] [DATETIME2](7) NULL,
	[PubDate_pt-BR] [DATETIME2](7) NULL,
	[PubDate_id-ID] [DATETIME2](7) NULL,
	[PubDate_ja-JP] [DATETIME2](7) NULL,
	[PubDate_ru-RU] [DATETIME2](7) NULL,
	[UpdatedDate_es-ES] [DATE] NULL,
	[UpdatedDate_zh-CN] [DATE] NULL,
	[UpdatedDate_fr-FR] [DATE] NULL,
	[UpdatedDate_it-IT] [DATE] NULL,
	[UpdatedDate_de-DE] [DATE] NULL,
	[UpdatedDate_pt-BR] [DATE] NULL,
	[UpdatedDate_id-ID] [DATE] NULL,
	[UpdatedDate_ja-JP] [DATE] NULL,
	[UpdatedDate_ru-RU] [DATE] NULL,
	[MediaNumbers_es-ES] [VARCHAR](MAX) NULL,
	[MediaNumbers_zh-CN] [VARCHAR](MAX) NULL,
	[MediaNumbers_fr-FR] [VARCHAR](MAX) NULL,
	[MediaNumbers_it-IT] [VARCHAR](MAX) NULL,
	[MediaNumbers_de-DE] [VARCHAR](MAX) NULL,
	[MediaNumbers_pt-BR] [VARCHAR](MAX) NULL,
	[MediaNumbers_id-ID] [VARCHAR](MAX) NULL,
	[MediaNumbers_ja-JP] [VARCHAR](MAX) NULL,
	[MediaNumbers_ru-RU] [VARCHAR](MAX) NULL,
	CONSTRAINT [PK_Consolidated_ID_Temp] PRIMARY KEY CLUSTERED ([ID])
	)
--Var
DECLARE @Sproc VARCHAR(200) = 'SISSEARCH.CONSOLIDATEDSERVICEIE_4_LOAD',
		@RowCount BIGINT,
		@LAPSETIME BIGINT,
		@TimeMarker DATETIME = getdate()

-- UPDATE profile

DECLARE @PROFILE_MUST_INCLUDE INT = 1,
		@PROFILE_MUST_EXCLUDE INT = 0;
DECLARE @PROFILE_INCLUDE_ALL INT = 0,
		@PROFILE_EXCLUDE_ALL INT = -1;

-- read permission values
DECLARE @prodFamilyID INT, @snpID INT, @infoTypeID INT;

SELECT @prodFamilyID = PermissionType_ID FROM admin.Permission WHERE PermissionType_Description='productFamily'
SELECT @snpID = PermissionType_ID FROM admin.Permission WHERE PermissionType_Description='serialNumberPrefix'
SELECT @infoTypeID = PermissionType_ID FROM admin.Permission WHERE PermissionType_Description='informationType'

-- Create a temp table with detailed PermissionType(family,snp,infotype) for each IE_ID
DROP TABLE IF EXISTS #IEProdNSNP

SELECT IE_ID, PermissionType_ID, Permission_Detail_ID 
INTO #IEProdNSNP
FROM (
	SELECT 
		e.IE_ID, @prodFamilyID as PermissionType_ID, pef.ProductFamily_ID as Permission_Detail_ID
	FROM sis.IE e
		inner join sis.IE_ProductFamily_Effectivity pef ON pef.IE_ID=e.IE_ID
		-- inner join sis.ProductFamily pf ON pef.ProductFamily_ID=pf.ProductFamily_ID
	union SELECT 
		e.IE_ID, @snpID as PermissionType_ID, sp.SerialNumberPrefix_ID as Permission_Detail_ID
	FROM sis.IE e
		inner join sis.IE_Effectivity ef ON ef.IE_ID=e.IE_ID
		inner join sis.SerialNumberPrefix sp ON ef.SerialNumberPrefix_ID=sp.SerialNumberPrefix_ID
) x
GROUP BY IE_ID, PermissionType_ID, Permission_Detail_ID
ORDER BY IE_ID, PermissionType_ID

SET @RowCount = @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Created Temp Table #IEProdNSNP',@DATAVALUE = @RowCount;
SET @TimeMarker = getdate()

DROP TABLE IF EXISTS #IEInfoType
SELECT 
	e.IE_ID, @infoTypeID as PermissionType_ID, i.InfoType_ID as Permission_Detail_ID
INTO #IEInfoType
FROM sis.IE e
	inner join sis.IE_InfoType_Relation i ON e.IE_ID=i.IE_ID

CREATE NONCLUSTERED INDEX IEProdNSNP_IE_ID ON #IEProdNSNP ([PermissionType_ID]) INCLUDE ([IE_ID],[Permission_Detail_ID])
CREATE NONCLUSTERED INDEX IEInfoType_IE_ID ON #IEInfoType ([PermissionType_ID]) INCLUDE ([IE_ID],[Permission_Detail_ID])

SET @RowCount = @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Created Temp Table #IEInfoType',@DATAVALUE = @RowCount;
SET @TimeMarker = getdate()


DROP TABLE IF EXISTS #AccessProdSNP
SELECT m.IE_ID, e.Profile_ID
INTO #AccessProdSNP
FROM #IEProdNSNP m
inner join admin.AccessProfile_Permission_Relation e ON
	m.PermissionType_ID=e.PermissionType_ID AND
	(
		e.Include_Exclude=@PROFILE_MUST_INCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_INCLUDE_ALL)
	)
	AND NOT (e.Include_Exclude=@PROFILE_MUST_EXCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_EXCLUDE_ALL))
-- use GROUP BY to remove duplicates
GROUP BY m.IE_ID, e.Profile_ID

DROP TABLE IF EXISTS #IEProdNSNP

SET @RowCount = @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Created Temp Table #AccessProdSNP',@DATAVALUE = @RowCount;
SET @TimeMarker = getdate()

DROP TABLE IF EXISTS #AccessInfoType
SELECT m.IE_ID, e.Profile_ID
INTO #AccessInfoType
FROM #IEInfoType m
inner join admin.AccessProfile_Permission_Relation e ON
	m.PermissionType_ID=e.PermissionType_ID AND
	(
		e.Include_Exclude=@PROFILE_MUST_INCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_INCLUDE_ALL)
	)
	AND NOT (e.Include_Exclude=@PROFILE_MUST_EXCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_EXCLUDE_ALL))
-- use GROUP BY to remove duplicates
GROUP BY m.IE_ID, e.Profile_ID

DROP TABLE IF EXISTS #IEInfoType

SET @RowCount = @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Created Temp Table #AccessInfoType',@DATAVALUE = @RowCount;
SET @TimeMarker = getdate()

DROP TABLE IF EXISTS #IEProfile
SELECT z.IE_ID, t.IESystemControlNumber, '['+string_agg(Profile_ID, ',') WITHIN GROUP (ORDER BY Profile_ID ASC)+']' as Profile
INTO #IEProfile
FROM (
	SELECT ps.IE_ID, ps.Profile_ID 
	FROM #AccessInfoType it
		inner join #AccessProdSNP ps ON ps.IE_ID=it.IE_ID and ps.Profile_ID=it.Profile_ID
	GROUP BY ps.IE_ID, ps.Profile_ID
) z
inner join sis.IE t ON t.IE_ID=z.IE_ID
GROUP BY z.IE_ID, t.IESystemControlNumber

DROP TABLE IF EXISTS #AccessInfoType

SET @RowCount = @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Created Temp Table #IEProfile',@DATAVALUE = @RowCount;
SET @TimeMarker = getdate()


--INSERT updated source INTO temp
INSERT INTO #Consolidated
(
 [ID]
,[IESystemControlNumber]
,[InfoType]
,[MediaNumbers]
,[UpdatedDate]
,[SerialNumbers]
,[SMCSCodes]
,[ProductStructureSystemIDs]
,[Title_en]
,[isMedia]
,[Profile]
,[ProductCodes]
,[InsertDate]
,[PubDate]
,[ControlNumber]
,[GraphicControlNumber]
,[familyCode]
,[familySubFamilyCode]
,[familySubFamilySalesModel]
,[familySubFamilySalesModelSNP]
,[Title_es-ES]
,[Title_zh-CN]
,[Title_fr-FR]
,[Title_it-IT]
,[Title_de-DE]
,[Title_pt-BR]
,[Title_id-ID]
,[Title_ja-JP]
,[Title_ru-RU]
,[PubDate_es-ES]
,[PubDate_zh-CN]
,[PubDate_fr-FR]
,[PubDate_it-IT]
,[PubDate_de-DE]
,[PubDate_pt-BR]
,[PubDate_id-ID]
,[PubDate_ja-JP]
,[PubDate_ru-RU]
,[UpdatedDate_es-ES]
,[UpdatedDate_zh-CN]
,[UpdatedDate_fr-FR]
,[UpdatedDate_it-IT]
,[UpdatedDate_de-DE]
,[UpdatedDate_pt-BR]
,[UpdatedDate_id-ID]
,[UpdatedDate_ja-JP]
,[UpdatedDate_ru-RU]
,[MediaNumbers_es-ES]
,[MediaNumbers_zh-CN]
,[MediaNumbers_fr-FR]
,[MediaNumbers_it-IT]
,[MediaNumbers_de-DE]
,[MediaNumbers_pt-BR]
,[MediaNumbers_id-ID]
,[MediaNumbers_ja-JP]
,[MediaNumbers_ru-RU]
)
SELECT 
	 COALESCE(bs.[ID], m.[ID], snp.[ID], pf.[ID], smcs.[ID], ps.[ID], ph.[ID]) ID
	,COALESCE(bs.[IESystemControlNumber], m.[IESystemControlNumber], snp.[IESystemControlNumber], pf.[IESystemControlNumber], smcs.[IESystemControlNumber], ps.[IESystemControlNumber], ph.[Iesystemcontrolnumber]) [IESystemControlNumber]
	,NULLIF(NULLIF(bs.[InfoTypeID], '[""]'), '') [InfoTypeID]
	,NULLIF(NULLIF(m.[MediaNumber], '[""]'), '') [MediaNumber]
	,bs.[DateUpdated]
	,snp.[SerialNumbers]
	,NULLIF(NULLIF(smcs.[SMCSCompCode], '[""]'), '') [SMCSCompCode]
	,NULLIF(NULLIF(ps.[System], '[""]'), '') [System]
	,bs.[IETitle]
	,bs.[isMedia]
	,p.[Profile]
	,NULLIF(NULLIF([ProductCodes], '[""]'), '') [ProductCodes]
	,GREATEST(bs.[InsertDate], m.[InsertDate], snp.[InsertDate], pf.[InsertDate], smcs.[InsertDate], ps.[InsertDate], ph.[InsertDate]) [InsertDate]
	,isnull(bs.[PubDate], '1900-01-01') [PubDate]
	,NULLIF(NULLIF([ControlNumber], '[""]'), '') ControlNumber
	,NULLIF(NULLIF([GraphicControlNumber], '[""]'), '') GraphicControlNumber
	,NULLIF(NULLIF([familyCode], '[""]'), '') [familyCode]
	,NULLIF(NULLIF([familySubFamilyCode], '[""]'), '') [familySubFamilyCode]
	,NULLIF(NULLIF([familySubFamilySalesModel], '[""]'), '') [familySubFamilySalesModel]
	,NULLIF(NULLIF([familySubFamilySalesModelSNP], '[""]'), '') [familySubFamilySalesModelSNP]
	,bs.[IETitle_es-ES]
	,bs.[IETitle_zh-CN]
	,bs.[IETitle_fr-FR]
	,bs.[IETitle_it-IT]
	,bs.[IETitle_de-DE]
	,bs.[IETitle_pt-BR]
	,bs.[IETitle_id-ID]
	,bs.[IETitle_ja-JP]
	,bs.[IETitle_ru-RU]
	,bs.[PubDate_es-ES]
	,bs.[PubDate_zh-CN]
	,bs.[PubDate_fr-FR]
	,bs.[PubDate_it-IT]
	,bs.[PubDate_de-DE]
	,bs.[PubDate_pt-BR]
	,bs.[PubDate_id-ID]
	,bs.[PubDate_ja-JP]
	,bs.[PubDate_ru-RU]
	,bs.[DateUpdated_es-ES]
	,bs.[DateUpdated_zh-CN]
	,bs.[DateUpdated_fr-FR]
	,bs.[DateUpdated_it-IT]
	,bs.[DateUpdated_de-DE]
	,bs.[DateUpdated_pt-BR]
	,bs.[DateUpdated_id-ID]
	,bs.[DateUpdated_ja-JP]
	,bs.[DateUpdated_ru-RU]
	,NULLIF(NULLIF(m.[MediaNumbers_es-ES], '[""]'), '') [MediaNumbers_es-ES]
	,NULLIF(NULLIF(m.[MediaNumbers_zh-CN], '[""]'), '') [MediaNumbers_zh-CN]
	,NULLIF(NULLIF(m.[MediaNumbers_fr-FR], '[""]'), '') [MediaNumbers_fr-FR]
	,NULLIF(NULLIF(m.[MediaNumbers_it-IT], '[""]'), '') [MediaNumbers_it-IT]
	,NULLIF(NULLIF(m.[MediaNumbers_de-DE], '[""]'), '') [MediaNumbers_de-DE]
	,NULLIF(NULLIF(m.[MediaNumbers_pt-BR], '[""]'), '') [MediaNumbers_pt-BR]
	,NULLIF(NULLIF(m.[MediaNumbers_id-ID], '[""]'), '') [MediaNumbers_id-ID]
	,NULLIF(NULLIF(m.[MediaNumbers_ja-JP], '[""]'), '') [MediaNumbers_ja-JP]
	,NULLIF(NULLIF(m.[MediaNumbers_ru-RU], '[""]'), '') [MediaNumbers_ru-RU]
FROM [SISSEARCH].[BASICSERVICEIE_2] bs
full outer join [SISSEARCH].[SERVICEIEMEDIA_2] m ON bs.ID = m.ID
full outer join [SISSEARCH].[SERVICEIESNP_4] snp ON COALESCE(bs.[ID], m.[ID]) = snp.[ID]
full outer join [SISSEARCH].[SERVICEIEPRODUCTFAMILY_2] pf ON COALESCE(bs.[ID], m.[ID], snp.[ID]) = pf.[ID]
full outer join [SISSEARCH].[SERVICEIESMCS_2] smcs ON COALESCE(bs.[ID], m.[ID], snp.[ID], pf.[ID]) = smcs.[ID]
full outer join [SISSEARCH].[SERVICEIEPRODUCTSTRUCTURE_2] ps ON COALESCE(bs.[ID], m.[ID], snp.[ID], pf.[ID], smcs.[ID]) = ps.[ID]
full outer join [SISSEARCH].[SERVICEIEPRODUCTHIERARCHY_2] ph ON COALESCE(bs.[ID], m.[ID], snp.[ID], pf.[ID], smcs.[ID], ps.[ID]) = ph.[ID]
left join #IEProfile p ON  COALESCE(bs.[ID], m.[ID], snp.[ID], pf.[ID], smcs.[ID], ps.[ID])=p.IESystemControlNumber
OPTION (FORCE ORDER)

DROP TABLE IF EXISTS #IEProfile


SET @RowCount = @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted INTO #Consolidated',@DATAVALUE = @RowCount;
--SELECT @RowCount, getdate(), 'Inserted INTO #Consolidated'
SET @TimeMarker = getdate()



UPDATE tgt
SET  
	 tgt.[IESystemControlNumber] = src.[IESystemControlNumber]
	,tgt.[InfoType] = src.[InfoType]
	,tgt.[MediaNumbers] = src.[MediaNumbers]
	,tgt.[UpdatedDate] = src.[UpdatedDate]
	,tgt.[SMCSCodes] = src.[SMCSCodes]
	,tgt.[ProductStructureSystemIDs] = src.[ProductStructureSystemIDs]
	,tgt.[Title_en] = src.[Title_en]
	,tgt.[isMedia] = src.[isMedia]
	,tgt.[Profile] = src.[Profile]
	,tgt.[ProductCodes] = src.[ProductCodes]
	,tgt.[InsertDate] = src.[InsertDate]
	,tgt.[PubDate] = src.[PubDate]
	,tgt.[ControlNumber] = src.[ControlNumber]
	,tgt.[GraphicControlNumber] = src.[GraphicControlNumber]
	,tgt.[familyCode] = src.[familyCode]
	,tgt.[familySubFamilyCode] = src.[familySubFamilyCode]
	,tgt.[familySubFamilySalesModel] = src.[familySubFamilySalesModel]
	,tgt.[familySubFamilySalesModelSNP] = src.[familySubFamilySalesModelSNP]
	,tgt.[Title_es-ES] = src.[Title_es-ES]
	,tgt.[Title_zh-CN] = src.[Title_zh-CN]
	,tgt.[Title_fr-FR] = src.[Title_fr-FR]
	,tgt.[Title_it-IT] = src.[Title_it-IT]
	,tgt.[Title_de-DE] = src.[Title_de-DE]
	,tgt.[Title_pt-BR] = src.[Title_pt-BR]
	,tgt.[Title_id-ID] = src.[Title_id-ID]
	,tgt.[Title_ja-JP] = src.[Title_ja-JP]
	,tgt.[Title_ru-RU] = src.[Title_ru-RU]
	,tgt.[PubDate_es-ES] = src.[PubDate_es-ES]
	,tgt.[PubDate_zh-CN] = src.[PubDate_zh-CN]
	,tgt.[PubDate_fr-FR] = src.[PubDate_fr-FR]
	,tgt.[PubDate_it-IT] = src.[PubDate_it-IT]
	,tgt.[PubDate_de-DE] = src.[PubDate_de-DE]
	,tgt.[PubDate_pt-BR] = src.[PubDate_pt-BR]
	,tgt.[PubDate_id-ID] = src.[PubDate_id-ID]
	,tgt.[PubDate_ja-JP] = src.[PubDate_ja-JP]
	,tgt.[PubDate_ru-RU] = src.[PubDate_ru-RU]
	,tgt.[UpdatedDate_es-ES] = src.[UpdatedDate_es-ES]
	,tgt.[UpdatedDate_zh-CN] = src.[UpdatedDate_zh-CN]
	,tgt.[UpdatedDate_fr-FR] = src.[UpdatedDate_fr-FR]
	,tgt.[UpdatedDate_it-IT] = src.[UpdatedDate_it-IT]
	,tgt.[UpdatedDate_de-DE] = src.[UpdatedDate_de-DE]
	,tgt.[UpdatedDate_pt-BR] = src.[UpdatedDate_pt-BR]
	,tgt.[UpdatedDate_id-ID] = src.[UpdatedDate_id-ID]
	,tgt.[UpdatedDate_ja-JP] = src.[UpdatedDate_ja-JP]
	,tgt.[UpdatedDate_ru-RU] = src.[UpdatedDate_ru-RU]
	,tgt.[MediaNumbers_es-ES] = src.[MediaNumbers_es-ES]
	,tgt.[MediaNumbers_zh-CN] = src.[MediaNumbers_zh-CN]
	,tgt.[MediaNumbers_fr-FR] = src.[MediaNumbers_fr-FR]
	,tgt.[MediaNumbers_it-IT] = src.[MediaNumbers_it-IT]
	,tgt.[MediaNumbers_de-DE] = src.[MediaNumbers_de-DE]
	,tgt.[MediaNumbers_pt-BR] = src.[MediaNumbers_pt-BR]
	,tgt.[MediaNumbers_id-ID] = src.[MediaNumbers_id-ID]
	,tgt.[MediaNumbers_ja-JP] = src.[MediaNumbers_ja-JP]
	,tgt.[MediaNumbers_ru-RU] = src.[MediaNumbers_ru-RU]
FROM #Consolidated tgt
Inner join --Get all attributes FROM the first version of the ID (no suffix) which matches the natural key.
(
	SELECT *
	FROM #Consolidated
	WHERE [Iesystemcontrolnumber] = ID
) src ON src.[IESystemControlNumber] = tgt.[Iesystemcontrolnumber]
WHERE tgt.ID like '%[_]%' --Only Update IDs with suffix.  These suffixed records are being created to get around an Azure json object limit.


SET @RowCount = @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated #Consolidated Suffixed IDs',@DATAVALUE = @RowCount;

SET @TimeMarker = getdate()

--Delete FROM target
Delete SISSEARCH.CONSOLIDATEDSERVICEIE_4
FROM  SISSEARCH.CONSOLIDATEDSERVICEIE_4 t
Left outer join #Consolidated s ON t.[ID] = s.[ID]
WHERE s.[ID] is null --Does not exist in source

SET @RowCount = @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted records FROM SISSEARCH.CONSOLIDATEDSERVICEIE_4',@DATAVALUE = @RowCount;

--SELECT @RowCount, getdate(), 'Deleted records FROM SISSEARCH.CONSOLIDATEDSERVICEIE_4'
SET @TimeMarker = getdate()

--UPDATE target WHERE ID exist in source and newer inserted DATETIME
UPDATE tgt
SET 
	 tgt.[IESystemControlNumber] = src.[IESystemControlNumber]
	,tgt.[InfoType] = src.[InfoType]
	,tgt.[MediaNumbers] = src.[MediaNumbers]
	,tgt.[UpdatedDate] = src.[UpdatedDate]
	,tgt.[SerialNumbers] = src.[SerialNumbers]
	,tgt.[SMCSCodes] = src.[SMCSCodes]
	,tgt.[ProductStructureSystemIDs] = src.[ProductStructureSystemIDs]
	,tgt.[Title_en] = src.[Title_en]
	,tgt.[isMedia] = src.[isMedia]
	,tgt.[Profile] = src.[Profile]
	,tgt.[ProductCodes] = src.[ProductCodes]
	,tgt.[InsertDate] = src.[InsertDate]
	,tgt.[PubDate] = src.[PubDate]
	,tgt.[ControlNumber] = src.[ControlNumber]
	,tgt.[familyCode] = src.[familyCode]
	,tgt.[familySubFamilyCode] = src.[familySubFamilyCode]
	,tgt.[familySubFamilySalesModel] = src.[familySubFamilySalesModel]
	,tgt.[familySubFamilySalesModelSNP] = src.[familySubFamilySalesModelSNP]
	,tgt.[Title_es-ES] = src.[Title_es-ES]
	,tgt.[Title_zh-CN] = src.[Title_zh-CN]
	,tgt.[Title_fr-FR] = src.[Title_fr-FR]
	,tgt.[Title_it-IT] = src.[Title_it-IT]
	,tgt.[Title_de-DE] = src.[Title_de-DE]
	,tgt.[Title_pt-BR] = src.[Title_pt-BR]
	,tgt.[Title_id-ID] = src.[Title_id-ID]
	,tgt.[Title_ja-JP] = src.[Title_ja-JP]
	,tgt.[Title_ru-RU] = src.[Title_ru-RU]
	,tgt.[PubDate_es-ES] = src.[PubDate_es-ES]
	,tgt.[PubDate_zh-CN] = src.[PubDate_zh-CN]
	,tgt.[PubDate_fr-FR] = src.[PubDate_fr-FR]
	,tgt.[PubDate_it-IT] = src.[PubDate_it-IT]
	,tgt.[PubDate_de-DE] = src.[PubDate_de-DE]
	,tgt.[PubDate_pt-BR] = src.[PubDate_pt-BR]
	,tgt.[PubDate_id-ID] = src.[PubDate_id-ID]
	,tgt.[PubDate_ja-JP] = src.[PubDate_ja-JP]
	,tgt.[PubDate_ru-RU] = src.[PubDate_ru-RU]
	,tgt.[UpdatedDate_es-ES] = src.[UpdatedDate_es-ES]
	,tgt.[UpdatedDate_zh-CN] = src.[UpdatedDate_zh-CN]
	,tgt.[UpdatedDate_fr-FR] = src.[UpdatedDate_fr-FR]
	,tgt.[UpdatedDate_it-IT] = src.[UpdatedDate_it-IT]
	,tgt.[UpdatedDate_de-DE] = src.[UpdatedDate_de-DE]
	,tgt.[UpdatedDate_pt-BR] = src.[UpdatedDate_pt-BR]
	,tgt.[UpdatedDate_id-ID] = src.[UpdatedDate_id-ID]
	,tgt.[UpdatedDate_ja-JP] = src.[UpdatedDate_ja-JP]
	,tgt.[UpdatedDate_ru-RU] = src.[UpdatedDate_ru-RU]
	,tgt.[MediaNumbers_es-ES] = src.[MediaNumbers_es-ES]
	,tgt.[MediaNumbers_zh-CN] = src.[MediaNumbers_zh-CN]
	,tgt.[MediaNumbers_fr-FR] = src.[MediaNumbers_fr-FR]
	,tgt.[MediaNumbers_it-IT] = src.[MediaNumbers_it-IT]
	,tgt.[MediaNumbers_de-DE] = src.[MediaNumbers_de-DE]
	,tgt.[MediaNumbers_pt-BR] = src.[MediaNumbers_pt-BR]
	,tgt.[MediaNumbers_id-ID] = src.[MediaNumbers_id-ID]
	,tgt.[MediaNumbers_ja-JP] = src.[MediaNumbers_ja-JP]
	,tgt.[MediaNumbers_ru-RU] = src.[MediaNumbers_ru-RU]
FROM SISSEARCH.CONSOLIDATEDSERVICEIE_4 tgt
Inner join #Consolidated src ON tgt.[ID] = src.[ID] --Existing
WHERE src.[INSERTDATE] > tgt.[InsertDate] --Updated in source
--We are not guaranteed that all sources will be updated at the same time (on the same day).  Therefore we need to handle newer INSERT dates as well as changed values.
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[InfoType],src.[InfoType],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[MediaNumbers],src.[MediaNumbers],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[UpdatedDate],src.[UpdatedDate],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[SerialNumbers],src.[SerialNumbers],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[SMCSCodes],src.[SMCSCodes],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ProductStructureSystemIDs],src.[ProductStructureSystemIDs],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[Title_en],src.[Title_en],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[isMedia],src.[isMedia],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ProductCodes],src.[ProductCodes],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[InsertDate],src.[InsertDate],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[PubDate],src.[PubDate],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[ControlNumber],src.[ControlNumber],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[GraphicControlNumber],src.[GraphicControlNumber],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[familyCode],src.[familyCode],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[familySubFamilyCode],src.[familySubFamilyCode],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[familySubFamilySalesModel],src.[familySubFamilySalesModel],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[familySubFamilySalesModelSNP],src.[familySubFamilySalesModelSNP],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[Title_es-ES],src.[Title_es-ES],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[Title_zh-CN],src.[Title_zh-CN],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[Title_fr-FR],src.[Title_fr-FR],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[Title_it-IT],src.[Title_it-IT],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[Title_de-DE],src.[Title_de-DE],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[Title_pt-BR],src.[Title_pt-BR],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[Title_id-ID],src.[Title_id-ID],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[Title_ja-JP],src.[Title_ja-JP],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[Title_ru-RU],src.[Title_ru-RU],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[PubDate_es-ES],src.[PubDate_es-ES],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[PubDate_zh-CN],src.[PubDate_zh-CN],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[PubDate_fr-FR],src.[PubDate_fr-FR],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[PubDate_it-IT],src.[PubDate_it-IT],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[PubDate_de-DE],src.[PubDate_de-DE],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[PubDate_pt-BR],src.[PubDate_pt-BR],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[PubDate_id-ID],src.[PubDate_id-ID],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[PubDate_ja-JP],src.[PubDate_ja-JP],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[PubDate_ru-RU],src.[PubDate_ru-RU],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[UpdatedDate_es-ES] ,src.[UpdatedDate_es-ES],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[UpdatedDate_zh-CN] ,src.[UpdatedDate_zh-CN],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[UpdatedDate_fr-FR] ,src.[UpdatedDate_fr-FR],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[UpdatedDate_it-IT] ,src.[UpdatedDate_it-IT],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[UpdatedDate_de-DE] ,src.[UpdatedDate_de-DE],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[UpdatedDate_pt-BR] ,src.[UpdatedDate_pt-BR],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[UpdatedDate_id-ID] ,src.[UpdatedDate_id-ID],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[UpdatedDate_ja-JP] ,src.[UpdatedDate_ja-JP],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[UpdatedDate_ru-RU] ,src.[UpdatedDate_ru-RU],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[MediaNumbers_es-ES],src.[MediaNumbers_es-ES],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[MediaNumbers_zh-CN],src.[MediaNumbers_zh-CN],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[MediaNumbers_fr-FR],src.[MediaNumbers_fr-FR],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[MediaNumbers_it-IT],src.[MediaNumbers_it-IT],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[MediaNumbers_de-DE],src.[MediaNumbers_de-DE],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[MediaNumbers_pt-BR],src.[MediaNumbers_pt-BR],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[MediaNumbers_id-ID],src.[MediaNumbers_id-ID],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[MediaNumbers_ja-JP],src.[MediaNumbers_ja-JP],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[MediaNumbers_ru-RU],src.[MediaNumbers_ru-RU],0)=1
OR [SISSEARCH].[fn_compare_source_target_columns] (tgt.[Profile],src.[Profile],0)=1


SET @RowCount = @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated records in SISSEARCH.CONSOLIDATEDSERVICEIE_4',@DATAVALUE = @RowCount;
SET @TimeMarker = getdate()

--INSERT new ID's
INSERT SISSEARCH.CONSOLIDATEDSERVICEIE_4
(
 [ID]
      ,[IESystemControlNumber]
      ,[InfoType]
      ,[MediaNumbers]
      ,[UpdatedDate]
      ,[SerialNumbers]
      ,[SMCSCodes]
      ,[ProductStructureSystemIDs]
      ,[Title_en]
      ,[isMedia]
	  ,[Profile]
      ,[ProductCodes]
      ,[InsertDate]
      ,[PubDate]
	  ,[ControlNumber]
	  ,[GraphicControlNumber]
	  ,[familyCode]
	  ,[familySubFamilyCode]
	  ,[familySubFamilySalesModel]
	  ,[familySubFamilySalesModelSNP]
      ,[Title_es-ES]
      ,[Title_zh-CN]
      ,[Title_fr-FR]
      ,[Title_it-IT]
      ,[Title_de-DE]
      ,[Title_pt-BR]
      ,[Title_id-ID]
      ,[Title_ja-JP]
      ,[Title_ru-RU]
      ,[PubDate_es-ES]
      ,[PubDate_zh-CN]
      ,[PubDate_fr-FR]
      ,[PubDate_it-IT]
      ,[PubDate_de-DE]
      ,[PubDate_pt-BR]
      ,[PubDate_id-ID]
      ,[PubDate_ja-JP]
      ,[PubDate_ru-RU]
      ,[UpdatedDate_es-ES]
      ,[UpdatedDate_zh-CN]
      ,[UpdatedDate_fr-FR]
      ,[UpdatedDate_it-IT]
      ,[UpdatedDate_de-DE]
      ,[UpdatedDate_pt-BR]
      ,[UpdatedDate_id-ID]
      ,[UpdatedDate_ja-JP]
      ,[UpdatedDate_ru-RU]
      ,[MediaNumbers_es-ES]
      ,[MediaNumbers_zh-CN]
      ,[MediaNumbers_fr-FR]
      ,[MediaNumbers_it-IT]
      ,[MediaNumbers_de-DE]
      ,[MediaNumbers_pt-BR]
      ,[MediaNumbers_id-ID]
      ,[MediaNumbers_ja-JP]
      ,[MediaNumbers_ru-RU]
)
SELECT 
 s.[ID]
,s.[IESystemControlNumber]
,s.[InfoType]
,s.[MediaNumbers]
,s.[UpdatedDate]
,s.[SerialNumbers]
,s.[SMCSCodes]
,s.[ProductStructureSystemIDs]
,s.[Title_en]
,s.[isMedia]
,s.[Profile]
,s.[ProductCodes]
,s.[InsertDate]
,s.[PubDate]
,s.[ControlNumber]
,s.[GraphicControlNumber]
,s.[familyCode]
,s.[familySubFamilyCode]
,s.[familySubFamilySalesModel]
,s.[familySubFamilySalesModelSNP]
,s.[Title_es-ES]
,s.[Title_zh-CN]
,s.[Title_fr-FR]
,s.[Title_it-IT]
,s.[Title_de-DE]
,s.[Title_pt-BR]
,s.[Title_id-ID]
,s.[Title_ja-JP]
,s.[Title_ru-RU]
,s.[PubDate_es-ES]
,s.[PubDate_zh-CN]
,s.[PubDate_fr-FR]
,s.[PubDate_it-IT]
,s.[PubDate_de-DE]
,s.[PubDate_pt-BR]
,s.[PubDate_id-ID]
,s.[PubDate_ja-JP]
,s.[PubDate_ru-RU]
,s.[UpdatedDate_es-ES]
,s.[UpdatedDate_zh-CN]
,s.[UpdatedDate_fr-FR]
,s.[UpdatedDate_it-IT]
,s.[UpdatedDate_de-DE]
,s.[UpdatedDate_pt-BR]
,s.[UpdatedDate_id-ID]
,s.[UpdatedDate_ja-JP]
,s.[UpdatedDate_ru-RU]
,s.[MediaNumbers_es-ES]
,s.[MediaNumbers_zh-CN]
,s.[MediaNumbers_fr-FR]
,s.[MediaNumbers_it-IT]
,s.[MediaNumbers_de-DE]
,s.[MediaNumbers_pt-BR]
,s.[MediaNumbers_id-ID]
,s.[MediaNumbers_ja-JP]
,s.[MediaNumbers_ru-RU]
FROM #Consolidated s
Left outer join SISSEARCH.CONSOLIDATEDSERVICEIE_4 t ON s.[ID] = t.[ID]
WHERE t.[ID] is null --Does not exist in target

SET @RowCount = @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted records in SISSEARCH.CONSOLIDATEDSERVICEIE_4',@DATAVALUE = @RowCount;
SET @TimeMarker = getdate()

--Add Restriction Codes
UPDATE c 
SET [RestrictionCode] = NULLIF(NULLIF(r.[RestrictionCode], '[""]'), '')
FROM [SISSEARCH].[CONSOLIDATEDSERVICEIE_4] c
Inner join [SISSEARCH].[SERVICEIERESTRICTACCESS_2] r ON c.IESystemControlNumber = r.IESystemControlNumber
WHERE isnull(c.RestrictionCode, '') <> r.RestrictionCode

SET @RowCount = @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated SISSEARCH.CONSOLIDATEDSERVICEIE_4.RestrictionCode',@DATAVALUE = @RowCount;
SET @TimeMarker = getdate()

EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Execution completed',@DATAVALUE = @RowCount;

END TRY

BEGIN CATCH 
DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(), @ERROELINE INT= ERROR_LINE()


DECLARE @error NVARCHAR(MAX) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC SISSEARCH.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = 'SISSEARCH.CONSOLIDATEDSERVICEIE_4_LOAD',@LOGMESSAGE = @error

END CATCH

END
