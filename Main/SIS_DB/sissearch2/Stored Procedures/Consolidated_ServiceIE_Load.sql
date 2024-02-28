CREATE Procedure [sissearch2].[Consolidated_ServiceIE_Load] As
BEGIN 

BEGIN TRY

--Start
EXEC sissearch2.WriteLog @NAMEOFSPROC = 'sissearch2.Consolidated_ServiceIE_Load', @LOGMESSAGE = 'Execution started';

--Prep
If Object_ID('tempdb..#Consolidated') is not null Drop table #Consolidated

--Create Temp
CREATE TABLE #Consolidated (
	[ID] [varchar](50) NOT NULL,
	[IESystemControlNumber] [varchar](15) NOT NULL,
	[InfoType] [varchar](4000) NULL,
	[MediaNumbers] [varchar](max) NULL,
	[UpdatedDate] [date] NULL,
	[SerialNumbers] [varchar](max) NULL,
	[SMCSCodes] [varchar](max) NULL,
	[ProductStructureSystemIDs] [varchar](max) NULL,
	[Title_en] [nvarchar](4000) NULL,
	[isMedia] [bit] NULL,
	[Profile] [varchar](max) NULL,
	[ProductCodes] [varchar](max) NULL,
	[InsertDate] [datetime] NOT NULL,
	[PubDate] [datetime2] NULL,
	[ControlNumber] [varchar](4000) NULL,
	[GraphicControlNumber] [varchar] (MAX) NULL,
	[familyCode] [varchar](max) NULL,
	[familySubFamilyCode] [varchar](max) NULL,
	[familySubFamilySalesModel] [varchar](max) NULL,
	[familySubFamilySalesModelSNP] [varchar](max) NULL,
	[Title_es-ES] [nvarchar](4000) NULL,
	[Title_zh-CN] [nvarchar](4000) NULL,
	[Title_fr-FR] [nvarchar](4000) NULL,
	[Title_it-IT] [nvarchar](4000) NULL,
	[Title_de-DE] [nvarchar](4000) NULL,
	[Title_pt-BR] [nvarchar](4000) NULL,
	[Title_id-ID] [nvarchar](4000) NULL,
	[Title_ja-JP] [nvarchar](4000) NULL,
	[Title_ru-RU] [nvarchar](4000) NULL,
	[PubDate_es-ES] [datetime2](7) NULL,
	[PubDate_zh-CN] [datetime2](7) NULL,
	[PubDate_fr-FR] [datetime2](7) NULL,
	[PubDate_it-IT] [datetime2](7) NULL,
	[PubDate_de-DE] [datetime2](7) NULL,
	[PubDate_pt-BR] [datetime2](7) NULL,
	[PubDate_id-ID] [datetime2](7) NULL,
	[PubDate_ja-JP] [datetime2](7) NULL,
	[PubDate_ru-RU] [datetime2](7) NULL,
	[UpdatedDate_es-ES] [date] NULL,
	[UpdatedDate_zh-CN] [date] NULL,
	[UpdatedDate_fr-FR] [date] NULL,
	[UpdatedDate_it-IT] [date] NULL,
	[UpdatedDate_de-DE] [date] NULL,
	[UpdatedDate_pt-BR] [date] NULL,
	[UpdatedDate_id-ID] [date] NULL,
	[UpdatedDate_ja-JP] [date] NULL,
	[UpdatedDate_ru-RU] [date] NULL,
	[MediaNumbers_es-ES] [varchar](max) NULL,
	[MediaNumbers_zh-CN] [varchar](max) NULL,
	[MediaNumbers_fr-FR] [varchar](max) NULL,
	[MediaNumbers_it-IT] [varchar](max) NULL,
	[MediaNumbers_de-DE] [varchar](max) NULL,
	[MediaNumbers_pt-BR] [varchar](max) NULL,
	[MediaNumbers_id-ID] [varchar](max) NULL,
	[MediaNumbers_ja-JP] [varchar](max) NULL,
	[MediaNumbers_ru-RU] [varchar](max) NULL
)

