CREATE  Procedure [SISSEARCH].[LNKMEDIAIEPART_LASTMODIFIEDDATE_LOAD]
As
-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181019
-- Modify Date: 20200206	removed PERSIST tables dependencies
-- Description: Maintain LNKMEDIAIEPART LASTMODIFIEDDATE
-- Exec SISSEARCH.LNKMEDIAIEPART_LASTMODIFIEDDATE_LOAD
-- =============================================

Begin

BEGIN TRY

SET NOCOUNT ON

Declare @LastInsertDate Datetime

Declare @SPStartTime DATETIME,
		@StepStartTime DATETIME,
		@ProcName VARCHAR(200),
		@SPStartLogID BIGINT,
		@StepLogID BIGINT,
		@RowCount BIGINT,
		@LAPSETIME BIGINT
SET @SPStartTime= GETDATE()
SET @ProcName= OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
 
EXEC @SPStartLogID = SISSEARCH.WriteLog @TIME = @SPStartTime, @NAMEOFSPROC = @ProcName;

/*
LnkIEPSID is being truncated and reloaded.  We need to know the last modified date for 
records in this table so we can trigger modifications when records are updated.  This
section of code adds a last modified date to the LnkIEPSID by maintaining a persistent 
version of the table which includes a last modified date (based in the insert date).

 Davide 20200206
[SISWEB_OWNER_STAGING].[LNKIEPSID_Merge] procedure now maintains the [SISWEB_OWNER].[LNKIEPSID] table which is not TRUNCATEd anymore. 
We can therefore eliminate the part of the code that does the MERGE with [SISWEB_OWNER].[LNKIEPSIDPERSIST] and the UPDATE back to [SISWEB_OWNER].[LNKIEPSID]
*/

----Load persistent table
----The pkey includes all fields in source.  Update will never occcur.  Handling Insert & Delete.

--SET @StepStartTime= GETDATE()
--INSERT INTO SISSEARCH.LOG (LogDateTime, LogType, NameofSproc) VALUES(@StepStartTime, 'Information', @ProcName)
--SET @StepLogID= @@IDENTITY

--Merge [SISWEB_OWNER].[LNKIEPSIDPERSIST] as tgt
--Using
--	(
--	SELECT [MEDIANUMBER],[IESYSTEMCONTROLNUMBER],[PSID] 
--	FROM [SISWEB_OWNER].[LNKIEPSID]
--	) as src
--On
--	(
--	tgt.MEDIANUMBER = src.MEDIANUMBER and
--	tgt.[IESYSTEMCONTROLNUMBER] = src.[IESYSTEMCONTROLNUMBER] and
--	tgt.[PSID] = src.[PSID]
--	)
--WHEN NOT MATCHED BY TARGET THEN  
--	INSERT ([MEDIANUMBER],[IESYSTEMCONTROLNUMBER],[PSID], [LASTMODIFIEDDATE]) VALUES ([MEDIANUMBER],[IESYSTEMCONTROLNUMBER],[PSID], getdate()) 
--WHEN NOT MATCHED BY SOURCE THEN 
--	Delete;

----Add LastModifiedDate to source if it does not exist.
--IF NOT EXISTS (
--  SELECT * 
--  FROM   sys.columns
--  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKIEPSID]') 
--         AND name = 'LASTMODIFIEDDATE'
--)
--Alter table [SISWEB_OWNER].[LNKIEPSID]
--Add [LASTMODIFIEDDATE] datetime2(6) NULL

----Update source last modified date
--Update src
--set src.[LASTMODIFIEDDATE] = tgt.LASTMODIFIEDDATE
--From [SISWEB_OWNER].[LNKIEPSID] src
--inner join [SISWEB_OWNER].[LNKIEPSIDPERSIST] tgt on 
--	tgt.MEDIANUMBER = src.MEDIANUMBER and
--	tgt.[IESYSTEMCONTROLNUMBER] = src.[IESYSTEMCONTROLNUMBER] and
--	tgt.[PSID] = src.[PSID]
--Where src.[LASTMODIFIEDDATE] <> tgt.LASTMODIFIEDDATE or src.[LASTMODIFIEDDATE] is null

--SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - LNKIEPSID LASTMODIFIEDDATE Updates: ' +  cast(@RowCount as varchar(50))

--UPDATE SISSEARCH.LOG
--SET LapseTime= DATEDIFF(SS, @StepStartTime, GETDATE()),
--	LogMessage= 'LNKIEPSID LASTMODIFIEDDATE Updates',
--	DataValue= @RowCount
--	where LogID= @StepLogID

/*
LNKPRODUCT is being truncated and reloaded.  We need to know the last modified date for 
records in this table so we can trigger modifications when records are updated.  This
section of code adds a last modified date to the LNKPRODUCT by maintaining a persistent 
version of the table which includes a last modified date (based in the insert date).

Davide 20200206
[SISWEB_OWNER_STAGING].[LNKPRODUCT_Merge] procedure now maintains the [SISWEB_OWNER].[LNKPRODUCT] table which is not TRUNCATEd anymore. 
We can therefore eliminate the part of the code that does the MERGE with [SISWEB_OWNER].[LNKPRODUCTPERSIST] and the UPDATE back to [SISWEB_OWNER].[LNKPRODUCT]
*/

--SET @StepStartTime= GETDATE()
--INSERT INTO SISSEARCH.LOG (LogDateTime, LogType, NameofSproc) VALUES(@StepStartTime, 'Information', @ProcName)
--SET @StepLogID= @@IDENTITY

----Add LastModifiedDate to source if it does not exist.
--IF NOT EXISTS (
--  SELECT * 
--  FROM   sys.columns
--  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[LNKPRODUCT]') 
--         AND name = 'LASTMODIFIEDDATE'
--)
--Alter table [SISWEB_OWNER].[LNKPRODUCT]
--Add [LASTMODIFIEDDATE] datetime2(6) NULL

