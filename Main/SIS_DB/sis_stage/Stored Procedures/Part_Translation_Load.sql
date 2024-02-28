-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180207
-- Description: Full load [sis_stage].Part_Translation
-- Modified Date: 20220917
-- Modified By: Anup Kushwaha
-- Description: Added Query to load Part Details for Parts from AsShippedPart table
-- Exec [sis_stage].Part_Translation_Load
-- =============================================
CREATE PROCEDURE [sis_stage].[Part_Translation_Load]
--(
--    -- Add the parameters for the stored procedure here
--    <@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>,
--    <@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
--)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from.  Adding to trigger commit.
    -- interfering with SELECT statements.
    SET NOCOUNT ON

BEGIN TRY

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
        @ProcessID uniqueidentifier = NewID(),
        @DEFAULT_ORGCODE VARCHAR(12) = SISWEB_OWNER_STAGING._getDefaultORGCODE()

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started' , @DATAVALUE = NULL;

-- Insert statements for procedure here
truncate table [sis_stage].[Part_Translation]

DECLARE @LANGUAGE_ID INTEGER;
SELECT @LANGUAGE_ID = L.Language_ID FROM sis_stage.Language AS L WHERE L.Language_Tag = 'en-US'
Insert into [sis_stage].[Part_Translation]
(
 [Part_ID]
,[Language_ID]
,[Part_Name]
)
Select
p.Part_ID,
@LANGUAGE_ID,--41, --English only
left(max(RELATEDPARTNAME), 150) Part_Name
From [SISWEB_OWNER].[LNKRELATEDPARTINFO] r
inner join [sis_stage].[Part] p on r.RELATEDPARTNUMBER = p.Part_Number and p.Org_Code = @DEFAULT_ORGCODE
where r.RELATEDPARTNUMBER <> 'COMMENT'
Group by p.Part_ID

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'PartNames from LNKRELATEDPARTINFO Loaded' , @DATAVALUE = @@RowCount;



--Load
--Get the last name received for each Part Number
Insert into [sis_stage].[Part_Translation]
(
 [Part_ID]
,[Language_ID]
,[Part_Name]
)
Select p2.Part_ID,p2.Language_ID,P2.PARTNAME from
(
Select
 p.[Part_ID]
,l.[Language_ID]
,left([PARTNAME], 150) [PARTNAME]
From
(--Union Part name list together and rank across entire set
Select
 [PARTNUMBER]
,[ORGCODE]
,[PARTNAME]
,Row_Number() Over (Partition By [PARTNUMBER], [ORGCODE] Order by [IEPUBDATE] desc, [IESYSTEMCONTROLNUMBER] desc, [PRIORITY] asc) RowRank
From
(
--Get the last name from IE Part.
--Requires getting the pub date to determine the last media that named the part.
Select * From
(
SELECT
 gp.[IEPARTNUMBER] [PARTNUMBER]
,[ORGCODE]
,isnull(d.[IEPUBDATE], '1900-01-01') [IEPUBDATE]
,gp.[IESYSTEMCONTROLNUMBER]
,gp.[IESEQUENCENUMBER]
,gp.[IEPARTNAME] [PARTNAME]
,1 [PRIORITY] --In cases where a part is equally ranked, use the priority
,Row_Number() Over (Partition By gp.[IEPARTNUMBER], gp.[ORGCODE] Order by isnull(d.[IEPUBDATE], '1900-01-01') desc, gp.[IESYSTEMCONTROLNUMBER] desc, gp.[IESEQUENCENUMBER]) RowRank
FROM [SISWEB_OWNER].[LNKMEDIAIEPART] gp
left outer join [SISWEB_OWNER].[MASMEDIA] m on gp.[MEDIANUMBER] = m.[MEDIANUMBER]
left outer join [SISWEB_OWNER].[LNKIEDATE] d on d.[IESYSTEMCONTROLNUMBER] = gp.[IESYSTEMCONTROLNUMBER]
Where gp.[IEPARTNUMBER] is not null and gp.[ORGCODE] is not null and gp.[IEPARTNAME] is not null  and m.MEDIAORIGIN <> 'SJ'
) x where RowRank = 1

Union All --No need to worry about distinct.  Rank will take care of this on outer query.

--Get the last name from Concist List.
--Requires getting the pub date to determine the last media that named the part.
Select * From
(
Select
 cl.[PARTNUMBER]
,cl.[ORGCODE]
,isnull(gp_data.[IEPUBDATE], '1900-01-01') [IEPUBDATE]
,cl.[IESYSTEMCONTROLNUMBER]
,cl.[PARTSEQUENCENUMBER]
,cl.[PARTNAME]
,2 [PRIORITY] --In cases where a part is equally ranked, use the priority
,Row_Number() Over (Partition By cl.[PARTNUMBER], cl.[ORGCODE] Order by isnull(gp_data.[IEPUBDATE], '1900-01-01') desc, cl.[IESYSTEMCONTROLNUMBER] desc, cl.[PARTSEQUENCENUMBER] desc) RowRank
FROM [SISWEB_OWNER].[LNKCONSISTLIST] cl
left outer join
(Select
case m.[MEDIASOURCE]
when 'N'
then gp.[IESYSTEMCONTROLNUMBER]
when 'A'
then gp.[IESYSTEMCONTROLNUMBER]
else gp.[IECONTROLNUMBER] end [CLIESYSTEMCONTROLNUMBER], d.[IEPUBDATE], m.MEDIAORIGIN
FROM [SISWEB_OWNER].[LNKMEDIAIEPART] gp
left outer join [SISWEB_OWNER].[MASMEDIA] m on gp.[MEDIANUMBER] = m.[MEDIANUMBER]
left outer join [SISWEB_OWNER].[LNKIEDATE] d on d.[IESYSTEMCONTROLNUMBER] = gp.[IESYSTEMCONTROLNUMBER]
) gp_data on cl.[IESYSTEMCONTROLNUMBER] = gp_data.[CLIESYSTEMCONTROLNUMBER]
where cl.[PARTNUMBER] is not null and cl.[ORGCODE] is not null and cl.[PARTNAME] is not null and gp_data.MEDIAORIGIN <> 'SJ'
) x where RowRank = 1
) x where PARTNUMBER <> 'COMMENT'
) x
inner join [sis_stage].[Part] p on p.[Part_Number] = x.[PARTNUMBER] and p.[Org_Code] = x.[ORGCODE]
inner join [sis_stage].[Language] l on l.[Language_Tag] = 'en-US' --Hard code
Where RowRank = 1
)p2
left join [sis_stage].[Part_Translation] pt on pt.Part_ID = p2.Part_ID
Where pt.Part_ID IS NULL
union 
select  -1,Language_ID,'NULLPARTNUMBER' from  [sis_stage].[Language] -- added to account for Parts with NULL for IEPARTNUMBER and has Part_ID -1 in sis.Part
WHERE [Language_Tag] = 'en-US'

