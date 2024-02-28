
-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180130
-- Modify Date: 20191009 BASEENGCONTROLNO + '-' + MEDIANUMBER for IETYPE = 'L'
-- Modify Date: 20201130 check those IEParts that have relations to SMCS in SMCS_IEPart_Relation so they cannot be deleted.
-- Description: Full load [sis_stage].IEPart
--Exec [sis_stage].IEPart_Load
-- Modified By: Kishor Padmanabhan
-- Modified Date: 20220919
-- Modified Reason: Moved Part and OfParts column to MediaSequence from IEPart
-- Associated User Story: 21373
-- =============================================
CREATE PROCEDURE [sis_stage].[IEPart_Load]
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

Declare @ProcName   VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
		@ProcessID  uniqueidentifier = NewID(),
		@NULLID     INT              = 0;


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

--Load 
Insert into [sis_stage].[IEPart] 
(
 [Part_ID]
,[Base_English_Control_Number]
,[Publish_Date]
,Update_Date
,IE_Control_Number
,PartName_for_NULL_PartNum
)
Select 
x.[Part_ID]
,x.[BASEENGCONTROLNO]
--,x.[Part]
--,x.[OFPARTS]
,x.[IEPUBDATE]
,x.IEUPDATEDATE
,x.IECONTROLNUMBER
,x.[PartName_for_NULL_PartNum]
From
(--Limit to last version of each IE
	Select *
	From 
	(
	--All records related to last version of each IE
		Select 
		 BASEENGCONTROLNO_Mod [BASEENGCONTROLNO]
		,gp.[IEPARTNUMBER]
		,gp.[ORGCODE]
		,gp.[IESYSTEMCONTROLNUMBER]
		--,isnull(gp.[PART], 1) [Part]
		--,isnull(gp.[OFPARTS], 1) [OFPARTS]
		,d.[IEPUBDATE]
		,CASE WHEN p.[Part_ID] IS NULL THEN '-1' ELSE p.[Part_ID] END AS [Part_ID]
		,gp.IEUPDATEDATE
		,gp.IECONTROLNUMBER
		,gp.[PartName_for_NULL_PartNum]
		,Row_Number() Over (Partition By gp.BASEENGCONTROLNO_Mod, d.[IEPUBDATE] Order by gp.[IEUPDATEDATE] desc, gp.[IEPARTNUMBER] desc) RowRank --Take last version based ordered by IEUpdateDate and IEPartNumber No in cases of ambiguity.
		From 
		(
		Select [MEDIANUMBER]
      ,[IESYSTEMCONTROLNUMBER]
	  ,[IEPARTNUMBER]
      ,[ORGCODE]
      ,[IEPARTNAME]
      ,[IESEQUENCENUMBER]
      ,[BASEENGCONTROLNO]
      ,[SECTIONNUMBER]
      ,[IEPARTMODIFIER]
      ,[IECAPTION]
      ,[IETYPE]
      ,[SERVICEABILITYINDICATOR]
      ,[IEUPDATEDATE]
      ,[IECONTROLNUMBER]
      --,[PART]
      --,[OFPARTS]
      ,[ARRANGEMENTINDICATOR]
      ,[CCRINDICATOR]
      ,[FILTERPARTINDICATOR]
      ,[MAINTPARTINDICATOR]
      ,[NPRINDICATOR]
      ,[TYPECHANGEINDICATOR]
      ,[LASTMODIFIEDDATE] 
	  ,CASE WHEN [IEPARTNUMBER] IS NULL THEN [IEPARTNAME] ELSE NULL END AS [PartName_for_NULL_PartNum]
	  ,CASE
		   WHEN IETYPE = 'L' THEN CASE BASEENGCONTROLNO
									  WHEN '-' THEN IESYSTEMCONTROLNUMBER + '-' + MEDIANUMBER
									  ELSE BASEENGCONTROLNO + '-' + MEDIANUMBER
									  END
			   ELSE CASE BASEENGCONTROLNO
					WHEN '-' THEN IESYSTEMCONTROLNUMBER
					ELSE BASEENGCONTROLNO
					END
			END BASEENGCONTROLNO_Mod 
		from SISWEB_OWNER.LNKMEDIAIEPART
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
			FROM SISWEB_OWNER.LNKMEDIAIEPART gp --GroupPart
			inner join [SISWEB_OWNER].[MASMEDIA] m on gp.[MEDIANUMBER] = m.[MEDIANUMBER] --and m.[MEDIASOURCE] = 'A' --Authoring Only
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
		where gp.[ORGCODE] is not null --We cannot accept group parts that do not have org code
	) gp
    Where RowRank = 1
) x

--select 'IEPart' Table_Name, @@RowCount Record_Count  

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'IEPart Load', @DATAVALUE = @@RowCount;

/* Davide 20191008 adding dummy record for IEPart_ID=-1 */
SELECT @NULLID = COUNT(*)
FROM sis_stage.IEPart_Key
WHERE IEPart_ID = -1;
PRINT @NULLID;
IF @NULLID = 0
	BEGIN
		SET IDENTITY_INSERT sis_stage.IEPart_Key ON;
		INSERT INTO sis_stage.IEPart_Key (IEPart_ID,Base_English_Control_Number) 
		VALUES (-1,'N/A');
		SET IDENTITY_INSERT sis_stage.IEPart_Key OFF;
END;

SELECT @NULLID = COUNT(*)
FROM sis_stage.IEPart
WHERE IEPart_ID = -1;
IF @NULLID = 0
	BEGIN
		INSERT INTO sis_stage.IEPart (IEPart_ID,Part_ID,Base_English_Control_Number,Publish_Date) 
		VALUES (-1,1,'N/A','1900-01-01');
END;

--Insert natural keys into key table
Insert into [sis_stage].[IEPart_Key] (Base_English_Control_Number)
Select s.Base_English_Control_Number
From [sis_stage].[IEPart] s
Left outer join [sis_stage].[IEPart_Key] k on s.Base_English_Control_Number = k.Base_English_Control_Number
Where k.IEPart_ID is null

--Key table load

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'IEPart Key Load', @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set IEPart_ID = k.IEPart_ID
From [sis_stage].[IEPart] s
inner join [sis_stage].[IEPart_Key] k on s.Base_English_Control_Number = k.Base_English_Control_Number
where s.IEPart_ID is null

--Surrogate Update

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'IEPart Update Surrogate', @DATAVALUE = @@RowCount;


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
