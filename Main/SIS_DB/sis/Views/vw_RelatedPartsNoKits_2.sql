Create View sis.vw_RelatedPartsNoKits_2 as
 SELECT b.Part_Number
      ,a.Type_Indicator
      ,c.Part_Number as Related_Part_Number
      ,d.Part_Name as Related_Part_Name
	  ,e.Language_Tag
      ,a.LastModified_Date
  FROM sis.Related_Part_Relation a
  inner join sis.Part b on a.Part_ID = b.Part_ID
  inner join sis.Part c on a.Related_Part_ID = c.Part_ID and b.Org_Code = c.Org_Code and c.Org_Code = 'CAT'
  inner join sis.Part_Translation d on c.Part_ID = d.Part_ID
  inner join sis.Language e on d.Language_ID = e.Language_ID
  WHERE a.Type_Indicator not in ('E', 'K')