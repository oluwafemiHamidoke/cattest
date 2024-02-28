CREATE PROCEDURE [sis_stage].[AsShipped_Load]
--(
--    -- Add the parameters for the stored procedure here
--    <@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>,
--    <@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
-- removed part_translation data insert
--)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

BEGIN TRY

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
		@ProcessID uniqueidentifier = NewID(),
        @DEFAULT_ORGCODE VARCHAR(12) = SISWEB_OWNER_STAGING._getDefaultORGCODE();


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;


/*
Load AsShippedEngine & AsShippedPart
AsShippedEngine unique key is at Part + Effectivity
AsShippedPart key is at Part
*/

--Engine
/*
Insert into [sis_stage].AsShippedEngine ([Part_ID],[SerialNumberPrefix_ID],[SerialNumberRange_ID],[Quantity],[Sequence_Number],[Change_Level_Number],[Assembly],[Less_Indicator],[Indentation])
Select p.Part_ID, snp.SerialNumberPrefix_ID, snr.SerialNumberRange_ID, max(e.QUANTITY) Quantity, e.PARTSEQUENCENUMBER, max(e.ENGGCHANGELEVELNO), max(e.[ASSEMBLY]), max(e.LESSINDICATOR), max(e.INDENTATION)
From [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE] e
Inner join [sis_stage].Part p on p.Part_Number = e.PARTNUMBER and p.Org_Code = @DEFAULT_ORGCODE
inner join [sis_stage].SerialNumberPrefix snp on snp.Serial_Number_Prefix = cast(left(e.SERIALNUMBER, 3) as varchar(3))
inner join [sis_stage].SerialNumberRange snr on 
	snr.Start_Serial_Number = e.SNR and 
	snr.End_Serial_Number = e.SNR
Where e.ParentID is null and  --There are only 2 levels.  Level 0 is the parent part.
e.isValidSerialNumber is null and 
e.isValidPartNumber is null
Group by p.Part_ID, snp.SerialNumberPrefix_ID, snr.SerialNumberRange_ID, e.PARTSEQUENCENUMBER --Verify grain


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'AsShippedEngine', @DATAVALUE = @@RowCount;

--Insert natural keys into key table
Insert into [sis_stage].[AsShippedEngine_Key] (Part_ID, SerialNumberPrefix_ID, SerialNumberRange_ID, Sequence_Number)
Select s.Part_ID, s.SerialNumberPrefix_ID, s.SerialNumberRange_ID, s.Sequence_Number
From [sis_stage].[AsShippedEngine] s
Left outer join [sis_stage].[AsShippedEngine_Key] k on s.Part_ID = k.Part_ID and s.SerialNumberPrefix_ID = k.SerialNumberPrefix_ID and s.SerialNumberRange_ID = k.SerialNumberRange_ID and s.Sequence_Number = k.Sequence_Number
Where k.AsShippedEngine_ID is null

--Key table load

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'AsShippedEngine Key Load', @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set AsShippedEngine_ID = k.AsShippedEngine_ID
From [sis_stage].[AsShippedEngine] s
inner join [sis_stage].[AsShippedEngine_Key] k on s.Part_ID = k.Part_ID and s.SerialNumberPrefix_ID = k.SerialNumberPrefix_ID and s.SerialNumberRange_ID = k.SerialNumberRange_ID and s.Sequence_Number = k.Sequence_Number
where s.AsShippedEngine_ID is null

--Surrogate Update

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'AsShippedEngine Update Surrogate', @DATAVALUE = @@RowCount;
*/
/*--============================================================ AsShippedPart Load ==========================================================================================='

--Level 1 Machine
Insert into [sis_stage].AsShippedPart (Part_ID)
Select Distinct p.Part_ID
From [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS] m --Parent part
Inner join [sis_stage].Part p on p.Part_Number = m.PARTNUMBER and p.Org_Code = @DEFAULT_ORGCODE
Where m.PARENTPARTNUMBER is null --Root.  All root parts should be loaded.  Using ParentPartNumber instead of ParentID because source has ParentPartNumbers that point to non-existing part numbers.
and (m.isValidPartNumber is null or m.isValidPartNumber = '0')
and m.isValidSerialNumber is null


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'AsShippedPart Machine Level 1', @DATAVALUE = @@RowCount;

--Level 2 Machine
Insert into [sis_stage].AsShippedPart (Part_ID)
Select Distinct p.Part_ID
From [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS] m --Parent part
Inner join [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] mc on m.ID_Int = mc.ParentID --Only include if there is a child part
Inner join [sis_stage].Part p on p.Part_Number = m.PARTNUMBER and p.Org_Code = @DEFAULT_ORGCODE
Where m.PARENTPARTNUMBER is not null --Not root
and (m.isValidPartNumber is null or m.isValidPartNumber = '0')
and m.isValidSerialNumber is null
Except --Not already loaded
Select Part_ID from [sis_stage].AsShippedPart


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'AsShippedPart Machine Level 2', @DATAVALUE = @@RowCount;

--Level 3 Machine
Insert into [sis_stage].AsShippedPart (Part_ID)
Select Distinct p.Part_ID
From [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] m --Parent part
Inner join [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3] mc on m.ID_Int = mc.ParentID --Only include if there is a child part
Inner join [sis_stage].Part p on p.Part_Number = m.PARTNUMBER and p.Org_Code = @DEFAULT_ORGCODE
Where
m.isValidPartNumber is null 
and m.isValidSerialNumber is null
Except --Not already loaded.
Select Part_ID from [sis_stage].AsShippedPart


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'AsShippedPart Machine Level 3', @DATAVALUE = @@RowCount;

--Insert natural keys into key table
Insert into [sis_stage].[AsShippedPart_Key] (Part_ID)
Select s.Part_ID
From [sis_stage].[AsShippedPart] s
Left outer join [sis_stage].[AsShippedPart_Key] k on s.Part_ID = k.Part_ID
Where k.AsShippedPart_ID is null

--Key table load

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'AsShippedPart Key Load', @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set AsShippedPart_ID = k.AsShippedPart_ID
From [sis_stage].[AsShippedPart] s
inner join [sis_stage].[AsShippedPart_Key] k on s.Part_ID = k.Part_ID
where s.AsShippedPart_ID is null

--Surrogate Update

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'AsShippedPart Update Surrogate', @DATAVALUE = @@RowCount;

--============================================================ AsShippedPart Level Relation Load ===========================================================================================

--Level 1 Machine

Insert into [sis_stage].[AsShippedPart_Level_Relation] (PartSequenceNumber,SerialNumberPrefix_ID,
                                                  SerialNumberRange_ID,PartNumber,Part_ID,ParentPartNumber,
                                                  AttachmentSerialNumber,PartOrder,PartLevel,PartType)
Select Distinct PARTSEQUENCENUMBER, SerialNumberPrefix_ID, SerialNumberRange_ID , PARTNUMBER, Part_ID, PARENTPARTNUMBER,ATTACHMENTSERIALNUMBER
              ,PARTORDER,PartLevel, PARTTYPE
From
    (
        Select DISTINCT e.PARTSEQUENCENUMBER,snp.SerialNumberPrefix_ID, snr.SerialNumberRange_ID,e.PARTNUMBER,cp.Part_ID,e.PARENTPARTNUMBER, e.ATTACHMENTSERIALNUMBER,
                        e.PARTORDER, case when e.PARENTPARTNUMBER is null then 0 else 1 end PartLevel, e.PARTTYPE, ROW_NUMBER() Over (Partition By e.SERIALNUMBER, e.PARTSEQUENCENUMBER Order by e.[EMDPROCESSEDDATE] desc) RowRank
        From [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS] e
            Inner join [sis_stage].SerialNumberPrefix snp on snp.Serial_Number_Prefix= e.SNP
            Inner join [sis_stage].SerialNumberRange snr on
            snr.Start_Serial_Number = e.SNR and
            snr.End_Serial_Number = e.SNR
            Inner join [sis_stage].Part cp on cp.Part_Number = e.PARTNUMBER  and cp.Org_Code = @DEFAULT_ORGCODE
    ) x
Where RowRank = 1


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'AsShippedPart Level Relation For Machine Level 1', @DATAVALUE = @@RowCount;

--Level 2 Machine
Insert into [sis_stage].[AsShippedPart_Level_Relation] (PartSequenceNumber,SerialNumberPrefix_ID,
                                                  SerialNumberRange_ID,PartNumber,Part_ID,ParentPartNumber,
                                                  AttachmentSerialNumber,PartOrder,PartLevel,PartType)
Select Distinct PARTSEQUENCENUMBER, SerialNumberPrefix_ID, SerialNumberRange_ID , PARTNUMBER, Part_ID, PARENTPARTNUMBER,ATTACHMENTSERIALNUMBER
              ,PARTORDER,2 PartLevel, PARTTYPE
From
    (
        Select DISTINCT e.PARTSEQUENCENUMBER,snp.SerialNumberPrefix_ID, snr.SerialNumberRange_ID,e.PARTNUMBER,cp.Part_ID,e.PARENTPARTNUMBER, e.ATTACHMENTSERIALNUMBER,
                        e.PARTORDER, 2 PartLevel, e.PARTTYPE, ROW_NUMBER() Over (Partition By e.SERIALNUMBER, e.PARTSEQUENCENUMBER Order by e.[EMDPROCESSEDDATE] desc) RowRank
        From [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] e
            Inner join [sis_stage].SerialNumberPrefix snp on snp.Serial_Number_Prefix= e.SNP
            Inner join [sis_stage].SerialNumberRange snr on
            snr.Start_Serial_Number = e.SNR and
            snr.End_Serial_Number = e.SNR
            Inner join [sis_stage].Part cp on cp.Part_Number = e.PARTNUMBER  and cp.Org_Code = @DEFAULT_ORGCODE and e.PARTORDER is not NULL
    ) x
Where RowRank = 1


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'AsShippedPart Level Relation For Machine Level 2', @DATAVALUE = @@RowCount;

--Level 3 Machine
Insert into [sis_stage].[AsShippedPart_Level_Relation] (PartSequenceNumber,SerialNumberPrefix_ID,
                                                  SerialNumberRange_ID,PartNumber,Part_ID,ParentPartNumber,
                                                  AttachmentSerialNumber,PartOrder,PartLevel,PartType)
Select Distinct PARTSEQUENCENUMBER, SerialNumberPrefix_ID, SerialNumberRange_ID , PARTNUMBER, Part_ID, PARENTPARTNUMBER,ATTACHMENTSERIALNUMBER
              ,PARTORDER,PartLevel, PARTTYPE
From
    (
        Select DISTINCT e.PARTSEQUENCENUMBER,snp.SerialNumberPrefix_ID, snr.SerialNumberRange_ID,e.PARTNUMBER,cp.Part_ID,e.PARENTPARTNUMBER, e.ATTACHMENTSERIALNUMBER,
                        e.PARTORDER, 3 PartLevel, e.PARTTYPE, ROW_NUMBER() Over (Partition By e.SERIALNUMBER, e.PARTSEQUENCENUMBER Order by e.[EMDPROCESSEDDATE] desc) RowRank
        From [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3] e
            Inner join [sis_stage].SerialNumberPrefix snp on snp.Serial_Number_Prefix= e.SNP
            Inner join [sis_stage].SerialNumberRange snr on
            snr.Start_Serial_Number = e.SNR and
            snr.End_Serial_Number = e.SNR
            Inner join [sis_stage].Part cp on cp.Part_Number = e.PARTNUMBER  and cp.Org_Code = @DEFAULT_ORGCODE and e.PARTORDER is not NULL
    ) x
Where RowRank = 1



EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'AsShippedPart Level Relation For Machine Level 3', @DATAVALUE = @@RowCount;
*/
--============================================================ Part AsShippedEngine Relation Load ==========================================================================================='

