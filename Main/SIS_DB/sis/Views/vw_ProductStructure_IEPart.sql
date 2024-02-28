CREATE VIEW [sis].[vw_ProductStructure_IEPart]
AS
(
SELECT [ProductStructure_ID]
      ,[IEPart_ID]
      ,[Media_ID]
      ,[Parentage]
      ,[ParentProductStructure_ID]
  FROM [sis].[ProductStructure_IEPart]
)