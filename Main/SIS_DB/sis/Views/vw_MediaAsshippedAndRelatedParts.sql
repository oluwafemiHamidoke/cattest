CREATE VIEW [sis].[vw_MediaAsshippedAndRelatedParts] as
    WITH CTE AS (
    (
    SELECT MS.IESystemControlNumber as IESYSTEMCONTROLNUMBER,
    SP.Serial_Number_Prefix as Serial_Number_Prefix,
    SR.Start_Serial_Number as Start_Serial_Number,
    SR.End_Serial_Number as End_Serial_Number
    from [sis].[AsShippedPart_Level_Relation] ASP
    inner join sis.SerialNumberPrefix SP on ASP.SerialNumberPrefix_ID = SP.SerialNumberPrefix_ID
    inner join sis.SerialNumberRange SR on ASP.SerialNumberRange_ID = SR.SerialNumberRange_ID
    inner join [sis].[IEPart] IEP on IEP.Part_ID=ASP.Part_ID
    inner join sis.IEPart_IEPart_Relation IER on IEP.IEPart_ID = IER.IEPart_ID
    inner join sis.MediaSection MES on MES.Media_ID=IER.Media_ID
    inner join [sis].[MediaSequence] MS on IER.Related_IEPart_ID=MS.IEPart_ID and MES.MediaSection_ID=MS.MediaSection_ID
    where ASP.PartLevel=0 or ASP.PartLevel=1
    group by MS.IESystemControlNumber,SP.Serial_Number_Prefix,SR.Start_Serial_Number,SR.End_Serial_Number
)
)
select
    IESYSTEMCONTROLNUMBER,Serial_Number_Prefix,Start_Serial_Number,End_Serial_Number
from CTE