/*
Load Part_AsShippedEngine_Relation - Load all child parts associated with AsShippedEngine parts
Load Part_AsShippedPart_Relation --For each AsShippedPart load all part by unioning the results of all AsShippedPart versions
*/

--Engine
/*
Insert into [sis_stage].[Part_AsShippedEngine_Relation] ([AsShippedEngine_ID], [Part_ID], [Quantity], [Sequence_Number], [Change_Level_Number], [Assembly], [Less_Indicator], [Indentation] )
Select e.AsShippedEngine_ID, cp.Part_ID, max(c.QUANTITY) Quantity, c.PARTSEQUENCENUMBER, max(c.ENGGCHANGELEVELNO), max(c.[ASSEMBLY]), max(c.LESSINDICATOR), max(c.INDENTATION)
From [sis_stage].AsShippedEngine e --All engine group parts
Inner join [sis_stage].SerialNumberPrefix snp on snp.SerialNumberPrefix_ID = e.SerialNumberPrefix_ID
Inner join [sis_stage].SerialNumberRange snr on snr.SerialNumberRange_ID = e.SerialNumberRange_ID
Inner join [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE] p on --Parent
	p.PARTSEQUENCENUMBER = e.[Sequence_Number] and 
	p.SNP = snp.Serial_Number_Prefix and 
	p.SNR = snr.Start_Serial_Number --Start and End are always the same for AsShipped
Inner join  [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE] c on c.ParentID = p.ID --Child
-- Two addtional join conditions for https://sis-cat-com.visualstudio.com/sis2-ui/_workitems/edit/25520
and c.SNP = snp.Serial_Number_Prefix and 
	c.SNR = snr.Start_Serial_Number --Start and End are always the same for AsShipped
Inner join [sis_stage].Part cp on cp.Part_Number = c.PARTNUMBER  and cp.Org_Code = @DEFAULT_ORGCODE--Child Part ID
where c.isValidPartNumber is null and c.isValidSerialNumber is null
Group by e.AsShippedEngine_ID, cp.Part_ID, c.PARTSEQUENCENUMBER --Verify grain


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_AsShippedPart Engine', @DATAVALUE = @@RowCount;

--Insert natural keys into key table
Insert into [sis_stage].[Part_AsShippedEngine_Relation_Key] (AsShippedEngine_ID, Part_ID, Sequence_Number)
Select s.AsShippedEngine_ID, s.Part_ID, s.Sequence_Number
From [sis_stage].[Part_AsShippedEngine_Relation] s
Left outer join [sis_stage].[Part_AsShippedEngine_Relation_Key] k on s.AsShippedEngine_ID = k.AsShippedEngine_ID and s.Part_ID = k.Part_ID and s.Sequence_Number = k.Sequence_Number
Where k.Part_AsShippedEngine_Relation_ID is null

--Key table load

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_AsShippedEngine_Relation Key Load', @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set Part_AsShippedEngine_Relation_ID = k.Part_AsShippedEngine_Relation_ID
From [sis_stage].[Part_AsShippedEngine_Relation] s
inner join [sis_stage].[Part_AsShippedEngine_Relation_Key] k on s.AsShippedEngine_ID = k.AsShippedEngine_ID and s.Part_ID = k.Part_ID and s.Sequence_Number = k.Sequence_Number
where s.Part_AsShippedEngine_Relation_ID is null

--Surrogate Update

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_AsShippedEngine_Relation Update Surrogate', @DATAVALUE = @@RowCount;
*/
/*--Level 1 Machine
Insert into [sis_stage].Part_AsShippedPart_Relation (Part_ID, AsShippedPart_ID, Quantity, Sequence_Number)
Select cp.Part_ID, m.AsShippedPart_ID, 1 Quantity, max(c.PARTSEQUENCENUMBER) PartSequenceNumber
From [sis_stage].AsShippedPart m --All machine group parts
Inner join [sis_stage].Part mp on mp.Part_ID = m.Part_ID
Inner join [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS] c on c.PARENTPARTNUMBER = mp.Part_Number and mp.Org_Code = @DEFAULT_ORGCODE --Child for the parent part across all serial numbers
Inner join [sis_stage].Part cp on cp.Part_Number = c.PARTNUMBER and cp.Org_Code = @DEFAULT_ORGCODE --Child part
where (c.isValidPartNumber is null or c.isValidPartNumber = '0') and c.isValidSerialNumber is null
Group by cp.Part_ID, m.AsShippedPart_ID --Verify grain


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_AsShippedPart Machine Level 1', @DATAVALUE = @@RowCount;

--Level 2 Machine
Insert into [sis_stage].Part_AsShippedPart_Relation (Part_ID, AsShippedPart_ID, Quantity, Sequence_Number)
Select cp.Part_ID, m.AsShippedPart_ID, 1 Quantity, max(c.PARTSEQUENCENUMBER) PartSequenceNumber
From [sis_stage].AsShippedPart m --All machine group parts
Inner join [sis_stage].Part mp on mp.Part_ID = m.Part_ID
Inner join [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] c on c.ParentPartNumberShort = mp.Part_Number and mp.Org_Code = @DEFAULT_ORGCODE
Inner join [sis_stage].Part cp on cp.Part_Number = c.PARTNUMBER and cp.Org_Code = @DEFAULT_ORGCODE --Child part
Left outer join [sis_stage].Part_AsShippedPart_Relation pr on pr.AsShippedPart_ID = m.AsShippedPart_ID and pr.Part_ID = cp.Part_ID
Where pr.Part_ID is null --Not already loaded into relation table
and c.isValidPartNumber is null and c.isValidSerialNumber is null
Group by cp.Part_ID, m.AsShippedPart_ID --Verify grain



EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_AsShippedPart Machine Level 2', @DATAVALUE = @@RowCount;

--Level 3 Machine
Insert into [sis_stage].Part_AsShippedPart_Relation (Part_ID, AsShippedPart_ID, Quantity, Sequence_Number)
Select cp.Part_ID, m.AsShippedPart_ID, 1 Quantity, max(c.PARTSEQUENCENUMBER) PartSequenceNumber
From [sis_stage].AsShippedPart m --All machine group parts
Inner join [sis_stage].Part mp on mp.Part_ID = m.Part_ID
Inner join [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3] c on c.ParentPartNumberShort = mp.Part_Number and mp.Org_Code = @DEFAULT_ORGCODE
Inner join [sis_stage].Part cp on cp.Part_Number = c.PARTNUMBER and cp.Org_Code = @DEFAULT_ORGCODE --Child part
Left outer join [sis_stage].Part_AsShippedPart_Relation pr on pr.AsShippedPart_ID = m.AsShippedPart_ID and pr.Part_ID = cp.Part_ID
Where pr.Part_ID is null --Not already loaded into relation table
and c.isValidPartNumber is null and c.isValidSerialNumber is null
Group by cp.Part_ID, m.AsShippedPart_ID --Verify grain


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_AsShippedPart Machine Level 3', @DATAVALUE = @@RowCount;


--Insert natural keys into key table
Insert into [sis_stage].[Part_AsShippedPart_Relation_Key] (Part_ID, AsShippedPart_ID)
Select s.Part_ID, s.AsShippedPart_ID
From [sis_stage].[Part_AsShippedPart_Relation] s
Left outer join [sis_stage].[Part_AsShippedPart_Relation_Key] k on s.Part_ID = k.Part_ID and s.AsShippedPart_ID = k.AsShippedPart_ID
Where k.Part_AsShippedPart_Relation_ID is null

--Key table load

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_AsShippedPart_Relation Key Load', @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set Part_AsShippedPart_Relation_ID = k.Part_AsShippedPart_Relation_ID
From [sis_stage].[Part_AsShippedPart_Relation] s
inner join [sis_stage].[Part_AsShippedPart_Relation_Key] k on s.Part_ID = k.Part_ID and s.AsShippedPart_ID = k.AsShippedPart_ID
where s.Part_AsShippedPart_Relation_ID is null

--Surrogate Update

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_AsShippedPart_Relation Update Surrogate', @DATAVALUE = @@RowCount;
*/

