CREATE PROCEDURE [sis_stage].[Product_Load]
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

--Load Product
insert into [sis_stage].SerialNumberPrefix
([Serial_Number_Prefix]
,[Classic_Product_Indicator]
,[CCR_Indicator])
Select
SerialNumberPrefix
,isnull(max(ClassicProductIndicator),0) ClassicProductIndicator
,isnull(max(x.CCR_Indicator),0)CCR_Indicator
From 
(
	SELECT 
	a.SNP SerialNumberPrefix,
	case max(a.CLASSICPARTINDICATOR)
		when 'Y' then 1
		else 0
	end ClassicProductIndicator
   ,case MAX(a.CCRINDICATOR) when 'Y' then 1
		else 0
	end AS CCR_Indicator
	FROM [SISWEB_OWNER].[LNKPRODUCT] a 
	Group by a.SNP
	Union 
	Select Distinct 
	a.SNP SerialNumberPrefix,
	NULL ClassicProductIndicator
   ,NULL AS CCR_Indicator
	FROM [SISWEB_OWNER].[LNKPARTSIESNP] a --Not all SNPs are found in LNKProduct.  Needed to load IEPart effectivity.
	Union 
	Select Distinct 
	a.SNP SerialNumberPrefix,
	NULL ClassicProductIndicator
	,NULL AS CCR_Indicator
	FROM [SISWEB_OWNER].[LNKIESNP] a 
	/* Davide 2019-09-10 according to the chat with Scott 
			[6:19 PM] Scott Belsly
			typeindicator needs to be 'S'
			​[6:19 PM] Scott Belsly
			'P' is product
	*/
	WHERE TYPEINDICATOR= 'S'
) x
Group by SerialNumberPrefix

--select 'SerialNumberPrefix' Table_Name, count(*) Record_Count from [sis_stage].SerialNumberPrefix
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SerialNumberPrefix Load' , @DATAVALUE = @@RowCount;


--Load Product from As Shipped
insert into [sis_stage].SerialNumberPrefix
([Serial_Number_Prefix]
,[Classic_Product_Indicator]
,[CCR_Indicator])
--10.5 million recors
--9 minutes
Select Distinct SNP, Classic_Part_Indicator, a.CCR_Indicator
From
(
--Machine
	SELECT Distinct SNP, 0 Classic_Part_Indicator, 0 CCR_Indicator FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS] where isValidSerialNumber is null and SNP is not null
	Union
	SELECT Distinct SNP, 0 Classic_Part_Indicator, 0 CCR_Indicator FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] where isValidSerialNumber is null and SNP is not null
	Union
	SELECT Distinct SNP, 0 Classic_Part_Indicator, 0 CCR_Indicator FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3] where isValidSerialNumber is null and SNP is not null
--	Union
----Attachment 
--	SELECT Distinct AttachmentSNP, 0 Classic_Part_Indicator FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS] where isValidSerialNumber is null and AttachmentSNP is not null
--	Union
--	SELECT Distinct AttachmentSNP, 0 Classic_Part_Indicator FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] where isValidSerialNumber is null and AttachmentSNP is not null
	--Union
	--SELECT Distinct AttachmentSNP, 0 Classic_Part_Indicator FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3] where isValidSerialNumber is null and AttachmentSNP is not null
	Union
--Engine
	SELECT Distinct SNP, 0 Classic_Part_Indicator, 0 CCR_Indicator FROM [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE] where isValidSerialNumber is null and SNP is not null
) a
left outer join [sis_stage].SerialNumberPrefix snp on snp.Serial_Number_Prefix = a.SNP
where snp.Serial_Number_Prefix is null --Do not override the currently loaded snp.  Retain classic part indicator.

--select 'SerialNumberPrefix' Table_Name, count(*) Record_Count from [sis_stage].SerialNumberPrefix
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SerialNumberPrefix AsShipped Load' , @DATAVALUE = @@RowCount;


