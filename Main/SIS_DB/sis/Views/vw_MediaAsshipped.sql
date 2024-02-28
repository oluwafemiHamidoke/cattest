CREATE VIEW [sis].[vw_MediaAsshipped] as
    WITH CTE AS (
    (
    SELECT MDS.IESystemControlNumber as IESYSTEMCONTROLNUMBER,
    snp.Serial_Number_Prefix as Serial_Number_Prefix,
    snr.Start_Serial_Number as Start_Serial_Number,
    snr.End_Serial_Number as End_Serial_Number
    FROM [sis].[AsShippedPart_Level_Relation] ASP
    INNER JOIN sis.SerialNumberPrefix snp on snp.SerialNumberPrefix_ID = ASP.SerialNumberPrefix_ID
    INNER JOIN sis.SerialNumberRange snr on snr.SerialNumberRange_ID = ASP.SerialNumberRange_ID
    INNER JOIN sis.IEPart IEP on IEP.Part_ID=ASP.Part_ID
    INNER JOIN sis.MediaSequence MDS on MDS.IEPart_ID=IEP.IEPart_ID
	where ASP.PartLevel=0 or ASP.PartLevel=1
    group by MDS.IESystemControlNumber,snp.Serial_Number_Prefix,snr.Start_Serial_Number,snr.End_Serial_Number
    )
)
select
    IESYSTEMCONTROLNUMBER,Serial_Number_Prefix,Start_Serial_Number,End_Serial_Number
from CTE