--/*
--Next the Part Translation table can be updated.  
--There are potentially many versions of the same part name.
--Select the last version using available dates.  Resolve anbiquitity with rank.
--*/

--Engine
--Insert into [sis_stage].[Part_Translation] ([Part_ID], Language_ID, Part_Name)
--Select Distinct Part_ID, Language_ID, PARTNAME
--From 
--	(
--	Select p.Part_ID, l.Language_ID, e.PARTNAME, ROW_NUMBER() Over (Partition By p.Part_Number, p.Org_Code Order by e.INDENTATION asc, len(PARTNAME) desc) RowRank
--	From [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE] e
--	Inner join [sis_stage].Part p on p.Part_Number = e.PARTNUMBER and p.Org_Code = @DEFAULT_ORGCODE
--	Inner join [sis_stage].Language l on l.Language_Tag = 'en-US'
--	Inner join [sis_stage].Part_Translation pt on pt.Language_ID = l.Language_ID and pt.Part_ID = p.Part_ID
--	Where 
--	pt.Part_Name is null or ltrim(rtrim(pt.Part_Name)) = ''--Only load the part name if it does not already exist.  As Shipped should not overwrite the IE related load.
--	and e.isValidPartNumber is null and e.isValidSerialNumber is null
--	) x
--Where RowRank = 1 --Limit to one version of en-US part name


--EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_Translation Engine', @DATAVALUE = @@RowCount;

----Level 1 & 2 Machine
--Insert into [sis_stage].[Part_Translation] ([Part_ID], Language_ID, Part_Name)
--Select Distinct Part_ID, Language_ID, PARTNAME
--From 
--	(
--	Select p.Part_ID, l.Language_ID, e.PARTNAME, ROW_NUMBER() Over (Partition By p.Part_Number, p.Org_Code Order by e.[EMDPROCESSEDDATE] desc, case when e.[PARENTPARTNUMBER] is null then 0 else 1 end asc, len(PARTNAME) desc, e.ID desc) RowRank
--	From [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS] e
--	Inner join [sis_stage].Part p on p.Part_Number = e.PARTNUMBER and p.Org_Code = @DEFAULT_ORGCODE
--	Inner join [sis_stage].Language l on l.Language_Tag = 'en-US'
--	Inner join [sis_stage].Part_Translation pt on pt.Language_ID = l.Language_ID and pt.Part_ID = p.Part_ID
--	Where 
--	pt.Part_Name is null or ltrim(rtrim(pt.Part_Name)) = ''--Only load the part name if it does not already exist.  As Shipped should not overwrite the IE related load.
--	and (e.isValidPartNumber is null or e.isValidPartNumber = '0') and e.isValidSerialNumber is null
--	) x
--Where RowRank = 1 --Limit to one version of en-US part name


--EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_Translation Machine Level 1 and 2', @DATAVALUE = @@RowCount;

----Level 3 Machine
--Insert into [sis_stage].[Part_Translation] ([Part_ID], Language_ID, Part_Name)
--Select Distinct Part_ID, Language_ID, PARTNAME
--From 
--	(
--	Select p.Part_ID, l.Language_ID, e.PARTNAME, ROW_NUMBER() Over (Partition By p.Part_Number, p.Org_Code Order by e.[EMDPROCESSEDDATE] desc, len(PARTNAME) desc, e.ID desc) RowRank
--	From [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] e
--	Inner join [sis_stage].Part p on p.Part_Number = e.PARTNUMBER and p.Org_Code = @DEFAULT_ORGCODE
--	Inner join [sis_stage].Language l on l.Language_Tag = 'en-US'
--	Inner join [sis_stage].Part_Translation pt on pt.Language_ID = l.Language_ID and pt.Part_ID = p.Part_ID
--	Where 
--	pt.Part_Name is null or ltrim(rtrim(pt.Part_Name)) = ''--Only load the part name if it does not already exist.  As Shipped should not overwrite the IE related load.
--	and e.isValidPartNumber is null and e.isValidSerialNumber is null
--	) x
--Where RowRank = 1 --Limit to one version of en-US part name


--EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_Translation Machine Level 3', @DATAVALUE = @@RowCount;

----Level 4 Machine
--Insert into [sis_stage].[Part_Translation] ([Part_ID], Language_ID, Part_Name)
--Select Distinct Part_ID, Language_ID, PARTNAME
--From 
--	(
--	Select p.Part_ID, l.Language_ID, e.PARTNAME, ROW_NUMBER() Over (Partition By p.Part_Number, p.Org_Code Order by e.[EMDPROCESSEDDATE] desc, len(PARTNAME) desc, e.ID desc) RowRank
--	From [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3] e
--	Inner join [sis_stage].Part p on p.Part_Number = e.PARTNUMBER and p.Org_Code = @DEFAULT_ORGCODE
--	Inner join [sis_stage].Language l on l.Language_Tag = 'en-US'
--	Inner join [sis_stage].Part_Translation pt on pt.Language_ID = l.Language_ID and pt.Part_ID = p.Part_ID
--	Where 
--	pt.Part_Name is null or ltrim(rtrim(pt.Part_Name)) = ''--Only load the part name if it does not already exist.  As Shipped should not overwrite the IE related load.
--	and e.isValidPartNumber is null and e.isValidSerialNumber is null
--	) x
--Where RowRank = 1 --Limit to one version of en-US part name


--EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_Translation Machine Level 4', @DATAVALUE = @@RowCount;


/*
Next we need to load the AsShipped Effectivity Table.
This is the effectivity for each AsShipped part.  Each part can be associated with many effectivity records.
Engine effectivity is stored in AsShippedEngine directly.
*/

