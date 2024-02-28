
CREATE   Procedure [SISSEARCH].[CONSISTPARTS_2_LOAD] 
As
/*---------------
Date: 10-04-2017
Object Description:		Loading changed data into SISSEARCH.CONSISTPARTS_2 from base tables
Modify date: 20210125	Davide: Split query to populate #RecordsToString in 2 parts see: https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/9477/
Exec [SISSEARCH].[CONSISTPARTS_2_LOAD]
Truncate table [SISSEARCH].[CONSISTPARTS_2]
---------------*/

Begin

BEGIN TRY

SET NOCOUNT ON

Declare @LASTINSERTDATE Datetime 

Declare @SPStartTime DATETIME,
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
Select IESYSTEMCONTROLNUMBER 
into #DeletedRecords
from  [SISSEARCH].[CONSISTPARTS_2]
Except 
Select IESYSTEMCONTROLNUMBER
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] 

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Records Detected',@DATAVALUE = @RowCount, @LOGID = @StepLogID

-- Delete Idenified Deleted Records in Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete from 
[SISSEARCH].[CONSISTPARTS_2] 
where  IESYSTEMCONTROLNUMBER  in (Select IESYSTEMCONTROLNUMBER From #DeletedRecords)

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Records from Target [SISSEARCH].[CONSISTPARTS_2] ',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Drop Temp
Drop Table #DeletedRecords

--Get Maximum insert date from Target	
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  @LASTINSERTDATE=coalesce(Max(INSERTDATE),'1900-01-01') From [SISSEARCH].[CONSISTPARTS_2]

--Print cast(getdate() as varchar(50)) + ' - Latest Insert Date in Target: ' + cast(@LASTINSERTDATE as varchar(50))


SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
Declare @Logmessage as varchar(50) = 'Latest Insert Date in Target '+cast (@LASTINSERTDATE as varchar(25))
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
  where LASTMODIFIEDDATE > @LASTINSERTDATE

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Detected into #InsertRecords',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_IESYSTEMCONTROLNUMBER 
    ON #InsertRecords(IESYSTEMCONTROLNUMBER)

--Delete Inserted records from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
 	
Delete from [SISSEARCH].[CONSISTPARTS_2]
where IESYSTEMCONTROLNUMBER in
 (Select IESYSTEMCONTROLNUMBER from  #InsertRecords)
 
SET @RowCount= @@RowCount  
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Inserted Records from Target [SISSEARCH].[CONSISTPARTS_2]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
	Drop table #RecordsToString
End
/*Modify date: 20210125	Davide: Split query to populate #RecordsToString in 2 parts see: https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/9477/ */
DROP TABLE IF EXISTS #PreRecordsToString;
SELECT b.IESYSTEMCONTROLNUMBER
	  ,b.IESYSTEMCONTROLNUMBER AS id
	  ,b.LASTMODIFIEDDATE AS      INSERTDATE
	  ,d.PARTNUMBER
	  ,d.PARTNAME
	  ,d.PARTMODIFIER
	  ,t.TRANSLATEDPARTNAME
	  ,t.LANGUAGEINDICATOR
INTO #PreRecordsToString
  FROM SISWEB_OWNER_SHADOW.LNKMEDIAIEPART AS b
	   INNER JOIN SISWEB_OWNER.MASMEDIA AS e ON
												e.MEDIANUMBER = b.MEDIANUMBER
												AND e.MEDIASOURCE = 'A'
	   JOIN SISWEB_OWNER_SHADOW.LNKCONSISTLIST AS d ON b.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER
	   LEFT JOIN SISWEB_OWNER.LNKTRANSLATEDSPN AS t ON d.PARTNAME = t.PARTNAME
  WHERE b.IESYSTEMCONTROLNUMBER IN(SELECT IESYSTEMCONTROLNUMBER FROM #InsertRecords);

SELECT IESYSTEMCONTROLNUMBER
	  ,id
	  ,INSERTDATE
	  ,replace(replace(replace(replace(replace(replace(replace(replace(replace(ISNULL(PARTNUMBER,'') + ':' + ISNULL(PARTNAME,'') + IIF(ISNULL(PARTMODIFIER,'') != '',' ' + PARTMODIFIER,''),'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS CONSISTPART
	  ,replace(replace(replace(replace(replace(replace(replace(replace(replace([8],'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                          [consistPartNames_id-ID]
	  ,replace(replace(replace(replace(replace(replace(replace(replace(replace(C,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_zh-CN]
	  ,replace(replace(replace(replace(replace(replace(replace(replace(replace(F,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_fr-FR]
	  ,replace(replace(replace(replace(replace(replace(replace(replace(replace(G,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_de-DE]
	  ,replace(replace(replace(replace(replace(replace(replace(replace(replace(L,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_it-IT]
	  ,replace(replace(replace(replace(replace(replace(replace(replace(replace(P,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_pt-BR]
	  ,replace(replace(replace(replace(replace(replace(replace(replace(replace(S,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_es-ES]
	  ,replace(replace(replace(replace(replace(replace(replace(replace(replace(R,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_ru-RU]
	  ,replace(replace(replace(replace(replace(replace(replace(replace(replace(J,'\','\\'),CHAR(8),' '),CHAR(9),' '),CHAR(10),' '),CHAR(11),' '),CHAR(12),' '),CHAR(13),' '),'"','\"'),'/','\/') AS                                                                                                            [consistPartNames_ja-JP]
INTO #RecordsToString
  FROM #PreRecordsToString PIVOT(MAX(TRANSLATEDPARTNAME) FOR LANGUAGEINDICATOR IN([8]
																				 ,C
																				 ,F
																				 ,G
																				 ,L
																				 ,P
																				 ,S
																				 ,R
																				 ,J)) AS pvt;
DROP TABLE IF EXISTS #PreRecordsToString;

/*Modify date: 20210125	Davide: Split query to populate #RecordsToString in 2 parts see: https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/9477/ */
SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Loaded to #RecordsToString',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID] 
ON #RecordsToString ([id] ASC)
INCLUDE ([IESYSTEMCONTROLNUMBER],[CONSISTPART],[INSERTDATE])
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

--29 Minutes to Get to this Point

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


--Select  
--    a.IESYSTEMCONTROLNUMBER,
--	a.ID,
--	coalesce(f.CONSISTPARTString,'') As CONSISTPART,
--	min(a.INSERTDATE) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
--into  #RecordsToStringResult
--from  #RecordsToString a
--cross apply 
--(
--	SELECT  '[' + stuff
--	(
--		(SELECT '","' + cast(CONSISTPART as varchar(MAX))        
--		FROM #RecordsToString as b 
--		where a.ID=b.ID 
--		order by b.ID
--		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')   
--	,1,2,'') + '"'+']'     
--) f (CONSISTPARTString)
--Group by 
--a.IESYSTEMCONTROLNUMBER,
--a.ID,
--f.CONSISTPARTString


--1:05 with just English
--5:01 with all languages
--Change from xmlpath to string_agg method
--Drop table #RecordsToStringResult_C
SELECT 
a.[id] ID,
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
min(a.[INSERTDATE]) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
Into #RecordsToStringResult
FROM #RecordsToString a
GROUP BY
a.IESYSTEMCONTROLNUMBER,
a.id


SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Temp RecordsToStringResult',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Drop temp table
Drop Table #RecordsToString

--Add pkey to result
Alter Table #RecordsToStringResult Alter Column ID varchar(50) Not NULL
ALTER TABLE #RecordsToStringResult ADD PRIMARY KEY CLUSTERED (ID) 
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult'

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

--Insert into [SISSEARCH].[CONSISTPARTS_2] (IESYSTEMCONTROLNUMBER,ID,CONSISTPART,INSERTDATE)
--Select IESYSTEMCONTROLNUMBER,ID,CONSISTPART,INSERTDATE from #RecordsToSTringResult

Insert into [SISSEARCH].[CONSISTPARTS_2] 
([IESYSTEMCONTROLNUMBER]
,[ID]
,[CONSISTPART]
,[INSERTDATE]
,[ConsistPartNames_es-ES]
,[ConsistPartNames_zh-CN]
,[ConsistPartNames_fr-FR]
,[ConsistPartNames_it-IT]
,[ConsistPartNames_de-DE]
,[ConsistPartNames_pt-BR]
,[ConsistPartNames_id-ID]
,[ConsistPartNames_ja-JP]
,[ConsistPartNames_ru-RU])
Select 
 [IESYSTEMCONTROLNUMBER]
,[ID]
,[CONSISTPART]
,[INSERTDATE]
,[consistPartNames_es-ES]
,[consistPartNames_zh-CN]
,[consistPartNames_fr-FR]
,[consistPartNames_it-IT]
,[consistPartNames_de-DE]
,[consistPartNames_pt-BR]
,[consistPartNames_id-ID]
,[consistPartNames_ja-JP]
,[consistPartNames_ru-RU]
from #RecordsToStringResult

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Insert into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Insert into Target [SISSEARCH].[CONSISTPARTS_2]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Drop temp
Drop table #RecordsToStringResult


/*
----------------------------------------------------------
Conversion
----------------------------------------------------------
*/

--Print cast(getdate() as varchar(50)) + ' - Conversion Start'

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;



--7:14
--Drop table #RecordsToString_C
;with CTE_CONSISTPART as
(
--LnkMediaPart 3,139,335
--LnkMediaPart + LNKPARTSIESNP 10,122,059
--LnkMediaPart + LNKPARTSIESNP distinct 9,190,684
--LnkMediaPart + LNKPARTSIESNP + MasMedia distinct 4,082,727
--LnkMediaPart + LNKPARTSIESNP + MasMedia + LNKCONSISTLIST distinct 2,689,114 (Some BaseEngineControlNo's are not found in LNKCONSISTLIST)
--LnkMediaPart + LNKPARTSIESNP + MasMedia + LNKCONSISTLIST 77,204,666 (Loads into temp in 2min 47sec)
select
    b.IESYSTEMCONTROLNUMBER,
	b.IESYSTEMCONTROLNUMBER as id,	
	replace( --escape /
		replace( --escape "
			replace( --escape carriage return (ascii 13)
				replace( --escape form feed (ascii 12) 
					replace( --escape vertical tab (ascii 11)
						replace( --escape line feed (ascii 10)
							replace( --escape horizontal tab (ascii 09)
								replace( --escape backspace (ascii 08)
									replace( --escape \
										isnull(d.PARTNUMBER,'')+':'+isnull(d.PARTNAME, '')+
										iif(isnull(d.PARTMODIFIER, '') != '', ' '+d.PARTMODIFIER, '')
									,'\', '\\')
								,char(8), ' ')
							,char(9), ' ')
						,char(10), ' ')
					,char(11), ' ')
				,char(12), ' ')
			,char(13), ' ')
			,'"', '\"')
		,'/', '\/') as CONSISTPART,
   b.LASTMODIFIEDDATE INSERTDATE,

replace(replace(replace(replace(replace(replace(replace(replace(replace(tr.[consistPartNames_id-ID]
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/') as [consistPartNames_id-ID],

replace(replace(replace(replace(replace(replace(replace(replace(replace(tr.[consistPartNames_zh-CN]
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/') as [consistPartNames_zh-CN],

replace(replace(replace(replace(replace(replace(replace(replace(replace(tr.[consistPartNames_fr-FR]
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/') as [consistPartNames_fr-FR],

replace(replace(replace(replace(replace(replace(replace(replace(replace(tr.[consistPartNames_de-DE]
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/') as [consistPartNames_de-DE],

replace(replace(replace(replace(replace(replace(replace(replace(replace(tr.[consistPartNames_it-IT]
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/') as [consistPartNames_it-IT],

replace(replace(replace(replace(replace(replace(replace(replace(replace(tr.[consistPartNames_pt-BR]
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/') as [consistPartNames_pt-BR],

replace(replace(replace(replace(replace(replace(replace(replace(replace(tr.[consistPartNames_es-ES]
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/') as [consistPartNames_es-ES],

replace(replace(replace(replace(replace(replace(replace(replace(replace(tr.[consistPartNames_ru-RU]
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/') as [consistPartNames_ru-RU],

replace(replace(replace(replace(replace(replace(replace(replace(replace(tr.[consistPartNames_ja-JP]
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/') as [consistPartNames_ja-JP]

from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] b With(NolocK)--3M
--inner join	[SISWEB_OWNER].LNKPARTSIESNP a With(Nolock) --10M
--	on a.IESYSTEMCONTROLNUMBER=b.IESYSTEMCONTROLNUMBER and a.MEDIANUMBER=b.MEDIANUMBER
inner join [SISWEB_OWNER].[MASMEDIA] e with(Nolock)
	on e.MEDIANUMBER=b.MEDIANUMBER and e.[MEDIASOURCE] ='C'  --Conversion
inner join #InsertRecords c --Add filter to limit to changed records
	on c.IESYSTEMCONTROLNUMBER=b.IESYSTEMCONTROLNUMBER
inner join [SISWEB_OWNER_SHADOW].LNKCONSISTLIST d With(Nolock) --56M
	on d.IESYSTEMCONTROLNUMBER  = b.BASEENGCONTROLNO-- Conversion records relate to LNKCONSISTLIST on baseengcontrolno instead of iesystemcontrolnumber
--where a.SNPType = 'P'

--Get translated values
left outer join
(
Select 
[PARTNAME], 
[8] [consistPartNames_id-ID], 
[C] [consistPartNames_zh-CN], 
[F] [consistPartNames_fr-FR], 
[G] [consistPartNames_de-DE], 
[L] [consistPartNames_it-IT], 
[P] [consistPartNames_pt-BR], 
[S] [consistPartNames_es-ES], 
[R] [consistPartNames_ru-RU], 
[J] [consistPartNames_ja-JP]
From 
(
SELECT c.[PARTNAME]
      ,[LANGUAGEINDICATOR]
      ,[TRANSLATEDPARTNAME]
FROM [SISWEB_OWNER_SHADOW].[LNKCONSISTLIST] c
Inner Join [SISWEB_OWNER].[LNKTRANSLATEDSPN] t on c.PARTNAME = t.PARTNAME
) p
Pivot
(
Max([TRANSLATEDPARTNAME]) 
For [LANGUAGEINDICATOR] in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
) pvt
) tr on tr.PARTNAME = d.PARTNAME
)
Select * 
into #RecordsToString_C
From CTE_CONSISTPART;

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Loaded to Temp #RecordsToString_C',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Drop temp
Drop Table #InsertRecords

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID] 
ON #RecordsToString_C ([id] ASC)
INCLUDE ([IESYSTEMCONTROLNUMBER],[CONSISTPART],[INSERTDATE])
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

--Records to String
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


--Select  
--    a.IESYSTEMCONTROLNUMBER,
--	a.ID,
--	coalesce(f.CONSISTPARTString,'') As CONSISTPART,
--	min(a.INSERTDATE) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
--into  #RecordsToStringResult_C
--from  #RecordsToString_C a
--cross apply 
--(
--	SELECT  '[' + stuff
--	(
--		(SELECT '","' + cast(CONSISTPART as varchar(MAX))        
--		FROM #RecordsToString_C as b 
--		where a.ID=b.ID 
--		order by b.ID
--		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')   
--	,1,2,'') + '"'+']'     
--) f (CONSISTPARTString)
--Group by 
--a.IESYSTEMCONTROLNUMBER,
--a.ID,
--f.CONSISTPARTString

--1:05 with just English
--5:01 with all languages
--Change from xmlpath to string_agg method
--Drop table #RecordsToStringResult_C
SELECT 
a.[id] ID,
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
min(a.[INSERTDATE]) INSERTDATE --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
Into #RecordsToStringResult_C
FROM #RecordsToString_C a
GROUP BY
a.IESYSTEMCONTROLNUMBER,
a.id



SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult_C Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Temp RecordsToStringResult_C',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Drop temp table
Drop Table #RecordsToString_C

--Add pkey to result
Alter Table #RecordsToStringResult_C Alter Column ID varchar(50) Not NULL
ALTER TABLE #RecordsToStringResult_C ADD PRIMARY KEY CLUSTERED (ID) 
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult_C'

--Insert result into target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


Insert into [SISSEARCH].[CONSISTPARTS_2] 
([IESYSTEMCONTROLNUMBER]
,[ID]
,[CONSISTPART]
,[INSERTDATE]
,[ConsistPartNames_es-ES]
,[ConsistPartNames_zh-CN]
,[ConsistPartNames_fr-FR]
,[ConsistPartNames_it-IT]
,[ConsistPartNames_de-DE]
,[ConsistPartNames_pt-BR]
,[ConsistPartNames_id-ID]
,[ConsistPartNames_ja-JP]
,[ConsistPartNames_ru-RU])
Select 
 [IESYSTEMCONTROLNUMBER]
,[ID]
,[CONSISTPART]
,[INSERTDATE]
,[consistPartNames_es-ES]
,[consistPartNames_zh-CN]
,[consistPartNames_fr-FR]
,[consistPartNames_it-IT]
,[consistPartNames_de-DE]
,[consistPartNames_pt-BR]
,[consistPartNames_id-ID]
,[consistPartNames_ja-JP]
,[consistPartNames_ru-RU]
from #RecordsToStringResult_C

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Insert into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Insert into Target [SISSEARCH].[CONSISTPARTS_2]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LOGID = @SPStartLogID,@DATAVALUE = @RowCount

DELETE FROM SISSEARCH.LOG WHERE DATEDIFF(DD, LogDateTime, GetDate())>30 and NameofSproc= @ProcName

END TRY

BEGIN CATCH 
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT= ERROR_LINE()

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC SISSEARCH.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error
END CATCH


End


/*
CREATE NONCLUSTERED INDEX NIX_LNKMEDIAIEPART_IESYSTEMCONTROLNUMBER 
ON [SISWEB_OWNER].[MASMEDIA] ([MEDIANUMBER] ASC)
INCLUDE ([MEDIASOURCE])

CREATE NONCLUSTERED INDEX NIX_LNKMEDIAIEPART_IESYSTEMCONTROLNUMBER 
    ON [SISWEB_OWNER].[LNKMEDIAIEPART](IESYSTEMCONTROLNUMBER)

CREATE NONCLUSTERED INDEX NIX_LNKPARTSIESNP_IESYSTEMCONTROLNUMBER 
    ON [SISWEB_OWNER].[LNKPARTSIESNP](IESYSTEMCONTROLNUMBER)

CREATE NONCLUSTERED INDEX NIX_LNKCONSISTLIST_IESYSTEMCONTROLNUMBER 
    ON [SISWEB_OWNER].[LNKCONSISTLIST](IESYSTEMCONTROLNUMBER)
*/
