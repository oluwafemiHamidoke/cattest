CREATE Procedure [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_LOAD]
As
/*---------------
Date: 26-06-2021
Object Description:  Loading changed data into SISSEARCH.EXPANDEDMININGPRODUCTPARTS from base tables
Exec [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_LOAD]
Truncate table [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS]
---------------*/

Begin

BEGIN TRY

SET NOCOUNT ON

Declare
@LastInsertDate Datetime

Declare
@SPStartTime DATETIME,
		@StepStartTime DATETIME,
		@ProcName VARCHAR(200),
		@SPStartLogID BIGINT,
		@StepLogID BIGINT,
		@RowCount BIGINT,
		@LAPSETIME BIGINT
SET @SPStartTime= GETDATE()
SET @ProcName= OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)

--Identify Deleted Records From Source

EXEC @SPStartLogID = SISSEARCH.WriteLog @TIME = @SPStartTime, @NAMEOFSPROC = @ProcName;

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#DeletedRecords') is not null
Begin
Drop table #DeletedRecords
End
Select distinct Iesystemcontrolnumber
into #DeletedRecords
from [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS]
	Except
Select IESYSTEMCONTROLNUMBER
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART]

SET @RowCount= @@RowCount
--	Print cast (getdate() as varchar (50)) + ' - Deleted Records Detected Count: ' + cast (@RowCount as varchar (50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Records Detected',@DATAVALUE = @RowCount, @LOGID = @StepLogID


-- Delete Idenified Deleted Records in Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete
from
	[SISSEARCH].[EXPANDEDMININGPRODUCTPARTS]
where Iesystemcontrolnumber in (Select Iesystemcontrolnumber From #DeletedRecords)

SET @RowCount= @@RowCount
--	Print cast (getdate() as varchar (50)) + ' - Deleted Records from Target Count: ' + cast (@RowCount as varchar (50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Records from Target [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Get Maximum insert date from Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select @LastInsertDate = coalesce(Max(INSERTDATE), '1900-01-01')
From [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS]
	Print cast (getdate() as varchar (50)) + ' - Latest Insert Date in Target: ' + cast (@LastInsertDate as varchar (50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
Declare @Logmessage as varchar(50) = 'Latest Insert Date in Target '+cast (@LastInsertDate as varchar(25))
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = @Logmessage , @LOGID = @StepLogID

--Identify Inserted records from Source

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#InsertRecords') is not null
Begin
Drop table #InsertRecords
End
Select IESYSTEMCONTROLNUMBER
into #InsertRecords
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART]
where LASTMODIFIEDDATE > @LastInsertDate

SET @RowCount= @@RowCount
--	Print cast (getdate() as varchar (50)) + ' - Inserted Records Detected Count: ' + cast (@RowCount as varchar (50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Detected into  #InsertRecords',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--NCI on temp
CREATE
NONCLUSTERED INDEX NIX_InsertRecords_iesystemcontrolnumber
    ON #InsertRecords(IESYSTEMCONTROLNUMBER)

--Delete Inserted records from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete
from [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS]
where Iesystemcontrolnumber in
	(Select IESYSTEMCONTROLNUMBER from #InsertRecords)

SET @RowCount= @@RowCount
--	Print cast (getdate() as varchar (50)) + ' - Deleted Inserted Records from Target Count: ' + cast (@RowCount as varchar (50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Inserted Records from [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


--Load Basic Parts data that's specific to EMP

DROP TABLE IF EXISTS #EMPBasicParts;
Select
	x.[IESYSTEMCONTROLNUMBER]
	 , x.[InformationType]
	 , x.[medianumber]
	 , x.ieupdatedate
	 , x.iepart
     , x.iepartnumber
	 , x.[PARTSMANUALMEDIANUMBER]
	 , x.[IECAPTION]
	 , x.[InsertDate]
     , x.[PubDate]
	 , 0 [isMedia]
		, x.ControlNumber
		, x.[mediaOrigin]
		, x.[orgCode]
into #EMPBasicParts
From
	(
	select distinct
	a.IESYSTEMCONTROLNUMBER as IESYSTEMCONTROLNUMBER,
	'[''5'']' As InformationType, -- Information type for EMP parts
	coalesce ('['+'"'+replace(    --escape /
	replace(                      --escape "
	replace(                      --replace carriage return (ascii 13)
	replace(                      --replace form feed (ascii 12)
	replace(                      --replace vertical tab (ascii 11)
	replace(                      --replace line feed (ascii 10)
	replace(                      --replace horizontal tab (ascii 09)
	replace(                      --replace backspace (ascii 08)
	replace(                      --escape \
	b.medianumber
		, '\', '\\')
		, char (8), ' ')
		, char (9), ' ')
		, char (10), ' ')
		, char (11), ' ')
		, char (12), ' ')
		, char (13), ' ')
		, '"', '\"')
		, '/', '\/')+'"'+']', '') as medianumber,
	isnull(d.dateupdated, '1900-01-01') as ieupdatedate,
	replace(                      --escape /
	replace(                      --escape "
	replace(                      --replace carriage return (ascii 13)
	replace(                      --replace form feed (ascii 12)
	replace(                      --replace vertical tab (ascii 11)
	replace(                      --replace line feed (ascii 10)
	replace(                      --replace horizontal tab (ascii 09)
	replace(                      --replace backspace (ascii 08)
	replace(                      --escape \
	isnull(b.iepartnumber, '')+':'+isnull(b.iepartname, '') +
	iif(isnull(b.iepartmodifier, '') != '', ' '+b.iepartmodifier, '')
		, '\', '\\')
		, char (8), ' ')
		, char (9), ' ')
		, char (10), ' ')
		, char (11), ' ')
		, char (12), ' ')
		, char (13), ' ')
		, '"', '\"')
		, '/', '\/') as iepart,
    b.iepartnumber as iepartnumber,
	coalesce ('['+'"'+replace(    --escape /
	replace(                      --escape "
	replace(                      --replace carriage return (ascii 13)
	replace(                      --replace form feed (ascii 12)
	replace(                      --replace vertical tab (ascii 11)
	replace(                      --replace line feed (ascii 10)
	replace(                      --replace horizontal tab (ascii 09)
	replace(                      --replace backspace (ascii 08)
	replace(                      --escape \
	b.medianumber
		, '\', '\\')
		, char (8), ' ')
		, char (9), ' ')
		, char (10), ' ')
		, char (11), ' ')
		, char (12), ' ')
		, char (13), ' ')
		, '"', '\"')
		, '/', '\/')+'"'+']', '') as PARTSMANUALMEDIANUMBER
		, Replace(
	Replace(
	Replace(
	Replace(
	Replace(
	Replace(
	Replace(
	Replace(
	Replace(
	Replace(
	Replace(
	Replace(
	Replace(
	Replace(
	b.IECAPTION
		, '<I>', ' ')
		, '</I>', ' ')
		, '<BR>', ' ')
		, '<TABLE BORDER=0>', ' ')
		, '<TR>', ' ')
		, '<TD COLSPAN=3 ALIGN=CENTER>', ' ')
		, '</TABLE>', ' ')
		, '<B>', ' ')
		, '</B>', ' ')
		, '<TD>', ' ')
		, '</TD>', ' ')
		, '<TR>', ' ')
		, '</TR>', ' ')
		, '@@@@@', ' ') As IECAPTION
		, b.LASTMODIFIEDDATE InsertDate
		, row_number() over (Partition by cast (a.IESYSTEMCONTROLNUMBER as VARCHAR) order by isnull(d.dateupdated, '1900-01-01') desc, b.LASTMODIFIEDDATE desc) RowRank
		, d.IEPUBDATE as [PubDate]
  		, case when len(trim (b.IECONTROLNUMBER)) = 0 then null else
	coalesce ('['+'"'+replace(    --escape /
	replace(                      --escape "
	replace(                      --replace carriage return (ascii 13)
	replace(                      --replace form feed (ascii 12)
	replace(                      --replace vertical tab (ascii 11)
	replace(                      --replace line feed (ascii 10)
	replace(                      --replace horizontal tab (ascii 09)
	replace(                      --replace backspace (ascii 08)
	replace(                      --escape \
	b.IECONTROLNUMBER
		, '\', '\\')
		, char (8), ' ')
		, char (9), ' ')
		, char (10), ' ')
		, char (11), ' ')
		, char (12), ' ')
		, char (13), ' ')
		, '"', '\"')
		, '/', '\/')+'"'+']', '')
	end as ControlNumber,
	e.MEDIAORIGIN [mediaOrigin],
	coalesce (b.ORGCODE, '') [orgCode]
	from [SISWEB_OWNER_SHADOW].LNKIEPRODUCTINSTANCE a
	inner join [SISWEB_OWNER_SHADOW].LNKMEDIAIEPART b
	on a.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER
	inner join #InsertRecords c --Add filter to limit to changed records
	on c.IESYSTEMCONTROLNUMBER=b.IESYSTEMCONTROLNUMBER
	left outer join [SISWEB_OWNER].LNKIEDATE d
	on a.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER and d.LANGUAGEINDICATOR='E'
	inner join [SISWEB_OWNER].[MASMEDIA] e
	on e.MEDIANUMBER=b.MEDIANUMBER
	where e.MEDIASOURCE = 'N' and e.MEDIAORIGIN = 'EM'
	) x where x.RowRank = 1

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_EMPBasicParts_iesystemcontrolnumber
    ON #EMPBasicParts(IESYSTEMCONTROLNUMBER)

/*---------------
Metrics calculated on SB2 Database:
 lnkieproductinstance distinct 1,124,639 ( ~16 Seconds)
 lnkieproductinstance + lnkmediaiepart + lnkiedate + MASMEDIA Distinct 1,124,639 ( ~46 Seconds )
 Total 1 Min
End of EMP Basic Parts load
---------------*/

--Load Consist Parts data that's specific to EMP

DROP TABLE IF EXISTS #EMPConsistParts;
DROP TABLE IF EXISTS #PreEMPConsistParts;
DROP TABLE IF EXISTS #CPRecordsToString;

SELECT b.IESYSTEMCONTROLNUMBER
	 , b.LASTMODIFIEDDATE AS      INSERTDATE
	 , d.PARTNUMBER
	 , d.PARTNAME
	 , d.PARTMODIFIER
	 , t.TRANSLATEDPARTNAME
	 , t.LANGUAGEINDICATOR
INTO #CPRecordsToString
FROM SISWEB_OWNER_SHADOW.LNKMEDIAIEPART AS b
		 INNER JOIN SISWEB_OWNER.MASMEDIA AS e ON
			e.MEDIANUMBER = b.MEDIANUMBER
		AND e.MEDIASOURCE = 'N' AND e.MEDIAORIGIN ='EM'
		 JOIN SISWEB_OWNER_SHADOW.LNKCONSISTLIST AS d ON b.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER
		 LEFT JOIN SISWEB_OWNER.LNKTRANSLATEDSPN AS t ON d.PARTNAME = t.PARTNAME
WHERE b.IESYSTEMCONTROLNUMBER IN(SELECT IESYSTEMCONTROLNUMBER
								 FROM #InsertRecords);

SELECT IESYSTEMCONTROLNUMBER
	 , INSERTDATE
	 , replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(ISNULL(PARTNUMBER,'') + ':' + ISNULL(PARTNAME,'') + IIF(ISNULL(PARTMODIFIER,'') != '',' ' + PARTMODIFIER,''),'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'. ', ' '),'"','\"'),'/','\/') AS CONSISTPART
	 , replace(replace(replace(replace(replace(replace(replace(replace(replace([8],'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                          [consistPartNames_id-ID]
	  , replace(replace(replace(replace(replace(replace(replace(replace(replace(C,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_zh-CN]
	  , replace(replace(replace(replace(replace(replace(replace(replace(replace(F,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_fr-FR]
	  , replace(replace(replace(replace(replace(replace(replace(replace(replace(G,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_de-DE]
	  , replace(replace(replace(replace(replace(replace(replace(replace(replace(L,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_it-IT]
	  , replace(replace(replace(replace(replace(replace(replace(replace(replace(P,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_pt-BR]
	  , replace(replace(replace(replace(replace(replace(replace(replace(replace(S,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_es-ES]
	  , replace(replace(replace(replace(replace(replace(replace(replace(replace(R,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_ru-RU]
	  , replace(replace(replace(replace(replace(replace(replace(replace(replace(J,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_ja-JP]
INTO #PreEMPConsistParts
FROM #CPRecordsToString PIVOT(MAX(TRANSLATEDPARTNAME) FOR LANGUAGEINDICATOR IN([8]
		,C
		,F
		,G
		,L
		,P
		,S
		,R
		,J)) AS pvt;
DROP TABLE IF EXISTS #CPRecordsToString;

SELECT
	a.[IESYSTEMCONTROLNUMBER],
	COALESCE('["' + STRING_AGG(CAST(CONSISTPART AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS CONSISTPART,
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_id-ID] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_id-ID],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_zh-CN] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_zh-CN],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_fr-FR] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_fr-FR],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_de-DE] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_de-DE],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_it-IT] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_it-IT],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_pt-BR] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_pt-BR],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_es-ES] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_es-ES],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_ru-RU] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_ru-RU],
	COALESCE('["' + STRING_AGG(CAST([consistPartNames_ja-JP] AS NVARCHAR(MAX)),'","') WITHIN GROUP (ORDER BY CONSISTPART) + '"]','') AS [consistPartNames_ja-JP],
	min(a.[INSERTDATE]) INSERTDATE
--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
Into #EMPConsistParts
FROM #PreEMPConsistParts a
GROUP BY
	a.IESYSTEMCONTROLNUMBER

DROP TABLE IF EXISTS #PreEMPConsistParts;

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_EMPConsistParts_iesystemcontrolnumber
    ON #EMPConsistParts(IESYSTEMCONTROLNUMBER)

/*---------------
Metrics calculated on SB2 Database:
 #CPRecordsToString insert 7,640,804  ( ~12 Seconds)
 #PreEMPConsistParts insert 1,872,814  ( ~1.14 Min )
 #EMPConsistParts insert (pivot + translations) on  114,368   ( ~1.30 Min )
 Total (Basic Parts + Consist Parts) ~2.46 Min
End of EMP Consist Parts load
---------------*/

--Load Product Hierarchy data that's specific to EMP parts

DROP TABLE IF EXISTS #EMPProductHierarchy;
DROP TABLE IF EXISTS #PreEMPProductHierarchy;
DROP TABLE IF EXISTS #PHRecordsToString;
DROP TABLE IF EXISTS #PHRecordsToString_FM
DROP TABLE IF EXISTS #PHRecordsToStringResult
DROP TABLE IF EXISTS #PHRecordsToStringResult_SF
DROP TABLE IF EXISTS #PHRecordsToString_SF
DROP TABLE IF EXISTS #PHRecordsToString_SNP
DROP TABLE IF EXISTS #PHRecordsToStringResult_SNP

CREATE TABLE #EMPProductHierarchy
(
	[Iesystemcontrolnumber] VARCHAR (50) NOT NULL,
	[familyCode] VARCHAR (MAX) NULL,
	[familySubFamilyCode] VARCHAR (MAX) NULL,
	[familySubFamilySalesModel] VARCHAR (MAX) NULL,
	[familySubFamilySalesModelSNP] VARCHAR (MAX) NULL,
	[InsertDate] DATETIME NOT NULL,
	PRIMARY KEY CLUSTERED ([Iesystemcontrolnumber] ASC)
	);


select
	a.IESYSTEMCONTROLNUMBER,
	replace( --escape /
			replace( --escape "
					replace( --replace carriage return (ascii 13)
							replace( --replace form feed (ascii 12)
									replace( --replace vertical tab (ascii 11)
											replace( --replace line feed (ascii 10)
													replace( --replace horizontal tab (ascii 09)
															replace( --replace backspace (ascii 08)
																	replace( --escape \
																			isnull(c.Family_Code,'')
																		,'\', '\\')
																,char(8), ' ')
														,char(9), ' ')
												,char(10), ' ')
										,char(11), ' ')
								,char(12), ' ')
						,char(13), ' ')
				,'"', '\"')
		,'/', '\/') as Family_Code,
	replace( --escape /
			replace( --escape "
					replace( --replace carriage return (ascii 13)
							replace( --replace form feed (ascii 12)
									replace( --replace vertical tab (ascii 11)
											replace( --replace line feed (ascii 10)
													replace( --replace horizontal tab (ascii 09)
															replace( --replace backspace (ascii 08)
																	replace( --escape \
																			isnull(c.Subfamily_Code,'')
																		,'\', '\\')
																,char(8), ' ')
														,char(9), ' ')
												,char(10), ' ')
										,char(11), ' ')
								,char(12), ' ')
						,char(13), ' ')
				,'"', '\"')
		,'/', '\/') as Subfamily_Code,
	replace( --escape /
			replace( --escape "
					replace( --replace carriage return (ascii 13)
							replace( --replace form feed (ascii 12)
									replace( --replace vertical tab (ascii 11)
											replace( --replace line feed (ascii 10)
													replace( --replace horizontal tab (ascii 09)
															replace( --replace backspace (ascii 08)
																	replace( --escape \
																			isnull(b.Model,'')
																		,'\', '\\')
																,char(8), ' ')
														,char(9), ' ')
												,char(10), ' ')
										,char(11), ' ')
								,char(12), ' ')
						,char(13), ' ')
				,'"', '\"')
		,'/', '\/') as Sales_Model,
	replace( --escape /
			replace( --escape "
					replace( --replace carriage return (ascii 13)
							replace( --replace form feed (ascii 12)
									replace( --replace vertical tab (ascii 11)
											replace( --replace line feed (ascii 10)
													replace( --replace horizontal tab (ascii 09)
															replace( --replace backspace (ascii 08)
																	replace( --escape \
																			isnull(b.SNP,'')
																		,'\', '\\')
																,char(8), ' ')
														,char(9), ' ')
												,char(10), ' ')
										,char(11), ' ')
								,char(12), ' ')
						,char(13), ' ')
				,'"', '\"')
		,'/', '\/') as Serial_Number_Prefix,
	d.LASTMODIFIEDDATE INSERTDATE
into #PHRecordsToString
from SISWEB_OWNER_SHADOW.LNKIEPRODUCTINSTANCE a
		 inner join SISWEB_OWNER_SHADOW.EMPPRODUCTINSTANCE b on a.EMPPRODUCTINSTANCE_ID = b.EMPPRODUCTINSTANCE_ID
		 inner join sis.vw_Product c on b.SNP=c.Serial_Number_Prefix
		 inner join SISWEB_OWNER_SHADOW.LNKMEDIAIEPART d on a.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER
		 inner join [SISWEB_OWNER].[MASMEDIA] e on e.MEDIANUMBER=d.MEDIANUMBER
	inner join #InsertRecords i on i.IESYSTEMCONTROLNUMBER = a.IESYSTEMCONTROLNUMBER
--Add filter to limit to changed records
where e.MEDIASOURCE = 'N' and e.MEDIAORIGIN = 'EM'

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_PHRecordsToString_IESystemControlNumber]
ON #PHRecordsToString (IESYSTEMCONTROLNUMBER ASC)
INCLUDE (Family_Code, Subfamily_Code, Sales_Model, Serial_Number_Prefix, INSERTDATE)
Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'


-- Family_Code
Select
	IESYSTEMCONTROLNUMBER,
	Family_Code,
	max(INSERTDATE) INSERTDATE
Into #PHRecordsToString_FM
From #PHRecordsToString
Group by IESYSTEMCONTROLNUMBER, Family_Code

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_IeSystemControlNumber_FM]
ON #PHRecordsToString_FM (IESYSTEMCONTROLNUMBER ASC)
INCLUDE (Family_Code, INSERTDATE)
Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Family_Code'

Select
	a.IESYSTEMCONTROLNUMBER,
	'["' + string_agg(a.Family_Code,'","') + '"]'  As RecordsToString,
	min(a.INSERTDATE) INSERTDATE
--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into #PHRecordsToStringResult
from #PHRecordsToString_FM a
Group by
	a.IESYSTEMCONTROLNUMBER

--Add pkey to result
Alter Table #PHRecordsToStringResult Alter Column IESYSTEMCONTROLNUMBER varchar(50) Not NULL
ALTER TABLE #PHRecordsToStringResult ADD PRIMARY KEY CLUSTERED (IESYSTEMCONTROLNUMBER)
	Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

	Insert into #EMPProductHierarchy
	(Iesystemcontrolnumber,familyCode,InsertDate)
Select IESYSTEMCONTROLNUMBER, RecordsToString, INSERTDATE
from #PHRecordsToStringResult

--Drop temp
Drop table #PHRecordsToStringResult
Drop table #PHRecordsToString_FM


-- Subfamily_Code
Select
	IESYSTEMCONTROLNUMBER,
	cast(Family_Code + '_' + Subfamily_Code as varchar(MAX)) RTS,
	max(INSERTDATE) INSERTDATE
Into #PHRecordsToString_SF
From #PHRecordsToString
Group by IESYSTEMCONTROLNUMBER, Family_Code, Subfamily_Code

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_IESystemControlNumber_SF]
ON #PHRecordsToString_SF (IESYSTEMCONTROLNUMBER ASC)
INCLUDE (RTS, INSERTDATE)
Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Subfamily_Code'

Select
	a.IESYSTEMCONTROLNUMBER,
	'["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
	min(a.INSERTDATE) INSERTDATE
--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
into #PHRecordsToStringResult_SF
from #PHRecordsToString_SF a
Group by
	a.IESYSTEMCONTROLNUMBER

--Add pkey to result
Alter Table  #PHRecordsToStringResult_SF Alter Column IESYSTEMCONTROLNUMBER varchar(50) Not NULL
ALTER TABLE  #PHRecordsToStringResult_SF ADD PRIMARY KEY CLUSTERED (IESYSTEMCONTROLNUMBER)
	Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

Update x
set familySubFamilyCode = y.RecordsToString
	From #EMPProductHierarchy  x
	inner join #PHRecordsToStringResult_SF y on x.IESYSTEMCONTROLNUMBER = y.IESYSTEMCONTROLNUMBER

--Drop temp
Drop table #PHRecordsToStringResult_SF
Drop table #PHRecordsToString_SF

Declare @LoopCount int = 0
Declare @BatchInsertCount int = 0
Declare @BatchProcessCount int = 0
Declare @BatchCount int = 100000
--Each loop will process this number of IDs
Declare @UpdateCount int = 0

-- Sales_Model
Select
	IESYSTEMCONTROLNUMBER,
	cast(Family_Code + '_' + Subfamily_Code + '_' + Sales_Model as varchar(MAX)) RTS,
	max(INSERTDATE) INSERTDATE
Into #PHRecordsToString_SM
From #PHRecordsToString
Group by IESYSTEMCONTROLNUMBER, Family_Code, Subfamily_Code, Sales_Model

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_IESystemControlNumber_SM]
ON #PHRecordsToString_SM (IESYSTEMCONTROLNUMBER ASC)
INCLUDE (RTS, INSERTDATE)
Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Sales_Model'

Create table #PHRecordsToStringResult_SM
(
	IESYSTEMCONTROLNUMBER varchar(50) not null,
	RecordsToString varchar(max) null,
	INSERTDATE datetime not null
)

--Add pkey to result
Alter Table  #PHRecordsToStringResult_SM Alter Column IESYSTEMCONTROLNUMBER varchar(50) Not NULL
ALTER TABLE  #PHRecordsToStringResult_SM ADD PRIMARY KEY CLUSTERED (IESYSTEMCONTROLNUMBER)
	Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'


	While (Select count(*)
	from #PHRecordsToString_SM) > 0
Begin


Insert into #PHRecordsToStringResult_SM
Select
	a.IESYSTEMCONTROLNUMBER,
	'["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
	min(a.INSERTDATE) INSERTDATE
	--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from (Select top (@BatchCount) With Ties
			*
	  From #PHRecordsToString_SM
	  order by IESYSTEMCONTROLNUMBER) a
Group by
	a.IESYSTEMCONTROLNUMBER

	Set @BatchInsertCount = @@ROWCOUNT
SET @RowCount= @RowCount + @BatchInsertCount
Set @LoopCount = @LoopCount + 1

	Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Sales_Model, Count: ' + Cast(@BatchInsertCount as varchar(50))

Update x
set familySubFamilySalesModel = y.RecordsToString
	From #EMPProductHierarchy  x
		inner join #PHRecordsToStringResult_SM y on x.IESYSTEMCONTROLNUMBER = y.IESYSTEMCONTROLNUMBER

Delete a
From #PHRecordsToString_SM a
		inner join (Select Distinct IESYSTEMCONTROLNUMBER
		From
			(Select top (@BatchCount) with Ties
				IESYSTEMCONTROLNUMBER
			From #PHRecordsToString_SM
			order by IESYSTEMCONTROLNUMBER) x
) b on a.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER

	Set @BatchProcessCount = @@ROWCOUNT
	Print cast(getdate() as varchar(50)) + ' - Total Update Count: ' + Cast(@RowCount as varchar(50)) + ' | Loop Count: ' + Cast(@LoopCount as varchar(50)) + ' | Batch Update Count: ' + Cast(@BatchInsertCount as varchar(50)) + ' | Batch Rows Processed: ' + Cast(@BatchProcessCount as varchar(50))

	Truncate table #PHRecordsToStringResult_SM

End
--End of records to string loop

--Drop temp
Drop table #PHRecordsToStringResult_SM
Drop table #PHRecordsToString_SM

--SNP
Select
	IESYSTEMCONTROLNUMBER,
	cast(Family_Code + '_' + Subfamily_Code + '_' + Sales_Model + '_' + Serial_Number_Prefix as varchar(MAX)) RTS,
	max(INSERTDATE) INSERTDATE
Into #PHRecordsToString_SNP
From #PHRecordsToString
Group by IESYSTEMCONTROLNUMBER, Family_Code, Subfamily_Code, Sales_Model, Serial_Number_Prefix

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_IESystemControlNumber_SNP]
ON #PHRecordsToString_SNP (IESYSTEMCONTROLNUMBER ASC)
INCLUDE (RTS, INSERTDATE)
Print cast(getdate() as varchar(50)) + ' - Nonclustered index added, Sales_Model'

Create table #PHRecordsToStringResult_SNP
(
	IESYSTEMCONTROLNUMBER varchar(50) not null,
	RecordsToString varchar(max) null,
	INSERTDATE datetime not null
)

--Add pkey to result
Alter Table  #PHRecordsToStringResult_SNP Alter Column IESYSTEMCONTROLNUMBER varchar(50) Not NULL
ALTER TABLE  #PHRecordsToStringResult_SNP ADD PRIMARY KEY CLUSTERED (IESYSTEMCONTROLNUMBER)
	Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

	While (Select count(*)
	from #PHRecordsToString_SNP) > 0
Begin

Insert into #PHRecordsToStringResult_SNP
Select
	a.IESYSTEMCONTROLNUMBER,
	'["' + string_agg(a.RTS,'","') + '"]'  As RecordsToString,
	min(a.INSERTDATE) INSERTDATE
	--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from (Select top (@BatchCount) With Ties
			*
	  From #PHRecordsToString_SNP
	  order by IESYSTEMCONTROLNUMBER) a
Group by
	a.IESYSTEMCONTROLNUMBER

	Set @BatchInsertCount = @@ROWCOUNT
SET @RowCount= @RowCount + @BatchInsertCount
Set @LoopCount = @LoopCount + 1

	Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult, Serial_Number_Prefix, Count: ' + Cast(@BatchInsertCount as varchar(50))

Update x
set familySubFamilySalesModelSNP = y.RecordsToString
	From #EMPProductHierarchy  x
		inner join #PHRecordsToStringResult_SNP y on x.IESYSTEMCONTROLNUMBER = y.IESYSTEMCONTROLNUMBER

Delete a
From #PHRecordsToString_SNP a
		inner join (Select Distinct IESYSTEMCONTROLNUMBER
		From (
Select top (@BatchCount) with Ties
				IESYSTEMCONTROLNUMBER
			From #PHRecordsToString_SNP
			order by IESYSTEMCONTROLNUMBER
) x ) b on a.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER

	Set @BatchProcessCount = @@ROWCOUNT
	Print cast(getdate() as varchar(50)) + ' - Total Update Count: ' + Cast(@RowCount as varchar(50)) + ' | Loop Count: ' + Cast(@LoopCount as varchar(50)) + ' | Batch Update Count: ' + Cast(@BatchInsertCount as varchar(50)) + ' | Batch Rows Processed: ' + Cast(@BatchProcessCount as varchar(50))

	Truncate table #PHRecordsToStringResult_SNP

End
--End of records to string loop

--Drop temp
Drop table  #PHRecordsToStringResult_SNP
Drop table #PHRecordsToString_SNP

/*
Metrics calculated on SB2 Database:
	#PHRecordsToString insert 13,594,560 ( ~15 Seconds)
	#EMPProductHierarchy insert after conversions 111,424 ( ~4.20 Seconds )
	Total (Basic Parts + Consist Parts + Product Hierarchy) ~ 7.12 Min
 */
--End of EMP Product Hierarchy load

--Load Product Structure data that's specific to EMP

DROP TABLE IF EXISTS #EMPProductStructure
DROP TABLE IF EXISTS #PSRecordsToString
DROP TABLE IF EXISTS #PSRecordsToStringSystem

CREATE TABLE #EMPProductStructure
(
	[Iesystemcontrolnumber] VARCHAR (50) NOT NULL,
    [SYSTEMPSID] VARCHAR (MAX) NULL,
	[PSID] VARCHAR (MAX) NULL,
	[InsertDate] DATETIME NOT NULL,
	PRIMARY KEY CLUSTERED ([Iesystemcontrolnumber] ASC)
	);
;with
	 CTE_PRODUCTSTRUCTURE_2
		 as
		 (
			 SELECT distinct c.IESYSTEMCONTROLNUMBER,
							 CASE
								 WHEN b.PARENTPRODUCTSTRUCTUREID <> '00000000'
									 THEN cast(b.PARENTPRODUCTSTRUCTUREID as varchar) + '_' + cast(a.PSID As varchar)
								 ELSE cast(a.PSID As varchar) + '_' + cast(a.PSID As varchar)
								 END as [PSID],
	 CASE
	 WHEN b.PARENTPRODUCTSTRUCTUREID <> '00000000'
	 THEN cast (b.PARENTPRODUCTSTRUCTUREID as varchar)
	 ELSE cast (a.PSID As varchar)
END
as [SYSTEMPSID],
			e.LASTMODIFIEDDATE [InsertDate]
		From [SISWEB_OWNER_SHADOW].LNKIEPSID a With(NolocK)
			inner join #InsertRecords f --Add filter to limit to changed records
			    on a.IESYSTEMCONTROLNUMBER=f.IESYSTEMCONTROLNUMBER
			inner join [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] e  With(NolocK)
			on e.MEDIANUMBER=a.MEDIANUMBER and a.IESYSTEMCONTROLNUMBER=e.IESYSTEMCONTROLNUMBER
			inner join [SISWEB_OWNER_SHADOW].[LNKIEPRODUCTINSTANCE] c With(NolocK)
			on c.IESYSTEMCONTROLNUMBER=e.IESYSTEMCONTROLNUMBER and c.MEDIANUMBER=e.MEDIANUMBER
			inner join [SISWEB_OWNER].MASPRODUCTSTRUCTURE b With(NolocK)
			on a.PSID=b.PRODUCTSTRUCTUREID and b.LANGUAGEINDICATOR='E'
			inner join [SISWEB_OWNER].[MASMEDIA] g With(NolocK)
			on g.MEDIANUMBER=e.MEDIANUMBER and g.MEDIASOURCE = 'N' and g.MEDIAORIGIN = 'EM'
	)

Select IESYSTEMCONTROLNUMBER,
	   replace( --escape /
			   replace( --escape "
					   replace( --escape carriage return (ascii 13)
							   replace( --escape form feed (ascii 12)
									   replace( --escape vertical tab (ascii 11)
											   replace( --escape line feed (ascii 10)
													   replace( --escape horizontal tab (ascii 09)
															   replace( --escape backspace (ascii 08)
																	   replace( --escape \
																			   isnull(PSID, '')
																		   ,'\', '\\')
																   ,char(8), ' ')
														   ,char(9), ' ')
												   ,char(10), ' ')
										   ,char(11), ' ')
								   ,char(12), ' ')
						   ,char(13), ' ')
				   ,'"', '\"')
		   ,'/', '\/') as PSID,
		   replace( --escape /
			   replace( --escape "
					   replace( --escape carriage return (ascii 13)
							   replace( --escape form feed (ascii 12)
									   replace( --escape vertical tab (ascii 11)
											   replace( --escape line feed (ascii 10)
													   replace( --escape horizontal tab (ascii 09)
															   replace( --escape backspace (ascii 08)
																	   replace( --escape \
																			   isnull([SYSTEMPSID], '')
																		   ,'\', '\\')
																   ,char(8), ' ')
														   ,char(9), ' ')
												   ,char(10), ' ')
										   ,char(11), ' ')
								   ,char(12), ' ')
						   ,char(13), ' ')
				   ,'"', '\"')
		   ,'/', '\/') as [SYSTEMPSID],
	[InsertDate]
into #PSRecordsToString
From CTE_PRODUCTSTRUCTURE_2;

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_EMPProductStructure_IESystemControlNumber]
ON #PSRecordsToString ([IESYSTEMCONTROLNUMBER] ASC)
INCLUDE ([PSID],[SYSTEMPSID],[InsertDate])
Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

Insert into #EMPProductStructure
	(Iesystemcontrolnumber,[PSID],InsertDate)
Select
	a.IESYSTEMCONTROLNUMBER as [IESYSTEMCONTROLNUMBER],
	coalesce(f.PSID,'') As [PSID],
	min(a.InsertDate) InsertDate
--There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from #PSRecordsToString a
	cross apply
	(
	SELECT '[' + stuff
	(
	(SELECT '","'  + cast([PSID] as varchar(MAX))
	FROM #PSRecordsToString as b
	where a.IESYSTEMCONTROLNUMBER=b.IESYSTEMCONTROLNUMBER
	order by b.IESYSTEMCONTROLNUMBER
	FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
		,1,2,'') + '"'+']'
	) f (PSID)
Group by
	a.IESYSTEMCONTROLNUMBER,
	f.PSID
SET @RowCount= @@RowCount
	Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

Select distinct IESYSTEMCONTROLNUMBER,[SYSTEMPSID]
into #PSRecordsToStringSystem
From #PSRecordsToString

DROP TABLE IF EXISTS #SYSTEMPSID
Select
	a.IESYSTEMCONTROLNUMBER,
	coalesce(f.[SYSTEMPSID],'') As [SYSTEMPSID]
into #SYSTEMPSID
from #PSRecordsToString a
	cross apply
	(
	SELECT '[' + stuff
	(
	(SELECT '","'  + cast([SYSTEMPSID] as varchar(MAX))
	FROM #PSRecordsToStringSystem as b
	where a.IESYSTEMCONTROLNUMBER=b.IESYSTEMCONTROLNUMBER
	order by b.IESYSTEMCONTROLNUMBER
	FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
		,1,2,'') + '"'+']'
	) f ([SYSTEMPSID])
Group by
	a.IESYSTEMCONTROLNUMBER,
	f.[SYSTEMPSID]

Update t
Set t.[SYSTEMPSID] = s.[SYSTEMPSID]
	From #EMPProductStructure t
	Inner join #SYSTEMPSID s on t.[IESYSTEMCONTROLNUMBER] = s.[IESYSTEMCONTROLNUMBER]

DROP TABLE IF EXISTS #SYSTEMPSID

/*
Metrics calculated on SB2 Database:
	#EMPProductStructure insert 111,424 ( ~2 Seconds)
	Total (Basic Parts + Consist Parts + Product Hierarchy + Product Structure) ~ 7.34 Min
 */
--End of EMP Product Structure load

--Load SNP data that's specific to EMP

DROP TABLE IF EXISTS #SNPRecordsToString;
DROP TABLE IF EXISTS #SNPRecordsToString_Ranked;
DROP TABLE IF EXISTS #EMPSerialNumberPrefixes;
DROP TABLE IF EXISTS #SNPArray

;with
	 CTE_SNP_4
		 as
		 (
			 Select distinct
				 a.IESYSTEMCONTROLNUMBER,
				 a.SNP,
				 c.LASTMODIFIEDDATE InsertDate,
				 a.PRODUCTINSTANCENUMBERS
			 FROM (
					  select IESYSTEMCONTROLNUMBER, SNP,
							 ISNULL('"' + STRING_AGG(cast(epi.NUMBER as varchar(max)),'","') + '"', '') AS [ProductInstanceNumbers]
					  from [SISWEB_OWNER_SHADOW].[LNKIEPRODUCTINSTANCE] lpi
						  inner join SISWEB_OWNER_SHADOW.EMPPRODUCTINSTANCE epi on epi.EMPPRODUCTINSTANCE_ID = lpi.EMPPRODUCTINSTANCE_ID
					  group by IESYSTEMCONTROLNUMBER, SNP

				  ) a
					  inner join [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] c With(NolocK) --3M
 on a.IESYSTEMCONTROLNUMBER =c.IESYSTEMCONTROLNUMBER
	 inner join #InsertRecords d --Add filter to limit to changed records
	 on c.IESYSTEMCONTROLNUMBER=d.IESYSTEMCONTROLNUMBER
	 inner join [SISWEB_OWNER].[MASMEDIA] b With(NolocK) --90K
 on b.MEDIANUMBER = c.MEDIANUMBER
 where b.MEDIASOURCE = 'N' and b.MEDIAORIGIN = 'EM'
	 )
Select IESYSTEMCONTROLNUMBER,
	   replace( --escape /
			   replace( --escape "
					   replace( --escape carriage return (ascii 13)
							   replace( --escape form feed (ascii 12)
									   replace( --escape vertical tab (ascii 11)
											   replace( --escape line feed (ascii 10)
													   replace( --escape horizontal tab (ascii 09)
															   replace( --escape backspace (ascii 08)
																	   replace( --escape \
																			   isnull(SNP,'')
																		   ,'\', '\\')
																   ,char(8), ' ')
														   ,char(9), ' ')
												   ,char(10), ' ')
										   ,char(11), ' ')
								   ,char(12), ' ')
						   ,char(13), ' ')
				   ,'"', '\"')
		   ,'/', '\/') as SNP,
	   InsertDate,
	   PRODUCTINSTANCENUMBERS
into #SNPRecordsToString
From CTE_SNP_4;

--NCI
CREATE NONCLUSTERED INDEX [IX_SNPRecordsToString_IESystemControlNumbers]
ON #SNPRecordsToString ([IESYSTEMCONTROLNUMBER], [SNP])
INCLUDE ([InsertDate], [PRODUCTINSTANCENUMBERS])
Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

Select

	x.IESYSTEMCONTROLNUMBER,
	r.SNP,

	r.InsertDate,
	r.PRODUCTINSTANCENUMBERS
Into #SNPRecordsToString_Ranked
From
	(
		--Get
		Select
			IESYSTEMCONTROLNUMBER
		From #SNPRecordsToString
		Group by IESYSTEMCONTROLNUMBER
	) x
		--Get the SNP & InsertDate
		Inner Join #SNPRecordsToString r on
			x.IESYSTEMCONTROLNUMBER = r.IESYSTEMCONTROLNUMBER


SELECT
	IESYSTEMCONTROLNUMBER,
	ISNULL('["' + STRING_AGG(cast(SNP as varchar(max)),'","') WITHIN GROUP (ORDER BY SNP) + '"]','[]') AS [serialNumbers.serialNumberPrefixes],
	ISNULL('[' + STRING_AGG(cast(PRODUCTINSTANCENUMBERS as varchar(max)),',') + ']','[]') AS [ProductInstanceNumbers],
	max(InsertDate) [InsertDate]
Into #SNPArray
FROM #SNPRecordsToString_Ranked
GROUP BY
	IESYSTEMCONTROLNUMBER


SELECT
	IESYSTEMCONTROLNUMBER,
	(
		Select
			JSON_Query(b.[serialNumbers.serialNumberPrefixes]) [serialNumberPrefixes]
		From #SNPArray b
		where a.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER
	For JSON Path
	) SerialNumbers,
	(
Select
	PRODUCTINSTANCENUMBERS as [ProductInstanceNumbers]
from #SNPArray c
where a.IESYSTEMCONTROLNUMBER = c.IESYSTEMCONTROLNUMBER
	) ProductInstanceNumbers,
	max(InsertDate) InsertDate
into #EMPSerialNumberPrefixes
FROM #SNPArray a
GROUP BY
	IESYSTEMCONTROLNUMBER

DROP TABLE IF EXISTS #SNPRecordsToString;
DROP TABLE IF EXISTS #SNPRecordsToString_Ranked;
DROP TABLE IF EXISTS #SNPArray

/*
Metrics calculated on SB2 Database:
	#EMPSerialNumberPrefixes insert 111,424 ( ~15 Seconds)
	Total (Basic Parts + Consist Parts + Product Hierarchy + Product Structure
			Serial Number Prefixes ) ~ 8.18 Min
 */
--End of EMP Serial Number Prefixes load

--Load to final EMP table

--Prep
DROP TABLE IF EXISTS #ConsolidatedEMP

--Create Temp
CREATE TABLE #ConsolidatedEMP (
	[ID] [varchar](50) NOT NULL,
	[Iesystemcontrolnumber] [varchar](50) NULL,
	[INSERTDATE] [datetime] NULL,
	[InformationType] [varchar](10) NULL,
	[Medianumber] [varchar](15) NULL,
	[IEupdatedate] [datetime2](0) NULL,
	[IEpart] [nvarchar](700) NULL,
    [IEpartNumber] [varchar](40) NULL,
	[PARTSMANUALMEDIANUMBER] [varchar](15) NULL,
	[IECAPTION] [nvarchar](2048) NULL,
	[CONSISTPART] [nvarchar](max) NULL,
    [SYSTEMPSID] [varchar](max) NULL,
	[PSID] [varchar](max) NULL,
	[SerialNumbers] [varchar](max) NULL,
	[ProductInstanceNumbers] [varchar](max) NULL,
	[isMedia] [bit] NULL,
-- 	[Profile] varchar(max) NULL,
	[PubDate] [datetime] NULL,
	[ControlNumber] [varchar](50) NULL,
	[familyCode] [varchar](max) NULL,
	[familySubFamilyCode] [varchar](max) NULL,
	[familySubFamilySalesModel] [varchar](max) NULL,
	[familySubFamilySalesModelSNP] [varchar](max) NULL,
-- 	[IePartHistory] [varchar](max) NULL,
-- 	[ConsistPartHistory] [varchar](max) NULL,
-- 	[IePartReplacement] [varchar](max) NULL,
-- 	[ConsistPartReplacement] [varchar](max) NULL,
	[ConsistPartNames_es-ES] [nvarchar](max) NULL,
	[ConsistPartNames_zh-CN] [nvarchar](max) NULL,
	[ConsistPartNames_fr-FR] [nvarchar](max) NULL,
	[ConsistPartNames_it-IT] [nvarchar](max) NULL,
	[ConsistPartNames_de-DE] [nvarchar](max) NULL,
	[ConsistPartNames_pt-BR] [nvarchar](max) NULL,
	[ConsistPartNames_id-ID] [nvarchar](max) NULL,
	[ConsistPartNames_ja-JP] [nvarchar](max) NULL,
	[ConsistPartNames_ru-RU] [nvarchar](max) NULL,
	[mediaOrigin] [varchar](2) NULL,
    [orgCode] [varchar](12)   NULL
);

--Set collation of temp
ALTER TABLE #ConsolidatedEMP
ALTER COLUMN [ID] varchar(50) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL

CREATE NONCLUSTERED INDEX IX_CONSOLIDATEDEMP
ON #ConsolidatedEMP ([Iesystemcontrolnumber])
INCLUDE ([ID],[INSERTDATE],[InformationType],[Medianumber],[IEupdatedate],
	[IEpart],[IEpartNumber],[PARTSMANUALMEDIANUMBER],[IECAPTION],[CONSISTPART],[SYSTEMPSID],[PSID],
	[isMedia],[PubDate],[ControlNumber],[familyCode],[familySubFamilyCode],
	[familySubFamilySalesModel],[familySubFamilySalesModelSNP],[ConsistPartNames_es-ES],
	[ConsistPartNames_zh-CN],[ConsistPartNames_fr-FR],[ConsistPartNames_it-IT],[ConsistPartNames_de-DE],
	[ConsistPartNames_pt-BR],[ConsistPartNames_id-ID],[ConsistPartNames_ja-JP],[ConsistPartNames_ru-RU],[mediaOrigin],
    [orgCode]);

DROP TABLE IF EXISTS #CONSOLIDATEDPARTS_4_IESYSTEMCONTROLNUMBERS;
CREATE TABLE #CONSOLIDATEDPARTS_4_IESYSTEMCONTROLNUMBERS (IESYSTEMCONTROLNUMBER VARCHAR(50) NOT NULL PRIMARY KEY);

INSERT INTO #CONSOLIDATEDPARTS_4_IESYSTEMCONTROLNUMBERS
SELECT IESYSTEMCONTROLNUMBER
FROM(SELECT IESYSTEMCONTROLNUMBER FROM #EMPBasicParts AS bp
	 UNION
	 SELECT IESYSTEMCONTROLNUMBER FROM #EMPConsistParts AS cp
	 UNION
	 SELECT IESYSTEMCONTROLNUMBER FROM #EMPProductStructure AS ps
	 UNION
	 SELECT IESYSTEMCONTROLNUMBER FROM #EMPSerialNumberPrefixes AS snp
	 UNION
	 SELECT IESYSTEMCONTROLNUMBER FROM #EMPProductHierarchy AS ph
	) AS T
;


--Insert updated source into temp
Insert into #ConsolidatedEMP
SELECT
	cast(IESYSTEMCONTROLNUMBERS.IESYSTEMCONTROLNUMBER as VARCHAR) As ID
	 ,coalesce(bp.[Iesystemcontrolnumber], cp.IESYSTEMCONTROLNUMBER, ps.[Iesystemcontrolnumber]
  		, snp.[Iesystemcontrolnumber], ph.[Iesystemcontrolnumber]) [Iesystemcontrolnumber]
	 ,coalesce(bp.InsertDate, cp.[INSERTDATE], ps.InsertDate, snp.InsertDate, ph.InsertDate) [INSERTDATE]
	 ,nullif(nullif(bp.[InformationType], '[""]'), '') [InformationType]
	 ,nullif(nullif(bp.[Medianumber], '[""]'), '') [Medianumber]
	 ,bp.[IEupdatedate]
	 ,bp.[IEpart]
     ,bp.[IEpartNumber]
	 ,nullif(nullif(bp.[PARTSMANUALMEDIANUMBER], '[""]'), '') [PARTSMANUALMEDIANUMBER]
	 ,bp.[IECAPTION]
	 --ConsistParts
	 ,nullif(nullif(cp.[CONSISTPART], '[""]'), '') [CONSISTPART]
	 --ProductStructure

     ,nullif(nullif(ps.[SYSTEMPSID], '[""]'), '') [SYSTEMPSID]
	 ,nullif(nullif(ps.[PSID], '[""]'), '') [PSID]

	 --SNP
	 ,nullif(nullif(snp.[SerialNumbers], '[""]'), '') [SerialNumbers]
	 ,nullif(nullif(snp.[ProductInstanceNumbers], '[""]'), '') [ProductInstanceNumbers]
	 ,bp.[isMedia]

	 ,bp.[PubDate]
	 ,nullif(nullif(bp.[ControlNumber], '[""]'), '') [ControlNumber]
	 ,nullif(nullif(ph.[familyCode], '[""]'), '') familyCode
	 ,nullif(nullif(ph.[familySubFamilyCode], '[""]'), '') familySubFamilyCode
	 ,nullif(nullif(ph.[familySubFamilySalesModel], '[""]'), '') familySubFamilySalesModel
	 ,nullif(nullif(ph.[familySubFamilySalesModelSNP], '[""]'), '') familySubFamilySalesModelSNP

	 ,nullif(nullif(cp.[ConsistPartNames_es-ES], '[""]'), '') [ConsistPartNames_es-ES]
	 ,nullif(nullif(cp.[ConsistPartNames_fr-FR], '[""]'), '') [ConsistPartNames_zh-CN]
	 ,nullif(nullif(cp.[ConsistPartNames_fr-FR], '[""]'), '') [ConsistPartNames_fr-FR]
	 ,nullif(nullif(cp.[ConsistPartNames_it-IT], '[""]'), '') [ConsistPartNames_it-IT]
	 ,nullif(nullif(cp.[ConsistPartNames_de-DE], '[""]'), '') [ConsistPartNames_de-DE]
	 ,nullif(nullif(cp.[ConsistPartNames_pt-BR], '[""]'), '') [ConsistPartNames_pt-BR]
	 ,nullif(nullif(cp.[ConsistPartNames_id-ID], '[""]'), '') [ConsistPartNames_id-ID]
	 ,nullif(nullif(cp.[ConsistPartNames_ja-JP], '[""]'), '') [ConsistPartNames_ja-JP]
	 ,nullif(nullif(cp.[ConsistPartNames_ru-RU], '[""]'), '') [ConsistPartNames_ru-RU]
	 ,mediaOrigin
	 ,bp.orgCode [orgCode]


FROM #CONSOLIDATEDPARTS_4_IESYSTEMCONTROLNUMBERS AS IESYSTEMCONTROLNUMBERS
		 LEFT JOIN #EMPBasicParts AS bp ON bp.IESYSTEMCONTROLNUMBER = IESYSTEMCONTROLNUMBERS.IESYSTEMCONTROLNUMBER
		 LEFT JOIN #EMPConsistParts AS cp ON cp.IESYSTEMCONTROLNUMBER = IESYSTEMCONTROLNUMBERS.IESYSTEMCONTROLNUMBER
		 LEFT JOIN #EMPProductStructure AS ps ON ps.IESYSTEMCONTROLNUMBER = IESYSTEMCONTROLNUMBERS.IESYSTEMCONTROLNUMBER
		 LEFT JOIN #EMPSerialNumberPrefixes AS snp ON snp.IESYSTEMCONTROLNUMBER = IESYSTEMCONTROLNUMBERS.IESYSTEMCONTROLNUMBER
		 LEFT JOIN #EMPProductHierarchy AS ph ON ph.IESYSTEMCONTROLNUMBER = IESYSTEMCONTROLNUMBERS.IESYSTEMCONTROLNUMBER
;

Update tgt
Set
  tgt.[INSERTDATE] = src.[INSERTDATE]
  ,tgt.[InformationType] = src.[InformationType]
  ,tgt.[Medianumber] = src.[Medianumber]
  ,tgt.[IEupdatedate] = src.[IEupdatedate]
  ,tgt.[IEpart] = src.[IEpart]
  ,tgt.[IEpartNumber] = src.[IEpartNumber]
  ,tgt.[PARTSMANUALMEDIANUMBER] = src.[PARTSMANUALMEDIANUMBER]
  ,tgt.[IECAPTION] = src.[IECAPTION]
  ,tgt.[CONSISTPART] = src.[CONSISTPART]
  ,tgt.[SYSTEM] = src.[SYSTEMPSID]
  ,tgt.[SYSTEMPSID] = src.[SYSTEMPSID]
  ,tgt.[PSID] = src.[PSID]
  ,tgt.[SerialNumbers] = src.[SerialNumbers]
  ,tgt.[ProductInstanceNumbers] = src.[ProductInstanceNumbers]
  ,tgt.[isMedia] = src.[isMedia]
  ,tgt.[PubDate] = src.[PubDate]
  ,tgt.[ControlNumber] = src.[ControlNumber]
  ,tgt.[familyCode] = src.[familyCode]
  ,tgt.[familySubFamilyCode] = src.[familySubFamilyCode]
  ,tgt.[familySubFamilySalesModel] = src.[familySubFamilySalesModel]
  ,tgt.familySubFamilySalesModelSNP = src.[familySubFamilySalesModelSNP]

  ,tgt.[ConsistPartNames_es-ES] = src.[ConsistPartNames_es-ES]
  ,tgt.[ConsistPartNames_zh-CN] = src.[ConsistPartNames_zh-CN]
  ,tgt.[ConsistPartNames_fr-FR] = src.[ConsistPartNames_fr-FR]
  ,tgt.[ConsistPartNames_it-IT] = src.[ConsistPartNames_it-IT]
  ,tgt.[ConsistPartNames_de-DE] = src.[ConsistPartNames_de-DE]
  ,tgt.[ConsistPartNames_pt-BR] = src.[ConsistPartNames_pt-BR]
  ,tgt.[ConsistPartNames_id-ID] = src.[ConsistPartNames_id-ID]
  ,tgt.[ConsistPartNames_ja-JP] = src.[ConsistPartNames_ja-JP]
  ,tgt.[ConsistPartNames_ru-RU] = src.[ConsistPartNames_ru-RU]
  ,tgt.[mediaOrigin]= src.[mediaOrigin]
  ,tgt.[orgCode]= src.[orgCode]

	From SISSEARCH.EXPANDEDMININGPRODUCTPARTS tgt
Inner join #ConsolidatedEMP src on tgt.[ID] = src.[ID] --Existing
Where src.[INSERTDATE] > tgt.[INSERTDATE] --Updated in source
   or (tgt. [InformationType] <> src. [InformationType] or (tgt. [InformationType] is null and src. [InformationType] is not null) or (tgt. [InformationType] is not null and src. [InformationType] is null))
   or (tgt. [Medianumber] <> src. [Medianumber] or (tgt. [Medianumber] is null and src. [Medianumber] is not null) or (tgt. [Medianumber] is not null and src. [Medianumber] is null))
   or (tgt. [IEupdatedate] <> src. [IEupdatedate] or (tgt. [IEupdatedate] is null and src. [IEupdatedate] is not null) or (tgt. [IEupdatedate] is not null and src. [IEupdatedate] is null))
   or (tgt. [IEpart] <> src. [IEpart] or (tgt. [IEpart] is null and src. [IEpart] is not null) or (tgt. [IEpart] is not null and src. [IEpart] is null))
   or (tgt. [IEpartNumber] <> src. [IEpartNumber] or (tgt. [IEpartNumber] is null and src. [IEpartNumber] is not null) or (tgt. [IEpartNumber] is not null and src. [IEpartNumber] is null))
   or (tgt. [PARTSMANUALMEDIANUMBER] <> src. [PARTSMANUALMEDIANUMBER] or (tgt. [PARTSMANUALMEDIANUMBER] is null and src. [PARTSMANUALMEDIANUMBER] is not null) or (tgt. [PARTSMANUALMEDIANUMBER] is not null and src. [PARTSMANUALMEDIANUMBER] is null))
   or (tgt. [IECAPTION] <> src. [IECAPTION] or (tgt. [IECAPTION] is null and src. [IECAPTION] is not null) or (tgt. [IECAPTION] is not null and src. [IECAPTION] is null))
   or (tgt. [CONSISTPART] <> src. [CONSISTPART] or (tgt. [CONSISTPART] is null and src. [CONSISTPART] is not null) or (tgt. [CONSISTPART] is not null and src. [CONSISTPART] is null))
   or (tgt. [SYSTEM] <> src. [SYSTEMPSID] or (tgt. [SYSTEM] is null and src. [SYSTEMPSID] is not null) or (tgt. [SYSTEM] is not null and src. [SYSTEMPSID] is null))
   or (tgt. [SYSTEMPSID] <> src. [SYSTEMPSID] or (tgt. [SYSTEMPSID] is null and src. [SYSTEMPSID] is not null) or (tgt. [SYSTEMPSID] is not null and src. [SYSTEMPSID] is null))
   or (tgt. [PSID] <> src. [PSID] or (tgt. [PSID] is null and src. [PSID] is not null) or (tgt. [PSID] is not null and src. [PSID] is null))
   or (tgt. [SerialNumbers] <> src. [SerialNumbers] or (tgt. [SerialNumbers] is null and src. [SerialNumbers] is not null) or (tgt. [SerialNumbers] is not null and src. [SerialNumbers] is null))
   or (tgt. [ProductInstanceNumbers] <> src. [ProductInstanceNumbers] or (tgt. [ProductInstanceNumbers] is null and src. [ProductInstanceNumbers] is not null) or (tgt. [ProductInstanceNumbers] is not null and src. [ProductInstanceNumbers] is null))
   or (tgt. [isMedia] <> src. [isMedia] or (tgt. [isMedia] is null and src. [isMedia] is not null) or (tgt. [isMedia] is not null and src. [isMedia] is null))
   or (tgt. [PubDate] <> src. [PubDate] or (tgt. [PubDate] is null and src. [PubDate] is not null) or (tgt. [PubDate] is not null and src. [PubDate] is null))
   or (tgt. [ControlNumber] <> src. [ControlNumber] or (tgt. [ControlNumber] is null and src. [ControlNumber] is not null) or (tgt. [ControlNumber] is not null and src. [ControlNumber] is null))
   or (tgt. [familyCode] <> src. [familyCode] or (tgt. [familyCode] is null and src. [familyCode] is not null) or (tgt. [familyCode] is not null and src. [familyCode] is null))
   or (tgt. [familySubFamilyCode] <> src. [familySubFamilyCode] or (tgt. [familySubFamilyCode] is null and src. [familySubFamilyCode] is not null) or (tgt. [familySubFamilyCode] is not null and src. [familySubFamilyCode] is null))
   or (tgt. [familySubFamilySalesModel] <> src. [familySubFamilySalesModel] or (tgt. [familySubFamilySalesModel] is null and src. [familySubFamilySalesModel] is not null) or (tgt. [familySubFamilySalesModel] is not null and src. [familySubFamilySalesModel] is null))
   or (tgt. [familySubFamilySalesModelSNP] <> src. [familySubFamilySalesModelSNP] or (tgt. [familySubFamilySalesModelSNP] is null and src. [familySubFamilySalesModelSNP] is not null) or (tgt. [familySubFamilySalesModelSNP] is not null and src. [familySubFamilySalesModelSNP] is null))
   or (tgt. [ConsistPartNames_es-ES] <> src. [ConsistPartNames_es-ES] or (tgt. [ConsistPartNames_es-ES] is null and src. [ConsistPartNames_es-ES] is not null) or (tgt. [ConsistPartNames_es-ES] is not null and src. [ConsistPartNames_es-ES] is null))
   or (tgt. [ConsistPartNames_zh-CN] <> src. [ConsistPartNames_zh-CN] or (tgt. [ConsistPartNames_zh-CN] is null and src. [ConsistPartNames_zh-CN] is not null) or (tgt. [ConsistPartNames_zh-CN] is not null and src. [ConsistPartNames_zh-CN] is null))
   or (tgt. [ConsistPartNames_fr-FR] <> src. [ConsistPartNames_fr-FR] or (tgt. [ConsistPartNames_fr-FR] is null and src. [ConsistPartNames_fr-FR] is not null) or (tgt. [ConsistPartNames_fr-FR] is not null and src. [ConsistPartNames_fr-FR] is null))
   or (tgt. [ConsistPartNames_it-IT] <> src. [ConsistPartNames_it-IT] or (tgt. [ConsistPartNames_it-IT] is null and src. [ConsistPartNames_it-IT] is not null) or (tgt. [ConsistPartNames_it-IT] is not null and src. [ConsistPartNames_it-IT] is null))
   or (tgt. [ConsistPartNames_de-DE] <> src. [ConsistPartNames_de-DE] or (tgt. [ConsistPartNames_de-DE] is null and src. [ConsistPartNames_de-DE] is not null) or (tgt. [ConsistPartNames_de-DE] is not null and src. [ConsistPartNames_de-DE] is null))
   or (tgt. [ConsistPartNames_pt-BR] <> src. [ConsistPartNames_pt-BR] or (tgt. [ConsistPartNames_pt-BR] is null and src. [ConsistPartNames_pt-BR] is not null) or (tgt. [ConsistPartNames_pt-BR] is not null and src. [ConsistPartNames_pt-BR] is null))
   or (tgt. [ConsistPartNames_id-ID] <> src. [ConsistPartNames_id-ID] or (tgt. [ConsistPartNames_id-ID] is null and src. [ConsistPartNames_id-ID] is not null) or (tgt. [ConsistPartNames_id-ID] is not null and src. [ConsistPartNames_id-ID] is null))
   or (tgt. [ConsistPartNames_ja-JP] <> src. [ConsistPartNames_ja-JP] or (tgt. [ConsistPartNames_ja-JP] is null and src. [ConsistPartNames_ja-JP] is not null) or (tgt. [ConsistPartNames_ja-JP] is not null and src. [ConsistPartNames_ja-JP] is null))
   or (tgt. [ConsistPartNames_ru-RU] <> src. [ConsistPartNames_ru-RU] or (tgt. [ConsistPartNames_ru-RU] is null and src. [ConsistPartNames_ru-RU] is not null) or (tgt. [ConsistPartNames_ru-RU] is not null and src. [ConsistPartNames_ru-RU] is null))
   or (tgt. [mediaOrigin] <> src. [mediaOrigin] or (tgt. [mediaOrigin] is null and src. [mediaOrigin] is not null) or (tgt. [mediaOrigin] is not null and src. [mediaOrigin] is null))
   or (tgt. [orgCode] <> src. [orgCode] or (tgt. [orgCode] is null and src. [orgCode] is not null) or (tgt. [orgCode] is not null and src. [orgCode] is null))

--Insert new ID's
INSERT SISSEARCH.EXPANDEDMININGPRODUCTPARTS
(
[ID]
,[Iesystemcontrolnumber]
,[INSERTDATE]
,[InformationType]
,[Medianumber]
,[IEupdatedate]
,[IEpart]
,[IEpartNumber]
,[PARTSMANUALMEDIANUMBER]
,[IECAPTION]
,[CONSISTPART]
,[SYSTEM]
,[SYSTEMPSID]
,[PSID]
,[SerialNumbers]
,[ProductInstanceNumbers]
,[isMedia]
,[PubDate]
,[ControlNumber]
,[familyCode]
,[familySubFamilyCode]
,[familySubFamilySalesModel]
,[familySubFamilySalesModelSNP]
,[ConsistPartNames_es-ES]
,[ConsistPartNames_zh-CN]
,[ConsistPartNames_fr-FR]
,[ConsistPartNames_it-IT]
,[ConsistPartNames_de-DE]
,[ConsistPartNames_pt-BR]
,[ConsistPartNames_id-ID]
,[ConsistPartNames_ja-JP]
,[ConsistPartNames_ru-RU]
,[mediaOrigin]
,[orgCode]
)
Select
	s.[ID]
	 ,s.[Iesystemcontrolnumber]
	 ,s.[INSERTDATE]
	 ,s.[InformationType]
	 ,s.[Medianumber]
	 ,s.[IEupdatedate]
	 ,s.[IEpart]
     ,s.[IEpartNumber]
	 ,s.[PARTSMANUALMEDIANUMBER]
	 ,s.[IECAPTION]
	 ,s.[CONSISTPART]
	 ,s.[SYSTEMPSID]
     ,s.[SYSTEMPSID]
	 ,s.[PSID]
	 ,s.[SerialNumbers]
	 ,s.[ProductInstanceNumbers]
	 ,s.[isMedia]
	 ,s.[PubDate]
	 ,s.[ControlNumber]
	 ,s.[familyCode]
	 ,s.[familySubFamilyCode]
	 ,s.[familySubFamilySalesModel]
	 ,s.[familySubFamilySalesModelSNP]
	 ,s.[ConsistPartNames_es-ES]
	 ,s.[ConsistPartNames_zh-CN]
	 ,s.[ConsistPartNames_fr-FR]
	 ,s.[ConsistPartNames_it-IT]
	 ,s.[ConsistPartNames_de-DE]
	 ,s.[ConsistPartNames_pt-BR]
	 ,s.[ConsistPartNames_id-ID]
	 ,s.[ConsistPartNames_ja-JP]
	 ,s.[ConsistPartNames_ru-RU]
	 ,s.[mediaOrigin]
	 ,s.[orgCode]
From #ConsolidatedEMP s
		 Left outer join SISSEARCH.EXPANDEDMININGPRODUCTPARTS t on s.[ID] = t.[ID]
Where t.[ID] is null --Does not exist in target

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Target [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS_LOAD]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Start graphic control number logic
--Array of GraphicControlNumber
--All IDs have been inserted. Next we need to get an array of GraphicControlNumbers and update the GraphicControlNumber field.

If Object_ID('Tempdb..#RecordsToString_GCN') is not null
  Begin
     Drop table #RecordsToString_GCN
  End;

  Select a.IESYSTEMCONTROLNUMBER As ID, b.GRAPHICCONTROLNUMBER As GraphicControlNumber
  into #RecordsToString_GCN
  from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART]  a
  inner join [SISWEB_OWNER_SHADOW].[LNKIEIMAGE] b on a.IESYSTEMCONTROLNUMBER=b.IESYSTEMCONTROLNUMBER
  inner join [SISWEB_OWNER].[MASMEDIA] c on a.MEDIANUMBER= c.MEDIANUMBER and c.MEDIAORIGIN='EM'
  where a.LASTMODIFIEDDATE > @LastInsertDate

SET @RowCount = @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Loaded to Temp #RecordsToString_GCN (GraphicControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID]
ON #RecordsToString_GCN ([ID] ASC)
INCLUDE (GraphicControlNumber)

--Records to String
SET @StepStartTime = GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToStringResult_GCN') is not null
  Begin
     Drop table #RecordsToStringResult_GCN
  End;

Select [ID],
    coalesce(f.GraphicControlNumberString,'') As [GraphicControlNumber]
into #RecordsToStringResult_GCN
From #RecordsToString_GCN a
CROSS apply
	(
		SELECT '[' + stuff (
			(
				SELECT  '","' + cast(GraphicControlNumber AS varchar(max))
				FROM	#RecordsToString_GCN AS b
                WHERE    a.ID = b.ID
                ORDER BY b.ID, cast(GraphicControlNumber as varchar(MAX))
				FOR xml path(''), type).value('.', 'varchar(max)') ,1,2,''
			) + '"'+']'
	) f (GraphicControlNumberString)
Group By [ID], f.GraphicControlNumberString

SET @RowCount = @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Temp RecordsToStringResult_GCN (GraphicControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--Add pkey to result
Alter Table #RecordsToStringResult_GCN Alter Column ID varchar(50) Not NULL
ALTER TABLE #RecordsToStringResult_GCN ADD PRIMARY KEY CLUSTERED (ID)

--Insert result into target
SET @StepStartTime = GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

--All IDs have been inserted already.  Update with ControlNumber Array.
Update EMP
Set EMP.GraphicControlNumber = nullif(nullif(R.GraphicControlNumber, ''), '[""]')
From SISSEARCH.[EXPANDEDMININGPRODUCTPARTS] EMP
Inner join #RecordsToStringResult_GCN R on EMP.ID = R.ID

SET @RowCount = @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated Target [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS] (GraphicControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--End graphic control number logic

SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LOGID = @SPStartLogID, @DATAVALUE = @RowCount

/*---------------
End of EXPANDEDMININGPRODUCTPARTS table load, total time including all sub-tables ~ 12 Min
  Note: Metrics were calculated on SB2 Database
 ----------------*/


END TRY

BEGIN CATCH
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT= ERROR_LINE()

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC SISSEARCH.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error

END CATCH


End