--Load Product from MasSNP
insert into [sis_stage].SerialNumberPrefix
([Serial_Number_Prefix]
,[Classic_Product_Indicator]
,CCR_Indicator)
Select Distinct SNP, Classic_Part_Indicator, a.CCR_Indicator
From
(
--Machine
	SELECT Distinct PRIMESERIALNUMBERPREFIX SNP, 0 Classic_Part_Indicator, 0 CCR_Indicator FROM [SISWEB_OWNER].[MASSNP]
	Union
	SELECT Distinct CAPTIVESERIALNUMBERPREFIX SNP, 0 Classic_Part_Indicator, 0 CCR_Indicator FROM [SISWEB_OWNER].[MASSNP]
) a
left outer join [sis_stage].SerialNumberPrefix snp on snp.Serial_Number_Prefix = a.SNP
where snp.Serial_Number_Prefix is null --Do not override the currently loaded snp.  Retain classic part indicator.

--select 'SerialNumberPrefix' Table_Name, count(*) Record_Count from [sis_stage].SerialNumberPrefix
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SerialNumberPrefix MASSNP Load' , @DATAVALUE = @@RowCount;

--Load Product from KIM
insert into [sis_stage].SerialNumberPrefix
([Serial_Number_Prefix]
,[Classic_Product_Indicator]
,[CCR_Indicator])
Select Distinct SNP, Classic_Part_Indicator, a.CCR_Indicator
From
(
--Engine
	SELECT Distinct ENGINEPREFIX SNP, 0 Classic_Part_Indicator, 0 CCR_Indicator FROM [KIM].[SIS_KitEffectivity] where ENGINEPREFIX is not null and ENGINEPREFIX <> ''
	Union
--Machine
	SELECT Distinct MACHINEPREFIX SNP, 0 Classic_Part_Indicator, 0 CCR_Indicator FROM [KIM].[SIS_KitEffectivity] where MACHINEPREFIX is not null and MACHINEPREFIX <> ''
	Union
--TQCONVERTOR
	SELECT Distinct TQCONVERTORPREFIX SNP, 0 Classic_Part_Indicator, 0 CCR_Indicator FROM [KIM].[SIS_KitEffectivity] where TQCONVERTORPREFIX is not null and TQCONVERTORPREFIX <> ''
) a
left outer join [sis_stage].SerialNumberPrefix snp on snp.Serial_Number_Prefix = a.SNP
where snp.Serial_Number_Prefix is null --Do not override the currently loaded snp.  Retain classic part indicator.

--select 'SerialNumberPrefix' Table_Name, count(*) Record_Count from [sis_stage].SerialNumberPrefix
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SerialNumberPrefix KIM Load' , @DATAVALUE = @@RowCount;


--Insert natural keys into key table
Insert into [sis_stage].[SerialNumberPrefix_Key] (Serial_Number_Prefix)
Select s.Serial_Number_Prefix
From [sis_stage].[SerialNumberPrefix] s
Left outer join [sis_stage].[SerialNumberPrefix_Key] k on s.Serial_Number_Prefix = k.Serial_Number_Prefix
Where k.SerialNumberPrefix_ID is null

--Key table load
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SerialNumberPrefix Key Load' , @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set SerialNumberPrefix_ID = k.SerialNumberPrefix_ID
From [sis_stage].[SerialNumberPrefix] s
inner join [sis_stage].[SerialNumberPrefix_Key] k on s.Serial_Number_Prefix = k.Serial_Number_Prefix
where s.SerialNumberPrefix_ID is null;

update [sis_stage].SerialNumberPrefix set [Is_Telematics_Flash] = 0 where  Serial_Number_Prefix in
('5RK','2PZ','2PZ-102','8GB','6HK','1HW','5AZ','APX','5AZ-264','MSY','DMC','M4J','RTL','TRG','R2R','ZSB',
'ZSP','01A','81A','9ZC','7EK','2BW','2BW-303','SPD','SHH','AX7','TWP','TR2','WRL','XDT','3SJ','1HL',
'4AR','4GZ','ATY','CBR','FDB','SSP','SND','RBT','D3T','RB4','SXP','EMD','A4M','WED','R8L','TWN','RWM',
'KWH','MH4','MT4','MN5','MT5','HRT','HRZ','HRY','ERM','SNT','5YW','JSM','LAJ','WSP','LTZ','ST3','ST7',
'SKH','SE2','SE3','SE4','SE5','SE6');

