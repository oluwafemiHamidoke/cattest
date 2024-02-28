CREATE PROCEDURE [sis_stage].[AsShipped_DDLPrep]
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

--SIS2ASSHIPPEDENGINE
IF NOT EXISTS (SELECT * FROM   sys.columns WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]') AND name = 'isValidSerialNumber')
Alter table [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]
Add isValidSerialNumber bit null

IF NOT EXISTS (SELECT * FROM   sys.columns WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]') AND name = 'isValidPartNumber')
Alter table [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]
Add isValidPartNumber bit null

IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]') AND name = 'ID')
Alter table [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]
Add ID int null

IF NOT EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[sis_stage].[SequenceSIS2ASSHIPPEDENGINEID]') AND type = 'SO')
CREATE SEQUENCE [sis_stage].[SequenceSIS2ASSHIPPEDENGINEID] AS Int START WITH 1 INCREMENT BY 1

IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]') AND name = 'ParentID')
Alter table [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]
Add ParentID int null

IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]') AND name = 'SNP')
Alter table [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]
Add SNP char(3) null

IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]') AND name = 'SNR')
Alter table [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]
Add SNR int null

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'DDL SIS2ASSHIPPEDENGINE', @@RowCount)


--LNKASSHIPPEDPRODUCTDETAILS
IF NOT EXISTS (SELECT * FROM   sys.columns WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS]') AND name = 'isValidSerialNumber')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS]
Add isValidSerialNumber bit null

IF NOT EXISTS (SELECT * FROM   sys.columns WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS]') AND name = 'isValidPartNumber')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS]
Add isValidPartNumber bit null

IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS]') AND name = 'ID_Int')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS]
Add ID_Int bigint null

IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS]') AND name = 'ParentID')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS]
Add ParentID bigint null

IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS]') AND name = 'SNP')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS]
Add SNP char(3) null

IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS]') AND name = 'SNR')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS]
Add SNR int null

--IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS]') AND name = 'AttachmentSNP')
--Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS]
--Add AttachmentSNP char(3) null

--IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS]') AND name = 'AttachmentSNR')
--Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS]
--Add AttachmentSNR int null

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'DDL LNKASSHIPPEDPRODUCTDETAILS2', @@RowCount)


--LNKASSHIPPEDPRODUCTDETAILS2
IF NOT EXISTS (SELECT * FROM   sys.columns WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]') AND name = 'isValidSerialNumber')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]
Add isValidSerialNumber bit null

IF NOT EXISTS (SELECT * FROM   sys.columns WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]') AND name = 'isValidPartNumber')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]
Add isValidPartNumber bit null

IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]') AND name = 'ID_Int')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]
Add ID_Int bigint null

--Add Required Schema
IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]') AND name = 'ParentID')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]
Add ParentID bigint null

IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]') AND name = 'SNP')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]
Add SNP char(3) null

IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]') AND name = 'SNR')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]
Add SNR int null

--IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]') AND name = 'AttachmentSNP')
--Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]
--Add AttachmentSNP char(3) null

--IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]') AND name = 'AttachmentSNR')
--Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]
--Add AttachmentSNR int null

IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]') AND name = 'ParentPartNumberShort')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]
Add ParentPartNumberShort varchar(100) null

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'DDL LNKASSHIPPEDPRODUCTDETAILS2', @@RowCount)


--LNKASSHIPPEDPRODUCTDETAILS3
IF NOT EXISTS (SELECT * FROM   sys.columns WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3]') AND name = 'isValidSerialNumber')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3]
Add isValidSerialNumber bit null

IF NOT EXISTS (SELECT * FROM   sys.columns WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3]') AND name = 'isValidPartNumber')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3]
Add isValidPartNumber bit null

IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3]') AND name = 'ID_Int')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3]
Add ID_Int bigint null

--Add Required Schema
IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3]') AND name = 'ParentID')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3]
Add ParentID bigint null

IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3]') AND name = 'SNP')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3]
Add SNP char(3) null

IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3]') AND name = 'SNR')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3]
Add SNR int null

IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3]') AND name = 'ParentPartNumberShort')
Alter table [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3]
Add ParentPartNumberShort varchar(100) null

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'DDL LNKASSHIPPEDPRODUCTDETAILS3', @@RowCount)



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
