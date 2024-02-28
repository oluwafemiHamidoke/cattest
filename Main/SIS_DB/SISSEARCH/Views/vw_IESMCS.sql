CREATE VIEW SISSEARCH.vw_IESMCS AS
select e.IE_ID, '["'+string_agg(cast(s.SMCSCOMPCODE as nvarchar(max)), '","')+'"]' as SMCSCodes
from sis.IE e
inner join sis.SMCS_IE_Relation sr on e.IE_ID=sr.IE_ID
inner join sis.SMCS s on s.SMCS_ID=sr.SMCS_ID
GROUP BY e.IE_ID
GO