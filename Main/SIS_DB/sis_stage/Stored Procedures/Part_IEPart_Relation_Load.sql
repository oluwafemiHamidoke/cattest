-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180130
-- Description: Full load [sis_stage].[Part_IEPart_Relation_Load]
-- Modified By: Kishor Padmanabhan
-- Modified Date: 20220919
-- Modified Reason: Moved Part and OfParts column to MediaSequence from IEPart
-- Associated User Story: 21373
-- truncate table [sis_stage].[Part_IEPart_Relation] 
--Exec [sis_stage].[Part_IEPart_Relation_Load]
-- =============================================
CREATE PROCEDURE [sis_stage].[Part_IEPart_Relation_Load]
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
Insert into [sis_stage].[Part_IEPart_Relation] 
(
 [Part_IEPart_Relation_ID]
,[Part_ID]
,[IEPart_ID]
,[Sequence_Number]
,[Reference_Number]
,[Graphic_Number]
,[Quantity]
,[Serviceability_Indicator]
,Parentage
,CCR_Indicator)
Select 
 k.[Part_IEPart_Relation_ID]
,p.[Part_ID]
,ie.[IEPart_ID]
,cl.[PARTSEQUENCENUMBER]
,max(cl.[REFERENCENO]) [REFERENCENO]
,max(cl.[GRAPHNO]) [GRAPHNO]
,max(cl.[QUANTITY]) [QUANTITY]
,max(cl.[SERVICEABILITYINDICATOR]) [SERVICEABILITYINDICATOR]
,max(cl.[PARENTAGE]) [PARENTAGE]
,case MAX(cl.CCRINDICATOR) when 'Y' then 1
	else 0
