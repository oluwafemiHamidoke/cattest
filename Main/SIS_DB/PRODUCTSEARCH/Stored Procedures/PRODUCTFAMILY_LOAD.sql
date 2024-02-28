
CREATE procedure [PRODUCTSEARCH].[PRODUCTFAMILY_LOAD] as
Begin

BEGIN TRY

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
		@RowCount BIGINT;

--Identify Deleted Records From Source

EXEC PRODUCTSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution Started';

--Get captive SNP arrays.
Drop Table if Exists #SNP_Captive
SELECT SNP_Prime, 
'["' + string_agg(cast(SNP_Captive as varchar(8000)), '","') within group (order by SNP_Captive) + '"]' SNP_Captive
into #SNP_Captive
From 
  (
	  Select Distinct p.Serial_Number_Prefix SNP_Prime, c.Serial_Number_Prefix SNP_Captive
	  FROM [sis].[CaptivePrime] cp
	  inner join [sis].[SerialNumberPrefix] p  on cp.Prime_SerialNumberPrefix_ID = p.SerialNumberPrefix_ID
	  inner join sis.SerialNumberPrefix c on cp.Captive_SerialNumberPrefix_ID = c.SerialNumberPrefix_ID
	  where p.Serial_Number_Prefix <> c.Serial_Number_Prefix
  ) x
  Group by SNP_Prime
  Order by 1,2

