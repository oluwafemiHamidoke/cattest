CREATE VIEW [sis].[vw_MediaAsshipped_v1] as
    WITH CTE AS (
    (
    SELECT MDS.IESystemControlNumber as IESYSTEMCONTROLNUMBER,
    ASP.SerialNumberPrefix_ID as SerialNumberPrefix_ID,
    ASP.SerialNumberRange_ID as SerialNumberRange_ID
    FROM [sis].[AsShippedPart_Level_Relation] ASP
    INNER JOIN sis.IEPart IEP on IEP.Part_ID=ASP.Part_ID
    INNER JOIN sis.MediaSequence MDS on MDS.IEPart_ID=IEP.IEPart_ID
    where ASP.PartLevel=0 or ASP.PartLevel=1
    group by MDS.IESystemControlNumber,ASP.SerialNumberPrefix_ID,ASP.SerialNumberRange_ID
)
)
select
    IESYSTEMCONTROLNUMBER,SerialNumberPrefix_ID,SerialNumberRange_ID
from CTE