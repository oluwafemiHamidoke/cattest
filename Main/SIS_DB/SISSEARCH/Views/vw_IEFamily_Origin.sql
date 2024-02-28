CREATE VIEW SISSEARCH.vw_IEFamily_Origin AS
--
-- main query, gets by Media_ID, the family hierarchy
--
select -- top 100
	e.IE_ID,
	--m.Media_Number,
	pf.Family_Code,
	ps.Subfamily_Code,
	sm.Sales_Model,
	snp.Serial_Number_Prefix
from sis.IE e
	inner join sis.IE_ProductFamily_Effectivity mpfe on e.IE_ID=mpfe.IE_ID
	inner join sis.Product_Relation pr on mpfe.ProductFamily_ID=pr.ProductFamily_ID
	inner join sis.ProductFamily pf on mpfe.ProductFamily_ID=pf.ProductFamily_ID
	inner join sis.ProductSubfamily ps on pr.ProductSubfamily_ID=ps.ProductSubfamily_ID
	inner join sis.SalesModel sm on pr.SalesModel_ID=sm.SalesModel_ID
	inner join sis.SerialNumberPrefix snp on pr.SerialNumberPrefix_ID=snp.SerialNumberPrefix_ID
UNION
select -- top 100
	e.IE_ID,
	--m.Media_Number,
	pf.Family_Code,
	ps.Subfamily_Code,
	sm.Sales_Model,
	sp.Serial_Number_Prefix
from sis.IE e
	inner join sis.IE_Effectivity ef on ef.IE_ID=e.IE_ID
	inner join sis.SerialNumberPrefix sp on ef.SerialNumberPrefix_ID=sp.SerialNumberPrefix_ID
	inner join sis.Product_Relation pr on pr.SerialNumberPrefix_ID=sp.SerialNumberPrefix_ID
	inner join sis.ProductFamily pf on pr.ProductFamily_ID=pf.ProductFamily_ID
	inner join sis.ProductSubfamily ps on pr.ProductSubfamily_ID=ps.ProductSubfamily_ID
	inner join sis.SalesModel sm on pr.SalesModel_ID=sm.SalesModel_ID
GO