--Set collation of temp
ALTER TABLE #Consolidated 
ALTER COLUMN [ID] varchar(50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL

--Var
Declare @Sproc varchar(200) = 'sissearch2.Consolidated_ServiceIE_Load'
Declare @RowCount BIGINT,
		@LAPSETIME BIGINT
Declare @TimeMarker datetime = getdate()

--Add pkey to temp
ALTER TABLE #Consolidated 
ADD PRIMARY KEY CLUSTERED ([ID])

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
-- each IE_ID
--
DROP TABLE IF EXISTS #IEProdNSNP

select IE_ID, PermissionType_ID, Permission_Detail_ID 
into #IEProdNSNP
from (
	select 
		e.IE_ID, @prodFamilyID as PermissionType_ID, pef.ProductFamily_ID as Permission_Detail_ID
	from sis.IE e
		inner join sis.IE_ProductFamily_Effectivity pef on pef.IE_ID=e.IE_ID
		-- inner join sis.ProductFamily pf on pef.ProductFamily_ID=pf.ProductFamily_ID
	union select 
		e.IE_ID, @snpID as PermissionType_ID, sp.SerialNumberPrefix_ID as Permission_Detail_ID
	from sis.IE e
		inner join sis.IE_Effectivity ef on ef.IE_ID=e.IE_ID
		inner join sis.SerialNumberPrefix sp on ef.SerialNumberPrefix_ID=sp.SerialNumberPrefix_ID
) x
group by IE_ID, PermissionType_ID, Permission_Detail_ID
order by IE_ID, PermissionType_ID

DROP TABLE IF EXISTS #IEInfoType
select 
	e.IE_ID, @infoTypeID as PermissionType_ID, i.InfoType_ID as Permission_Detail_ID
into #IEInfoType
from sis.IE e
	inner join sis.IE_InfoType_Relation i on e.IE_ID=i.IE_ID

CREATE NONCLUSTERED INDEX IEProdNSNP_IE_ID ON #IEProdNSNP ([PermissionType_ID]) INCLUDE ([IE_ID],[Permission_Detail_ID])
CREATE NONCLUSTERED INDEX IEInfoType_IE_ID ON #IEInfoType ([PermissionType_ID]) INCLUDE ([IE_ID],[Permission_Detail_ID])

DROP TABLE IF EXISTS #AccessProdSNP
select m.IE_ID, e.Profile_ID
into #AccessProdSNP
from #IEProdNSNP m
inner join admin.AccessProfile_Permission_Relation e ON
	m.PermissionType_ID=e.PermissionType_ID AND
	(
		e.Include_Exclude=@PROFILE_MUST_INCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_INCLUDE_ALL)
	)
	AND NOT (e.Include_Exclude=@PROFILE_MUST_EXCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_EXCLUDE_ALL))
-- use GROUP BY to remove duplicates
GROUP BY m.IE_ID, e.Profile_ID

DROP TABLE IF EXISTS #IEProdNSNP

DROP TABLE IF EXISTS #AccessInfoType
select m.IE_ID, e.Profile_ID
into #AccessInfoType
from #IEInfoType m
inner join admin.AccessProfile_Permission_Relation e ON
	m.PermissionType_ID=e.PermissionType_ID AND
	(
		e.Include_Exclude=@PROFILE_MUST_INCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_INCLUDE_ALL)
	)
	AND NOT (e.Include_Exclude=@PROFILE_MUST_EXCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_EXCLUDE_ALL))
-- use GROUP BY to remove duplicates
GROUP BY m.IE_ID, e.Profile_ID

DROP TABLE IF EXISTS #IEInfoType

