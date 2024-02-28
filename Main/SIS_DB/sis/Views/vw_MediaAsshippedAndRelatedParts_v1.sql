CREATE VIEW [sis].[vw_MediaAsshippedAndRelatedParts_v1] as
    WITH CTE AS (
    (
    SELECT MS.IESystemControlNumber as IESYSTEMCONTROLNUMBER,
    ASP.SerialNumberPrefix_ID as SerialNumberPrefix_ID,
    ASP.SerialNumberRange_ID as SerialNumberRange_ID
    from [sis].[AsShippedPart_Level_Relation] ASP
    inner join [sis].[IEPart] IEP on IEP.Part_ID=ASP.Part_ID
    inner join sis.IEPart_IEPart_Relation IER on IEP.IEPart_ID = IER.IEPart_ID
    inner join sis.MediaSection MES on MES.Media_ID=IER.Media_ID
    inner join [sis].[MediaSequence] MS on IER.Related_IEPart_ID=MS.IEPart_ID and MES.MediaSection_ID=MS.MediaSection_ID
    where ASP.PartLevel=0 or ASP.PartLevel=1
    group by MS.IESystemControlNumber,ASP.SerialNumberPrefix_ID,ASP.SerialNumberRange_ID
)
)
select
    IESYSTEMCONTROLNUMBER,SerialNumberPrefix_ID,SerialNumberRange_ID
from CTE
