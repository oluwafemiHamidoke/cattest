CREATE VIEW sis.vw_IEPart_SNP_TopLevel
AS
	select distinct pir.ProductStructure_ID, CASE WHEN consist.Part_ID is NULL  THEN 1 ELSE 0 END isTopLevel ,m.Media_Number ,
	mseq.IESystemControlNumber, p.Part_Number,p.Org_Code,pt.Part_Name, mseq.Sequence_Number, mseqt.Modifier,mseqt.Caption, snp.Serial_Number_Prefix
	from sis.ProductStructure_IEPart_Relation pir
	inner join sis.SerialNumberPrefix snp on snp.SerialNumberPrefix_ID = pir.SerialNumberPrefix_ID
	inner join sis.Media m on m.Media_ID = pir.Media_ID
	inner join sis.MediaSection msec on msec.Media_ID = m.Media_ID
	inner join sis.MediaSequence mseq on mseq.MediaSection_ID = msec.MediaSection_ID
	inner join sis.MediaSequence_Translation mseqt on mseqt.MediaSequence_ID = mseq.MediaSequence_ID and mseq.IEPart_ID = pir.IEPart_ID 
	inner join sis.IEPart iep on iep.IEPart_ID = pir.IEPart_ID
	inner join sis.Part p on p.Part_ID = iep.Part_ID
	inner join sis.Part_Translation pt on p.Part_ID = pt.Part_ID and mseqt.Language_ID = pt.Language_ID
	left join (
		select pir.SerialNumberPrefix_ID, ier.Part_ID, pir.Media_ID from sis.ProductStructure_IEPart_Relation pir
		inner join  sis.Part_IEPart_Relation ier
		on pir.IEPart_ID = ier.IEPart_ID 
	) consist
		on consist.Media_ID = m.Media_ID 
		and consist.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID
		and p.Part_ID = consist.Part_ID

	union all

	select distinct pir.PSID, CASE WHEN con.Part_ID is NULL  THEN 1 ELSE 0 END isTopLevel, m.Media_Number ,mseq.IESystemControlNumber, 
	p.Part_Number,p.Org_Code,pt.Part_Name, mseq.Sequence_Number, mseqt.Modifier,mseqt.Caption, inst.SNP
	from SISWEB_OWNER.LNKIEPSID pir
	inner join sis.Media m on m.Media_Number = pir.MEDIANUMBER
	inner join sis.MediaSection msec on msec.Media_ID = m.Media_ID
	inner join sis.MediaSequence mseq on mseq.MediaSection_ID = msec.MediaSection_ID and mseq.IESystemControlNumber = pir.IESYSTEMCONTROLNUMBER
	inner join sis.MediaSequence_Translation mseqt on mseqt.MediaSequence_ID = mseq.MediaSequence_ID
	inner join sis.IEPart iep on iep.IEPart_ID = mseq.IEPart_ID
	inner join sis.Part p on p.Part_ID = iep.Part_ID
	inner join sis.Part_Translation pt on p.Part_ID = pt.Part_ID and mseqt.Language_ID = pt.Language_ID
	inner JOIN  SISWEB_OWNER.LNKIEPRODUCTINSTANCE ieprodinst on mseq.IESystemControlNumber = ieprodinst.IESYSTEMCONTROLNUMBER and m.Media_Number = ieprodinst.MEDIANUMBER
	inner join SISWEB_OWNER.EMPPRODUCTINSTANCE inst on ieprodinst.EMPPRODUCTINSTANCE_ID = inst.EMPPRODUCTINSTANCE_ID
	inner join sis.SerialNumberPrefix snp on snp.Serial_Number_Prefix = inst.SNP
	left outer join (
		select psid1.MEDIANUMBER,inst1.SNP,pier1.Part_ID,PSID from sis.MediaSequence mseq1
		INNER JOIN sis.Part_IEPart_Relation pier1 on pier1.IEPart_ID = mseq1.IEPart_ID
		INNER JOIN SISWEB_OWNER.LNKIEPSID psid1 on psid1.IESYSTEMCONTROLNUMBER = mseq1.IESystemControlNumber
		INNER JOIN SISWEB_OWNER.LNKIEPRODUCTINSTANCE ieprodinst1 on mseq1.IESystemControlNumber = ieprodinst1.IESYSTEMCONTROLNUMBER and psid1.MEDIANUMBER = ieprodinst1.MEDIANUMBER
		inner join SISWEB_OWNER_SHADOW.EMPPRODUCTINSTANCE inst1 on ieprodinst1.EMPPRODUCTINSTANCE_ID = inst1.EMPPRODUCTINSTANCE_ID
	
	) con
		on con.MEDIANUMBER = m.Media_Number
		and con.SNP = snp.Serial_Number_Prefix
		and con.Part_ID = p.Part_ID
		and con.PSID = pir.PSID
GO