DROP TABLE IF EXISTS #IEProfile
select z.IE_ID, t.IESystemControlNumber, '['+string_agg(Profile_ID, ',') WITHIN GROUP (ORDER BY Profile_ID ASC)+']' as Profile
into #IEProfile
from (
	select ps.IE_ID, ps.Profile_ID 
	from #AccessInfoType it
		inner join #AccessProdSNP ps on ps.IE_ID=it.IE_ID and ps.Profile_ID=it.Profile_ID
	group by ps.IE_ID, ps.Profile_ID
) z
inner join sis.IE t on t.IE_ID=z.IE_ID
GROUP BY z.IE_ID, t.IESystemControlNumber

DROP TABLE IF EXISTS #AccessInfoType

--Insert updated source into temp
Insert into #Consolidated
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
	 coalesce(bs.[ID], m.[ID], snp.[ID], pf.[ID], smcs.[ID], ps.[ID], ph.[ID]) ID
	,coalesce(bs.[IESystemControlNumber], m.[IESystemControlNumber], snp.[IESystemControlNumber], pf.[IESystemControlNumber], smcs.[IESystemControlNumber], ps.[IESystemControlNumber], ph.[Iesystemcontrolnumber]) [IESystemControlNumber]
	,nullif(nullif(bs.[InfoTypeID], '[""]'), '') [InfoTypeID]
	,nullif(nullif(m.[MediaNumber], '[""]'), '') [MediaNumber]
	,bs.[DateUpdated]
	,snp.[SerialNumbers]
	,nullif(nullif(smcs.[SMCSCompCode], '[""]'), '') [SMCSCompCode]
	,nullif(nullif(ps.[System], '[""]'), '') [System]
	,bs.[IETitle]
	,bs.[isMedia]
	,p.[Profile]
	,nullif(nullif([ProductCodes], '[""]'), '') [ProductCodes]
	,GREATEST(bs.[InsertDate], m.[InsertDate], snp.[InsertDate], pf.[InsertDate], smcs.[InsertDate], ps.[InsertDate], ph.[InsertDate]) [InsertDate]
	,isnull(bs.[PubDate], '1900-01-01') [PubDate]
	,nullif(nullif([ControlNumber], '[""]'), '') ControlNumber
	,nullif(nullif([GraphicControlNumber], '[""]'), '') GraphicControlNumber
	,nullif(nullif([familyCode], '[""]'), '') [familyCode]
	,nullif(nullif([familySubFamilyCode], '[""]'), '') [familySubFamilyCode]
	,nullif(nullif([familySubFamilySalesModel], '[""]'), '') [familySubFamilySalesModel]
	,nullif(nullif([familySubFamilySalesModelSNP], '[""]'), '') [familySubFamilySalesModelSNP]
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
	,nullif(nullif(m.[MediaNumbers_es-ES], '[""]'), '') [MediaNumbers_es-ES]
	,nullif(nullif(m.[MediaNumbers_zh-CN], '[""]'), '') [MediaNumbers_zh-CN]
	,nullif(nullif(m.[MediaNumbers_fr-FR], '[""]'), '') [MediaNumbers_fr-FR]
	,nullif(nullif(m.[MediaNumbers_it-IT], '[""]'), '') [MediaNumbers_it-IT]
	,nullif(nullif(m.[MediaNumbers_de-DE], '[""]'), '') [MediaNumbers_de-DE]
	,nullif(nullif(m.[MediaNumbers_pt-BR], '[""]'), '') [MediaNumbers_pt-BR]
	,nullif(nullif(m.[MediaNumbers_id-ID], '[""]'), '') [MediaNumbers_id-ID]
	,nullif(nullif(m.[MediaNumbers_ja-JP], '[""]'), '') [MediaNumbers_ja-JP]
	,nullif(nullif(m.[MediaNumbers_ru-RU], '[""]'), '') [MediaNumbers_ru-RU]
