CREATE VIEW [sis].[vw_AsshippedEngine] as
    WITH CTE AS (
    (
    SELECT shippedEngine.Sequence_Number as Sequence_Number, shippedEngine.Assembly as Assembly,
    shippedEngine.Change_Level_Number as Change_Level_Number, shippedEngine.Indentation as Indentation, shippedEngine.Less_Indicator as Less_Indicator,
    part.Part_ID as Part_ID, part.Part_Number as Part_Number, shippedEngine.Quantity as Quantity,
    snp.Serial_Number_Prefix as Serial_Number_Prefix, snr.Start_Serial_Number as Start_Serial_Number, pt.Part_Name as Part_Name,pt.Language_ID as Language_ID,
    snr.End_Serial_Number as End_Serial_Number
    FROM sis.AsShippedEngine shippedEngine
    INNER JOIN sis.SerialNumberPrefix snp ON shippedEngine.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID
    INNER JOIN sis.SerialNumberRange snr ON shippedEngine.SerialNumberRange_ID = snr.SerialNumberRange_ID
    INNER JOIN sis.Part part ON shippedEngine.Part_ID = part.Part_ID
    LEFT JOIN sis.Part_Translation pt ON part.Part_ID = pt.Part_ID
    UNION
    SELECT pasr.Sequence_Number as Sequence_Number, pasr.Assembly as Assembly,
    pasr.Change_Level_Number as Change_Level_Number,pasr.Indentation as Indentation, pasr.Less_Indicator as Less_Indicator,
    part.Part_ID as Part_ID,part.Part_Number as Part_Number, shippedEngine.Quantity as Quantity,
    snp.Serial_Number_Prefix as Serial_Number_Prefix,snr.Start_Serial_Number as Start_Serial_Number, pt.Part_Name as Part_Name,pt.Language_ID as Language_ID,
    snr.End_Serial_Number as End_Serial_Number
    FROM sis.AsShippedEngine shippedEngine
    INNER JOIN sis.SerialNumberPrefix snp ON shippedEngine.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID
    INNER JOIN sis.SerialNumberRange snr ON shippedEngine.SerialNumberRange_ID = snr.SerialNumberRange_ID
    INNER JOIN [sis].[Part_AsShippedEngine_Relation] pasr
    on pasr.AsShippedEngine_ID = shippedEngine.AsShippedEngine_ID
    INNER JOIN sis.Part part with (forceseek, index([PK_Part])) ON part.Part_ID = pasr.Part_ID
    LEFT JOIN sis.Part_Translation pt ON part.Part_ID = pt.Part_ID
)
)
select Sequence_Number, Assembly, Change_Level_Number, Indentation, Less_Indicator, Part_ID,
       Part_Number, Quantity, Serial_Number_Prefix, Start_Serial_Number, End_Serial_Number, Part_Name,Language_ID
from CTE group by Sequence_Number, Assembly, Change_Level_Number, Indentation, Less_Indicator, Part_ID,
                  Part_Number, Quantity, Serial_Number_Prefix, Start_Serial_Number, End_Serial_Number,Part_Name,Language_ID