----Load persistent table
--Merge [SISWEB_OWNER].[LNKPRODUCTPERSIST] as tgt
--Using
--	(
--	SELECT
--	   [PRODUCTCODE]
--      ,[SEQUENCENUMBER]
--      ,[SALESMODELNO]
--      ,[SNP]
--      ,[SALESMODELSEQNO]
--      ,[STATUSINDICATOR]
--      ,[CCRINDICATOR]
--      ,[FREQUENCY]
--      ,[SHIPPEDDATE]
--      ,[CLASSICPARTINDICATOR] 
--	  ,[LASTMODIFIEDDATE]
--	FROM [SISWEB_OWNER].[LNKPRODUCT]
--	) as src
--On   
--	tgt.[PRODUCTCODE] = src.[PRODUCTCODE] and
--	tgt.[SEQUENCENUMBER] = src.[SEQUENCENUMBER] and
--	tgt.[SALESMODELNO] = src.[SALESMODELNO] and
--	tgt.[SNP] = src.[SNP] 
--WHEN MATCHED AND 
--	--(tgt.[PRODUCTCODE] <> src.[PRODUCTCODE] or (tgt.[PRODUCTCODE] is null and src.[PRODUCTCODE] is not null) or (tgt.[PRODUCTCODE] is not null and src.[PRODUCTCODE] is null)) or
--	--(tgt.[SEQUENCENUMBER] <> src.[SEQUENCENUMBER] or (tgt.[SEQUENCENUMBER] is null and src.[SEQUENCENUMBER] is not null) or (tgt.[SEQUENCENUMBER] is not null and src.[SEQUENCENUMBER] is null)) or
--	--(tgt.[SALESMODELNO] <> src.[SALESMODELNO] or (tgt.[SALESMODELNO] is null and src.[SALESMODELNO] is not null) or (tgt.[SALESMODELNO] is not null and src.[SALESMODELNO] is null)) or
--	--(tgt.[SNP] <> src.[SNP] or (tgt.[SNP] is null and src.[SNP] is not null) or (tgt.[SNP] is not null and src.[SNP] is null)) or
--	(tgt.[SALESMODELSEQNO] <> src.[SALESMODELSEQNO] or (tgt.[SALESMODELSEQNO] is null and src.[SALESMODELSEQNO] is not null) or (tgt.[SALESMODELSEQNO] is not null and src.[SALESMODELSEQNO] is null)) or
--	(tgt.[STATUSINDICATOR] <> src.[STATUSINDICATOR] or (tgt.[STATUSINDICATOR] is null and src.[STATUSINDICATOR] is not null) or (tgt.[STATUSINDICATOR] is not null and src.[STATUSINDICATOR] is null)) or
--	(tgt.[CCRINDICATOR] <> src.[CCRINDICATOR] or (tgt.[CCRINDICATOR] is null and src.[CCRINDICATOR] is not null) or (tgt.[CCRINDICATOR] is not null and src.[CCRINDICATOR] is null)) or
--	(tgt.[FREQUENCY] <> src.[FREQUENCY] or (tgt.[FREQUENCY] is null and src.[FREQUENCY] is not null) or (tgt.[FREQUENCY] is not null and src.[FREQUENCY] is null)) or
--	(tgt.[SHIPPEDDATE] <> src.[SHIPPEDDATE] or (tgt.[SHIPPEDDATE] is null and src.[SHIPPEDDATE] is not null) or (tgt.[SHIPPEDDATE] is not null and src.[SHIPPEDDATE] is null)) or
--	(tgt.[CLASSICPARTINDICATOR]  <> src.[CLASSICPARTINDICATOR]  or (tgt.[CLASSICPARTINDICATOR]  is null and src.[CLASSICPARTINDICATOR]  is not null) or (tgt.[CLASSICPARTINDICATOR]  is not null and src.[CLASSICPARTINDICATOR]  is null))
--    THEN UPDATE SET 
--	--tgt.[PRODUCTCODE] = src.[PRODUCTCODE],
--	--tgt.[SEQUENCENUMBER] = src.[SEQUENCENUMBER],
--	--tgt.[SALESMODELNO] = src.[SALESMODELNO],
--	--tgt.[SNP] = src.[SNP],
--	tgt.[SALESMODELSEQNO] = src.[SALESMODELSEQNO],
--	tgt.[STATUSINDICATOR] = src.[STATUSINDICATOR],
--	tgt.[CCRINDICATOR] = src.[CCRINDICATOR],
--	tgt.[FREQUENCY] = src.[FREQUENCY],
--	tgt.[SHIPPEDDATE] = src.[SHIPPEDDATE],
--	tgt.[CLASSICPARTINDICATOR]  = src.[CLASSICPARTINDICATOR],
--	tgt.[LASTMODIFIEDDATE] = getdate()
--WHEN NOT MATCHED BY TARGET THEN  
--	INSERT (
--	 [PRODUCTCODE]
--	,[SEQUENCENUMBER]
--	,[SALESMODELNO]
--	,[SNP]
--	,[SALESMODELSEQNO]
--	,[STATUSINDICATOR]
--	,[CCRINDICATOR]
--	,[FREQUENCY]
--	,[SHIPPEDDATE]
--	,[CLASSICPARTINDICATOR] 
--	,[LASTMODIFIEDDATE]
--	) VALUES (
--	 [PRODUCTCODE]
--	,[SEQUENCENUMBER]
--	,[SALESMODELNO]
--	,[SNP]
--	,[SALESMODELSEQNO]
--	,[STATUSINDICATOR]
--	,[CCRINDICATOR]
--	,[FREQUENCY]
--	,[SHIPPEDDATE]
--	,[CLASSICPARTINDICATOR] 
--	, getdate()
--	  ) 
--WHEN NOT MATCHED BY SOURCE THEN 
--	Delete;

