-- Davide 20190606 removed column from language table

CREATE View [sis].[vw_Product] as
SELECT
 l.Language_ID
,l.Language
--,l.Country
,l.Language_Tag
,p.Family_Code
,pft.Family_Name
,ps.ProductSubfamily_ID
,ps.Subfamily_Code
,pst.Subfamily_Name
,p.ProductFamily_ID
,sm.Sales_Model
,snp.Serial_Number_Prefix
,snp.Classic_Product_Indicator
  FROM [sis].[ProductFamily] p
  cross join [sis].[Language] l
  inner join [sis].[Product_Relation] pr on p.ProductFamily_ID = pr.ProductFamily_ID
  inner join [sis].[SerialNumberPrefix] snp on snp.SerialNumberPrefix_ID = pr.SerialNumberPrefix_ID
  inner join [sis].[SalesModel] sm on sm.SalesModel_ID = pr.SalesModel_ID
  inner join [sis].[ProductSubfamily] ps on pr.ProductSubfamily_ID = ps.ProductSubfamily_ID
  inner join [sis].[ProductSubfamily_Translation] pst on ps.ProductSubfamily_ID = pst.ProductSubfamily_ID and l.Language_ID = pst.Language_ID
  --inner join [sis].[ProductFamily] pf on pr.ProductFamily_ID = pf.ProductFamily_ID
  inner join [sis].[ProductFamily_Translation] pft on p.ProductFamily_ID = pft.ProductFamily_ID and l.Language_ID = pft.Language_ID
GO

