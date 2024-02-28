CREATE Procedure [sissearch2].[Consolidated_Media_Load] as 

BEGIN 
BEGIN TRY

--Start
EXEC sissearch2.WriteLog @NAMEOFSPROC = 'sissearch2.Consolidated_Media_Load', @LOGMESSAGE = 'Execution started';

--Prep
If Object_ID('tempdb..#Consolidated') is not null Drop table #Consolidated

--Create Temp
CREATE TABLE #Consolidated (
	[ID] [varchar](50) NULL,
	[BaseEngMediaNumber] [varchar](15) NULL,
	[INSERTDATE] [datetime] NULL,
	[Media_Number] [varchar](15) NULL,
	[MediaTitle_en-US] [nvarchar](1536) NULL,
	[MediaTitle_es-ES] [nvarchar](1536) NULL,
	[MediaTitle_fr-FR] [nvarchar](1536) NULL,
	[MediaTitle_pt-BR] [nvarchar](1536) NULL,
	[MediaTitle_it-IT] [nvarchar](1536) NULL,
	[MediaTitle_id-ID] [nvarchar](1536) NULL,
	[MediaTitle_zh-CN] [nvarchar](1536) NULL,
	[MediaTitle_de-DE] [nvarchar](1536) NULL,
	[MediaTitle_ja-JP] [nvarchar](1536) NULL,
	[MediaTitle_ru-RU] [nvarchar](1536) NULL,
	[isMedia] [bit] NULL,
	[Profile] [varchar](max) NULL,
	[InformationType] [varchar](max) NULL,
	[SerialNumbers] [varchar](max) NULL,
	[ProductCode] [varchar](500) NULL, 
	[UpdatedDate] [datetime] NULL,
	[PubDate] [datetime2] NULL,
	[PIPPSPNumber] [varchar](7) NULL,
	[familyCode] [VARCHAR](MAX) NULL,
	[familySubFamilyCode] [VARCHAR](MAX) NULL,
	[familySubFamilySalesModel] [VARCHAR](MAX) NULL,
	[familySubFamilySalesModelSNP] [VARCHAR](MAX) NULL,
	[MediaNumber_es-ES] [varchar](15) NULL,
	[MediaNumber_zh-CN] [varchar](15) NULL,
	[MediaNumber_fr-FR] [varchar](15) NULL,
	[MediaNumber_it-IT] [varchar](15) NULL,
	[MediaNumber_de-DE] [varchar](15) NULL,
	[MediaNumber_pt-BR] [varchar](15) NULL,
	[MediaNumber_id-ID] [varchar](15) NULL,
	[MediaNumber_ja-JP] [varchar](15) NULL,
	[MediaNumber_ru-RU] [varchar](15) NULL,
	[PubDate_es-ES] [datetime2](7) NULL,
	[PubDate_zh-CN] [datetime2](7) NULL,
	[PubDate_fr-FR] [datetime2](7) NULL,
	[PubDate_it-IT] [datetime2](7) NULL,
	[PubDate_de-DE] [datetime2](7) NULL,
	[PubDate_pt-BR] [datetime2](7) NULL,
	[PubDate_id-ID] [datetime2](7) NULL,
	[PubDate_ja-JP] [datetime2](7) NULL,
	[PubDate_ru-RU] [datetime2](7) NULL,
	[UpdatedDate_es-ES] [datetime] NULL,
	[UpdatedDate_zh-CN] [datetime] NULL,
	[UpdatedDate_fr-FR] [datetime] NULL,
	[UpdatedDate_it-IT] [datetime] NULL,
	[UpdatedDate_de-DE] [datetime] NULL,
	[UpdatedDate_pt-BR] [datetime] NULL,
	[UpdatedDate_id-ID] [datetime] NULL,
	[UpdatedDate_ja-JP] [datetime] NULL,
	[UpdatedDate_ru-RU] [datetime] NULL,
	[Media_Origin] [varchar](2) NULL
)

--Set collation of temp
ALTER TABLE #Consolidated 
ALTER COLUMN [ID] varchar(50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL

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
-- each Media_ID
--

DROP TABLE IF EXISTS #MediaProdNSNP
select * 
into #MediaProdNSNP
from (
	select m.Media_ID, @prodFamilyID as PermissionType_ID, mpfe.ProductFamily_ID as Permission_Detail_ID 
	from sis.Media m
		inner join sis.Media_ProductFamily_Effectivity mpfe on m.Media_ID=mpfe.Media_ID
		inner join sis.Product_Relation pr on mpfe.ProductFamily_ID=pr.ProductFamily_ID
	union
	 select m.Media_ID, @prodFamilyID as PermissionType_ID, pr.ProductFamily_ID as Permission_Detail_ID 
	from sis.Media m
		inner join sis.Media_Effectivity me on m.Media_ID=me.Media_ID
		inner join sis.Product_Relation pr on me.SerialNumberPrefix_ID=pr.SerialNumberPrefix_ID
	union
	 select m.Media_ID, @snpID as PermissionType_ID, me.SerialNumberPrefix_ID as Permission_Detail_ID 
	from sis.Media m
		inner join sis.Media_Effectivity me on m.Media_ID=me.Media_ID
) x
order by Media_ID, PermissionType_ID

DROP TABLE IF EXISTS #MediaInfoType
select m.Media_ID, @infoTypeID as PermissionType_ID, it.InfoType_ID as Permission_Detail_ID   
 into #MediaInfoType
 from sis.Media m 
 inner join sis.Media_InfoType_Relation it on m.Media_ID=it.Media_ID

DROP TABLE IF EXISTS #AccessProdSNP
select m.Media_ID, e.Profile_ID
into #AccessProdSNP
from #MediaProdNSNP m
inner join admin.AccessProfile_Permission_Relation e ON
	m.PermissionType_ID=e.PermissionType_ID AND
	(
		e.Include_Exclude=@PROFILE_MUST_INCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_INCLUDE_ALL)
	)
	AND NOT (e.Include_Exclude=@PROFILE_MUST_EXCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_EXCLUDE_ALL))