----Update source last modified date
--Update src
--set src.[LASTMODIFIEDDATE] = tgt.LASTMODIFIEDDATE
--From [SISWEB_OWNER].[LNKPRODUCT] src
--inner join [SISWEB_OWNER].[LNKPRODUCTPERSIST] tgt on 
--	tgt.[PRODUCTCODE] = src.[PRODUCTCODE] and
--	tgt.[SEQUENCENUMBER] = src.[SEQUENCENUMBER] and
--	tgt.[SALESMODELNO] = src.[SALESMODELNO] and
--	tgt.[SNP] = src.[SNP] 
--Where src.[LASTMODIFIEDDATE] <> tgt.LASTMODIFIEDDATE or src.[LASTMODIFIEDDATE] is null

--SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - LNKPRODUCT LASTMODIFIEDDATE Updates: ' +  cast(@RowCount as varchar(50))

--UPDATE SISSEARCH.LOG
--SET LapseTime= DATEDIFF(SS, @StepStartTime, GETDATE()),
--	LogMessage= 'LNKPRODUCT LASTMODIFIEDDATE Updates',
--	DataValue= @RowCount
--	where LogID= @StepLogID

/*
MASPRODUCT is being truncated and reloaded.  We need to know the last modified date for 
records in this table so we can trigger modifications when records are updated.  This
section of code adds a last modified date to the MASPRODUCT by maintaining a persistent 
version of the table which includes a last modified date (based in the insert date).

Davide 20200206
[SISWEB_OWNER_STAGING].[MASPRODUCT_Merge] procedure now maintains the [SISWEB_OWNER].[MASPRODUCT] table which is not TRUNCATEd anymore. 
We can therefore eliminate the part of the code that does the MERGE with [SISWEB_OWNER].[MASPRODUCTPERSIST] and the UPDATE back to [SISWEB_OWNER].[MASPRODUCT]
*/

--SET @StepStartTime= GETDATE()
--INSERT INTO SISSEARCH.LOG (LogDateTime, LogType, NameofSproc) VALUES(@StepStartTime, 'Information', @ProcName)
--SET @StepLogID= @@IDENTITY

----Add LastModifiedDate to source if it does not exist.
--IF NOT EXISTS (
--  SELECT * 
--  FROM   sys.columns
--  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[MASPRODUCT]') 
--         AND name = 'LASTMODIFIEDDATE'
--)
--Alter table [SISWEB_OWNER].[MASPRODUCT]
--Add [LASTMODIFIEDDATE] datetime2(6) NULL

----Load persistent table
--Merge [SISWEB_OWNER].[MASPRODUCTPERSIST] as tgt
--Using
--	(
--	SELECT [PRODUCTCODE]
--      ,[SEQUENCENUMBER]
--      ,[LANGUAGEINDICATOR]
--      ,[PRODUCTTYPE]
--      ,[PRODUCTDESCRIPTION]
--      ,[FREQUENCY]
--      ,[LASTMODIFIEDDATE]
--	FROM [SISWEB_OWNER].[MASPRODUCT]
--	) as src
--On
--	tgt.[PRODUCTCODE] = src.[PRODUCTCODE] and
--	tgt.[SEQUENCENUMBER] = src.[SEQUENCENUMBER] and 
--	tgt.[LANGUAGEINDICATOR] = src.[LANGUAGEINDICATOR]
--WHEN MATCHED AND
--	--(tgt.[PRODUCTCODE] <> src.[PRODUCTCODE] or (tgt.[PRODUCTCODE] is null and src.[PRODUCTCODE] is not null) or (tgt.[PRODUCTCODE] is not null and src.[PRODUCTCODE] is null)) or
--	--(tgt.[SEQUENCENUMBER] <> src.[SEQUENCENUMBER] or (tgt.[SEQUENCENUMBER] is null and src.[SEQUENCENUMBER] is not null) or (tgt.[SEQUENCENUMBER] is not null and src.[SEQUENCENUMBER] is null)) or
--	--(tgt.[LANGUAGEINDICATOR] <> src.[LANGUAGEINDICATOR] or (tgt.[LANGUAGEINDICATOR] is null and src.[LANGUAGEINDICATOR] is not null) or (tgt.[LANGUAGEINDICATOR] is not null and src.[LANGUAGEINDICATOR] is null)) or
--	(tgt.[PRODUCTTYPE] <> src.[PRODUCTTYPE] or (tgt.[PRODUCTTYPE] is null and src.[PRODUCTTYPE] is not null) or (tgt.[PRODUCTTYPE] is not null and src.[PRODUCTTYPE] is null)) or
--	(tgt.[PRODUCTDESCRIPTION] <> src.[PRODUCTDESCRIPTION] or (tgt.[PRODUCTDESCRIPTION] is null and src.[PRODUCTDESCRIPTION] is not null) or (tgt.[PRODUCTDESCRIPTION] is not null and src.[PRODUCTDESCRIPTION] is null)) or
--	(tgt.[FREQUENCY] <> src.[FREQUENCY] or (tgt.[FREQUENCY] is null and src.[FREQUENCY] is not null) or (tgt.[FREQUENCY] is not null and src.[FREQUENCY] is null))
--	THEN UPDATE SET
--	--tgt.[PRODUCTCODE] = src.[PRODUCTCODE],
--	--tgt.[SEQUENCENUMBER] = src.[SEQUENCENUMBER],
--	--tgt.[LANGUAGEINDICATOR] = src.[LANGUAGEINDICATOR],
--	tgt.[PRODUCTTYPE] = src.[PRODUCTTYPE],
--	tgt.[PRODUCTDESCRIPTION] = src.[PRODUCTDESCRIPTION],
--	tgt.[FREQUENCY] = src.[FREQUENCY],
--	tgt.[LASTMODIFIEDDATE] = getdate()
--WHEN NOT MATCHED BY TARGET THEN  
--	INSERT (
--	[PRODUCTCODE]
--      ,[SEQUENCENUMBER]
--      ,[LANGUAGEINDICATOR]
--      ,[PRODUCTTYPE]
--      ,[PRODUCTDESCRIPTION]
--      ,[FREQUENCY]
--      ,[LASTMODIFIEDDATE]
--	  ) VALUES (
--	  [PRODUCTCODE]
--      ,[SEQUENCENUMBER]
--      ,[LANGUAGEINDICATOR]
--      ,[PRODUCTTYPE]
--      ,[PRODUCTDESCRIPTION]
--      ,[FREQUENCY]
--      , getdate()) 
--WHEN NOT MATCHED BY SOURCE THEN 
--	Delete;