--Get the last name received for each AsShippedPart PartNumber
--Requires getting the LASTMODIFIEDDATE to determine the latest name updated for part.
Insert into [sis_stage].[Part_Translation]
(
 [Part_ID]
,[Language_ID]
,[Part_Name]
)
Select p.Part_ID, l.Language_ID, left(z.PartName, 150) PartName
From (
Select Distinct PARTNUMBER, PARTNAME
From
(
Select
    PARTNUMBER,
	PARTNAME,
	Row_Number() Over (Partition By PARTNUMBER Order by isnull(LASTMODIFIEDDATE, '1900-01-01') desc, SERIALNUMBER desc, PARTSEQUENCENUMBER desc) RowRank
From
    (
        SELECT SERIALNUMBER, PARTSEQUENCENUMBER, isnull(LASTMODIFIEDDATE, '1900-01-01') as LASTMODIFIEDDATE, PARTNUMBER, PARTNAME
		FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS]
		where (isValidPartNumber is null or isValidPartNumber = '0')  and isValidSerialNumber is null
		and PARTNUMBER is not null and PARTNUMBER != '' and PARTNAME is not null

		Union

		SELECT SERIALNUMBER, PARTSEQUENCENUMBER, isnull(LASTMODIFIEDDATE, '1900-01-01') as LASTMODIFIEDDATE, PARTNUMBER, PARTNAME
		FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS2]
		where isValidPartNumber is null and isValidSerialNumber is null
		and PARTNUMBER is not null and PARTNUMBER != '' and PARTNAME is not null

		Union

		SELECT SERIALNUMBER, PARTSEQUENCENUMBER, isnull(LASTMODIFIEDDATE, '1900-01-01') as LASTMODIFIEDDATE, PARTNUMBER, PARTNAME
		FROM [SISWEB_OWNER].[LNKASSHIPPEDPRODUCTDETAILS3]
		where isValidPartNumber is null and isValidSerialNumber is null
		and PARTNUMBER is not null and PARTNUMBER != '' and PARTNAME is not null

		Union

		SELECT SERIALNUMBER, PARTSEQUENCENUMBER, isnull(UPDATEDATETIME, '1900-01-01') as LASTMODIFIEDDATE, PARTNUMBER, PARTNAME
		FROM [SISWEB_OWNER].[SIS2ASSHIPPEDENGINE]
		where isValidPartNumber is null and isValidSerialNumber is null
		and PARTNUMBER is not null and PARTNUMBER != '' and PARTNAME is not null
    ) x
) y
Where RowRank = 1
) z
inner join [sis_stage].[Part] p on p.Part_Number = z.PARTNUMBER and p.[Org_Code] = @DEFAULT_ORGCODE
inner join [sis_stage].[Language] l on l.[Language_Tag] = 'en-US' --Hard code
left join [sis_stage].[Part_Translation] pt on pt.Part_ID = p.Part_ID
Where pt.Part_ID IS NULL