end AS CCRINDICATOR
From
(--Limit to last version of each IE
	Select *
	From 
	(
	--All records related to last version of each IE
		Select 
		 gp.BASEENGCONTROLNO_Mod [BASEENGCONTROLNO]
		,gp.[IESYSTEMCONTROLNUMBER]
		--,isnull(gp.[PART], 1) [Part]
		--,isnull(gp.[OFPARTS], 1) [OFPARTS]
		,d.[IEPUBDATE]
		,Row_Number() Over (Partition By gp.BASEENGCONTROLNO_Mod, d.[IEPUBDATE] Order by gp.[IEUPDATEDATE] desc, gp.[IEPARTNUMBER] desc,gp.[IESYSTEMCONTROLNUMBER] desc) RowRank --Take last version based ordered by IEUpdateDate and IEPartNumber No in cases of ambiguity.
		From 
		(
			Select *, 
			CASE
			    WHEN IETYPE = 'L'
			        THEN CASE BASEENGCONTROLNO
			                    WHEN '-'
			                        THEN IESYSTEMCONTROLNUMBER + '-' + MEDIANUMBER
									ELSE BASEENGCONTROLNO + '-' + MEDIANUMBER
								END
					ELSE CASE BASEENGCONTROLNO
								 WHEN '-'
								    THEN IESYSTEMCONTROLNUMBER
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
			    WHEN IETYPE = 'L'
			        THEN CASE gp.BASEENGCONTROLNO
					        WHEN '-'
					            THEN gp.IESYSTEMCONTROLNUMBER + '-' + gp.MEDIANUMBER
								ELSE gp.BASEENGCONTROLNO + '-' + gp.MEDIANUMBER
						    END
			        ELSE CASE gp.BASEENGCONTROLNO
					        WHEN '-'
					            THEN gp.IESYSTEMCONTROLNUMBER
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
			    WHEN IETYPE = 'L'
			        THEN CASE gp.BASEENGCONTROLNO
					        WHEN '-'
					            THEN gp.IESYSTEMCONTROLNUMBER + '-' + gp.MEDIANUMBER
								ELSE gp.BASEENGCONTROLNO + '-' + gp.MEDIANUMBER
						    END
				    ELSE CASE gp.BASEENGCONTROLNO
						    WHEN '-'
						        THEN gp.IESYSTEMCONTROLNUMBER
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
inner join [sis_stage].[IEPart] ie on ie.[Base_English_Control_Number] = x.[BASEENGCONTROLNO] -- and ie.[Part] = x.[Part]
inner join [SISWEB_OWNER].[LNKCONSISTLIST] cl on x.[IESYSTEMCONTROLNUMBER] = cl.[IESYSTEMCONTROLNUMBER]
inner join [sis_stage].[Part] p on p.[Part_Number] = cl.[PARTNUMBER] and p.[Org_Code] = cl.[ORGCODE]
Left outer join [sis_stage].[Part_IEPart_Relation_Key] k on p.Part_ID = k.Part_ID and ie.IEPart_ID = k.IEPart_ID and cl.[PARTSEQUENCENUMBER]= k.Sequence_Number
Group by 
k.[Part_IEPart_Relation_ID]
,p.[Part_ID]
,ie.[IEPart_ID]
,cl.[PARTSEQUENCENUMBER]


--select 'Part_IEPart_Relation Authoring' Table_Name, @@RowCount Record_Count  

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_IEPart_Relation Authoring Load', @DATAVALUE = @@RowCount;


--Load Conversion
Insert into [sis_stage].[Part_IEPart_Relation] 
(
[Part_IEPart_Relation_ID]
,[Part_ID]
,[IEPart_ID]
,[Sequence_Number]
,[Reference_Number]
,[Graphic_Number]
,[Quantity]
,[Serviceability_Indicator]
,Parentage
,CCR_Indicator)
Select 
 k.[Part_IEPart_Relation_ID]
,p.[Part_ID]
,ie.[IEPart_ID]
,cl.[PARTSEQUENCENUMBER]
,max(cl.[REFERENCENO]) [REFERENCENO]
,max(cl.[GRAPHNO]) [GRAPHNO]
,max(cl.[QUANTITY]) [QUANTITY]
,max(cl.[SERVICEABILITYINDICATOR]) [SERVICEABILITYINDICATOR]
,max(cl.[PARENTAGE]) [PARENTAGE]
,case MAX(cl.CCRINDICATOR) when 'Y' then 1
	else 0
end AS CCRINDICATOR
From
(--Limit to last version of each IE
	Select *
	From 
	(
	--All records related to last version of each IE
		Select 
		 gp.BASEENGCONTROLNO_Mod
		,gp.BASEENGCONTROLNO
		,gp.[IESYSTEMCONTROLNUMBER]
		,d.[IEPUBDATE]
		,Row_Number() Over (Partition By gp.[BASEENGCONTROLNO_Mod], d.[IEPUBDATE] Order by gp.[IEUPDATEDATE] desc, gp.[IEPARTNUMBER] desc,gp.[IESYSTEMCONTROLNUMBER] desc) RowRank --Take last version based ordered by IEUpdateDate and IEPartNumber No in cases of ambiguity.
		From (
			Select *, 
			CASE
			    WHEN IETYPE = 'L'
			        THEN CASE BASEENGCONTROLNO
			                WHEN '-'
			                    THEN IESYSTEMCONTROLNUMBER + '-' + MEDIANUMBER
								ELSE BASEENGCONTROLNO + '-' + MEDIANUMBER
							END
					ELSE CASE BASEENGCONTROLNO
							 WHEN '-'
							    THEN IESYSTEMCONTROLNUMBER
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
			   WHEN IETYPE = 'L'
			        THEN CASE gp.BASEENGCONTROLNO
						    WHEN '-'
						        THEN gp.IESYSTEMCONTROLNUMBER + '-' + gp.MEDIANUMBER
							    ELSE gp.BASEENGCONTROLNO + '-' + gp.MEDIANUMBER
							END
			        ELSE CASE gp.BASEENGCONTROLNO
					        WHEN '-'
					            THEN gp.IESYSTEMCONTROLNUMBER
					            ELSE gp.BASEENGCONTROLNO
					        END
			    END BASEENGCONTROLNO_Mod
			,max([IEPUBDATE]) [IEPUBDATE] --Identify last pub version
			FROM [SISWEB_OWNER].[LNKMEDIAIEPART] gp --GroupPart
			inner join [SISWEB_OWNER].[MASMEDIA] m on gp.[MEDIANUMBER] = m.[MEDIANUMBER] and m.[MEDIASOURCE] = 'C' --Conversion Only
			inner join [SISWEB_OWNER].[LNKIEDATE] d on gp.[IESYSTEMCONTROLNUMBER] = d.[IESYSTEMCONTROLNUMBER]
			Where [BASEENGCONTROLNO] <> '-' --Exception; ESO
			Group BY
			CASE
			    WHEN IETYPE = 'L'
			        THEN CASE gp.BASEENGCONTROLNO
					        WHEN '-'
					            THEN gp.IESYSTEMCONTROLNUMBER + '-' + gp.MEDIANUMBER
								ELSE gp.BASEENGCONTROLNO + '-' + gp.MEDIANUMBER
						    END
				    ELSE CASE gp.BASEENGCONTROLNO
						    WHEN '-'
						        THEN gp.IESYSTEMCONTROLNUMBER
						        ELSE gp.BASEENGCONTROLNO
						    END
				END
		) lv on gp.[BASEENGCONTROLNO_Mod] = lv.[BASEENGCONTROLNO_Mod] and d.[IEPUBDATE] = lv.[IEPUBDATE]
		left outer join [sis_stage].[Part] p on gp.[IEPARTNUMBER] = p.[Part_Number] and gp.[ORGCODE] = p.[Org_Code]
		--Where gp.[IEPARTNUMBER] is not null and --We cannot accept group parts that do not have a part number
        Where gp.[ORGCODE] is not null
	) gp
	Where RowRank = 1
) x
inner join [sis_stage].[IEPart] ie on ie.[Base_English_Control_Number] = x.[BASEENGCONTROLNO_Mod] --and ie.[Part] = x.[Part]
inner join [SISWEB_OWNER].[LNKCONSISTLIST] cl on x.[BASEENGCONTROLNO] = cl.[IESYSTEMCONTROLNUMBER]
inner join [sis_stage].[Part] p on p.[Part_Number] = cl.[PARTNUMBER] and p.[Org_Code] = cl.[ORGCODE]
Left outer join [sis_stage].[Part_IEPart_Relation_Key] k on p.Part_ID = k.Part_ID and ie.IEPart_ID = k.IEPart_ID and cl.[PARTSEQUENCENUMBER]= k.Sequence_Number
Group by 
k.[Part_IEPart_Relation_ID]
,p.[Part_ID]
,ie.[IEPart_ID]
,cl.[PARTSEQUENCENUMBER]

--select 'Part_IEPart_Relation Conversion' Table_Name, @@RowCount Record_Count  

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_IEPart_Relation Conversion Load', @DATAVALUE = @@RowCount;

--Insert natural keys into key table
Insert into [sis_stage].[Part_IEPart_Relation_Key] (Part_ID, IEPart_ID, Sequence_Number)
Select s.Part_ID, s.IEPart_ID, s.Sequence_Number
From [sis_stage].[Part_IEPart_Relation] s
Left outer join [sis_stage].[Part_IEPart_Relation_Key] k on s.Part_ID = k.Part_ID and s.IEPart_ID = k.IEPart_ID and s.Sequence_Number = k.Sequence_Number
Where k.Part_IEPart_Relation_ID is null

--Key table load

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_IEPart_Relation Key Load', @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set Part_IEPart_Relation_ID = k.Part_IEPart_Relation_ID
From [sis_stage].[Part_IEPart_Relation] s
inner join [sis_stage].[Part_IEPart_Relation_Key] k on s.Part_ID = k.Part_ID and s.IEPart_ID = k.IEPart_ID and s.Sequence_Number = k.Sequence_Number
where s.Part_IEPart_Relation_ID is null

--Surrogate Update

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_IEPart_Relation Update Surrogate', @DATAVALUE = @@RowCount;


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


