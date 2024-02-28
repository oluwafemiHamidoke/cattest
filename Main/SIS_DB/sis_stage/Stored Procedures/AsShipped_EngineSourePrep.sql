CREATE PROCEDURE [sis_stage].[AsShipped_EngineSourePrep]
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
Update [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE] set SNP = left(ltrim(rtrim(SERIALNUMBER)), 3) where SNP is null
Update [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE] set SNR = try_cast(Substring(ltrim(rtrim(SERIALNUMBER)), 4, 5) as int) where SNR is null



Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'SNP SNR', @@RowCount)


IF NOT EXISTS (SELECT * FROM   sys.columns WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]') AND name = 'isValidSerialNumber')
Alter table [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]
Add isValidSerialNumber bit null

--15 seconds to set 0 values
--Not setting 1 values.  Null values are valid.
Update s
Set isValidSerialNumber = 0
--Select Distinct SERIALNUMBER
From [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE] s
Where try_cast(SUBSTRING(SERIALNUMBER,4,99) as int) is null or --Must be an int 
SERIALNUMBER like '%.%' and --Decimals are not allowed
Len(ltrim(rtrim(SERIALNUMBER))) <> 8 --Limit to only serial numbers with 8 charaters, no period, and numeric.

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'isValidSerialNumber', @@RowCount)


IF NOT EXISTS (SELECT * FROM   sys.columns WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]') AND name = 'isValidPartNumber')
Alter table [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]
Add isValidPartNumber bit null

--17 seconds to set 0 values
--Not setting 1 values.  Null values are valid.
Update s
Set isValidPartNumber = 0
--Select Distinct PartNumber
From [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE] s
left outer join [SISWEB_OWNER].[MASSMCS] smcs on smcs.SMCSCOMPCODE = s.PARTNUMBER
Where smcs.ID is not null --Valid parts do not match SMCS code

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'isValidPartNumber', @@RowCount)


--Add an efficient unique key
--Requires writing to 150 million records.  55 minutes on initial load.
IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]') AND name = 'ID')
Alter table [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]
Add ID int null

IF NOT EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[sis_stage].[SequenceSIS2ASSHIPPEDENGINEID]') AND type = 'SO')
CREATE SEQUENCE [sis_stage].[SequenceSIS2ASSHIPPEDENGINEID] AS Int START WITH 1 INCREMENT BY 1
update [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE] set [ID] = next value for [sis_stage].[SequenceSIS2ASSHIPPEDENGINEID] where [ID] is null;

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ID', @@RowCount)


--Create Index
If NOT EXISTS (SELECT * FROM sys.indexes WHERE name='SIS2ASSHIPPEDENGINE_PARTNUMBER_NC' AND object_id = OBJECT_ID('SISWEB_OWNER.SIS2ASSHIPPEDENGINE'))
CREATE NONCLUSTERED INDEX [SIS2ASSHIPPEDENGINE_PARTNUMBER_NC] ON [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]
(
	[SERIALNUMBER] ASC,
	[PARTNUMBER] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Index SIS2ASSHIPPEDENGINE_PARTNUMBER_NC', @@RowCount)


--Create Index
If NOT EXISTS (SELECT * FROM sys.indexes WHERE name='SIS2ASSHIPPEDENGINE_IndSerSeq_NC' AND object_id = OBJECT_ID('SISWEB_OWNER.SIS2ASSHIPPEDENGINE'))
CREATE NONCLUSTERED INDEX [SIS2ASSHIPPEDENGINE_IndSerSeq_NC] ON [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]
(
	
	[SERIALNUMBER] ASC,
	[PARTSEQUENCENUMBER] ASC,
	[INDENTATION] ASC
)
Include (ID)
WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Index SIS2ASSHIPPEDENGINE_IndSerSeq_NC', @@RowCount)


--Add PartentID
IF NOT EXISTS (SELECT * FROM   sys.columns  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]') AND name = 'ParentID')
Alter table [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]
Add ParentID int null

--25 minutes to run subquery
--42 minutes to run entire update prior to adding index
--25 minutes to run entire update after adding index
Update x
set x.ParentID = y.ParentID
From [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE] x
inner join 
(
	Select ID, max(ParentID_Prior) over (Partition By [SERIALNUMBER] order by [SERIALNUMBER], [PARTSEQUENCENUMBER]) as ParentID --Spread the parent sequence value across partition
    From 
    (
        Select *, sum(case when ParentID_Prior is null then 0 else 1 end) over (Partition By [SERIALNUMBER] order by [SERIALNUMBER], [PARTSEQUENCENUMBER]) as value_partition --Create a partition to identify the group of child parts
        From 
        (
            SELECT *, 
                    case when INDENTATION = 1 and lag(INDENTATION,1,NULL) Over (Partition By [SERIALNUMBER] Order by [SERIALNUMBER], PARTSEQUENCENUMBER) = '0' 
                    then  lag(ID,1,NULL) Over (Partition By [SERIALNUMBER] Order by [SERIALNUMBER], PARTSEQUENCENUMBER) 
                    else NULL end ParentID_Prior
                FROM [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE] with (nolock) --where SERIALNUMBER in ('SDN00992')
        ) x
        where INDENTATION = '1' --Only required for child records.  Source has only a 0 and 1 as values for indentation.
    ) x
) y on x.ID = y.ID
where x.ParentID is null or x.ParentID <> y.ParentID

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