--Machine Level 1
--15 min
/*Insert into [sis_stage].[AsShippedPart_Effectivity] ([AsShippedPart_ID], [SerialNumberPrefix_ID], [SerialNumberRange_ID])
Select Distinct asp.AsShippedPart_ID, snp.SerialNumberPrefix_ID, snr.SerialNumberRange_ID
From [sis_stage].AsShippedPart asp
Inner join [sis_stage].Part p on p.Part_ID = asp.Part_ID
Inner join [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS] src on src.PARTNUMBER = p.Part_Number and p.Org_Code = @DEFAULT_ORGCODE --explode happens here
inner join [sis_stage].SerialNumberPrefix snp on snp.Serial_Number_Prefix = src.SNP
inner join [sis_stage].SerialNumberRange snr on 
	snr.Start_Serial_Number = src.SNR and 
	snr.End_Serial_Number = src.SNR
Where (src.isValidPartNumber is null or src.isValidPartNumber = '0') and src.isValidSerialNumber is null
and src.PARENTPARTNUMBER is null


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'AsShipped_Effectivity Machine Level 1', @DATAVALUE = @@RowCount;

--Machine Level 2
Insert into [sis_stage].[AsShippedPart_Effectivity] ([AsShippedPart_ID], [SerialNumberPrefix_ID], [SerialNumberRange_ID])
Select Distinct asp.AsShippedPart_ID, snp.SerialNumberPrefix_ID, snr.SerialNumberRange_ID
From [sis_stage].AsShippedPart asp
Inner join [sis_stage].Part p on p.Part_ID = asp.Part_ID
Inner join [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS] src on src.PARTNUMBER = p.Part_Number and p.Org_Code = @DEFAULT_ORGCODE --explode happens here
Inner join [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] mc on src.ID_Int = mc.ParentID --Only include if there is a child part
inner join [sis_stage].SerialNumberPrefix snp on snp.Serial_Number_Prefix = src.SNP
inner join [sis_stage].SerialNumberRange snr on 
	snr.Start_Serial_Number = src.SNR and 
	snr.End_Serial_Number = src.SNR
--Left outer join [sis_stage].AsShippedPart_Effectivity ase on 
--	ase.AsShippedPart_ID = asp.AsShippedPart_ID and 
--	ase.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID and
--	ase.SerialNumberRange_ID = snr.SerialNumberRange_ID
Where 
--ase.AsShippedPart_Effectivity_ID is null and --Not already loaed in effectivity
(src.isValidPartNumber is null or src.isValidPartNumber = '0') and src.isValidSerialNumber is null
and src.PARENTPARTNUMBER is not null --Not root
Except --Not already loaed in effectivity
Select AsShippedPart_ID, SerialNumberPrefix_ID, SerialNumberRange_ID From [sis_stage].AsShippedPart_Effectivity


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'AsShipped_Effectivity Machine Level 2', @DATAVALUE = @@RowCount;


----Machine Level 3
Insert into [sis_stage].[AsShippedPart_Effectivity] ([AsShippedPart_ID], [SerialNumberPrefix_ID], [SerialNumberRange_ID])
Select Distinct asp.AsShippedPart_ID, snp.SerialNumberPrefix_ID, snr.SerialNumberRange_ID
From [sis_stage].AsShippedPart asp
Inner join [sis_stage].Part p on p.Part_ID = asp.Part_ID
Inner join [SISWEB_OWNER].LNKASSHIPPEDPRODUCTDETAILS2 src on src.PARTNUMBER = p.Part_Number and p.Org_Code = @DEFAULT_ORGCODE --explode happens here
Inner join [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3] mc on src.ID_Int = mc.ParentID --Only include if there is a child part
inner join [sis_stage].SerialNumberPrefix snp on snp.Serial_Number_Prefix = src.SNP
inner join [sis_stage].SerialNumberRange snr on 
	snr.Start_Serial_Number = src.SNR and 
	snr.End_Serial_Number = src.SNR
--Left outer join [sis_stage].AsShippedPart_Effectivity ase on 
--	ase.AsShippedPart_ID = asp.AsShippedPart_ID and 
--	ase.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID and
--	ase.SerialNumberRange_ID = snr.SerialNumberRange_ID
Where 
--ase.AsShippedPart_Effectivity_ID is null and --Not already loaed in effectivity
src.isValidPartNumber is null and src.isValidSerialNumber is null
Except --Not already loaed in effectivity
Select AsShippedPart_ID, SerialNumberPrefix_ID, SerialNumberRange_ID From [sis_stage].AsShippedPart_Effectivity


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'AsShipped_Effectivity Machine Level 3', @DATAVALUE = @@RowCount;

--Insert natural keys into key table
Insert into [sis_stage].[AsShippedPart_Effectivity_Key] (AsShippedPart_ID, SerialNumberPrefix_ID, SerialNumberRange_ID)
Select s.AsShippedPart_ID, s.SerialNumberPrefix_ID, s.SerialNumberRange_ID
From [sis_stage].[AsShippedPart_Effectivity] s
Left outer join [sis_stage].[AsShippedPart_Effectivity_Key] k on s.AsShippedPart_ID = k.AsShippedPart_ID and s.SerialNumberPrefix_ID = k.SerialNumberPrefix_ID and s.SerialNumberRange_ID = k.SerialNumberRange_ID
Where k.AsShippedPart_Effectivity_ID is null

--Key table load

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'AsShippedPart_Effectivity Key Load', @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set AsShippedPart_Effectivity_ID = k.AsShippedPart_Effectivity_ID
From [sis_stage].[AsShippedPart_Effectivity] s
inner join [sis_stage].[AsShippedPart_Effectivity_Key] k on s.AsShippedPart_ID = k.AsShippedPart_ID and s.SerialNumberPrefix_ID = k.SerialNumberPrefix_ID and s.SerialNumberRange_ID = k.SerialNumberRange_ID
where s.AsShippedPart_Effectivity_ID is null

--Surrogate Update

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'AsShippedPart_Effectivity Update Surrogate', @DATAVALUE = @@RowCount;
*/