From [sissearch2].[Basic_ServiceIE] bs
full outer join [sissearch2].[ServiceIE_Media] m on bs.ID = m.ID
full outer join [sissearch2].[ServiceIE_SNP] snp on coalesce(bs.[ID], m.[ID]) = snp.[ID]
full outer join [sissearch2].[ServiceIE_ProductFamily] pf on coalesce(bs.[ID], m.[ID], snp.[ID]) = pf.[ID]
full outer join [sissearch2].[SERVICEIE_SMCS] smcs on coalesce(bs.[ID], m.[ID], snp.[ID], pf.[ID]) = smcs.[ID]
full outer join [sissearch2].[ServiceIE_ProductStructure] ps on coalesce(bs.[ID], m.[ID], snp.[ID], pf.[ID], smcs.[ID]) = ps.[ID]
full outer join [sissearch2].[ServiceIE_ProductHierarchy] ph on coalesce(bs.[ID], m.[ID], snp.[ID], pf.[ID], smcs.[ID], ps.[ID]) = ph.[ID]
left join #IEProfile p ON  coalesce(bs.[ID], m.[ID], snp.[ID], pf.[ID], smcs.[ID], ps.[ID])=p.IESystemControlNumber
Option (Force Order)

DROP TABLE IF EXISTS #IEProfile

Set @RowCount = @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into #Consolidated',@DATAVALUE = @RowCount;
--Select @RowCount, getdate(), 'Inserted into #Consolidated'
Set @TimeMarker = getdate()

Update tgt
Set  
	 tgt.[IESystemControlNumber] = src.[IESystemControlNumber]
	,tgt.[InfoType] = src.[InfoType]
	,tgt.[MediaNumbers] = src.[MediaNumbers]
	,tgt.[UpdatedDate] = src.[UpdatedDate]
	--,tgt.[SerialNumbers] = src.[SerialNumbers]
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
From #Consolidated tgt
Inner join --Get all attributes from the first version of the ID (no suffix) which matches the natural key.
(
	Select *
	From #Consolidated
	Where [IESystemControlNumber] = ID
) src on src.[IESystemControlNumber] = tgt.[IESystemControlNumber]
where tgt.ID like '%[_]%' --Only update IDs with suffix.  These suffixed records are being created to get around an Azure json object limit.


Set @RowCount = @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated #Consolidated Suffixed IDs',@DATAVALUE = @RowCount;
--Select @RowCount, getdate(), 'Inserted into #Consolidated'
Set @TimeMarker = getdate()

--Delete from target
Delete sissearch2.Consolidated_ServiceIE
From  sissearch2.Consolidated_ServiceIE t
Left outer join #Consolidated s on t.[ID] = s.[ID]
Where s.[ID] is null --Does not exist in source

Set @RowCount = @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted records from sissearch2.Consolidated_ServiceIE',@DATAVALUE = @RowCount;

--Select @RowCount, getdate(), 'Deleted records from sissearch2.Consolidated_ServiceIE'
Set @TimeMarker = getdate()