--Get the last name received for each LNKNPRINFO PartNumber
-- Taking based on highest PRIMARYSEQNO to get the latest part name based on part number
Insert into [sis_stage].[Part_Translation]
(
 [Part_ID]
,[Language_ID]
,[Part_Name]
)
SELECT 	ISNULL(t.Part_ID,-1) AS Part_ID,
		ISNULL(t.Language_ID,-1) AS Language_ID,
		t.Part_Name		
FROM
(
	SELECT P.Part_ID AS Part_ID,l.Language_ID AS Language_ID,NPR.PARTNUMBERDESCRIPTION AS Part_Name,
	RANK() OVER(PARTITION BY NPR.PARTNUMBER ORDER BY NPR.PRIMARYSEQNO DESC) AS R -- there are multiple descriptions for each partnumber, we take the latest
	FROM SISWEB_OWNER.LNKNPRINFO AS NPR
	INNER JOIN [sis_stage].[Part] AS P ON P.Part_Number = NPR.PARTNUMBER AND P.Org_Code = @DEFAULT_ORGCODE
	INNER JOIN [sis_stage].[Language] l on l.[Language_Tag] = 'en-US' 
	LEFT JOIN [sis_stage].[Part_Translation] pt on pt.Part_ID = P.Part_ID
	WHERE pt.Part_ID IS NULL 
		AND P.Part_ID IS NOT NULL 
		AND PARTNUMBER IS NOT NULL 
		AND PARTNUMBERDESCRIPTION IS NOT NULL 
) AS t
WHERE R = 1;

--Blow logic is commented since those part names are already covered in above insert
--Requires getting the LASTMODIFIEDDATE to determine the latest name updated for part.
/*Insert into [sis_stage].[Part_Translation]
(
 [Part_ID]
,[Language_ID]
,[Part_Name]
)
Select p.Part_ID, l.Language_ID, left(z.PartName, 150) PartName
From (
	Select Distinct PARTNUMBER, PARTNAME
	From (
		Select PARTNUMBER,
			PARTNAME,
			Row_Number() Over (Partition By PARTNUMBER Order by isnull(LASTMODIFIEDDATE, '1900-01-01') desc) RowRank
		From (
			Select Distinct PARTNUMBER, PARTNUMBERDESCRIPTION as PARTNAME, LASTMODIFIEDDATE
			From SISWEB_OWNER.LNKNPRINFO
			Where PARTNUMBER is not null and PARTNUMBERDESCRIPTION is not null
			) x
		) y
	Where RowRank = 1
	) z
inner join [sis_stage].[Part] p on p.Part_Number = z.PARTNUMBER and p.[Org_Code] = @DEFAULT_ORGCODE
inner join [sis_stage].[Language] l on l.[Language_Tag] = 'en-US' --Hard code
left join [sis_stage].[Part_Translation] pt on pt.Part_ID = p.Part_ID
Where pt.Part_ID IS NULL and p.Part_ID IS NOT NULL
*/
--select 'Part_Translation' Table_Name, @@RowCount Record_Count
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_Translation Load' , @DATAVALUE = @@RowCount;

--Add names for replacement parts
--Authoring names take precedence over replacement part names.
--Do not update the name if it already exists.
-- Davide 20200430: removed hardcoded Language_ID 41 https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/6117/

Insert into [sis_stage].[Part_Translation]
(
 [Part_ID]
,[Language_ID]
,[Part_Name]
)

	select Part_ID,@LANGUAGE_ID,Part_Name
	from (Select distinct p.Part_ID,
		PARTNAME [Part_Name],
		ROW_NUMBER() OVER(PARTITION BY p.Part_Number,p.Org_Code ORDER BY SCPART_ID DESC) AS RowNum
		from EMP_STAGING.SCPART sc
		inner join sis_stage.Part p
		on sc.PARTNUMBER = p.Part_Number
		and p.Org_Code = sc.ORGCODE
		left join sis_stage.Part_Translation pt
		on pt.Part_ID = p.Part_ID
		where pt.Part_ID is null
	) a
	where RowNum = 1

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Added SAP/NGS English Part names' , @DATAVALUE = @@RowCount;

-- Davide 20200616: added rest of languages from LNKTRANSLATEDSPN https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/6484/
INSERT INTO sis_stage.Part_Translation
	   (Part_ID
	   ,Language_ID
	   ,Part_Name
	   )
