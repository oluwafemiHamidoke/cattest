
Create view sis.[vw_AsShippedPart] as 
Select * From sis.vw_AsShippedPart1 
Union All
Select * From sis.vw_AsShippedPart2
Union All
Select * From sis.vw_AsShippedPart3