--Update target where ID exist in source and newer inserted datetime
Update tgt
Set 
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
From sissearch2.Consolidated_ServiceIE tgt
Inner join #Consolidated src on tgt.[ID] = src.[ID] --Existing
Where src.[INSERTDATE] > tgt.[InsertDate] --Updated in source
--We are not guaranteed that all sources will be updated at the same time (on the same day).  Therefore we need to handle newer insert dates as well as changed values.
or (tgt. [InfoType] <> src. [InfoType] or (tgt. [InfoType] is null and src. [InfoType] is not null) or (tgt. [InfoType] is not null and src. [InfoType] is null))
or (tgt. [MediaNumbers] <> src. [MediaNumbers] or (tgt. [MediaNumbers] is null and src. [MediaNumbers] is not null) or (tgt. [MediaNumbers] is not null and src. [MediaNumbers] is null))
or (tgt. [UpdatedDate] <> src. [UpdatedDate] or (tgt. [UpdatedDate] is null and src. [UpdatedDate] is not null) or (tgt. [UpdatedDate] is not null and src. [UpdatedDate] is null))
or (tgt. [SerialNumbers] <> src. [SerialNumbers] or (tgt. [SerialNumbers] is null and src. [SerialNumbers] is not null) or (tgt. [SerialNumbers] is not null and src. [SerialNumbers] is null))
or (tgt. [SMCSCodes] <> src. [SMCSCodes] or (tgt. [SMCSCodes] is null and src. [SMCSCodes] is not null) or (tgt. [SMCSCodes] is not null and src. [SMCSCodes] is null))
or (tgt. [ProductStructureSystemIDs] <> src. [ProductStructureSystemIDs] or (tgt. [ProductStructureSystemIDs] is null and src. [ProductStructureSystemIDs] is not null) or (tgt. [ProductStructureSystemIDs] is not null and src. [ProductStructureSystemIDs] is null))
or (tgt. [Title_en] <> src. [Title_en] or (tgt. [Title_en] is null and src. [Title_en] is not null) or (tgt. [Title_en] is not null and src. [Title_en] is null))
or (tgt. [isMedia] <> src. [isMedia] or (tgt. [isMedia] is null and src. [isMedia] is not null) or (tgt. [isMedia] is not null and src. [isMedia] is null))
or (tgt. [ProductCodes] <> src. [ProductCodes] or (tgt. [ProductCodes] is null and src. [ProductCodes] is not null) or (tgt. [ProductCodes] is not null and src. [ProductCodes] is null))
or (tgt. [InsertDate] <> src. [InsertDate] or (tgt. [InsertDate] is null and src. [InsertDate] is not null) or (tgt. [InsertDate] is not null and src. [InsertDate] is null))
or (tgt. [PubDate] <> src. [PubDate] or (tgt. [PubDate] is null and src. [PubDate] is not null) or (tgt. [PubDate] is not null and src. [PubDate] is null))
--or (tgt. [RestrictionCode] <> src. [RestrictionCode] or (tgt. [RestrictionCode] is null and src. [RestrictionCode] is not null) or (tgt. [RestrictionCode] is not null and src. [RestrictionCode] is null))
or (tgt. [ControlNumber] <> src. [ControlNumber] or (tgt. [ControlNumber] is null and src. [ControlNumber] is not null) or (tgt. [ControlNumber] is not null and src. [ControlNumber] is null))
or (tgt. [GraphicControlNumber] <> src. [GraphicControlNumber] or (tgt. [GraphicControlNumber] is null and src. [GraphicControlNumber] is not null) or (tgt. [GraphicControlNumber] is not null and src. [GraphicControlNumber] is null))
or (tgt. [familyCode] <> src. [familyCode] or (tgt. [familyCode] is null and src. [familyCode] is not null) or (tgt. [familyCode] is not null and src. [familyCode] is null))
or (tgt. [familySubFamilyCode] <> src. [familySubFamilyCode] or (tgt. [familySubFamilyCode] is null and src. [familySubFamilyCode] is not null) or (tgt. [familySubFamilyCode] is not null and src. [familySubFamilyCode] is null))
or (tgt. [familySubFamilySalesModel] <> src. [familySubFamilySalesModel] or (tgt. [familySubFamilySalesModel] is null and src. [familySubFamilySalesModel] is not null) or (tgt. [familySubFamilySalesModel] is not null and src. [familySubFamilySalesModel] is null))
or (tgt. [familySubFamilySalesModelSNP] <> src. [familySubFamilySalesModelSNP] or (tgt. [familySubFamilySalesModelSNP] is null and src. [familySubFamilySalesModelSNP] is not null) or (tgt. [familySubFamilySalesModelSNP] is not null and src. [familySubFamilySalesModelSNP] is null))
or (tgt. [Title_es-ES] <> src. [Title_es-ES] or (tgt. [Title_es-ES] is null and src. [Title_es-ES] is not null) or (tgt. [Title_es-ES] is not null and src. [Title_es-ES] is null))
or (tgt. [Title_zh-CN] <> src. [Title_zh-CN] or (tgt. [Title_zh-CN] is null and src. [Title_zh-CN] is not null) or (tgt. [Title_zh-CN] is not null and src. [Title_zh-CN] is null))
or (tgt. [Title_fr-FR] <> src. [Title_fr-FR] or (tgt. [Title_fr-FR] is null and src. [Title_fr-FR] is not null) or (tgt. [Title_fr-FR] is not null and src. [Title_fr-FR] is null))
or (tgt. [Title_it-IT] <> src. [Title_it-IT] or (tgt. [Title_it-IT] is null and src. [Title_it-IT] is not null) or (tgt. [Title_it-IT] is not null and src. [Title_it-IT] is null))
or (tgt. [Title_de-DE] <> src. [Title_de-DE] or (tgt. [Title_de-DE] is null and src. [Title_de-DE] is not null) or (tgt. [Title_de-DE] is not null and src. [Title_de-DE] is null))
or (tgt. [Title_pt-BR] <> src. [Title_pt-BR] or (tgt. [Title_pt-BR] is null and src. [Title_pt-BR] is not null) or (tgt. [Title_pt-BR] is not null and src. [Title_pt-BR] is null))
or (tgt. [Title_id-ID] <> src. [Title_id-ID] or (tgt. [Title_id-ID] is null and src. [Title_id-ID] is not null) or (tgt. [Title_id-ID] is not null and src. [Title_id-ID] is null))
or (tgt. [Title_ja-JP] <> src. [Title_ja-JP] or (tgt. [Title_ja-JP] is null and src. [Title_ja-JP] is not null) or (tgt. [Title_ja-JP] is not null and src. [Title_ja-JP] is null))
or (tgt. [Title_ru-RU] <> src. [Title_ru-RU] or (tgt. [Title_ru-RU] is null and src. [Title_ru-RU] is not null) or (tgt. [Title_ru-RU] is not null and src. [Title_ru-RU] is null))
or (tgt. [PubDate_es-ES] <> src. [PubDate_es-ES] or (tgt. [PubDate_es-ES] is null and src. [PubDate_es-ES] is not null) or (tgt. [PubDate_es-ES] is not null and src. [PubDate_es-ES] is null))
or (tgt. [PubDate_zh-CN] <> src. [PubDate_zh-CN] or (tgt. [PubDate_zh-CN] is null and src. [PubDate_zh-CN] is not null) or (tgt. [PubDate_zh-CN] is not null and src. [PubDate_zh-CN] is null))
or (tgt. [PubDate_fr-FR] <> src. [PubDate_fr-FR] or (tgt. [PubDate_fr-FR] is null and src. [PubDate_fr-FR] is not null) or (tgt. [PubDate_fr-FR] is not null and src. [PubDate_fr-FR] is null))
or (tgt. [PubDate_it-IT] <> src. [PubDate_it-IT] or (tgt. [PubDate_it-IT] is null and src. [PubDate_it-IT] is not null) or (tgt. [PubDate_it-IT] is not null and src. [PubDate_it-IT] is null))
or (tgt. [PubDate_de-DE] <> src. [PubDate_de-DE] or (tgt. [PubDate_de-DE] is null and src. [PubDate_de-DE] is not null) or (tgt. [PubDate_de-DE] is not null and src. [PubDate_de-DE] is null))
or (tgt. [PubDate_pt-BR] <> src. [PubDate_pt-BR] or (tgt. [PubDate_pt-BR] is null and src. [PubDate_pt-BR] is not null) or (tgt. [PubDate_pt-BR] is not null and src. [PubDate_pt-BR] is null))
or (tgt. [PubDate_id-ID] <> src. [PubDate_id-ID] or (tgt. [PubDate_id-ID] is null and src. [PubDate_id-ID] is not null) or (tgt. [PubDate_id-ID] is not null and src. [PubDate_id-ID] is null))
or (tgt. [PubDate_ja-JP] <> src. [PubDate_ja-JP] or (tgt. [PubDate_ja-JP] is null and src. [PubDate_ja-JP] is not null) or (tgt. [PubDate_ja-JP] is not null and src. [PubDate_ja-JP] is null))
or (tgt. [PubDate_ru-RU] <> src. [PubDate_ru-RU] or (tgt. [PubDate_ru-RU] is null and src. [PubDate_ru-RU] is not null) or (tgt. [PubDate_ru-RU] is not null and src. [PubDate_ru-RU] is null))
or (tgt. [UpdatedDate_es-ES] <> src. [UpdatedDate_es-ES] or (tgt. [UpdatedDate_es-ES] is null and src. [UpdatedDate_es-ES] is not null) or (tgt. [UpdatedDate_es-ES] is not null and src. [UpdatedDate_es-ES] is null))
or (tgt. [UpdatedDate_zh-CN] <> src. [UpdatedDate_zh-CN] or (tgt. [UpdatedDate_zh-CN] is null and src. [UpdatedDate_zh-CN] is not null) or (tgt. [UpdatedDate_zh-CN] is not null and src. [UpdatedDate_zh-CN] is null))
or (tgt. [UpdatedDate_fr-FR] <> src. [UpdatedDate_fr-FR] or (tgt. [UpdatedDate_fr-FR] is null and src. [UpdatedDate_fr-FR] is not null) or (tgt. [UpdatedDate_fr-FR] is not null and src. [UpdatedDate_fr-FR] is null))
or (tgt. [UpdatedDate_it-IT] <> src. [UpdatedDate_it-IT] or (tgt. [UpdatedDate_it-IT] is null and src. [UpdatedDate_it-IT] is not null) or (tgt. [UpdatedDate_it-IT] is not null and src. [UpdatedDate_it-IT] is null))
or (tgt. [UpdatedDate_de-DE] <> src. [UpdatedDate_de-DE] or (tgt. [UpdatedDate_de-DE] is null and src. [UpdatedDate_de-DE] is not null) or (tgt. [UpdatedDate_de-DE] is not null and src. [UpdatedDate_de-DE] is null))
or (tgt. [UpdatedDate_pt-BR] <> src. [UpdatedDate_pt-BR] or (tgt. [UpdatedDate_pt-BR] is null and src. [UpdatedDate_pt-BR] is not null) or (tgt. [UpdatedDate_pt-BR] is not null and src. [UpdatedDate_pt-BR] is null))
or (tgt. [UpdatedDate_id-ID] <> src. [UpdatedDate_id-ID] or (tgt. [UpdatedDate_id-ID] is null and src. [UpdatedDate_id-ID] is not null) or (tgt. [UpdatedDate_id-ID] is not null and src. [UpdatedDate_id-ID] is null))
or (tgt. [UpdatedDate_ja-JP] <> src. [UpdatedDate_ja-JP] or (tgt. [UpdatedDate_ja-JP] is null and src. [UpdatedDate_ja-JP] is not null) or (tgt. [UpdatedDate_ja-JP] is not null and src. [UpdatedDate_ja-JP] is null))
or (tgt. [UpdatedDate_ru-RU] <> src. [UpdatedDate_ru-RU] or (tgt. [UpdatedDate_ru-RU] is null and src. [UpdatedDate_ru-RU] is not null) or (tgt. [UpdatedDate_ru-RU] is not null and src. [UpdatedDate_ru-RU] is null))
or (tgt. [MediaNumbers_es-ES] <> src. [MediaNumbers_es-ES] or (tgt. [MediaNumbers_es-ES] is null and src. [MediaNumbers_es-ES] is not null) or (tgt. [MediaNumbers_es-ES] is not null and src. [MediaNumbers_es-ES] is null))
or (tgt. [MediaNumbers_zh-CN] <> src. [MediaNumbers_zh-CN] or (tgt. [MediaNumbers_zh-CN] is null and src. [MediaNumbers_zh-CN] is not null) or (tgt. [MediaNumbers_zh-CN] is not null and src. [MediaNumbers_zh-CN] is null))
or (tgt. [MediaNumbers_fr-FR] <> src. [MediaNumbers_fr-FR] or (tgt. [MediaNumbers_fr-FR] is null and src. [MediaNumbers_fr-FR] is not null) or (tgt. [MediaNumbers_fr-FR] is not null and src. [MediaNumbers_fr-FR] is null))
or (tgt. [MediaNumbers_it-IT] <> src. [MediaNumbers_it-IT] or (tgt. [MediaNumbers_it-IT] is null and src. [MediaNumbers_it-IT] is not null) or (tgt. [MediaNumbers_it-IT] is not null and src. [MediaNumbers_it-IT] is null))
or (tgt. [MediaNumbers_de-DE] <> src. [MediaNumbers_de-DE] or (tgt. [MediaNumbers_de-DE] is null and src. [MediaNumbers_de-DE] is not null) or (tgt. [MediaNumbers_de-DE] is not null and src. [MediaNumbers_de-DE] is null))
or (tgt. [MediaNumbers_pt-BR] <> src. [MediaNumbers_pt-BR] or (tgt. [MediaNumbers_pt-BR] is null and src. [MediaNumbers_pt-BR] is not null) or (tgt. [MediaNumbers_pt-BR] is not null and src. [MediaNumbers_pt-BR] is null))
or (tgt. [MediaNumbers_id-ID] <> src. [MediaNumbers_id-ID] or (tgt. [MediaNumbers_id-ID] is null and src. [MediaNumbers_id-ID] is not null) or (tgt. [MediaNumbers_id-ID] is not null and src. [MediaNumbers_id-ID] is null))
or (tgt. [MediaNumbers_ja-JP] <> src. [MediaNumbers_ja-JP] or (tgt. [MediaNumbers_ja-JP] is null and src. [MediaNumbers_ja-JP] is not null) or (tgt. [MediaNumbers_ja-JP] is not null and src. [MediaNumbers_ja-JP] is null))
or (tgt. [MediaNumbers_ru-RU] <> src. [MediaNumbers_ru-RU] or (tgt. [MediaNumbers_ru-RU] is null and src. [MediaNumbers_ru-RU] is not null) or (tgt. [MediaNumbers_ru-RU] is not null and src. [MediaNumbers_ru-RU] is null))
or (tgt.[Profile] <> src.[Profile] or (tgt.[Profile] is null and src.[Profile] is not null) or (tgt.[Profile] is not null and src.[Profile] is null))

