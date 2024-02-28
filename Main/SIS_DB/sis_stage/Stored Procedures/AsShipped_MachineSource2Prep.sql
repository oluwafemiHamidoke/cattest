
-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180626
-- Description: Full load [sis_stage].[AsShipped_MachineSource2Prep]]
--Exec [sis_stage].[AsShipped_MachineSource2Prep]
-- =============================================
CREATE PROCEDURE [sis_stage].[AsShipped_MachineSource2Prep]
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

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution started', NULL)

--SNP / SNR
Update [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] set SNP = left(ltrim(rtrim(SERIALNUMBER)), 3) where SNP is null
Update [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] set SNR = try_cast(Substring(ltrim(rtrim(SERIALNUMBER)), 4, 5) as int) where SNR is null

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'SNP SNR', @@RowCount)

--Attachement SNP / SNR
--Update [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] set AttachmentSNP = left(ltrim(rtrim(ATTACHMENTSERIALNUMBER)), 3) 
--where AttachmentSNP is null 
--and ATTACHMENTSERIALNUMBER is not null
--and try_cast(SUBSTRING(ATTACHMENTSERIALNUMBER,4,99) as int) is not null --Must be an int 
--and ATTACHMENTSERIALNUMBER not like '%.%' --Decimals are not allowed
--and Len(ltrim(rtrim(ATTACHMENTSERIALNUMBER))) <> 8 --Limit to only serial numbers with 8 charaters, no period, and numeric.

--Update [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] set AttachmentSNR = try_cast(Substring(ltrim(rtrim(ATTACHMENTSERIALNUMBER)), 4, 5) as int) 
--where AttachmentSNR is null
--and ATTACHMENTSERIALNUMBER is not null
--and try_cast(SUBSTRING(ATTACHMENTSERIALNUMBER,4,99) as int) is not null --Must be an int 
--and ATTACHMENTSERIALNUMBER not like '%.%' --Decimals are not allowed
--and Len(ltrim(rtrim(ATTACHMENTSERIALNUMBER))) <> 8 --Limit to only serial numbers with 8 charaters, no period, and numeric.

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Attachement SNP SNR', @@RowCount)

--0 seconds to set 0 values
--Not setting 1 values.  Null values are valid.
Update s
Set isValidSerialNumber = 0
--Select Distinct SERIALNUMBER
From [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] s
Where try_cast(SUBSTRING(SERIALNUMBER,4,99) as int) is null or --Must be an int 
SERIALNUMBER like '%.%' and --Decimals are not allowed
Len(ltrim(rtrim(SERIALNUMBER))) <> 8 --Limit to only serial numbers with 8 charaters, no period, and numeric.

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'isValidSerialNumber', @@RowCount)

--0 minutes to set 0 values
--Not setting 1 values.  Null values are valid.
Update s
Set isValidPartNumber = 0
--Select Distinct PartNumber
From [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] s
left outer join [SISWEB_OWNER].[MASSMCS] smcs on smcs.SMCSCOMPCODE = s.PARTNUMBER
Where smcs.ID is not null --Valid parts do not match SMCS code

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'isValidPartNumber', @@RowCount)


--Source has a clusterd index on ID numeric 38,10.  Load this into an int column.
--Add an efficient unique key
update [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] set [ID_Int] = cast(ID as bigint) where [ID_Int] is null

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ID_Int', @@RowCount)


--Create Index
If NOT EXISTS (SELECT * FROM sys.indexes WHERE name='LNKASSHIPPEDPRODUCTDETAILS2_PARENTPARTNUMBER_NC' AND object_id = OBJECT_ID('SISWEB_OWNER.LNKASSHIPPEDPRODUCTDETAILS2'))
CREATE NONCLUSTERED INDEX [LNKASSHIPPEDPRODUCTDETAILS2_PARENTPARTNUMBER_NC] ON [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]
(
	[SERIALNUMBER] ASC,
	[PARTNUMBER] ASC,
	[PARENTPARTNUMBER] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Index LNKASSHIPPEDPRODUCTDETAILS2_PARENTPARTNUMBER_NC', @@RowCount)


--Add PartentID
--Source does not update records.  Only delete and insert.  So, no need to recalculate the parentID.
Update c
set ParentID = p.ID_Int, ParentPartNumberShort = p.PARTNUMBER
--SELECT c.ID_Int, p.ID_Int ParentID
FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] c
Inner join [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS] p on c.PARENTPARTNUMBER = CONCAT(p.PARENTPARTNUMBER, p.PARTNUMBER) and c.SERIALNUMBER = p.SERIALNUMBER
where c.PARENTPARTNUMBER is not null and (c.ParentID is null or c.ParentPartNumberShort is null)

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ParentID', @@RowCount)


Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution completed', NULL)


END TRY

BEGIN CATCH 

	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
			@ERROELINE INT= ERROR_LINE()

	Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
	Values (@ProcessID, GETDATE(), 'Error', @ProcName, 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE, NULL)

END CATCH

END