DROP TABLE IF EXISTS #Row_Action
Create table #Row_Action (Row_Action varchar(50))
Insert into #Row_Action (Row_Action)
Select Row_Action From (
MERGE into PRODUCTSEARCH.PRODUCTFAMILY tgt
USING
	(
	SELECT  
	--Stripped values cause duplicates on key.  Grouping and selecting max on attributes.
	coalesce(nullif(epi.Number, ''), 'N/A')Product_Instance_Number
	,p.Family_Code --Key
	,coalesce(nullif(ltrim(rtrim(pft.Family_Name)), ''), 'N/A') [Family_Name_en-US]
	,ps.Subfamily_Code --Key
	,coalesce(nullif(ltrim(rtrim(pst.Subfamily_Name)), ''), 'N/A') [Subfamily_Name_en-US]
	,case
		when epi.EMPProductInstance_ID is NULL then coalesce(nullif(ltrim(rtrim(sm.Sales_Model)), ''), 'N/A')
		else coalesce(nullif(ltrim(rtrim(epi.Model)), ''), 'N/A')
		end as Sales_Model --Key
	,coalesce(nullif(ltrim(rtrim(snp.Serial_Number_Prefix)), ''), 'N/A') Serial_Number_Prefix --Key
	,coalesce(nullif(ltrim(rtrim(l.Language_Tag)), ''), 'N/A') Language_Tag
	,snpc.SNP_Captive [Captive_Serial_Number_Prefix]
	,coalesce(nullif(ltrim(rtrim(epi.Name)), ''), 'N/A') [Product_Instance_Name]
	,case when epi.EMPProductInstance_ID is NULL then 0 else 1 end as isExpandedMiningProduct
	,nullif(concat('[','"' + nullif(ltrim(rtrim(epi.Alias1)), '') + '",', '"' + nullif(ltrim(rtrim(epi.Alias2)), '') + '",', '"' + nullif(ltrim(rtrim(epi.Alias3)), '') + '"', ']'), '[]' ) [Aliases]
	
	,TRIM(']' FROM TRIM('[' FROM (select 
	isExpandedMiningProduct,
	[Aliases] as aliases,
	[Aliases] as aliases_exact,
	[Product_Instance_Name] as productInstanceName,
	[Product_Instance_Name] as productInstanceName_exact,
	SALESORDERNUMBER salesOrderNumber,
	SALESORDERNUMBER salesOrderNumber_exact,
	ALTERNATESERIALNUMBER alternateSerialNumber,
	ALTERNATESERIALNUMBER alternateSerialNumber_exact

	from (
		select nullif(concat('[','"' + nullif(ltrim(rtrim(epi.Alias1)), '') + '",', '"' + nullif(ltrim(rtrim(epi.Alias2)), '') + '",', '"' + nullif(ltrim(rtrim(epi.Alias3)), '') + '"', ']'), '[]' ) [Aliases]
		,case when epi.EMPProductInstance_ID is NULL then CAST(0 AS BIT) else CAST(1 AS BIT) end as isExpandedMiningProduct
		,coalesce(nullif(ltrim(rtrim(epi.Name)), ''), 'N/A') [Product_Instance_Name]
		,SALESORDERNUMBER
		,ALTERNATESERIALNUMBER
		) a FOR JSON AUTO))) as Emp_Data
	
	FROM [sis].[ProductFamily] p
	cross join [sis].[Language] l
	inner join [sis].[Product_Relation] pr on p.ProductFamily_ID = pr.ProductFamily_ID
	inner join [sis].[SerialNumberPrefix] snp on snp.SerialNumberPrefix_ID = pr.SerialNumberPrefix_ID
	inner join [sis].[SalesModel] sm on sm.SalesModel_ID = pr.SalesModel_ID
	inner join [sis].[ProductSubfamily] ps on pr.ProductSubfamily_ID = ps.ProductSubfamily_ID
	inner join [sis].[ProductSubfamily_Translation] pst on ps.ProductSubfamily_ID = pst.ProductSubfamily_ID and l.Language_ID = pst.Language_ID
	inner join [sis].[ProductFamily_Translation] pft on p.ProductFamily_ID = pft.ProductFamily_ID and l.Language_ID = pft.Language_ID
	left outer join #SNP_Captive snpc on ltrim(rtrim(snpc.SNP_Prime)) = ltrim(rtrim(snp.Serial_Number_Prefix))
	left outer join SISWEB_OWNER.EMPPRODUCTINSTANCE epi on ltrim(rtrim(epi.SNP)) = ltrim(rtrim(snp.Serial_Number_Prefix)) and p.Family_Code = 'EMP'
	where l.Language_Tag = 'en-US'
	) src
ON --Source is constrainted to non-null values
	tgt.Family_Code = src.Family_Code and
	tgt.Subfamily_Code = src.Subfamily_Code and
	tgt.Sales_Model = src.Sales_Model and
	tgt.[Serial_Number_Prefix] = src.[Serial_Number_Prefix] and
	tgt.[Product_Instance_Number] = src.[Product_Instance_Number] and
	tgt.[Aliases] = src.[Aliases] and
	tgt.[Emp_Data] = src.[Emp_Data]
WHEN NOT MATCHED BY SOURCE THEN Delete --Delete when no longer in the source
WHEN NOT MATCHED BY TARGET THEN --Insert when not found in target
	INSERT ([Family_Code]
           ,[Family_Name_en-US]
		   ,[Subfamily_Code]
           ,[Subfamily_Name_en-US]
           ,[Sales_Model]
           ,[Serial_Number_Prefix]
		   ,[Captive_Serial_Number_Prefix]
           ,[Product_Instance_Number]
           ,[Product_Instance_Name]
           ,[isExpandedMiningProduct]
           ,[Aliases]
		   ,Emp_Data)
     VALUES
           (src.[Family_Code]
           ,src.[Family_Name_en-US]
		   ,src.[Subfamily_Code]
           ,src.[Subfamily_Name_en-US]
           ,src.[Sales_Model]
           ,src.[Serial_Number_Prefix]
		   ,src.[Captive_Serial_Number_Prefix]
           ,src.[Product_Instance_Number]
           ,src.[Product_Instance_Name]
           ,src.[isExpandedMiningProduct]
           ,src.[Aliases]
		   ,Emp_Data)
WHEN MATCHED AND --Update when keys match and attributes differ
	isnull(tgt.[Family_Name_en-US], '') <> isnull(src.[Family_Name_en-US], '') or
    isnull(tgt.[Subfamily_Name_en-US], '') <> isnull(src.[Subfamily_Name_en-US], '') or
    isnull(tgt.[Serial_Number_Prefix], '') <> isnull(src.[Serial_Number_Prefix], '') or
	isnull(tgt.[Captive_Serial_Number_Prefix], '') <> isnull(src.[Captive_Serial_Number_Prefix], '') or
    isnull(tgt.[Product_Instance_Name], '') <> isnull(src.[Product_Instance_Name], '') or
	isnull(tgt.[Aliases], '') <> isnull(src.[Aliases], '') or
	isnull(tgt.[Emp_Data], '') <> isnull(src.[Emp_Data], '')
	THEN UPDATE SET
	 tgt.[Family_Name_en-US] = src.[Family_Name_en-US]
    ,tgt.[Subfamily_Name_en-US]  =src.[Subfamily_Name_en-US]
    ,tgt.[Serial_Number_Prefix] = src.[Serial_Number_Prefix]
	,tgt.[Captive_Serial_Number_Prefix] = src.[Captive_Serial_Number_Prefix]
	,tgt.[Product_Instance_Name] = src.[Product_Instance_Name]
	,tgt.[Aliases] = src.[Aliases]
	,tgt.[Emp_Data] = src.[Emp_Data]
OUTPUT $action Row_Action) x (Row_Action)
;

