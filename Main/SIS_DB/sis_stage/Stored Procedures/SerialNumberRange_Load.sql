CREATE PROCEDURE [sis_stage].[SerialNumberRange_Load]
--(
--    -- Add the parameters for the stored procedure here
--    <@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>,
--    <@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
--)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON


BEGIN TRY

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
		@ProcessID uniqueidentifier = NewID()

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started' , @DATAVALUE = NULL;

    -- Insert statements for procedure here

--Load
Insert into [sis_stage].[SerialNumberRange]
([Start_Serial_Number]
,[End_Serial_Number])
-- Insert missing SerialNumberRange records from the staging table([sis_stage].[ssf_sistele]) to SerialNumberRange table.
-- This ensures that any new serial number ranges found in the staging table are added to the SerialNumberRange table.
SELECT DISTINCT 
SN_START_RANGE Start_Serial_Number
, SN_END_RANGE End_Serial_Number
FROM [sis_stage].[ssf_sistele]  
UNION
SELECT Distinct
 [BEGINNINGRANGE] Start_Serial_Number
,[ENDRANGE] End_Serial_Number
FROM [SISWEB_OWNER].[LNKPARTSIESNP]
Union
SELECT Distinct
 [BEGINNINGRANGE] Start_Serial_Number
,[ENDRANGE] End_Serial_Number
FROM [SISWEB_OWNER].[LNKIESNP]
Union 
SELECT Distinct
 [BEGINNINGRANGE] Start_Serial_Number
,[ENDRANGE] End_Serial_Number
FROM [SISWEB_OWNER].[LNKMEDIASNP]
Union
--As Shipped
--10.5 million records
--9 minutes
Select Distinct
	 SNR Start_Serial_Number
	,SNR End_Serial_Number
From
(
--Machine
	SELECT Distinct SNR FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS] where isValidSerialNumber is null and SNR is not null
	Union
	SELECT Distinct SNR FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] where isValidSerialNumber is null and SNR is not null
	Union
	SELECT Distinct SNR FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3] where isValidSerialNumber is null and SNR is not null
--	Union
----Attachment
--	SELECT Distinct AttachmentSNR FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS] where isValidSerialNumber is null and AttachmentSNR is not null
--	Union
--	SELECT Distinct AttachmentSNR FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] where isValidSerialNumber is null and AttachmentSNR is not null
	--Union
	--SELECT Distinct AttachmentSNR FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3] and AttachmentSNP is not null
	Union
--Eninge
	SELECT Distinct SNR FROM [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE] where isValidSerialNumber is null and SNR is not null
) x
Union
--MasSNP (captive range)
SELECT Distinct
 [BEGINNINGRANGE] Start_Serial_Number
,[ENDRANGE] End_Serial_Number
FROM [SISWEB_OWNER].[MASSNP]
Union
-- adding KIM as new Source
select distinct MACHINESNBEGIN,MACHINESNEND
		from [KIM].[SIS_KitEffectivity]
		where MACHINESNBEGIN is not null
UNION
select distinct ENGINESNBEGIN,ENGINESNEND
	from [KIM].[SIS_KitEffectivity]
	where ENGINESNBEGIN is not null
UNION
select distinct  TQCONVERTORSNBEGIN,TQCONVERTORSNEND
	from [KIM].[SIS_KitEffectivity]
	where TQCONVERTORSNBEGIN is not null
UNION
Select try_cast(Substring(ltrim(rtrim(PRIMESERIALNUMBER)), 4, 5) as int) as Start_Serial_Number,
try_cast(Substring(ltrim(rtrim(PRIMESERIALNUMBER)), 4, 5) as int) as End_Serial_Number
from [SISWEB_OWNER].[LNKCAPTIVETOPRIME]
UNION
Select try_cast(Substring(ltrim(rtrim(CAPTIVESERIALNUMBER)), 4, 5) as int) as Start_Serial_Number,
try_cast(Substring(ltrim(rtrim(CAPTIVESERIALNUMBER)), 4, 5) as int) as End_Serial_Number
from [SISWEB_OWNER].[LNKCAPTIVETOPRIME]
UNION
SELECT DISTINCT 
	TRY_CAST(SER_NO_BDY AS INT) AS Start_Serial_Number,
	TRY_CAST(SER_NO_BDY AS INT) AS End_Serial_Number
FROM [PIS].[WHS_PIP_PSP_PGM]
WHERE SER_NO_BDY <> 'ue' --excluding junk data.

--select 'SerialNumberRange' Table_Name, @@RowCount Record_Count
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SerialNumberRange Load' , @DATAVALUE = @@RowCount;

--Insert natural keys into key table
Insert into [sis_stage].[SerialNumberRange_Key] (Start_Serial_Number, End_Serial_Number)
Select s.Start_Serial_Number, s.End_Serial_Number
From [sis_stage].[SerialNumberRange] s
Left outer join [sis_stage].[SerialNumberRange_Key] k on s.Start_Serial_Number = k.Start_Serial_Number and s.End_Serial_Number = k.End_Serial_Number
Where k.SerialNumberRange_ID is null

--Key table load
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SerialNumberRange Key Load' , @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set SerialNumberRange_ID = k.SerialNumberRange_ID
From [sis_stage].[SerialNumberRange] s
inner join [sis_stage].[SerialNumberRange_Key] k on s.Start_Serial_Number = k.Start_Serial_Number and s.End_Serial_Number = k.End_Serial_Number
where s.SerialNumberRange_ID is null

--Surrogate Update
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SerialNumberRange Update Surrogate' , @DATAVALUE = @@RowCount;

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