----Update source last modified date
--Update src
--set src.[LASTMODIFIEDDATE] = tgt.LASTMODIFIEDDATE
--From [SISWEB_OWNER].[MASPRODUCT] src
--inner join [SISWEB_OWNER].[MASPRODUCTPERSIST] tgt on 
--	tgt.[PRODUCTCODE] = src.[PRODUCTCODE] and
--	tgt.[SEQUENCENUMBER] = src.[SEQUENCENUMBER] and 
--	tgt.[LANGUAGEINDICATOR] = src.[LANGUAGEINDICATOR]
--Where src.[LASTMODIFIEDDATE] <> tgt.LASTMODIFIEDDATE or src.[LASTMODIFIEDDATE] is null

--SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - MASPRODUCT LASTMODIFIEDDATE Updates: ' +  cast(@RowCount as varchar(50))

--UPDATE SISSEARCH.LOG
--SET LapseTime= DATEDIFF(SS, @StepStartTime, GETDATE()),
--	LogMessage= 'MASPRODUCT LASTMODIFIEDDATE Updates',
--	DataValue= @RowCount
--	where LogID= @StepLogID


/*
MASSNP is being truncated and reloaded.  We need to know the last modified date for 
records in this table so we can trigger modifications when records are updated.  This
section of code adds a last modified date to the MASSNP by maintaining a persistent 
version of the table which includes a last modified date (based in the insert date).

Davide 20200206
[SISWEB_OWNER_STAGING].[MASSNP_Merge] procedure now maintains the [SISWEB_OWNER].[MASSNP] table which is not TRUNCATEd anymore. 
We can therefore eliminate the part of the code that does the MERGE with [SISWEB_OWNER].[MASSNP] and the UPDATE back to [SISWEB_OWNER].[MASSNP]
*/

--SET @StepStartTime= GETDATE()
--INSERT INTO SISSEARCH.LOG (LogDateTime, LogType, NameofSproc) VALUES(@StepStartTime, 'Information', @ProcName)
--SET @StepLogID= @@IDENTITY

----Add LastModifiedDate to source if it does not exist.
--IF NOT EXISTS (
--  SELECT * 
--  FROM   sys.columns
--  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[MASSNP]') 
--         AND name = 'LASTMODIFIEDDATE'
--)
--Alter table [SISWEB_OWNER].[MASSNP]
--Add [LASTMODIFIEDDATE] datetime2(6) NULL

----Load persistent table
--Merge [SISWEB_OWNER].[MASSNPPERSIST] as tgt
--Using
--	(
--	SELECT [CAPTIVESERIALNUMBERPREFIX]
--      ,[BEGINNINGRANGE]
--      ,[ENDRANGE]
--      ,[PRIMESERIALNUMBERPREFIX]
--      ,[MEDIANUMBER]
--      ,[DOCUMENTTITLE]
--      ,[CONFIGURATIONTYPE]
--      ,[LASTMODIFIEDDATE]
--	FROM [SISWEB_OWNER].[MASSNP]
--	) as src
--On
--	tgt.[CAPTIVESERIALNUMBERPREFIX] = src.[CAPTIVESERIALNUMBERPREFIX] and
--	tgt.[BEGINNINGRANGE] = src.[BEGINNINGRANGE] and
--	tgt.[ENDRANGE] = src.[ENDRANGE] and
--	tgt.[PRIMESERIALNUMBERPREFIX] = src.[PRIMESERIALNUMBERPREFIX] and
--	tgt.[MEDIANUMBER] = src.[MEDIANUMBER] and
--	tgt.[DOCUMENTTITLE] = src.[DOCUMENTTITLE]
--WHEN MATCHED AND
--	--(tgt.[CAPTIVESERIALNUMBERPREFIX] <> src.[CAPTIVESERIALNUMBERPREFIX] or (tgt.[CAPTIVESERIALNUMBERPREFIX] is null and src.[CAPTIVESERIALNUMBERPREFIX] is not null) or (tgt.[CAPTIVESERIALNUMBERPREFIX] is not null and src.[CAPTIVESERIALNUMBERPREFIX] is null)) or
--	--(tgt.[BEGINNINGRANGE] <> src.[BEGINNINGRANGE] or (tgt.[BEGINNINGRANGE] is null and src.[BEGINNINGRANGE] is not null) or (tgt.[BEGINNINGRANGE] is not null and src.[BEGINNINGRANGE] is null)) or
--	--(tgt.[ENDRANGE] <> src.[ENDRANGE] or (tgt.[ENDRANGE] is null and src.[ENDRANGE] is not null) or (tgt.[ENDRANGE] is not null and src.[ENDRANGE] is null)) or
--	--(tgt.[PRIMESERIALNUMBERPREFIX] <> src.[PRIMESERIALNUMBERPREFIX] or (tgt.[PRIMESERIALNUMBERPREFIX] is null and src.[PRIMESERIALNUMBERPREFIX] is not null) or (tgt.[PRIMESERIALNUMBERPREFIX] is not null and src.[PRIMESERIALNUMBERPREFIX] is null)) or
--	--(tgt.[MEDIANUMBER] <> src.[MEDIANUMBER] or (tgt.[MEDIANUMBER] is null and src.[MEDIANUMBER] is not null) or (tgt.[MEDIANUMBER] is not null and src.[MEDIANUMBER] is null)) or
--	--(tgt.[DOCUMENTTITLE] <> src.[DOCUMENTTITLE] or (tgt.[DOCUMENTTITLE] is null and src.[DOCUMENTTITLE] is not null) or (tgt.[DOCUMENTTITLE] is not null and src.[DOCUMENTTITLE] is null)) or
--	(tgt.[CONFIGURATIONTYPE] <> src.[CONFIGURATIONTYPE] or (tgt.[CONFIGURATIONTYPE] is null and src.[CONFIGURATIONTYPE] is not null) or (tgt.[CONFIGURATIONTYPE] is not null and src.[CONFIGURATIONTYPE] is null))
--	THEN UPDATE SET
--	--tgt.[CAPTIVESERIALNUMBERPREFIX] = src.[CAPTIVESERIALNUMBERPREFIX],
--	--tgt.[BEGINNINGRANGE] = src.[BEGINNINGRANGE],
--	--tgt.[ENDRANGE] = src.[ENDRANGE],
--	--tgt.[PRIMESERIALNUMBERPREFIX] = src.[PRIMESERIALNUMBERPREFIX],
--	--tgt.[MEDIANUMBER] = src.[MEDIANUMBER],
--	--tgt.[DOCUMENTTITLE] = src.[DOCUMENTTITLE],
--	tgt.[CONFIGURATIONTYPE] = src.[CONFIGURATIONTYPE],
--	tgt.[LASTMODIFIEDDATE] = getdate()
--WHEN NOT MATCHED BY TARGET THEN  
--	INSERT (
--	[CAPTIVESERIALNUMBERPREFIX]
--      ,[BEGINNINGRANGE]
--      ,[ENDRANGE]
--      ,[PRIMESERIALNUMBERPREFIX]
--      ,[MEDIANUMBER]
--      ,[DOCUMENTTITLE]
--      ,[CONFIGURATIONTYPE]
--      ,[LASTMODIFIEDDATE]
--	  ) VALUES (
--	  [CAPTIVESERIALNUMBERPREFIX]
--      ,[BEGINNINGRANGE]
--      ,[ENDRANGE]
--      ,[PRIMESERIALNUMBERPREFIX]
--      ,[MEDIANUMBER]
--      ,[DOCUMENTTITLE]
--      ,[CONFIGURATIONTYPE]
--      , getdate()) 
--WHEN NOT MATCHED BY SOURCE THEN 
--	Delete;