Declare @InsertCount int, @UpdateCount int, @DeleteCount int
Select top 1 @InsertCount = Row_Count from (Select count(*) Row_Count From #Row_Action where Row_Action = 'INSERT' Group by Row_Action Union Select 0) x Order by Row_Count desc
Select top 1 @UpdateCount = Row_Count from (Select count(*) Row_Count From #Row_Action where Row_Action = 'UPDATE' Group by Row_Action Union Select 0) x Order by Row_Count desc
Select top 1 @DeleteCount = Row_Count from (Select count(*) Row_Count From #Row_Action where Row_Action = 'DELETE' Group by Row_Action Union Select 0) x Order by Row_Count desc


EXEC PRODUCTSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Insert Count', @DATAVALUE = @InsertCount;
EXEC PRODUCTSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Update Count', @DATAVALUE = @UpdateCount;
EXEC PRODUCTSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Delete Count', @DATAVALUE = @DeleteCount;


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
-- Create a temp table with detailed PermissionType(family,snp) for
-- each Product_ID
--

DROP TABLE IF EXISTS #ProductProdNSNP
select DISTINCT * 
into #ProductProdNSNP
from (
	select p.Product_Family_ID, @snpID as PermissionType_ID, snp.SerialNumberPrefix_ID as Permission_Detail_ID
	 from PRODUCTSEARCH.PRODUCTFAMILY p
	 inner join sis.SerialNumberPrefix snp on snp.Serial_Number_Prefix=p.Serial_Number_Prefix
) x
order by Product_Family_ID, PermissionType_ID

DROP TABLE IF EXISTS #ProductInfoType
select p.Product_Family_ID, @infoTypeID as PermissionType_ID, 5 as Permission_Detail_ID
into #ProductInfoType
	from PRODUCTSEARCH.PRODUCTFAMILY p


DROP TABLE IF EXISTS #AccessProdSNP
select m.Product_Family_ID, e.Profile_ID
into #AccessProdSNP
from #ProductProdNSNP m
inner join admin.AccessProfile_Permission_Relation e ON
	m.PermissionType_ID=e.PermissionType_ID AND
	(
		e.Include_Exclude=@PROFILE_MUST_INCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=0)
	)
	AND NOT (e.Include_Exclude=@PROFILE_MUST_EXCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_EXCLUDE_ALL))
-- use GROUP BY to remove duplicates
GROUP BY m.Product_Family_ID, e.Profile_ID

DROP TABLE IF EXISTS #ProductProdNSNP


DROP TABLE IF EXISTS #AccessInfoType
select m.Product_Family_ID, e.Profile_ID
into #AccessInfoType
from #ProductInfoType m
inner join admin.AccessProfile_Permission_Relation e ON
	m.PermissionType_ID=e.PermissionType_ID AND
	(
		e.Include_Exclude=@PROFILE_MUST_INCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=0)
	)
	AND NOT (e.Include_Exclude=@PROFILE_MUST_EXCLUDE AND (m.Permission_Detail_ID=e.Permission_Detail_ID OR e.Permission_Detail_ID=@PROFILE_EXCLUDE_ALL))
-- use GROUP BY to remove duplicates
GROUP BY m.Product_Family_ID, e.Profile_ID

DROP TABLE IF EXISTS #ProductInfoType


DROP TABLE IF EXISTS #ProductProfile
select z.Product_Family_ID, '['+string_agg(Profile_ID, ',') WITHIN GROUP (ORDER BY Profile_ID ASC)+']' as Profile
into #ProductProfile
from (
	select ps.Product_Family_ID, ps.Profile_ID 
	from #AccessInfoType it
		inner join #AccessProdSNP ps on ps.Product_Family_ID=it.Product_Family_ID and ps.Profile_ID=it.Profile_ID
	group by ps.Product_Family_ID, ps.Profile_ID
) z
GROUP BY z.Product_Family_ID

DROP TABLE IF EXISTS #AccessProdSNP
DROP TABLE IF EXISTS #AccessInfoType

--
-- Group permissions in a json adding Product_Number for later merge into consolidated table
--
UPDATE PRODUCTSEARCH.PRODUCTFAMILY
SET Profile=m.Profile
FROM #ProductProfile m WHERE PRODUCTFAMILY.Product_Family_ID=m.Product_Family_ID

DROP TABLE IF EXISTS #ProductProfile


-- profile updated

EXEC PRODUCTSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Executed Successfully';

END TRY

--Error log
BEGIN CATCH 

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
		@ERROELINE INT= ERROR_LINE();

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE

EXEC SISSEARCH.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @error

END CATCH

End