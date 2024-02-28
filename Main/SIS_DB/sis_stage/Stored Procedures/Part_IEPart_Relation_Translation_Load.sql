-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180130
-- Description: Full load [sis_stage].[Part_IEPart_Relation_Translation_Load]
-- Modified By: Kishor Padmanabhan
-- Modified Date: 20220919
-- Modified Reason: Moved Part and OfParts column to MediaSequence from IEPart
-- Associated User Story: 21373
--Exec [sis_stage].[Part_IEPart_Relation_Translation_Load]
--Truncate table [sis_stage].Part_IEPart_Relation_Translation
-- =============================================
CREATE PROCEDURE [sis_stage].[Part_IEPart_Relation_Translation_Load]
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

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

    -- Insert statements for procedure here

--Load Authoring
Insert into [sis_stage].[Part_IEPart_Relation_Translation] 
(
 [Part_IEPart_Relation_ID]
,[Language_ID]
,[Part_IEPart_Name]
,[Part_IEPart_Modifier]
,[Part_IEPart_Note] 
)
Select 
 ier.Part_IEPart_Relation_ID
,l.Language_ID
,max(CASE WHEN LEN(ISNULL(cl.COMMENTS,'')) > 0 THEN ltrim(rtrim(cl.COMMENTS)) ELSE ltrim(rtrim(cl.PARTNAME)) END ) AS COMMENTS
,max(case when ltrim(rtrim(cl.PARTMODIFIER)) = '' then null else ltrim(rtrim(cl.PARTMODIFIER)) end) PARTMODIFIER
,max(case when ltrim(rtrim(cl.NOTE)) = '' then null else ltrim(rtrim(cl.NOTE)) end) NOTE
From
(--Limit to last version of each IE
	Select *
	From 
	(
	--All records related to last version of each IE
		Select 
		 gp.BASEENGCONTROLNO_Mod [BASEENGCONTROLNO]
		,gp.[IESYSTEMCONTROLNUMBER]
		,d.[IEPUBDATE]
		,Row_Number() Over (Partition By gp.BASEENGCONTROLNO_Mod, d.[IEPUBDATE] Order by gp.[IEUPDATEDATE] desc, gp.[IEPARTNUMBER] desc) RowRank --Take last version based ordered by IEUpdateDate and IEPartNumber No in cases of ambiguity.
		From 
		(
			Select *, 
			CASE
			   WHEN IETYPE = 'L' THEN CASE BASEENGCONTROLNO
									  WHEN '-' THEN IESYSTEMCONTROLNUMBER + '-' + MEDIANUMBER
									  ELSE BASEENGCONTROLNO + '-' + MEDIANUMBER
									  END
			   ELSE CASE BASEENGCONTROLNO
					WHEN '-' THEN IESYSTEMCONTROLNUMBER
					ELSE BASEENGCONTROLNO
					END
			END BASEENGCONTROLNO_Mod 
			from [SISWEB_OWNER].[LNKMEDIAIEPART]
		) gp
		inner join [SISWEB_OWNER].[LNKIEDATE] d on gp.[IESYSTEMCONTROLNUMBER] = d.[IESYSTEMCONTROLNUMBER]
		Inner Join 
		(--Only load the most recent version of each IE (base english control number) as a group part based on the IEPUBDATE.
			Select 
			CASE
			   WHEN IETYPE = 'L' THEN CASE gp.BASEENGCONTROLNO
									  WHEN '-' THEN gp.IESYSTEMCONTROLNUMBER + '-' + gp.MEDIANUMBER
									  ELSE gp.BASEENGCONTROLNO + '-' + gp.MEDIANUMBER
									  END
			   ELSE CASE gp.BASEENGCONTROLNO
					WHEN '-' THEN gp.IESYSTEMCONTROLNUMBER
					ELSE gp.BASEENGCONTROLNO
					END
			END BASEENGCONTROLNO
			,max([IEPUBDATE]) [IEPUBDATE] --Identify last pub version
			FROM [SISWEB_OWNER].[LNKMEDIAIEPART] gp --GroupPart
			inner join [SISWEB_OWNER].[MASMEDIA] m on gp.[MEDIANUMBER] = m.[MEDIANUMBER] and m.[MEDIASOURCE] in ('A','N') --Authoring Only
			inner join [SISWEB_OWNER].[LNKIEDATE] d on gp.[IESYSTEMCONTROLNUMBER] = d.[IESYSTEMCONTROLNUMBER]
			--Where [BASEENGCONTROLNO] <> '-' --Exception; ESO
			Group BY 
			CASE
				   WHEN IETYPE = 'L' THEN CASE gp.BASEENGCONTROLNO
										  WHEN '-' THEN gp.IESYSTEMCONTROLNUMBER + '-' + gp.MEDIANUMBER
										  ELSE gp.BASEENGCONTROLNO + '-' + gp.MEDIANUMBER
										  END
				   ELSE CASE gp.BASEENGCONTROLNO
						WHEN '-' THEN gp.IESYSTEMCONTROLNUMBER
						ELSE gp.BASEENGCONTROLNO
						END
				END
		) lv on gp.BASEENGCONTROLNO_Mod = lv.[BASEENGCONTROLNO] and d.[IEPUBDATE] = lv.[IEPUBDATE]
		left outer join [sis_stage].[Part] p on gp.[IEPARTNUMBER] = p.[Part_Number] and gp.[ORGCODE] = p.[Org_Code]
		--Where gp.[IEPARTNUMBER] is not null and --We cannot accept group parts that do not have a part number
		Where gp.[ORGCODE] is not null
	) gp
	Where RowRank = 1
) x
inner join [sis_stage].[IEPart] ie on ie.[Base_English_Control_Number] = x.[BASEENGCONTROLNO] --and ie.[Part] = x.[Part]
inner join [SISWEB_OWNER].[LNKCONSISTLIST] cl on x.[IESYSTEMCONTROLNUMBER] = cl.[IESYSTEMCONTROLNUMBER]
inner join [sis_stage].[Part] p on p.[Part_Number] = cl.[PARTNUMBER] and p.[Org_Code] = cl.[ORGCODE]
inner join [sis_stage].[Part_IEPart_Relation] ier on ier.Part_ID = p.Part_ID and ier.IEPart_ID = ie.IEPart_ID and ier.Sequence_Number = cl.PARTSEQUENCENUMBER
inner join [sis_stage].[Language] l on l.[Language_Tag] = 'en-US' --Hard code
where ((cl.PARTNUMBER = 'COMMENT' and cl.COMMENTS is not null) or ((cl.PARTMODIFIER is not null and ltrim(rtrim(cl.PARTMODIFIER)) <> '') or cl.PARTMODIFIER is null) or (cl.NOTE is not null and ltrim(rtrim(cl.NOTE)) <> ''))
Group by
 ier.Part_IEPart_Relation_ID