----Update source last modified date
--Update src
--set src.[LASTMODIFIEDDATE] = tgt.LASTMODIFIEDDATE
--From [SISWEB_OWNER].[MASSNP] src
--inner join [SISWEB_OWNER].[MASSNPPERSIST] tgt on 
--	tgt.[CAPTIVESERIALNUMBERPREFIX] = src.[CAPTIVESERIALNUMBERPREFIX] and
--	tgt.[BEGINNINGRANGE] = src.[BEGINNINGRANGE] and
--	tgt.[ENDRANGE] = src.[ENDRANGE] and
--	tgt.[PRIMESERIALNUMBERPREFIX] = src.[PRIMESERIALNUMBERPREFIX] and
--	tgt.[MEDIANUMBER] = src.[MEDIANUMBER] and
--	tgt.[DOCUMENTTITLE] = src.[DOCUMENTTITLE]
--Where src.[LASTMODIFIEDDATE] <> tgt.LASTMODIFIEDDATE or src.[LASTMODIFIEDDATE] is null

--SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - MASSNP LASTMODIFIEDDATE Updates: ' +  cast(@RowCount as varchar(50))

--UPDATE SISSEARCH.LOG
--SET LapseTime= DATEDIFF(SS, @StepStartTime, GETDATE()),
--	LogMessage= 'MASSNP LASTMODIFIEDDATE Updates',
--	DataValue= @RowCount
--	where LogID= @StepLogID


/*
*********************************************
*/

--IESYSTEMCONTROLNUMBER
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	IF OBJECT_ID('tempdb..#IE') IS NOT NULL DROP TABLE #IE
	Select IESYSTEMCONTROLNUMBER, Max(LASTMODIFIEDDATE) LASTMODIFIEDDATE
	into #IE
	From 
	(
	Select IESYSTEMCONTROLNUMBER, cast(LASTMODIFIEDDATE as datetime) LASTMODIFIEDDATE From [SISWEB_OWNER_SHADOW].[LNKPARTSIESNP]
	Union All
	Select IESYSTEMCONTROLNUMBER, cast(LASTMODIFIEDDATE as datetime) LASTMODIFIEDDATE From [SISWEB_OWNER].[LNKIEDATE]
	Union All
	Select IESYSTEMCONTROLNUMBER, cast(LASTMODIFIEDDATE as datetime) LASTMODIFIEDDATE From [SISWEB_OWNER].[LNKIETITLE]
	Union All
	Select IESYSTEMCONTROLNUMBER, cast(LASTMODIFIEDDATE as datetime) LASTMODIFIEDDATE From [SISWEB_OWNER].[LNKIESNP]
	Union All
	Select IESYSTEMCONTROLNUMBER, cast(LASTMODIFIEDDATE as datetime) LASTMODIFIEDDATE From [SISWEB_OWNER].[LNKIESMCS]
	Union All
	Select IESYSTEMCONTROLNUMBER, cast(LASTMODIFIEDDATE as datetime) LASTMODIFIEDDATE From [SISWEB_OWNER_SHADOW].LNKCONSISTLIST
	Union All
	Select IESYSTEMCONTROLNUMBER, cast(LASTMODIFIEDDATE as datetime) LASTMODIFIEDDATE From [SISWEB_OWNER_SHADOW].[LNKIEPSID] --pbf Added 20190228
	Union All 
	--pbf 20190315
	--LNKRelatedPartInfo for matching ConsistPart
	Select b.IESYSTEMCONTROLNUMBER, max(cast(k.LASTMODIFIEDDATE as datetime)) LASTMODIFIEDDATE
	from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] b With(NolocK)--3M
	inner join [SISWEB_OWNER_SHADOW].LNKCONSISTLIST d With(Nolock) --56M
	on b.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER
	inner join [SISWEB_OWNER].[LNKRELATEDPARTINFO] k
	on k.PARTNUMBER = d.PARTNUMBER
	Group by b.IESYSTEMCONTROLNUMBER
	Union All 
	--pbf 20190315
	--LNKRelatedPartInfo for matching IEPart
	Select b.IESYSTEMCONTROLNUMBER, max(cast(k.LASTMODIFIEDDATE as datetime)) LASTMODIFIEDDATE
	from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] b With(NolocK)--3M
	inner join [SISWEB_OWNER].[LNKRELATEDPARTINFO] k
	on k.PARTNUMBER = b.IEPARTNUMBER
	Group by b.IESYSTEMCONTROLNUMBER
	Union All
	SELECT [IESYSTEMCONTROLNUMBER], cast([LASTMODIFIEDDATE] as datetime) LASTMODIFIEDDATE FROM [SISWEB_OWNER].[LNKIEINFOTYPE] --pbf Added 20190327
	) x
	Group by IESYSTEMCONTROLNUMBER

	Update l
	set LASTMODIFIEDDATE = u.LASTMODIFIEDDATE
	From [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] l
	inner join #IE u on l.IESYSTEMCONTROLNUMBER = u.IESYSTEMCONTROLNUMBER
	where cast(l.LASTMODIFIEDDATE as datetime) < u.LASTMODIFIEDDATE

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - LNKMEDIAIEPART LASTMODIFIEDDATE IESYSTEMCONTROLNUMBER Updates: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'LNKMEDIAIEPART LASTMODIFIEDDATE IESYSTEMCONTROLNUMBER Updates';



