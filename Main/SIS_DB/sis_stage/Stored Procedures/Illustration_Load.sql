-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180412
-- Description: Full load Illustration Tables
-- Modified By: Kishor Padmanabhan
-- Modified Date: 20220919
-- Modified Reason: Moved Part and OfParts column to MediaSequence from IEPart
-- Associated User Story: 21373
/*
Truncate Table [sis_stage].Illustration_File
Truncate Table [sis_stage].IEPart_Illustration_Relation
Delete from [sis_stage].Illustration
Exec [sis_stage].Illustration_Load
*/
-- =============================================
CREATE PROCEDURE [sis_stage].[Illustration_Load]

AS
BEGIN
    SET NOCOUNT ON

BEGIN TRY

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
		@ProcessID uniqueidentifier = NewID()


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

--=========================================================================================================================================================================
-- Loading Illustration 
--=========================================================================================================================================================================

--Load Illustration
Insert into [sis_stage].[Illustration] 
(
Graphic_Control_Number
)
SELECT Distinct [GRAPHICCONTROLNUMBER]
FROM [SISWEB_OWNER].[SIS2GRAPHICLOCATION]

--select 'Illustration' Table_Name, @@RowCount Record_Count 

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Illustration Load', @DATAVALUE = @@RowCount;

--Insert natural keys into key table
Insert into [sis_stage].[Illustration_Key] (Graphic_Control_Number)
Select s.Graphic_Control_Number
From [sis_stage].[Illustration] s
Left outer join [sis_stage].[Illustration_Key] k on s.Graphic_Control_Number = k.Graphic_Control_Number
Where k.Illustration_ID is null

--Key table load

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Illustration Key Load', @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set Illustration_ID = k.Illustration_ID
From [sis_stage].[Illustration] s
inner join [sis_stage].[Illustration_Key] k on s.Graphic_Control_Number = k.Graphic_Control_Number
where s.Illustration_ID is null

--Surrogate Update

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Illustration Update Surrogate', @DATAVALUE = @@RowCount;

--=========================================================================================================================================================================
-- Loading Illustration File
--=========================================================================================================================================================================

--Load Illustration_File
Insert into [sis_stage].[Illustration_File]
(
[Illustration_ID],
[File_Location]
,[Mime_Type]
,[File_Location_Highres]
,[File_Size_Byte_Highres] 
,[File_Size_Byte]
)
Select i.Illustration_ID, m.[LOCATION], m.MIMETYPE, m.LOCATIONHIGHRES, m.FILESIZEBYTEHIGHRES,m.FILESIZEBYTE
From [SISWEB_OWNER].[SIS2GRAPHICLOCATION] m
inner join [sis_stage].[Illustration] i on m.GRAPHICCONTROLNUMBER = i.Graphic_Control_Number
	   LEFT JOIN SISWEB_OWNER.[MASIMAGELOCATION] AS l ON
m.GRAPHICCONTROLNUMBER = l.GRAPHICCONTROLNUMBER
AND RIGHT(m.LOCATION,CHARINDEX('/',REVERSE(m.LOCATION),-1)) = RIGHT(l.IMAGELOCATION,CHARINDEX('/',REVERSE(l.IMAGELOCATION),-1))

--select 'Illustration_File' Table_Name, @@RowCount Record_Count  

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Illustration_File Load', @DATAVALUE = @@RowCount;

--Insert natural keys into key table
Insert into [sis_stage].[Illustration_File_Key] (Illustration_ID, File_Location)
Select s.Illustration_ID, s.File_Location
From [sis_stage].[Illustration_File] s
Left outer join [sis_stage].[Illustration_File_Key] k on s.Illustration_ID = k.Illustration_ID and s.File_Location = k.File_Location
Where k.Illustration_File_ID is null

--Key table load

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Illustration_File Key Load', @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set Illustration_File_ID = k.Illustration_File_ID
From [sis_stage].[Illustration_File] s
inner join [sis_stage].[Illustration_File_Key] k on s.Illustration_ID = k.Illustration_ID and s.File_Location = k.File_Location
where s.Illustration_File_ID is null

--Surrogate Update

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Illustration_File Update Surrogate', @DATAVALUE = @@RowCount;


--=========================================================================================================================================================================
-- Loading Illustration Relation
--=========================================================================================================================================================================

--Load IEPart_Illustration_Relation
Insert into [sis_stage].[IEPart_Illustration_Relation]
(
[IEPart_ID],
[Illustration_ID],
[Graphic_Number]
)
Select 
ie.[IEPart_ID],
i.Illustration_ID,
max(li.GRAPHICSEQUENCENUMBER) GRAPHICSEQUENCENUMBER
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
				END AS BASEENGCONTROLNO_Mod
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
				END AS BASEENGCONTROLNO
			,max([IEPUBDATE]) [IEPUBDATE] --Identify last pub version
			FROM [SISWEB_OWNER].[LNKMEDIAIEPART] gp --GroupPart
			inner join [SISWEB_OWNER].[LNKIEDATE] d on gp.[IESYSTEMCONTROLNUMBER] = d.[IESYSTEMCONTROLNUMBER]
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
		--Where gp.[IEPARTNUMBER] is not null and --We cannot accept group parts that do not have a part number
		Where gp.[ORGCODE] is not null
	) gp
	Where RowRank = 1
) x
inner join [sis_stage].[IEPart] ie on ie.[Base_English_Control_Number] = x.[BASEENGCONTROLNO] --and ie.[Part] = x.[Part]
inner join [SISWEB_OWNER].[LNKIEIMAGE] li on li.IESYSTEMCONTROLNUMBER = x.IESYSTEMCONTROLNUMBER
inner join [sis_stage].[Illustration] i on i.Graphic_Control_Number = li.GRAPHICCONTROLNUMBER
Group by ie.[IEPart_ID], i.Illustration_ID
option (force order)

--select 'IEPart_Illustration_Relation' Table_Name, @@RowCount Record_Count  

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'IEPart_Illustration_Relation Load', @DATAVALUE = @@RowCount;

--Insert natural keys into key table
Insert into [sis_stage].[IEPart_Illustration_Relation_Key] (Illustration_ID, IEPart_ID)
Select s.Illustration_ID, s.IEPart_ID
From [sis_stage].[IEPart_Illustration_Relation] s
Left outer join [sis_stage].[IEPart_Illustration_Relation_Key] k on s.Illustration_ID = k.Illustration_ID and s.IEPart_ID = k.IEPart_ID
Where k.Illustration_Relation_ID is null

--Key table load

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'IEPart_Illustration_Relation Key Load', @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set Illustration_Relation_ID = k.Illustration_Relation_ID
From [sis_stage].[IEPart_Illustration_Relation] s
inner join [sis_stage].[IEPart_Illustration_Relation_Key] k on s.Illustration_ID = k.Illustration_ID and s.IEPart_ID = k.IEPart_ID
where s.Illustration_Relation_ID is null

--Surrogate Update

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'IEPart_Illustration_Relation Update Surrogate', @DATAVALUE = @@RowCount;


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