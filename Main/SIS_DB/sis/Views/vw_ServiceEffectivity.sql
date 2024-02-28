CREATE  VIEW [sis].[vw_ServiceEffectivity] as
WITH CTE AS (
(
	Select  distinct ie.IESystemControlNumber,
              snp.Serial_Number_Prefix, 
              snr.Start_Serial_Number,
			  snr.End_Serial_Number,
              '' as Part_Number,
				info.Is_Structured,
              sm.Sales_Model
       from               
		sis.IE_Effectivity ieeff
       join sis.IE ie on ie.IE_ID = ieeff.IE_ID
       join sis.IE_InfoType_Relation ieinfo on ieinfo.IE_ID = ie.IE_ID
       join sis.InfoType info on info.InfoType_ID = ieinfo.InfoType_ID
       join sis.SerialNumberRange snr on snr.SerialNumberRange_ID = ieeff.SerialNumberRange_ID
       join sis.SerialNumberPrefix snp on snp.SerialNumberPrefix_ID = ieeff.SerialNumberPrefix_ID
       join sis.Product_Relation pr on pr.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID
       join sis.SalesModel sm on pr.SalesModel_ID = sm.SalesModel_ID

union 
select  distinct
		ie.IESystemControlNumber,
		snp.Serial_Number_Prefix, 
		snr.Start_Serial_Number, 
		snr.End_Serial_Number, 
		part.Part_Number,
		info.Is_Structured,
        sm.Sales_Model
	from sis.Part_IE_Effectivity partie
	join sis.IE ie on ie.IE_ID = partie.IE_ID
	join sis.IE_InfoType_Relation ieinfo on ieinfo.IE_ID = ie.IE_ID
	join sis.InfoType info on info.InfoType_ID = ieinfo.InfoType_ID
	join sis.Part part on part.Part_ID = partie.Part_ID
	join sis.SerialNumberRange snr on snr.SerialNumberRange_ID = partie.SerialNumberRange_ID
	join sis.SerialNumberPrefix snp on snp.SerialNumberPrefix_ID = partie.SerialNumberPrefix_ID
    join sis.Product_Relation pr on pr.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID
    join sis.SalesModel sm on pr.SalesModel_ID = sm.SalesModel_ID
)

)
select distinct
	IESystemControlNumber,
	Serial_Number_Prefix, 
	Start_Serial_Number, 
	End_Serial_Number, 
	STRING_AGG(nullif(CAST(Part_Number as VARCHAR(MAX)),''), ',') Within Group (order by Part_Number) Part_Numbers,
    Sales_Model
from CTE
where Is_Structured = 1
group by IESystemControlNumber, Serial_Number_Prefix, Start_Serial_Number, End_Serial_Number,Sales_Model;