--BASEENGCONTROLNO
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	IF OBJECT_ID('tempdb..#IEC') IS NOT NULL DROP TABLE #IEC
	Select IESYSTEMCONTROLNUMBER, max(cast(LASTMODIFIEDDATE as datetime)) LASTMODIFIEDDATE
	into #IEC
	From [SISWEB_OWNER_SHADOW].LNKCONSISTLIST --Conversion
	Group by IESYSTEMCONTROLNUMBER
 
	Update l
	set LASTMODIFIEDDATE = u.LASTMODIFIEDDATE
	From [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] l
	inner join #IEC u on l.BASEENGCONTROLNO = u.IESYSTEMCONTROLNUMBER
	where cast(l.LASTMODIFIEDDATE as datetime) < u.LASTMODIFIEDDATE

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - LNKMEDIAIEPART LASTMODIFIEDDATE BASEENGCONTROLNO Updates: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'LNKMEDIAIEPART LASTMODIFIEDDATE BASEENGCONTROLNO Updates';


--MEDIANUMBER
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	IF OBJECT_ID('tempdb..#MN') IS NOT NULL DROP TABLE #MN
	Select MEDIANUMBER, Max(LASTMODIFIEDDATE) LASTMODIFIEDDATE
	into #MN
	From 
	(
	Select MEDIANUMBER, cast(LASTMODIFIEDDATE as datetime) LASTMODIFIEDDATE From [SISWEB_OWNER].[MASMEDIA]
	Union All
	Select b.MEDIANUMBER, cast(a.LASTMODIFIEDDATE as datetime) LASTMODIFIEDDATE From [SISWEB_OWNER].[LNKMEDIASNP] a 
      	   inner join [SISWEB_OWNER].[MASMEDIA] b on b.[BASEENGLISHMEDIANUMBER]=a.MEDIANUMBER
	) x
	Group by MEDIANUMBER

	Update l
	set LASTMODIFIEDDATE = u.LASTMODIFIEDDATE
	From [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] l
	inner join #MN u on l.MEDIANUMBER = u.MEDIANUMBER
	where cast(l.LASTMODIFIEDDATE as datetime) < u.LASTMODIFIEDDATE

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - LNKMEDIAIEPART LASTMODIFIEDDATE MEDIANUMBER Updates: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'LNKMEDIAIEPART LASTMODIFIEDDATE MEDIANUMBER Updates';


--Language (Handing en-US only)
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	Update l
	set LASTMODIFIEDDATE = u.[LastModifiedDate]
	From [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] l
	cross join (SELECT [LastModifiedDate] FROM [sis].[Language] where Language_Tag = 'en-US') u --pbf 20190327; We are only handling en-US currently.  Once we begin dealing with multiple languages, we will need to create and impliment logic to deal with language updates dynamically
	where cast(l.LASTMODIFIEDDATE as datetime) < u.[LastModifiedDate]

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - LNKMEDIAIEPART LASTMODIFIEDDATE LANGUAGE Updates: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'LNKMEDIAIEPART LASTMODIFIEDDATE LANGUAGE Updates';
	
