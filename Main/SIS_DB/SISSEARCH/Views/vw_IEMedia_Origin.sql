CREATE VIEW SISSEARCH.vw_IEMedia_Origin AS
select e.IE_ID, 
	cast(m.Media_Number as nvarchar(max)) as Media_Number,
	cast(m.PIPPS_Number as nvarchar(max)) as PIPPS_Number
from [SISSEARCH].[vw_BasicServiceIE_Origin] e
	inner join sis.[IE_Effectivity] ef on e.IE_ID=ef.IE_ID
	inner join sis.[Media] m on ef.Media_ID=m.Media_ID
GROUP BY e.IE_ID, m.Media_Number, m.PIPPS_Number
GO