Set @RowCount = @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated records in sissearch2.Consolidated_ServiceIE',@DATAVALUE = @RowCount;
--Select @RowCount, getdate(), 'Updated records in sissearch2.Consolidated_ServiceIE'
Set @TimeMarker = getdate()

--Insert new ID's
INSERT sissearch2.Consolidated_ServiceIE
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
Select 
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
From #Consolidated s
Left outer join sissearch2.Consolidated_ServiceIE t on s.[ID] = t.[ID]
Where t.[ID] is null --Does not exist in target

Set @RowCount = @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted records in sissearch2.Consolidated_ServiceIE',@DATAVALUE = @RowCount;
--Select @RowCount, getdate(), 'Inserted records in sissearch2.Consolidated_ServiceIE'
Set @TimeMarker = getdate()

--Add Restriction Codes
Update c 
Set [RestrictionCode] = nullif(nullif(r.[RestrictionCode], '[""]'), '')
From [sissearch2].[Consolidated_ServiceIE] c
Inner join [sissearch2].[ServiceIE_RestrictAccess] r on c.IESystemControlNumber = r.IESystemControlNumber
Where isnull(c.RestrictionCode, '') <> r.RestrictionCode

Set @RowCount = @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated sissearch2.Consolidated_ServiceIE.RestrictionCode',@DATAVALUE = @RowCount;
--Select @RowCount, getdate(), 'Inserted records in sissearch2.Consolidated_ServiceIE'
Set @TimeMarker = getdate()

--End
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Execution completed',@DATAVALUE = @RowCount;

END TRY

BEGIN CATCH 
DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(), @ERROELINE INT= ERROR_LINE()

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC sissearch2.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = 'sissearch2.Consolidated_ServiceIE_Load',@LOGMESSAGE = @error

END CATCH

END