/*
--AsShipped Engine
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

  Update p
  set p.LASTMODIFIEDDATE = a.LASTMODIFIEDDATE
  FROM [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] p
  inner join [SISWEB_OWNER].[LNKPARTSIESNP] snp on p.IESYSTEMCONTROLNUMBER = snp.IESYSTEMCONTROLNUMBER and p.MEDIANUMBER = snp.MEDIANUMBER
  --inner join [SISWEB_OWNER].[LNKASSHIPPEDCONSIST] a on a.SNP = snp.SNP and a.SNR between snp.BEGINNINGRANGE and snp.ENDRANGE --Requires that Full_Load_P4 is run to prepare the source table
  inner join [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE] a on a.SNP = snp.SNP and a.SNR between snp.BEGINNINGRANGE and snp.ENDRANGE --Requires that Full_Load_P4 is run to prepare the source table; 20190506 pbf redirec to new source
  Where p.LASTMODIFIEDDATE < a.[UPDATEDATETIME] and a.[UPDATEDATETIME] is not null

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - LNKMEDIAIEPART LASTMODIFIEDDATE LNKASSHIPPEDCONSIST Updates: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'LNKMEDIAIEPART LASTMODIFIEDDATE LNKASSHIPPEDCONSIST Updates';
	

--AsShipped Part
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

  Update p
  set p.LASTMODIFIEDDATE = a.LASTMODIFIEDDATE
  FROM [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] p
  inner join [SISWEB_OWNER].[LNKPARTSIESNP] snp on p.IESYSTEMCONTROLNUMBER = snp.IESYSTEMCONTROLNUMBER and p.MEDIANUMBER = snp.MEDIANUMBER
  inner join [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS] a on a.SNP = snp.SNP and a.SNR between snp.BEGINNINGRANGE and snp.ENDRANGE --Requires that Full_Load_P4 is run to prepare the source table
  Where p.LASTMODIFIEDDATE < a.LASTMODIFIEDDATE and a.LASTMODIFIEDDATE is not null

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - LNKMEDIAIEPART LASTMODIFIEDDATE LNKASSHIPPEDPRODUCTDETAILS Updates: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'LNKMEDIAIEPART LASTMODIFIEDDATE LNKASSHIPPEDPRODUCTDETAILS Updates';


--AsShipped Part2
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

  Update p
  set p.LASTMODIFIEDDATE = a.LASTMODIFIEDDATE
  FROM [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] p
  inner join [SISWEB_OWNER].[LNKPARTSIESNP] snp on p.IESYSTEMCONTROLNUMBER = snp.IESYSTEMCONTROLNUMBER and p.MEDIANUMBER = snp.MEDIANUMBER
  inner join [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2] a on a.SNP = snp.SNP and a.SNR between snp.BEGINNINGRANGE and snp.ENDRANGE --Requires that Full_Load_P4 is run to prepare the source table
  Where p.LASTMODIFIEDDATE < a.LASTMODIFIEDDATE and a.LASTMODIFIEDDATE is not null

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - LNKMEDIAIEPART LASTMODIFIEDDATE LNKASSHIPPEDPRODUCTDETAILS2 Updates: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'LNKMEDIAIEPART LASTMODIFIEDDATE LNKASSHIPPEDPRODUCTDETAILS2 Updates';


--AsShipped Part3
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

  Update p
  set p.LASTMODIFIEDDATE = a.LASTMODIFIEDDATE
  FROM [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] p
  inner join [SISWEB_OWNER].[LNKPARTSIESNP] snp on p.IESYSTEMCONTROLNUMBER = snp.IESYSTEMCONTROLNUMBER and p.MEDIANUMBER = snp.MEDIANUMBER
  inner join [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3] a on a.SNP = snp.SNP and a.SNR between snp.BEGINNINGRANGE and snp.ENDRANGE --Requires that Full_Load_P4 is run to prepare the source table
  Where p.LASTMODIFIEDDATE < a.LASTMODIFIEDDATE and a.LASTMODIFIEDDATE is not null

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - LNKMEDIAIEPART LASTMODIFIEDDATE LNKASSHIPPEDPRODUCTDETAILS3 Updates: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'LNKMEDIAIEPART LASTMODIFIEDDATE LNKASSHIPPEDPRODUCTDETAILS3 Updates';
*/


  --Update all IE with same SNP when LNKPRODUCT is updated
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	--Update LNKPRODUCT_PARTIAL table if any of the field is changed in [SISWEB_OWNER].[LNKPRODUCT]
	MERGE [SISWEB_OWNER].[LNKPRODUCT_PARTIAL] tgt
	USING [SISWEB_OWNER].[LNKPRODUCT] src
	ON tgt.ID = src.ID
	WHEN MATCHED AND EXISTS
	(
		SELECT src.PRODUCTCODE, src.SALESMODELNO, src.SNP, src.STATUSINDICATOR, src.CCRINDICATOR, src.FREQUENCY, src.SHIPPEDDATE, src.CLASSICPARTINDICATOR
		EXCEPT
		SELECT tgt.PRODUCTCODE, tgt.SALESMODELNO, tgt.SNP, tgt.STATUSINDICATOR, tgt.CCRINDICATOR, tgt.FREQUENCY, tgt.SHIPPEDDATE, tgt.CLASSICPARTINDICATOR
	)
	THEN UPDATE SET tgt.PRODUCTCODE = src.PRODUCTCODE,
		tgt.SALESMODELNO = src.SALESMODELNO,
		tgt.SNP = src.SNP,
		tgt.STATUSINDICATOR = src.STATUSINDICATOR,
		tgt.CCRINDICATOR = src.CCRINDICATOR,
		tgt.FREQUENCY = src.FREQUENCY,
		tgt.SHIPPEDDATE = src.SHIPPEDDATE,
		tgt.CLASSICPARTINDICATOR = src.CLASSICPARTINDICATOR,
		tgt.LASTMODIFIEDDATE = src.LASTMODIFIEDDATE
	WHEN NOT MATCHED BY TARGET
	THEN INSERT(ID, PRODUCTCODE, SALESMODELNO, SNP, STATUSINDICATOR, CCRINDICATOR, FREQUENCY, SHIPPEDDATE, CLASSICPARTINDICATOR, LASTMODIFIEDDATE)
			VALUES (src.ID, src.PRODUCTCODE, src.SALESMODELNO, src.SNP, src.STATUSINDICATOR, src.CCRINDICATOR, src.FREQUENCY, src.SHIPPEDDATE, src.CLASSICPARTINDICATOR, src.LASTMODIFIEDDATE)
	WHEN NOT MATCHED BY SOURCE
	THEN DELETE;
	
  --Update LASTMODIFIEDDATE if changes to [SISWEB_OWNER].[LNKPRODUCT_PARTIAL]
  Update p
  set p.LASTMODIFIEDDATE = a.LASTMODIFIEDDATE
  FROM [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] p
  inner join [SISWEB_OWNER_SHADOW].[LNKPARTSIESNP] snp on p.IESYSTEMCONTROLNUMBER = snp.IESYSTEMCONTROLNUMBER and p.MEDIANUMBER = snp.MEDIANUMBER
  inner join 
  (
	Select max(a.LASTMODIFIEDDATE) LASTMODIFIEDDATE, SNP
	From [SISWEB_OWNER].[LNKPRODUCT_PARTIAL] a
	where a.LASTMODIFIEDDATE is not null
	Group by a.SNP
  )a on a.SNP = snp.SNP 
  Where p.LASTMODIFIEDDATE < a.LASTMODIFIEDDATE and a.LASTMODIFIEDDATE is not null

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - LNKMEDIAIEPART LASTMODIFIEDDATE LNKPRODUCT Updates: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'LNKMEDIAIEPART LASTMODIFIEDDATE LNKPRODUCT Updates';


  --Update all IE with same ProductCOde when MASPRODUCT is updated
  
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

	--Update LNKPRODUCT_PARTIAL table if any of the field is changed in [SISWEB_OWNER].[LNKPRODUCT]
	MERGE [SISWEB_OWNER].[MASPRODUCT_PARTIAL] tgt
	USING [SISWEB_OWNER].[MASPRODUCT] src
	ON tgt.ID = src.ID
	WHEN MATCHED AND EXISTS
	(
		SELECT src.PRODUCTCODE, src.PRODUCTTYPE, src.PRODUCTDESCRIPTION, src.FREQUENCY
		EXCEPT
		SELECT tgt.PRODUCTCODE, tgt.PRODUCTTYPE, tgt.PRODUCTDESCRIPTION, tgt.FREQUENCY
	)
	THEN UPDATE SET 
		tgt.PRODUCTCODE  = src.PRODUCTCODE,
		tgt.PRODUCTTYPE  = src.PRODUCTTYPE,
		tgt.PRODUCTDESCRIPTION  = src.PRODUCTDESCRIPTION,
		tgt.FREQUENCY  = src.FREQUENCY,
		tgt.LASTMODIFIEDDATE = src.LASTMODIFIEDDATE
	WHEN NOT MATCHED BY TARGET
	THEN INSERT(ID, PRODUCTCODE, PRODUCTTYPE, PRODUCTDESCRIPTION, FREQUENCY, LASTMODIFIEDDATE)
			VALUES (src.ID, src.PRODUCTCODE, src.PRODUCTTYPE, src.PRODUCTDESCRIPTION, src.FREQUENCY, src.LASTMODIFIEDDATE)
	WHEN NOT MATCHED BY SOURCE
	THEN DELETE;

  --Update LASTMODIFIEDDATE if changes to [SISWEB_OWNER].[MASPRODUCT_PARTIAL]
  Update p
  set p.LASTMODIFIEDDATE = a.LASTMODIFIEDDATE
  FROM [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] p
  inner join [SISWEB_OWNER_SHADOW].[LNKPARTSIESNP] snp on p.IESYSTEMCONTROLNUMBER = snp.IESYSTEMCONTROLNUMBER and p.MEDIANUMBER = snp.MEDIANUMBER
  inner join 
  (
	Select max(a.LASTMODIFIEDDATE) LASTMODIFIEDDATE, SNP
	FROM [SISWEB_OWNER].[LNKPRODUCT] b
	inner join [SISWEB_OWNER].[MASPRODUCT_PARTIAL] a on a.PRODUCTCODE = b.PRODUCTCODE
	where a.LASTMODIFIEDDATE is not null
	Group by b.SNP
  ) a on a.SNP = snp.SNP 
  Where p.LASTMODIFIEDDATE < a.LASTMODIFIEDDATE and a.LASTMODIFIEDDATE is not null

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - LNKMEDIAIEPART LASTMODIFIEDDATE MASPRODUCT Updates: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'LNKMEDIAIEPART LASTMODIFIEDDATE MASPRODUCT Updates';


  --Update all IE with same snp (based on CAPTIVESERIALNUMBERPREFIX) when MASSNP is updated
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

  Update p
  set p.LASTMODIFIEDDATE = a.LASTMODIFIEDDATE
  FROM [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] p
  inner join [SISWEB_OWNER_SHADOW].[LNKPARTSIESNP] snp on p.IESYSTEMCONTROLNUMBER = snp.IESYSTEMCONTROLNUMBER and p.MEDIANUMBER = snp.MEDIANUMBER
  inner join 
  (
	Select max(a.LASTMODIFIEDDATE) LASTMODIFIEDDATE, PRIMESERIALNUMBERPREFIX PSNP, CAPTIVESERIALNUMBERPREFIX CNP, MEDIANUMBER
	FROM [SISWEB_OWNER].[MASSNP] a
	where a.LASTMODIFIEDDATE is not null
	Group by PRIMESERIALNUMBERPREFIX, CAPTIVESERIALNUMBERPREFIX, MEDIANUMBER
  ) a on (a.PSNP = snp.SNP or a.CNP = snp.SNP) and a.MEDIANUMBER = p.MEDIANUMBER --Same prime or captive snp.  Also same media number.
  Where p.LASTMODIFIEDDATE < a.LASTMODIFIEDDATE and a.LASTMODIFIEDDATE is not null

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - LNKMEDIAIEPART LASTMODIFIEDDATE MASSNP Updates: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'LNKMEDIAIEPART LASTMODIFIEDDATE MASSNP Updates';




--Finish
SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LOGID = @SPStartLogID

DELETE FROM SISSEARCH.LOG WHERE DATEDIFF(DD, LogDateTime, GetDate())>30 and NameofSproc= @ProcName

END TRY

BEGIN CATCH 
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT= ERROR_LINE()

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC SISSEARCH.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error
END CATCH


End
GO

