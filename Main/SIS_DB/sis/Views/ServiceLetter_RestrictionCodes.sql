Create View sis.ServiceLetter_RestrictionCodes as
SELECT [InfoTypeID]
      ,isnull(m.MKT_ORG_DESC,[OrgCode]) [OrgCode]
  FROM [sis].[ServiceLetter_Type_Codes] c
  Left outer join [SIS_AUTHORING].[MKT_ORG_MAP] m on c.OrgCode = m.SIS_TYPE