-- use GROUP BY to remove duplicates
GROUP BY m.Media_ID, e.Profile_ID


DROP TABLE IF EXISTS #AccessInfoType
select m.Media_ID, e.Profile_ID
into #AccessInfoType
from #MediaInfoType m
inner join admin.AccessProfile_Permission_Relation e ON
	m.PermissionType_ID=e.PermissionType_ID AND
	(
		e.Include_Exclude=@PROFILE_MUST_INCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_INCLUDE_ALL)
	)
	AND NOT (e.Include_Exclude=@PROFILE_MUST_EXCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_EXCLUDE_ALL))
GROUP BY m.Media_ID, e.Profile_ID

DROP TABLE IF EXISTS #MediaProfile
select z.Media_ID, t.Media_Number, '['+string_agg(Profile_ID, ',') WITHIN GROUP (ORDER BY Profile_ID ASC)+']' as Profile
into #MediaProfile
from (
	select ps.Media_ID, ps.Profile_ID 
	from #AccessInfoType it
		inner join #AccessProdSNP ps on ps.Media_ID=it.Media_ID and ps.Profile_ID=it.Profile_ID
	group by ps.Media_ID, ps.Profile_ID
) z
inner join sis.Media t on t.Media_ID=z.Media_ID
GROUP BY z.Media_ID, t.Media_Number



--Var
Declare @Sproc varchar(200) = 'sissearch2.Consolidated_Media_Load'
Declare @RowCount BIGINT,
		@LAPSETIME BIGINT
Declare @TimeMarker datetime = getdate()

--Add pkey to temp
ALTER TABLE #Consolidated 
ADD PRIMARY KEY CLUSTERED ([ID])

--Insert updated source into temp
Insert into #Consolidated
SELECT coalesce(bm.[ID], it.[ID], sn.[ID], pf.[ID], ph.[ID]) ID
      ,coalesce(bm.[BaseEngMediaNumber], it.[Media_Number], sn.[Media_Number], pf.[Media_Number], ph.[Media_Number]) [BaseEngMediaNumber]
	  ,GREATEST(bm.InsertDate, it.InsertDate, sn.InsertDate, pf.InsertDate, ph.[InsertDate]) [INSERTDATE]
	  --Basic Meda
      --,[BeginRange]
      --,[EndRange]
	  ,nullif(nullif(bm.[Media_Number], '[""]'), '') [Media_Number]
      ,[MediaTitle_en-US]
      ,[MediaTitle_es-ES]
      ,[MediaTitle_fr-FR]
      ,[MediaTitle_pt-BR]
      ,[MediaTitle_it-IT]
      ,[MediaTitle_in-ID] [MediaTitle_id-ID]
      ,[MediaTitle_zh-CN]
      ,[MediaTitle_de-DE]
      ,[MediaTitle_ja-JP]
      ,[MediaTitle_ru-RU]

      ,[isMedia]
	  ,mp.[Profile]
	  --Info Type
	  ,nullif(nullif([InformationType], '[""]'), '') [InformationType]
	  --SNP
      ,[SerialNumbers]
	  --Product Family
	  ,nullif(nullif([ProductCode], '[""]'), '') [ProductCode]
	  ,bm.UpdatedDate
	  ,bm.PubDate
	  ,bm.PIPPSPNumber

	  ,nullif(nullif([familyCode], '[""]'), '') [familyCode]
	  ,nullif(nullif([familySubFamilyCode], '[""]'), '') [familySubFamilyCode]
	  ,nullif(nullif([familySubFamilySalesModel], '[""]'), '') [familySubFamilySalesModel]
	  ,nullif(nullif([familySubFamilySalesModelSNP], '[""]'), '') [familySubFamilySalesModelSNP]

	  ,nullif(nullif([MediaNumber_es-ES], '[""]'), '') [MediaNumber_es-ES]
	  ,nullif(nullif([MediaNumber_zh-CN], '[""]'), '') [MediaNumber_zh-CN]
	  ,nullif(nullif([MediaNumber_fr-FR], '[""]'), '') [MediaNumber_fr-FR]
	  ,nullif(nullif([MediaNumber_it-IT], '[""]'), '') [MediaNumber_it-IT]
	  ,nullif(nullif([MediaNumber_de-DE], '[""]'), '') [MediaNumber_de-DE]
	  ,nullif(nullif([MediaNumber_pt-BR], '[""]'), '') [MediaNumber_pt-BR]
	  ,nullif(nullif([MediaNumber_id-ID], '[""]'), '') [MediaNumber_id-ID]
	  ,nullif(nullif([MediaNumber_ja-JP], '[""]'), '') [MediaNumber_ja-JP]
	  ,nullif(nullif([MediaNumber_ru-RU], '[""]'), '') [MediaNumber_ru-RU]
      ,bm.[PubDate_es-ES]
      ,bm.[PubDate_zh-CN]
      ,bm.[PubDate_fr-FR]
      ,bm.[PubDate_it-IT]
      ,bm.[PubDate_de-DE]
      ,bm.[PubDate_pt-BR]
      ,bm.[PubDate_id-ID]
      ,bm.[PubDate_ja-JP]
      ,bm.[PubDate_ru-RU]
      ,bm.[UpdatedDate_es-ES]
      ,bm.[UpdatedDate_zh-CN]
      ,bm.[UpdatedDate_fr-FR]
      ,bm.[UpdatedDate_it-IT]
      ,bm.[UpdatedDate_de-DE]
      ,bm.[UpdatedDate_pt-BR]
      ,bm.[UpdatedDate_id-ID]
      ,bm.[UpdatedDate_ja-JP]
      ,bm.[UpdatedDate_ru-RU]
	  ,e.Media_Origin [Media_Origin]
