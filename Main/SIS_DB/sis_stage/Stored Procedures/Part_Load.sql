CREATE PROCEDURE [sis_stage].[Part_Load]
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
		@ProcessID uniqueidentifier = NewID(),
        @DEFAULT_ORGCODE VARCHAR(12) = SISWEB_OWNER_STAGING._getDefaultORGCODE(),
        @ORGCODE_SEPARATOR VARCHAR(1) = SISWEB_OWNER_STAGING._getDefaultORGCODESeparator();

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

    -- Insert statements for procedure here

-- Inserting the PartID -1 record to handle records with NULL for IEPARTNUMBER in LNKMEDIAIEPART. User Story 16132
insert into sis_stage.Part
values
('-1','NULL','CAT')

--Load
Insert into [sis_stage].[Part] ([Part_Number],[Org_Code])
Select 'Comment', @DEFAULT_ORGCODE
Union
Select Distinct [IEPARTNUMBER], [ORGCODE]
From [SISWEB_OWNER].[LNKMEDIAIEPART]
where IEPARTNUMBER IS NOT NULL
Union
Select Distinct [PARTNUMBER], [ORGCODE]
From [SISWEB_OWNER].[LNKCONSISTLIST]
Union
Select Distinct RELATEDPARTNUMBER, @DEFAULT_ORGCODE
From [SISWEB_OWNER].[LNKRELATEDPARTINFO]
Union
SELECT Distinct SISWEB_OWNER_STAGING._getPartNumberBySeparator(x.value,@ORGCODE_SEPARATOR) Part_Number,
                SISWEB_OWNER_STAGING._getOrgCodeBySeparator(x.value,@ORGCODE_SEPARATOR,@DEFAULT_ORGCODE) Org_Code
FROM [SISWEB_OWNER].[SUPERSESSIONCHAINS]
    CROSS APPLY STRING_SPLIT([CHAIN], '|') x
UNION
Select Distinct
    PARTNUMBER, @DEFAULT_ORGCODE
From
    (
        SELECT Distinct PARTNUMBER FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS] where (isValidPartNumber is null or isValidPartNumber = '0')  and isValidSerialNumber is null
        Union
        SELECT Distinct PARTNUMBER FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] where isValidPartNumber is null and isValidSerialNumber is null
        Union
        SELECT Distinct PARTNUMBER FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3] where isValidPartNumber is null and isValidSerialNumber is null
        Union
        SELECT Distinct PARTNUMBER FROM [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE] where isValidPartNumber is null and isValidSerialNumber is null
    ) x
Where PARTNUMBER is not null
UNION
select distinct PARTNUMBER, @DEFAULT_ORGCODE
FROM SISWEB_OWNER.LNKNPRINFO


--select 'Part' Table_Name, @@RowCount Record_Count  
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part Load', @DATAVALUE = @@RowCount;


--Insert natural keys into key table
Insert into [sis_stage].[Part_Key] (Part_Number, Org_Code)
Select s.Part_Number, s.Org_Code
From [sis_stage].[Part] s
    Left outer join [sis_stage].[Part_Key] k on s.Part_Number = k.Part_Number and s.Org_Code = k.Org_Code
Where k.Part_ID is null

--Key table load
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part Key Load', @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set Part_ID = k.Part_ID
    From [sis_stage].[Part] s
inner join [sis_stage].[Part_Key] k on s.Part_Number = k.Part_Number and s.Org_Code = k.Org_Code
where s.Part_ID is null

--Surrogate Update
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part Update Surrogate', @DATAVALUE = @@RowCount;

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;

END TRY

BEGIN CATCH 

	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
			@ERRORLINE INT= ERROR_LINE(),
			@LOGMESSAGE VARCHAR(MAX);

	SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
	EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;

END CATCH

END
