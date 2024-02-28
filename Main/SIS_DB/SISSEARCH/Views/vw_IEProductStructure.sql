
CREATE   VIEW SISSEARCH.vw_IEProductStructure AS
select x.IE_ID, '['+string_agg(cast(x.ProductStructure_ID as nvarchar(max)), ',')+']' as ProductStructureSystemIDs
from (
	select distinct e.IE_ID, p.ProductStructure_ID 
	from sis.IE e
		inner join sis.ProductStructure_IE_Relation pr on e.IE_ID=pr.IE_ID
		inner join sis.ProductStructure p on p.ProductStructure_ID=pr.ProductStructure_ID
) x
GROUP BY x.IE_ID
GO