From [sissearch2].[Basic_ServiceMedia] bm
  Full outer join [sissearch2].[Media_InfoType] it on bm.[ID] = it.[ID]
  Full outer join [sissearch2].[Media_SNP] sn on coalesce(bm.[ID], it.[ID]) = sn.[ID]
  Full outer join [sissearch2].[Media_ProductFamily] pf on coalesce(bm.[ID], it.[ID], sn.[ID]) = pf.[ID]
  full outer join [sissearch2].[Media_ProductHierarchy] ph on coalesce(bm.[ID], it.[ID], sn.[ID], pf.[ID]) = ph.[ID]
  left join #MediaProfile mp ON coalesce(bm.[ID], it.[ID], sn.[ID], pf.[ID])=mp.Media_Number
  left join [sis].[Media_Translation] e ON e.MEDIA_NUMBER=bm.Media_Number
  --left join [SISWEB_OWNER].[MASMEDIA] e ON e.MEDIANUMBER=bm.[BaseEngMediaNumber]
Option (Force Order)



DROP TABLE IF EXISTS #MediaProfile

SET @RowCount= @@RowCount
SET @LAPSETIME = datediff(SS, @TimeMarker, getdate())
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into #Consolidated', @DATAVALUE = @RowCount;

--Select @RowCount, getdate(), 'Inserted into #Consolidated'
Set @TimeMarker = getdate()


Update tgt
Set tgt.BaseEngMediaNumber = src.BaseEngMediaNumber
	,tgt.[INSERTDATE] = src.[INSERTDATE]
	,tgt.[Media_Number] = src.[Media_Number]
	,tgt.[MediaTitle_en-US] = src.[MediaTitle_en-US]
	,tgt.[MediaTitle_es-ES] = src.[MediaTitle_es-ES]
	,tgt.[MediaTitle_fr-FR] = src.[MediaTitle_fr-FR]
	,tgt.[MediaTitle_pt-BR] = src.[MediaTitle_pt-BR]
	,tgt.[MediaTitle_it-IT] = src.[MediaTitle_it-IT]
	,tgt.[MediaTitle_id-ID] = src.[MediaTitle_id-ID]
	,tgt.[MediaTitle_zh-CN] = src.[MediaTitle_zh-CN]
	,tgt.[MediaTitle_de-DE] = src.[MediaTitle_de-DE]
	,tgt.[MediaTitle_ja-JP] = src.[MediaTitle_ja-JP]
	,tgt.[MediaTitle_ru-RU] = src.[MediaTitle_ru-RU]
	,tgt.[isMedia] = src.[isMedia]
	,tgt.[Profile] = src.[Profile]
	,tgt.[InformationType] = src.[InformationType]
	--,tgt.[SerialNumbers] = src.[SerialNumbers]
	,tgt.[ProductCode] = src.[ProductCode]
	,tgt.[UpdatedDate] = src.[UpdatedDate]
	,tgt.[PubDate] = src.[PubDate]
	,tgt.[PIPPSPNumber] = src.[PIPPSPNumber]
	,tgt.[familyCode] = src.[familyCode]
	,tgt.[familySubFamilyCode] = src.[familySubFamilyCode]
	,tgt.[familySubFamilySalesModel] = src.[familySubFamilySalesModel]
	,tgt.[familySubFamilySalesModelSNP] = src.[familySubFamilySalesModelSNP]

      ,tgt.[MediaNumber_es-ES] = src.[MediaNumber_es-ES]
      ,tgt.[MediaNumber_zh-CN] = src.[MediaNumber_zh-CN]
      ,tgt.[MediaNumber_fr-FR] = src.[MediaNumber_fr-FR]
      ,tgt.[MediaNumber_it-IT] = src.[MediaNumber_it-IT]
      ,tgt.[MediaNumber_de-DE] = src.[MediaNumber_de-DE]
      ,tgt.[MediaNumber_pt-BR] = src.[MediaNumber_pt-BR]
      ,tgt.[MediaNumber_id-ID] = src.[MediaNumber_id-ID]
      ,tgt.[MediaNumber_ja-JP] = src.[MediaNumber_ja-JP]
      ,tgt.[MediaNumber_ru-RU] = src.[MediaNumber_ru-RU]
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
	  ,tgt.[Media_Origin] = src.[Media_Origin]