,l.Language_ID
Option (Force Order)

--select 'Part_IEPart_Relation Authoring' Table_Name, @@RowCount Record_Count  
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_IEPart_Relation Authoring Load', @DATAVALUE = @@RowCount;

--Load Conversion
Insert into [sis_stage].[Part_IEPart_Relation_Translation] 
(
 [Part_IEPart_Relation_ID]
,[Language_ID]
,[Part_IEPart_Name]
,[Part_IEPart_Modifier]
,[Part_IEPart_Note] 
)
Select 
 ier.Part_IEPart_Relation_ID
,l.Language_ID
,max(case when ltrim(rtrim(cl.COMMENTS)) = '' then null else ltrim(rtrim(cl.COMMENTS)) end) COMMENTS
,max(case when ltrim(rtrim(cl.PARTMODIFIER)) = '' then null else ltrim(rtrim(cl.PARTMODIFIER)) end) PARTMODIFIER
,max(case when ltrim(rtrim(cl.NOTE)) = '' then null else ltrim(rtrim(cl.NOTE)) end) NOTE
From
(--Limit to last version of each IE
	Select *
	From 
	(
	--All records related to last version of each IE
		Select 
		 gp.[BASEENGCONTROLNO]
		,gp.[IESYSTEMCONTROLNUMBER]
		,d.[IEPUBDATE]
		,Row_Number() Over (Partition By gp.[BASEENGCONTROLNO], d.[IEPUBDATE] Order by gp.[IEUPDATEDATE] desc, gp.[IEPARTNUMBER] desc) RowRank --Take last version based ordered by IEUpdateDate and IEPartNumber No in cases of ambiguity.
		From [SISWEB_OWNER].[LNKMEDIAIEPART] gp
		inner join [SISWEB_OWNER].[LNKIEDATE] d on gp.[IESYSTEMCONTROLNUMBER] = d.[IESYSTEMCONTROLNUMBER]
		Inner Join 
		(--Only load the most recent version of each IE (base english control number) as a group part based on the IEPUBDATE.
			Select 
			[BASEENGCONTROLNO]
			,max([IEPUBDATE]) [IEPUBDATE] --Identify last pub version
			FROM [SISWEB_OWNER].[LNKMEDIAIEPART] gp --GroupPart
			inner join [SISWEB_OWNER].[MASMEDIA] m on gp.[MEDIANUMBER] = m.[MEDIANUMBER] and m.[MEDIASOURCE] = 'C' --Conversion Only
			inner join [SISWEB_OWNER].[LNKIEDATE] d on gp.[IESYSTEMCONTROLNUMBER] = d.[IESYSTEMCONTROLNUMBER]
			Where [BASEENGCONTROLNO] <> '-' --Exception; ESO
			Group BY [BASEENGCONTROLNO]
		) lv on gp.[BASEENGCONTROLNO] = lv.[BASEENGCONTROLNO] and d.[IEPUBDATE] = lv.[IEPUBDATE]
		left outer join [sis_stage].[Part] p on gp.[IEPARTNUMBER] = p.[Part_Number] and gp.[ORGCODE] = p.[Org_Code]
		--Where gp.[IEPARTNUMBER] is not null and --We cannot accept group parts that do not have a part number
		Where gp.[ORGCODE] is not null
	) gp
	Where RowRank = 1
) x
inner join [sis_stage].[IEPart] ie on ie.[Base_English_Control_Number] = x.[BASEENGCONTROLNO] --and ie.[Part] = x.[Part]
inner join [SISWEB_OWNER].[LNKCONSISTLIST] cl on x.[BASEENGCONTROLNO] = cl.[IESYSTEMCONTROLNUMBER]
inner join [sis_stage].[Part] p on p.[Part_Number] = cl.[PARTNUMBER] and p.[Org_Code] = cl.[ORGCODE]
inner join [sis_stage].[Part_IEPart_Relation] ier on ier.Part_ID = p.Part_ID and ier.IEPart_ID = ie.IEPart_ID and ier.Sequence_Number = cl.PARTSEQUENCENUMBER
inner join [sis_stage].[Language] l on l.[Language_Tag] = 'en-US' --Hard code
where ((cl.PARTNUMBER = 'COMMENT' and cl.COMMENTS is not null) or (cl.PARTMODIFIER is not null and ltrim(rtrim(cl.PARTMODIFIER)) <> '') or (cl.NOTE is not null and ltrim(rtrim(cl.NOTE)) <> ''))
Group by
 ier.Part_IEPart_Relation_ID
,l.Language_ID
Option (force order)

--select 'Part_IEPart_Relation Conversion' Table_Name, @@RowCount Record_Count  
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_IEPart_Relation Conversion Load', @DATAVALUE = @@RowCount;

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
