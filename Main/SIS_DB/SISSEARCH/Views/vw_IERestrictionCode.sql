CREATE   VIEW SISSEARCH.vw_IERestrictionCode AS
select e.IE_ID, '["'+string_agg(e.Dealer_Code, '","') + '"]' as RestrictionCode
from (
	select distinct a.IE_ID, d.Dealer_Code 
	from sis.IE_Dealer_Relation a 
	inner join sis.Dealer d on a.Dealer_ID=d.Dealer_ID 
) e
GROUP BY e.IE_ID
GO