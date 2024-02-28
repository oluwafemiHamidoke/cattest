
--
-- Media Product Hierarchy View
--
-- This query pulls LNKMEDIASNP
-- -- -- !!!!!!!!!!!   @BaiLu: 
--						1) please help comment the business case for TYPEINDICATOR in S,P, 
--						2) Validate Language_ID=38 filter in vw_Product

CREATE   VIEW [SISSEARCH].[vw_MEDIAPRODUCT] AS
SELECT
	a.BASEENGLISHMEDIANUMBER as MEDIANUMBER,
	b.Family_Code,
	b.Subfamily_Code,
	b.Sales_Model,
	b.Serial_Number_Prefix--,
	-- a.[MEDIAUPDATEDDATE]
	from SISWEB_OWNER.MASMEDIA a
	inner join SISWEB_OWNER.LNKMEDIASNP c on c.TYPEINDICATOR='P' and a.BASEENGLISHMEDIANUMBER=c.MEDIANUMBER
	inner join sis.vw_Product b on Language_ID=38 AND c.SNP=b.Family_Code
UNION SELECT
	a.BASEENGLISHMEDIANUMBER as MEDIANUMBER,
	b.Family_Code,
	b.Subfamily_Code,
	b.Sales_Model,
	b.Serial_Number_Prefix--,
	-- a.[MEDIAUPDATEDDATE]
	from SISWEB_OWNER.MASMEDIA a
	inner join SISWEB_OWNER.LNKMEDIASNP c on c.TYPEINDICATOR='S' and a.BASEENGLISHMEDIANUMBER=c.MEDIANUMBER and c.INFOTYPEID not in (
		Select [INFOTYPEID] from SISSEARCH.REF_EXCLUDEINFOTYPE where [Search2_Status] = 1 and [Selective_Exclude] = 0
	)
	inner join sis.vw_Product b on Language_ID=38 AND c.SNP=b.Serial_Number_Prefix
	where a.LANGUAGEINDICATOR = 'E'
	and not exists(
		select 1 from SISSEARCH.REF_SELECTIVE_EXCLUDEINFOTYPE 
	where INFOTYPEID = c.INFOTYPEID and [Excluded_Values] = a.MEDIAORIGIN
	)