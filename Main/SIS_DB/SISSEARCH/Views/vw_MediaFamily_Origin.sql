CREATE VIEW SISSEARCH.[vw_MediaFamily_Origin] AS
--
-- main query, gets by Media_ID, the family hierarchy
--
select
	m.Media_ID,
	pf.Family_Code,
	ps.Subfamily_Code,
	sm.Sales_Model,
	snp.Serial_Number_Prefix
from sis.Media m
	inner join sis.Media_ProductFamily_Effectivity mpfe on m.Media_ID=mpfe.Media_ID
	inner join sis.Product_Relation pr on mpfe.ProductFamily_ID=pr.ProductFamily_ID
	inner join sis.ProductFamily pf on mpfe.ProductFamily_ID=pf.ProductFamily_ID
	inner join sis.ProductSubfamily ps on pr.ProductSubfamily_ID=ps.ProductSubfamily_ID
	inner join sis.SalesModel sm on pr.SalesModel_ID=sm.SalesModel_ID
	inner join sis.SerialNumberPrefix snp on pr.SerialNumberPrefix_ID=snp.SerialNumberPrefix_ID
UNION
select
	m.Media_ID,
	pf.Family_Code,
	ps.Subfamily_Code,
	sm.Sales_Model,
	sp.Serial_Number_Prefix
from sis.Media m
	inner join sis.Media_Effectivity e on m.Media_ID=e.Media_ID
	inner join sis.SerialNumberPrefix sp on e.SerialNumberPrefix_ID=sp.SerialNumberPrefix_ID
	inner join sis.Product_Relation pr on pr.SerialNumberPrefix_ID=sp.SerialNumberPrefix_ID
	inner join sis.ProductFamily pf on pr.ProductFamily_ID=pf.ProductFamily_ID
	inner join sis.ProductSubfamily ps on pr.ProductSubfamily_ID=ps.ProductSubfamily_ID
	inner join sis.SalesModel sm on pr.SalesModel_ID=sm.SalesModel_ID
GO	