--Krishna Rudraraju 20210811 (BUG14199) Adding Distinct to avoid duplicate values causing Primary Key violation for the combination of Part_ID and Language_ID
SELECT DISTINCT PT.Part_ID
	  ,L.Language_ID
	  ,TSPN.TRANSLATEDPARTNAME AS Part_Name
  FROM sis_stage.Part_Translation AS PT
	   JOIN SISWEB_OWNER.LNKTRANSLATEDSPN AS TSPN ON TSPN.PARTNAME = PT.Part_Name
	   JOIN sis_stage.Language AS L ON
									   L.Legacy_Language_Indicator = TSPN.LANGUAGEINDICATOR
									   AND L.Default_Language = 1
  WHERE TSPN.LANGUAGEINDICATOR <> 'E';

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Translation for Non-English added' , @DATAVALUE = @@RowCount;

-- Ajit 20210713: added translations for SISJ if not already present
INSERT INTO sis_stage.Part_Translation
	   (Part_ID
	   ,Language_ID
	   ,Part_Name
	   )
select
--top 100 pt.Part_Name,p.Part_Number ,sisj.PARTNAME,sisj.PARTNUMBER
p.Part_ID, (select Language_ID from [sis].[Language] where Language_Code = 'ja' and Default_Language = 1),sisj.PARTNAME
from sis_stage.Part p
left join [sis_stage].[Part_Translation] pt  on p.Part_ID = pt.Part_ID and pt.Language_ID = 76
left join
(
	select
		y.PARTNAME
		,y.PARTNUMBER ,row_number() over ( Partition by y.[PARTNUMBER] order by isnull(y.LASTMODIFIEDDATE, '1900-01-01') desc) RowRank
		from(
		Select
			x.PARTNAME
			,x.PARTNUMBER
			,x.LASTMODIFIEDDATE
			from (
				select
				Row_Number() Over (Partition By cl.[PARTNUMBER] Order by isnull(cl.LASTMODIFIEDDATE, '1900-01-01') desc, cl.[IESYSTEMCONTROLNUMBER] desc, cl.[PARTSEQUENCENUMBER] desc) RowRank
				,cl.PARTNAME
				,cl.PARTNUMBER
				, isnull(cl.LASTMODIFIEDDATE, '1900-01-01') LASTMODIFIEDDATE
				FROM [SISWEB_OWNER].[LNKCONSISTLIST] cl
				inner join
					(Select
					case m.[MEDIASOURCE] when 'A' then gp1.[IESYSTEMCONTROLNUMBER] else gp1.[IECONTROLNUMBER] end [CLIESYSTEMCONTROLNUMBER],m.MEDIAORIGIN
					FROM [SISWEB_OWNER].[LNKMEDIAIEPART] gp1
					inner join [SISWEB_OWNER].[MASMEDIA] m on gp1.[MEDIANUMBER] = m.[MEDIANUMBER]
					where m.MEDIAORIGIN = 'SJ'
				) gp0
				on cl.[IESYSTEMCONTROLNUMBER] = gp0.[CLIESYSTEMCONTROLNUMBER]
				where  cl.PARTNAME is not null and cl.PARTNUMBER is not null
			)x
			where RowRank =1
		union
		select
			z.PARTNAME
			,z.PARTNUMBER
			,z.LASTMODIFIEDDATE
			from (
				SELECT Row_Number() Over (Partition By gp2.[IEPARTNUMBER] Order by isnull(gp2.LASTMODIFIEDDATE, '1900-01-01') desc, gp2.[IESYSTEMCONTROLNUMBER] desc) RowRank
				,[gp2].[IEPARTNAME] PARTNAME, gp2.[IEPARTNUMBER] PARTNUMBER, gp2.LASTMODIFIEDDATE LASTMODIFIEDDATE
				FROM [SISWEB_OWNER].[LNKMEDIAIEPART] gp2
				inner join [SISWEB_OWNER].[MASMEDIA] m on gp2.[MEDIANUMBER] = m.[MEDIANUMBER]
				where m.MEDIAORIGIN = 'SJ'
				and gp2.[IEPARTNUMBER] is not null and gp2.[IEPARTNAME] is not null
			)z where RowRank =1
		)y
) sisj
on sisj.PARTNUMBER = p.Part_Number and p.Org_Code = @DEFAULT_ORGCODE
where sisj.RowRank = 1 and
sisj.PARTNAME is not null and sisj.PARTNAME not like  '%?%' and pt.Part_Name is null and sisj.PARTNAME<> '*';

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SISJ partnames added' , @DATAVALUE = @@RowCount;


--select 'Part_Translation Related_Parts' Table_Name, @@RowCount Record_Count
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_Translation Related_Parts Load' , @DATAVALUE = @@RowCount;

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