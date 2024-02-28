
create View sis.[vw_MediaSeq] as
select ms.IESystemControlNumber,
       m.Media_Number,
       ms.Arrangement_Indicator,
       ms_t.Caption,
       ms_t.Modifier,
       ms.NPR_Indicator,
       ms.Serviceability_Indicator,
       ms.TypeChange_Indicator,
       ms.IEPart_ID,
       snr.Start_Serial_Number,
       snr.End_Serial_Number,
       snp.Serial_Number_Prefix
from sis.MediaSequence ms
         inner join sis.MediaSequence_Effectivity ms_e on ms_e.MediaSequence_ID = ms.MediaSequence_ID
         inner join sis.SerialNumberPrefix snp on snp.SerialNumberPrefix_ID = ms_e.SerialNumberPrefix_ID
         inner join sis.SerialNumberRange snr on snr.SerialNumberRange_ID = ms_e.SerialNumberRange_ID
         inner join sis.MediaSection msec on msec.MediaSection_ID = ms.MediaSection_ID
         inner join sis.Media m on m.Media_ID = msec.Media_ID
         inner join sis.MediaSequence_Translation ms_t on ms_t.MediaSequence_ID = ms.MediaSequence_ID