--Surrogate Update
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SerialNumberPrefix Update Surrogate' , @DATAVALUE = @@RowCount;


--Load SalesModel
insert into [sis_stage].SalesModel
([Sales_Model])
SELECT Distinct
a.SALESMODELNO SalesModelNumber
FROM [SISWEB_OWNER].[LNKPRODUCT] a
Group by a.SALESMODELNO

--select 'SalesModel' Table_Name, count(*) Record_Count from [sis_stage].SalesModel
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SalesModel Load' , @DATAVALUE = @@RowCount;

--Insert natural keys into key table
Insert into [sis_stage].[SalesModel_Key] (Sales_Model)
Select s.Sales_Model
From [sis_stage].[SalesModel] s
Left outer join [sis_stage].[SalesModel_Key] k on s.Sales_Model = k.Sales_Model
Where k.SalesModel_ID is null

--Key table load
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SalesModel Key Load' , @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set SalesModel_ID = k.SalesModel_ID
From [sis_stage].[SalesModel] s
inner join [sis_stage].[SalesModel_Key] k on s.Sales_Model = k.Sales_Model
where s.SalesModel_ID is null

--Surrogate Update
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SalesModel Update Surrogate' , @DATAVALUE = @@RowCount;


--Load ProductSubfamily
insert into [sis_stage].[ProductSubfamily]
([Subfamily_Code])
SELECT Distinct
[PRODUCTDESCRIPTION]
FROM [SISWEB_OWNER].[MASPRODUCT]
where PRODUCTTYPE = 'P'

--select 'ProductSubfamily' Table_Name, count(*) Record_Count from [sis_stage].ProductSubfamily
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'ProductSubfamily Load' , @DATAVALUE = @@RowCount;

--Insert natural keys into key table
Insert into [sis_stage].[ProductSubfamily_Key] (Subfamily_Code)
Select s.Subfamily_Code
From [sis_stage].[ProductSubfamily] s
Left outer join [sis_stage].[ProductSubfamily_Key] k on s.Subfamily_Code = k.Subfamily_Code
Where k.ProductSubfamily_ID is null

--Key table load
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'ProductSubfamily Key Load' , @DATAVALUE = @@RowCount;


--Update stage table with surrogate keys from key table
Update s
Set ProductSubfamily_ID = k.ProductSubfamily_ID
From [sis_stage].[ProductSubfamily] s
inner join [sis_stage].[ProductSubfamily_Key] k on s.Subfamily_Code = k.Subfamily_Code
where s.ProductSubfamily_ID is null

--Surrogate Update
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'ProductSubfamily Update Surrogate' , @DATAVALUE = @@RowCount;


--Load ProductFamily
insert into [sis_stage].[ProductFamily]
([Family_Code])
SELECT Distinct
[PRODUCTCODE]
FROM [SISWEB_OWNER].[MASPRODUCT]
where PRODUCTTYPE = 'F'

--select 'ProductFamily' Table_Name, count(*) Record_Count from [sis_stage].[ProductFamily]
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'ProductFamily Load' , @DATAVALUE = @@RowCount;

--Insert natural keys into key table
Insert into [sis_stage].[ProductFamily_Key] (Family_Code)
Select s.Family_Code
From [sis_stage].[ProductFamily] s
Left outer join [sis_stage].[ProductFamily_Key] k on s.Family_Code = k.Family_Code
Where k.ProductFamily_ID is null

--Key table load
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'ProductFamily Key Load' , @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set ProductFamily_ID = k.ProductFamily_ID
From [sis_stage].[ProductFamily] s
inner join [sis_stage].[ProductFamily_Key] k on s.Family_Code = k.Family_Code
where s.ProductFamily_ID is null

--Surrogate Update
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'ProductFamily Update Surrogate' , @DATAVALUE = @@RowCount;

--Load Product_Relation
Insert into [sis_stage].[Product_Relation]
([SerialNumberPrefix_ID]
 ,[SalesModel_ID]
 ,[ProductSubfamily_ID]
 ,[ProductFamily_ID]
 ,[Shipped_Date]) 