From #Consolidated tgt
Inner join --Get all attributes from the first version of the ID (no suffix) which matches the natural key.
(
	Select *
	From #Consolidated
	Where BaseEngMediaNumber = ID
) src on src.BaseEngMediaNumber = tgt.BaseEngMediaNumber
where tgt.ID like '%[_]%' --Only update IDs with suffix.  These suffixed records are being created to get around an Azure json object limit.

SET @RowCount= @@RowCount
SET @LAPSETIME = DATEDIFF(SS, @TimeMarker, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Updated #Consolidated Suffixed IDs',@LAPSETIME = @LAPSETIME,@DATAVALUE = @RowCount;

--Select @RowCount, getdate(), 'Inserted into #Consolidated'
Set @TimeMarker = getdate()


--Delete from target
Delete sissearch2.Consolidated_Media
From  sissearch2.Consolidated_Media t
Left outer join #Consolidated s on t.[ID] = s.[ID]
Where s.[ID] is null --Does not exist in source

SET @RowCount= @@RowCount
SET @LAPSETIME = DATEDIFF(SS, @TimeMarker, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Deleted records from sissearch2.Consolidated_Media_Load',@LAPSETIME = @LAPSETIME,@DATAVALUE = @RowCount;

 

Set @TimeMarker = getdate()

--Update target where ID exist in source and newer inserted datetime
Update tgt
Set 
	tgt.[INSERTDATE] = src.[INSERTDATE]
	--,tgt.[BeginRange] = src.[BeginRange]
	--,tgt.[EndRange] = src.[EndRange]
	,tgt.[Media_Number] = src.[Media_Number]
	,tgt.[MediaTitle_en-US] = src.[MediaTitle_en-US]
	,tgt.[MediaTitle_es-ES] = src.[MediaTitle_es-ES]
	,tgt.[MediaTitle_fr-FR] = src.[MediaTitle_fr-FR]
	,tgt.[MediaTitle_pt-BR] = src.[MediaTitle_pt-BR]
	,tgt.[MediaTitle_it-IT] = src.[MediaTitle_it-IT]
	,tgt.[MediaTitle_id-ID] = src.[MediaTitle_id-ID]
	,tgt.[MediaTitle_zh-CN] = src.[MediaTitle_zh-CN]
	,tgt.[MediaTitle_de-DE] = src.[MediaTitle_de-DE]
	,tgt.[MediaTitle_ja-JP] = src.[MediaTitle_ja-JP]
	,tgt.[MediaTitle_ru-RU] = src.[MediaTitle_ru-RU]
	,tgt.[isMedia] = src.[isMedia]
	,tgt.[Profile] = src.[Profile]
	,tgt.[InformationType] = src.[InformationType]
	,tgt.[SerialNumbers] = src.[SerialNumbers]
	,tgt.[ProductCode] = src.[ProductCode]
	,tgt.[UpdatedDate] = src.[UpdatedDate]
	,tgt.[PubDate] = src.[PubDate]
	,tgt.[PIPPSPNumber] = src.[PIPPSPNumber]
	,tgt.[familyCode] = src.[familyCode]
	,tgt.[familySubFamilyCode] = src.[familySubFamilyCode]
	,tgt.[familySubFamilySalesModel] = src.[familySubFamilySalesModel]
	,tgt.[familySubFamilySalesModelSNP] = src.[familySubFamilySalesModelSNP]
      ,tgt.[MediaNumber_es-ES] = src.[MediaNumber_es-ES]
      ,tgt.[MediaNumber_zh-CN] = src.[MediaNumber_zh-CN]
      ,tgt.[MediaNumber_fr-FR] = src.[MediaNumber_fr-FR]
      ,tgt.[MediaNumber_it-IT] = src.[MediaNumber_it-IT]
      ,tgt.[MediaNumber_de-DE] = src.[MediaNumber_de-DE]
      ,tgt.[MediaNumber_pt-BR] = src.[MediaNumber_pt-BR]
      ,tgt.[MediaNumber_id-ID] = src.[MediaNumber_id-ID]
      ,tgt.[MediaNumber_ja-JP] = src.[MediaNumber_ja-JP]
      ,tgt.[MediaNumber_ru-RU] = src.[MediaNumber_ru-RU]
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
	  ,tgt.[Media_Origin] = src.[Media_Origin]
From sissearch2.Consolidated_Media tgt
Inner join #Consolidated src on tgt.[ID] = src.[ID] --Existing
Where src.[INSERTDATE] > tgt.[INSERTDATE] --Updated in source
--We are not guaranteed that all sources will be updated at the same time (on the same day).  Therefore we need to handle newer insert dates as well as changed values.
or (tgt.[Media_Number] <> src.[Media_Number] or (tgt.[Media_Number] is null and src.[Media_Number] is not null) or (tgt.[Media_Number] is not null and src.[Media_Number] is null))
or (tgt.[MediaTitle_en-US] <> src.[MediaTitle_en-US] or (tgt.[MediaTitle_en-US] is null and src.[MediaTitle_en-US] is not null) or (tgt.[MediaTitle_en-US] is not null and src.[MediaTitle_en-US] is null))
or (tgt.[MediaTitle_es-ES] <> src.[MediaTitle_es-ES] or (tgt.[MediaTitle_es-ES] is null and src.[MediaTitle_es-ES] is not null) or (tgt.[MediaTitle_es-ES] is not null and src.[MediaTitle_es-ES] is null))
or (tgt.[MediaTitle_fr-FR] <> src.[MediaTitle_fr-FR] or (tgt.[MediaTitle_fr-FR] is null and src.[MediaTitle_fr-FR] is not null) or (tgt.[MediaTitle_fr-FR] is not null and src.[MediaTitle_fr-FR] is null))
or (tgt.[MediaTitle_pt-BR] <> src.[MediaTitle_pt-BR] or (tgt.[MediaTitle_pt-BR] is null and src.[MediaTitle_pt-BR] is not null) or (tgt.[MediaTitle_pt-BR] is not null and src.[MediaTitle_pt-BR] is null))
or (tgt.[MediaTitle_it-IT] <> src.[MediaTitle_it-IT] or (tgt.[MediaTitle_it-IT] is null and src.[MediaTitle_it-IT] is not null) or (tgt.[MediaTitle_it-IT] is not null and src.[MediaTitle_it-IT] is null))
or (tgt.[MediaTitle_id-ID] <> src.[MediaTitle_id-ID] or (tgt.[MediaTitle_id-ID] is null and src.[MediaTitle_id-ID] is not null) or (tgt.[MediaTitle_id-ID] is not null and src.[MediaTitle_id-ID] is null))
or (tgt.[MediaTitle_zh-CN] <> src.[MediaTitle_zh-CN] or (tgt.[MediaTitle_zh-CN] is null and src.[MediaTitle_zh-CN] is not null) or (tgt.[MediaTitle_zh-CN] is not null and src.[MediaTitle_zh-CN] is null))
or (tgt.[MediaTitle_de-DE] <> src.[MediaTitle_de-DE] or (tgt.[MediaTitle_de-DE] is null and src.[MediaTitle_de-DE] is not null) or (tgt.[MediaTitle_de-DE] is not null and src.[MediaTitle_de-DE] is null))
or (tgt.[MediaTitle_ja-JP] <> src.[MediaTitle_ja-JP] or (tgt.[MediaTitle_ja-JP] is null and src.[MediaTitle_ja-JP] is not null) or (tgt.[MediaTitle_ja-JP] is not null and src.[MediaTitle_ja-JP] is null))
or (tgt.[MediaTitle_ru-RU] <> src.[MediaTitle_ru-RU] or (tgt.[MediaTitle_ru-RU] is null and src.[MediaTitle_ru-RU] is not null) or (tgt.[MediaTitle_ru-RU] is not null and src.[MediaTitle_ru-RU] is null))
or (tgt.[isMedia] <> src.[isMedia] or (tgt.[isMedia] is null and src.[isMedia] is not null) or (tgt.[isMedia] is not null and src.[isMedia] is null))
or (tgt.[InformationType] <> src.[InformationType] or (tgt.[InformationType] is null and src.[InformationType] is not null) or (tgt.[InformationType] is not null and src.[InformationType] is null))
or (tgt.[SerialNumbers] <> src.[SerialNumbers] or (tgt.[SerialNumbers] is null and src.[SerialNumbers] is not null) or (tgt.[SerialNumbers] is not null and src.[SerialNumbers] is null))
or (tgt.[ProductCode] <> src.[ProductCode] or (tgt.[ProductCode] is null and src.[ProductCode] is not null) or (tgt.[ProductCode] is not null and src.[ProductCode] is null))
or (tgt.[UpdatedDate] <> src.[UpdatedDate] or (tgt.[UpdatedDate] is null and src.[UpdatedDate] is not null) or (tgt.[UpdatedDate] is not null and src.[UpdatedDate] is null))
or (tgt.[PubDate] <> src.[PubDate] or (tgt.[PubDate] is null and src.[PubDate] is not null) or (tgt.[PubDate] is not null and src.[PubDate] is null))
--or (tgt.[RestrictionCode] <> src.[RestrictionCode] or (tgt.[RestrictionCode] is null and src.[RestrictionCode] is not null) or (tgt.[RestrictionCode] is not null and src.[RestrictionCode] is null))
or (tgt.[PIPPSPNumber] <> src.[PIPPSPNumber] or (tgt.[PIPPSPNumber] is null and src.[PIPPSPNumber] is not null) or (tgt.[PIPPSPNumber] is not null and src.[PIPPSPNumber] is null))
or (tgt.[familyCode] <> src.[familyCode] or (tgt.[familyCode] is null and src.[familyCode] is not null) or (tgt.[familyCode] is not null and src.[familyCode] is null))
or (tgt.[familySubFamilyCode] <> src.[familySubFamilyCode] or (tgt.[familySubFamilyCode] is null and src.[familySubFamilyCode] is not null) or (tgt.[familySubFamilyCode] is not null and src.[familySubFamilyCode] is null))
or (tgt.[familySubFamilySalesModel] <> src.[familySubFamilySalesModel] or (tgt.[familySubFamilySalesModel] is null and src.[familySubFamilySalesModel] is not null) or (tgt.[familySubFamilySalesModel] is not null and src.[familySubFamilySalesModel] is null))
or (tgt.[familySubFamilySalesModelSNP] <> src.[familySubFamilySalesModelSNP] or (tgt.[familySubFamilySalesModelSNP] is null and src.[familySubFamilySalesModelSNP] is not null) or (tgt.[familySubFamilySalesModelSNP] is not null and src.[familySubFamilySalesModelSNP] is null))
or (tgt.[MediaNumber_es-ES] <> src.[MediaNumber_es-ES] or (tgt.[MediaNumber_es-ES] is null and src.[MediaNumber_es-ES] is not null) or (tgt.[MediaNumber_es-ES] is not null and src.[MediaNumber_es-ES] is null))
or (tgt.[MediaNumber_zh-CN] <> src.[MediaNumber_zh-CN] or (tgt.[MediaNumber_zh-CN] is null and src.[MediaNumber_zh-CN] is not null) or (tgt.[MediaNumber_zh-CN] is not null and src.[MediaNumber_zh-CN] is null))
or (tgt.[MediaNumber_fr-FR] <> src.[MediaNumber_fr-FR] or (tgt.[MediaNumber_fr-FR] is null and src.[MediaNumber_fr-FR] is not null) or (tgt.[MediaNumber_fr-FR] is not null and src.[MediaNumber_fr-FR] is null))
or (tgt.[MediaNumber_it-IT] <> src.[MediaNumber_it-IT] or (tgt.[MediaNumber_it-IT] is null and src.[MediaNumber_it-IT] is not null) or (tgt.[MediaNumber_it-IT] is not null and src.[MediaNumber_it-IT] is null))
or (tgt.[MediaNumber_de-DE] <> src.[MediaNumber_de-DE] or (tgt.[MediaNumber_de-DE] is null and src.[MediaNumber_de-DE] is not null) or (tgt.[MediaNumber_de-DE] is not null and src.[MediaNumber_de-DE] is null))
or (tgt.[MediaNumber_pt-BR] <> src.[MediaNumber_pt-BR] or (tgt.[MediaNumber_pt-BR] is null and src.[MediaNumber_pt-BR] is not null) or (tgt.[MediaNumber_pt-BR] is not null and src.[MediaNumber_pt-BR] is null))
or (tgt.[MediaNumber_id-ID] <> src.[MediaNumber_id-ID] or (tgt.[MediaNumber_id-ID] is null and src.[MediaNumber_id-ID] is not null) or (tgt.[MediaNumber_id-ID] is not null and src.[MediaNumber_id-ID] is null))
or (tgt.[MediaNumber_ja-JP] <> src.[MediaNumber_ja-JP] or (tgt.[MediaNumber_ja-JP] is null and src.[MediaNumber_ja-JP] is not null) or (tgt.[MediaNumber_ja-JP] is not null and src.[MediaNumber_ja-JP] is null))
or (tgt.[MediaNumber_ru-RU] <> src.[MediaNumber_ru-RU] or (tgt.[MediaNumber_ru-RU] is null and src.[MediaNumber_ru-RU] is not null) or (tgt.[MediaNumber_ru-RU] is not null and src.[MediaNumber_ru-RU] is null))
or (tgt.[PubDate_es-ES] <> src.[PubDate_es-ES] or (tgt.[PubDate_es-ES] is null and src.[PubDate_es-ES] is not null) or (tgt.[PubDate_es-ES] is not null and src.[PubDate_es-ES] is null))
or (tgt.[PubDate_zh-CN] <> src.[PubDate_zh-CN] or (tgt.[PubDate_zh-CN] is null and src.[PubDate_zh-CN] is not null) or (tgt.[PubDate_zh-CN] is not null and src.[PubDate_zh-CN] is null))
or (tgt.[PubDate_fr-FR] <> src.[PubDate_fr-FR] or (tgt.[PubDate_fr-FR] is null and src.[PubDate_fr-FR] is not null) or (tgt.[PubDate_fr-FR] is not null and src.[PubDate_fr-FR] is null))
or (tgt.[PubDate_it-IT] <> src.[PubDate_it-IT] or (tgt.[PubDate_it-IT] is null and src.[PubDate_it-IT] is not null) or (tgt.[PubDate_it-IT] is not null and src.[PubDate_it-IT] is null))
or (tgt.[PubDate_de-DE] <> src.[PubDate_de-DE] or (tgt.[PubDate_de-DE] is null and src.[PubDate_de-DE] is not null) or (tgt.[PubDate_de-DE] is not null and src.[PubDate_de-DE] is null))
or (tgt.[PubDate_pt-BR] <> src.[PubDate_pt-BR] or (tgt.[PubDate_pt-BR] is null and src.[PubDate_pt-BR] is not null) or (tgt.[PubDate_pt-BR] is not null and src.[PubDate_pt-BR] is null))
or (tgt.[PubDate_id-ID] <> src.[PubDate_id-ID] or (tgt.[PubDate_id-ID] is null and src.[PubDate_id-ID] is not null) or (tgt.[PubDate_id-ID] is not null and src.[PubDate_id-ID] is null))
or (tgt.[PubDate_ja-JP] <> src.[PubDate_ja-JP] or (tgt.[PubDate_ja-JP] is null and src.[PubDate_ja-JP] is not null) or (tgt.[PubDate_ja-JP] is not null and src.[PubDate_ja-JP] is null))
or (tgt.[PubDate_ru-RU] <> src.[PubDate_ru-RU] or (tgt.[PubDate_ru-RU] is null and src.[PubDate_ru-RU] is not null) or (tgt.[PubDate_ru-RU] is not null and src.[PubDate_ru-RU] is null))
or (tgt.[UpdatedDate_es-ES] <> src.[UpdatedDate_es-ES] or (tgt.[UpdatedDate_es-ES] is null and src.[UpdatedDate_es-ES] is not null) or (tgt.[UpdatedDate_es-ES] is not null and src.[UpdatedDate_es-ES] is null))
or (tgt.[UpdatedDate_zh-CN] <> src.[UpdatedDate_zh-CN] or (tgt.[UpdatedDate_zh-CN] is null and src.[UpdatedDate_zh-CN] is not null) or (tgt.[UpdatedDate_zh-CN] is not null and src.[UpdatedDate_zh-CN] is null))
or (tgt.[UpdatedDate_fr-FR] <> src.[UpdatedDate_fr-FR] or (tgt.[UpdatedDate_fr-FR] is null and src.[UpdatedDate_fr-FR] is not null) or (tgt.[UpdatedDate_fr-FR] is not null and src.[UpdatedDate_fr-FR] is null))
or (tgt.[UpdatedDate_it-IT] <> src.[UpdatedDate_it-IT] or (tgt.[UpdatedDate_it-IT] is null and src.[UpdatedDate_it-IT] is not null) or (tgt.[UpdatedDate_it-IT] is not null and src.[UpdatedDate_it-IT] is null))
or (tgt.[UpdatedDate_de-DE] <> src.[UpdatedDate_de-DE] or (tgt.[UpdatedDate_de-DE] is null and src.[UpdatedDate_de-DE] is not null) or (tgt.[UpdatedDate_de-DE] is not null and src.[UpdatedDate_de-DE] is null))
or (tgt.[UpdatedDate_pt-BR] <> src.[UpdatedDate_pt-BR] or (tgt.[UpdatedDate_pt-BR] is null and src.[UpdatedDate_pt-BR] is not null) or (tgt.[UpdatedDate_pt-BR] is not null and src.[UpdatedDate_pt-BR] is null))
or (tgt.[UpdatedDate_id-ID] <> src.[UpdatedDate_id-ID] or (tgt.[UpdatedDate_id-ID] is null and src.[UpdatedDate_id-ID] is not null) or (tgt.[UpdatedDate_id-ID] is not null and src.[UpdatedDate_id-ID] is null))
or (tgt.[UpdatedDate_ja-JP] <> src.[UpdatedDate_ja-JP] or (tgt.[UpdatedDate_ja-JP] is null and src.[UpdatedDate_ja-JP] is not null) or (tgt.[UpdatedDate_ja-JP] is not null and src.[UpdatedDate_ja-JP] is null))
or (tgt.[UpdatedDate_ru-RU] <> src.[UpdatedDate_ru-RU] or (tgt.[UpdatedDate_ru-RU] is null and src.[UpdatedDate_ru-RU] is not null) or (tgt.[UpdatedDate_ru-RU] is not null and src.[UpdatedDate_ru-RU] is null))
or (tgt.[Profile] <> src.[Profile] or (tgt.[Profile] is null and src.[Profile] is not null) or (tgt.[Profile] is not null and src.[Profile] is null))
or (tgt.[Media_Origin] <> src.[Media_Origin] or (tgt.[Media_Origin] is null and src.[Media_Origin] is not null) or (tgt.[Media_Origin] is not null and src.[Media_Origin] is null))


SET @RowCount= @@RowCount
SET @LAPSETIME = DATEDIFF(SS, @TimeMarker, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Updated records in sissearch2.Consolidated_Media_Load',@LAPSETIME= @LAPSETIME,@DATAVALUE = @RowCount;



Set @TimeMarker = getdate()

--Insert new ID's
INSERT sissearch2.Consolidated_Media
([ID]
      ,[BaseEngMediaNumber]
      ,[INSERTDATE]
      ,[Media_Number]
      ,[MediaTitle_en-US]
      ,[MediaTitle_es-ES]
      ,[MediaTitle_fr-FR]
      ,[MediaTitle_pt-BR]
      ,[MediaTitle_it-IT]
      ,[MediaTitle_id-ID]
      ,[MediaTitle_zh-CN]
      ,[MediaTitle_de-DE]
	  ,[MediaTitle_ja-JP]
      ,[MediaTitle_ru-RU]
      ,[isMedia]
	  ,[Profile]
      ,[InformationType]
      ,[SerialNumbers]
      ,[ProductCode]
      ,[UpdatedDate]
      ,[PubDate]
      ,[PIPPSPNumber]
	  ,[familyCode]
	  ,[familySubFamilyCode]
	  ,[familySubFamilySalesModel]
	  ,[familySubFamilySalesModelSNP]
      ,[MediaNumber_es-ES]
      ,[MediaNumber_zh-CN]
      ,[MediaNumber_fr-FR]
      ,[MediaNumber_it-IT]
      ,[MediaNumber_de-DE]
      ,[MediaNumber_pt-BR]
      ,[MediaNumber_id-ID]
      ,[MediaNumber_ja-JP]
      ,[MediaNumber_ru-RU]
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
	  ,[Media_Origin]
	  )
Select 
 s.[ID]
,s.[BaseEngMediaNumber]
,s.[INSERTDATE]
,s.[Media_Number]
,s.[MediaTitle_en-US]
,s.[MediaTitle_es-ES]
,s.[MediaTitle_fr-FR]
,s.[MediaTitle_pt-BR]
,s.[MediaTitle_it-IT]
,s.[MediaTitle_id-ID]
,s.[MediaTitle_zh-CN]
,s.[MediaTitle_de-DE]
	  ,s.[MediaTitle_ja-JP]
      ,s.[MediaTitle_ru-RU]
,s.[isMedia]
,s.[Profile]
,s.[InformationType]
,s.[SerialNumbers]
,s.[ProductCode]
,s.[UpdatedDate]
,s.[PubDate]
,s.[PIPPSPNumber]
,s.[familyCode]
,s.[familySubFamilyCode]
,s.[familySubFamilySalesModel]
,s.[familySubFamilySalesModelSNP]
      ,s.[MediaNumber_es-ES]
      ,s.[MediaNumber_zh-CN]
      ,s.[MediaNumber_fr-FR]
      ,s.[MediaNumber_it-IT]
      ,s.[MediaNumber_de-DE]
      ,s.[MediaNumber_pt-BR]
      ,s.[MediaNumber_id-ID]
      ,s.[MediaNumber_ja-JP]
      ,s.[MediaNumber_ru-RU]
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
	  ,s.[Media_Origin]
From #Consolidated s
Left outer join sissearch2.Consolidated_Media t on s.[ID] = t.[ID]
Where t.[ID] is null --Does not exist in target

SET @RowCount= @@RowCount
SET @LAPSETIME = DATEDIFF(SS, @TimeMarker, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Inserted records in sissearch2.Consolidated_Media',@LAPSETIME = @LAPSETIME,@DATAVALUE = @RowCount;


Set @TimeMarker = getdate()

--Add Restriction Codes
Update c 
Set [RestrictionCode] = nullif(nullif(r.[RestrictionCode], '[""]'), '')
From sissearch2.Consolidated_Media c
Inner join [sissearch2].[Media_RestrictAccess] r on c.BaseEngMediaNumber = r.Media_Number
Where isnull(c.RestrictionCode, '') <> r.RestrictionCode

SET @RowCount= @@RowCount
SET @LAPSETIME = DATEDIFF(SS, @TimeMarker, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @Sproc, @LOGMESSAGE = 'Updated sissearch2.Consolidated_Media_Load.RestrictionCode',@LAPSETIME = @LAPSETIME,@DATAVALUE = @RowCount;



END TRY

BEGIN CATCH 
DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(), @ERROELINE INT= ERROR_LINE()
SET @ERRORMESSAGE  = CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE;
EXEC sissearch2.WriteLog @NAMEOFSPROC = 'sissearch2.Consolidated_Media_Load', @LOGMESSAGE = @ERRORMESSAGE;


END CATCH

END
GO