/*
Next we need to load the Serialized Component Effectivity Table.
This is the effectivity defined by the "attachment" field in the source.  
Note that the serialized component effectivity should relate to the AsShipped effectivity for a specific AsShipped Part. Otherwise, we would not know which machine the attachment was on.
Engine source does not have attachements.
Level 3 of the machine source does have attachements, but the design does not support loading.
We are not setting fkey to SNR or SNP because the serial numbers are not concistent in the attachmentserialnumber source field.
*/
/*
--Machine Level 1 & 2
--We can load attachment effectivity for both level 1 and 2 at the same time because they are all based on part number
Insert into [sis_stage].[SerializedComponent_Effectivity]  ([AsShippedPart_Effectivity_ID], [SerialNumber])
Select Distinct ase.[AsShippedPart_Effectivity_ID], src.ATTACHMENTSERIALNUMBER
From [sis_stage].AsShippedPart asp
Inner join [sis_stage].Part p on p.Part_ID = asp.Part_ID
Inner join [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS] src on src.PARTNUMBER = p.Part_Number and p.Org_Code = @DEFAULT_ORGCODE --explode happens here
--Part effectivity
inner join [sis_stage].SerialNumberPrefix snp on snp.Serial_Number_Prefix = src.SNP
inner join [sis_stage].SerialNumberRange snr on snr.Start_Serial_Number = src.SNR and snr.End_Serial_Number = src.SNR
inner join [sis_stage].[AsShippedPart_Effectivity] ase on 
	ase.AsShippedPart_ID = asp.AsShippedPart_ID and 
	ase.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID and 
	ase.SerialNumberRange_ID = snr.SerialNumberRange_ID
--Attachment effectivity
--inner join [sis_stage].SerialNumberPrefix asnp on asnp.Serial_Number_Prefix = src.AttachmentSNP
--inner join [sis_stage].SerialNumberRange asnr on asnr.Start_Serial_Number = src.AttachmentSNR and asnr.End_Serial_Number = src.AttachmentSNR
Where (src.isValidPartNumber is null or src.isValidPartNumber = '0') and src.isValidSerialNumber is null
and src.ATTACHMENTSERIALNUMBER is not null


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SerializedComponent_Effectivity Machine Level 1 and 2', @DATAVALUE = @@RowCount;

--Machine Level 3
Insert into [sis_stage].[SerializedComponent_Effectivity]  ([AsShippedPart_Effectivity_ID], [SerialNumber])
Select Distinct ase.[AsShippedPart_Effectivity_ID], src.ATTACHMENTSERIALNUMBER
From [sis_stage].AsShippedPart asp
Inner join [sis_stage].Part p on p.Part_ID = asp.Part_ID
Inner join [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] src on src.PARTNUMBER = p.Part_Number and p.Org_Code = @DEFAULT_ORGCODE --explode happens here
--Part effectivity
inner join [sis_stage].SerialNumberPrefix snp on snp.Serial_Number_Prefix = src.SNP
inner join [sis_stage].SerialNumberRange snr on snr.Start_Serial_Number = src.SNR and snr.End_Serial_Number = src.SNR
inner join [sis_stage].[AsShippedPart_Effectivity] ase on 
	ase.AsShippedPart_ID = asp.AsShippedPart_ID and 
	ase.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID and 
	ase.SerialNumberRange_ID = snr.SerialNumberRange_ID
--Attachment effectivity
--inner join [sis_stage].SerialNumberPrefix asnp on asnp.Serial_Number_Prefix = src.AttachmentSNP
--inner join [sis_stage].SerialNumberRange asnr on asnr.Start_Serial_Number = src.AttachmentSNR and asnr.End_Serial_Number = src.AttachmentSNR
--SerializedComponent_Effectivity (check if already loaded)
Left outer join [sis_stage].SerializedComponent_Effectivity sce on 
	sce.AsShippedPart_Effectivity_ID = ase.AsShippedPart_Effectivity_ID and
	sce.SerialNumber = src.ATTACHMENTSERIALNUMBER
Where 
sce.AsShippedPart_Effectivity_ID is null --Do not load same effectivity more than once
and src.isValidPartNumber is null and src.isValidSerialNumber is null
and src.ATTACHMENTSERIALNUMBER is not null


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SerializedComponent_Effectivity Machine Level 3', @DATAVALUE = @@RowCount;

--Insert natural keys into key table
Insert into [sis_stage].[SerializedComponent_Effectivity_Key] (AsShippedPart_Effectivity_ID, SerialNumber)
Select s.AsShippedPart_Effectivity_ID, s.SerialNumber
From [sis_stage].[SerializedComponent_Effectivity] s
Left outer join [sis_stage].[SerializedComponent_Effectivity_Key] k on s.AsShippedPart_Effectivity_ID = k.AsShippedPart_Effectivity_ID and s.SerialNumber = k.SerialNumber
Where k.SerializedComponent_Effectivity_ID is null

--Key table load

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SerializedComponent_Effectivity Key Load', @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set SerializedComponent_Effectivity_ID = k.SerializedComponent_Effectivity_ID
From [sis_stage].[SerializedComponent_Effectivity] s
inner join [sis_stage].[SerializedComponent_Effectivity_Key] k on s.AsShippedPart_Effectivity_ID = k.AsShippedPart_Effectivity_ID and s.SerialNumber = k.SerialNumber
where s.SerializedComponent_Effectivity_ID is null

--Surrogate Update

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SerializedComponent_Effectivity Update Surrogate', @DATAVALUE = @@RowCount;
*/
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed' , @DATAVALUE = NULL;


END TRY

BEGIN CATCH 

	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
			@ERRORLINE INT= ERROR_LINE(),
			@LOGMESSAGE VARCHAR(MAX);

	SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
	EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;

END CATCH

END