SELECT 
--a.SNP SerialNumberPrefix,
--a.SALESMODELNO SalesModelNumber,
p.SerialNumberPrefix_ID,
m.SalesModel_ID,
--s.PRODUCTDESCRIPTION Subfamily_Code,
ps.ProductSubfamily_ID,
--f.PRODUCTCODE FamilyCode,
pf.ProductFamily_ID,
a.SHIPPEDDATE
FROM [SISWEB_OWNER].[LNKPRODUCT] a 
left outer join (
	SELECT [PRODUCTCODE]
	,[SEQUENCENUMBER]
	,max([PRODUCTTYPE]) PRODUCTTYPE
	,max([PRODUCTDESCRIPTION]) PRODUCTDESCRIPTION
	FROM [SISWEB_OWNER].[MASPRODUCT]
	where PRODUCTTYPE = 'P'
	group by PRODUCTCODE, SEQUENCENUMBER
    ) s
on a.PRODUCTCODE = s.PRODUCTCODE 
	and a.SEQUENCENUMBER = s.SEQUENCENUMBER
left outer join (
	SELECT [PRODUCTCODE]
	,max([PRODUCTTYPE]) PRODUCTTYPE
	,max([PRODUCTDESCRIPTION]) PRODUCTDESCRIPTION
	FROM [SISWEB_OWNER].[MASPRODUCT]
	where PRODUCTTYPE = 'F'
	group by PRODUCTCODE, SEQUENCENUMBER
    ) f
on s.PRODUCTCODE = f.PRODUCTCODE
inner join [sis_stage].[SerialNumberPrefix] p on p.Serial_Number_Prefix = a.SNP
inner join [sis_stage].[SalesModel] m on m.Sales_Model = a.SALESMODELNO
inner join [sis_stage].[ProductSubfamily] ps on ps.Subfamily_Code = s.PRODUCTDESCRIPTION
inner join [sis_stage].[ProductFamily] pf on pf.Family_Code = f.[PRODUCTCODE]
order by f.PRODUCTCODE, s.PRODUCTDESCRIPTION, a.SALESMODELNO, a.SNP

--select 'Product_Relation' Table_Name, count(*) Record_Count from [sis_stage].[Product_Relation]
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Product_Relation Load' , @DATAVALUE = @@RowCount;


--Subfamily Translation
Insert into [sis_stage].[ProductSubfamily_Translation]
(
 [ProductSubfamily_ID]
,[Language_ID]
,[Subfamily_Name]
)
SELECT ProductSubfamily_ID
		   ,l.Language_ID
		   ,PRODUCTDESCRIPTION AS Subfamily_Name
	   FROM SISWEB_OWNER.MASPRODUCT AS P
			JOIN sis_stage.ProductSubfamily AS PS ON PS.Subfamily_Code = P.PRODUCTDESCRIPTION
			JOIN sis_stage.Language AS l ON
											l.Legacy_Language_Indicator = P.LANGUAGEINDICATOR
											AND l.Default_Language = 1
	   WHERE PRODUCTTYPE = 'P'
	   GROUP BY ProductSubfamily_ID
			   ,Language_ID
			   ,PRODUCTDESCRIPTION;

--select 'ProductSubfamily_Translation' Table_Name, @@RowCount Record_Count
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'ProductSubfamily_Translation Load' , @DATAVALUE = @@RowCount;


--Family Translation
Insert into [sis_stage].[ProductFamily_Translation]
(
 [ProductFamily_ID]
,[Language_ID]
,[Family_Name]
)
SELECT ProductFamily_ID
	  ,l.Language_ID
	  ,PRODUCTDESCRIPTION AS Family_Name
  FROM SISWEB_OWNER.MASPRODUCT AS pfs
	   JOIN sis_stage.ProductFamily AS pf ON pf.Family_Code = pfs.PRODUCTCODE
	   JOIN sis_stage.Language AS l ON
									   l.Legacy_Language_Indicator = pfs.LANGUAGEINDICATOR
									   AND l.Default_Language = 1
  WHERE PRODUCTTYPE = 'F';

--select 'ProductFamily_Translation' Table_Name, @@RowCount Record_Count
Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'ProductFamily_Translation Load', @@RowCount)
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'ProductFamily_Translation Load' , @DATAVALUE = @@RowCount;

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
