CREATE  Procedure [SISSEARCH].[BASICPARTS_2_LOAD] 
As
/*---------------
Date: 10-04-2017
Object Description:  Loading changed data into SISSEARCH.BASICPARTS from base tables
Exec [SISSEARCH].[BASICPARTS_2_LOAD]
Truncate table [SISSEARCH].[BASICPARTS_2]
Select top 100 * From SISSEARCH.LOG Order By LogID desc
---------------*/


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

--Identify Deleted Records From Source

EXEC @SPStartLogID = SISSEARCH.WriteLog @TIME = @SPStartTime, @NAMEOFSPROC = @ProcName;

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#DeletedRecords') is not null
  Begin 
     Drop table #DeletedRecords
  End
Select Iesystemcontrolnumber 
into #DeletedRecords
from  [SISSEARCH].[BASICPARTS_2]
group by Iesystemcontrolnumber
Except 
Select IESYSTEMCONTROLNUMBER
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] 

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  @RowCount 

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Records Detected',@DATAVALUE = @RowCount, @LOGID = @StepLogID

-- Delete Idenified Deleted Records in Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete from 
[SISSEARCH].[BASICPARTS_2] 
where  Iesystemcontrolnumber  in (Select Iesystemcontrolnumber From #DeletedRecords)

SET @RowCount= @@RowCount
--print  cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' + @RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Records from Target [SISSEARCH].[BASICPARTS_2]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	
Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [SISSEARCH].[BASICPARTS_2]
--print  cast(getdate() as varchar(50)) + ' - Latest Insert Date in Target: ' + cast(@LastInsertDate as varchar(50))

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
--print  cast(getdate() as varchar(50)) + ' - Inserted Records Detected Count: ' + @RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Detected #InsertRecords',@DATAVALUE = @RowCount, @LOGID = @StepLogID
	
--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_iesystemcontrolnumber 
    ON #InsertRecords(IESYSTEMCONTROLNUMBER)

--Delete Inserted records from Target 	
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete from [SISSEARCH].[BASICPARTS_2]
where Iesystemcontrolnumber in
 (Select IESYSTEMCONTROLNUMBER from  #InsertRecords)
 
SET @RowCount= @@RowCount   
--print  cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + @RowCount 

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Inserted Records from Target [SISSEARCH].[BASICPARTS_2]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

insert into [SISSEARCH].[BASICPARTS_2]
       (
       [ID]
      ,[Iesystemcontrolnumber]
      --,[BeginRange]
      --,[EndRange]
      ,[InformationType]
      ,[Medianumber]
      ,[IEupdatedate]
      ,[IEpart]
      ,[IEpartNumber]
      ,[PARTSMANUALMEDIANUMBER]
	  ,[IECAPTION]
      ,[InsertDate]
	  ,[isMedia]
	  ,[PubDate]
	  ,ControlNumber
	  ,[IEPartName_id-ID]
	  ,[IEPartName_zh-CN] 
	  ,[IEPartName_fr-FR] 
	  ,[IEPartName_de-DE] 
	  ,[IEPartName_it-IT] 
	  ,[IEPartName_pt-BR] 
	  ,[IEPartName_es-ES] 
	  ,[IEPartName_ru-RU] 
	  ,[IEPartName_ja-JP]
	  ,[mediaOrigin]
	  ,[orgCode]
	  )

--lnkPartsiesnp distinct 9,248,860 (2 MIN)
--lnkPartsiesnp + lnkmediaiepart Distinct 9,190,684 (10 MIN)
--lnkPartsiesnp + lnkmediaiepart + lnkiedate Distinct 9,190,562 (9 MIN)
--lnkPartsiesnp + lnkmediaiepart + lnkiedate + MASMEDIA Distinct 9,190,562 (9 MIN)
--Total 14 Min
(
Select  
	   [ID]
      ,[Iesystemcontrolnumber]
      --,[BeginRange]
      --,[EndRange]
      ,[InformationType]
      ,[medianumber]
      ,ieupdatedate
      ,iepart
      ,IEpartNumber
      ,[PARTSMANUALMEDIANUMBER]
	  ,[IECAPTION]
      ,[InsertDate]
	  ,0
	  ,[PubDate]
	  ,ControlNumber
	  ,[iePartName_id-ID]
	  ,[iePartName_zh-CN] 
	  ,[iePartName_fr-FR] 
	  ,[iePartName_de-DE] 
	  ,[iePartName_it-IT] 
	  ,[iePartName_pt-BR] 
	  ,[iePartName_es-ES] 
	  ,[iePartName_ru-RU] 
	  ,[iePartName_ja-JP]
	  ,[mediaOrigin]
	  ,[orgCode]
From 
	(
	select distinct 
		cast(a.IESYSTEMCONTROLNUMBER as VARCHAR) As ID,
		a.IESYSTEMCONTROLNUMBER as Iesystemcontrolnumber, 
		--a.beginningrange as BeginRange, 
		--a.endrange As  EndRange, 
		'[''5'']' As InformationType  , --InformationType not in source. pbf 20180313 add brackets and quote.
		coalesce('['+'"'+replace( --escape /
			replace( --escape "
				replace( --replace carriage return (ascii 13)
					replace( --replace form feed (ascii 12) 
						replace( --replace vertical tab (ascii 11)
							replace( --replace line feed (ascii 10)
								replace( --replace horizontal tab (ascii 09)
									replace( --replace backspace (ascii 08)
										replace( --escape \
											b.medianumber
										,'\', '\\')
									,char(8), ' ')
								,char(9), ' ')
							,char(10), ' ')
						,char(11), ' ')
					,char(12), ' ')
				,char(13), ' ')
				,'"', '\"')
			,'/', '\/')+'"'+']','') as  medianumber,
		isnull(d.dateupdated, '1900-01-01') as ieupdatedate, 
			replace( --escape "
				replace( --replace carriage return (ascii 13)
					replace( --replace form feed (ascii 12) 
						replace( --replace vertical tab (ascii 11)
							replace( --replace line feed (ascii 10)
								replace( --replace horizontal tab (ascii 09)
									replace( --replace backspace (ascii 08)
										replace( --escape \
											isnull(b.iepartnumber,'')+':'+isnull(b.iepartname,'') +
											iif(isnull(b.iepartmodifier, '') != '', ' '+b.iepartmodifier, '')
										,'\', '\\')
									,char(8), ' ')
								,char(9), ' ')
							,char(10), ' ')
						,char(11), ' ')
					,char(12), ' ')
				,char(13), ' ')
				,'"', '\"')
			as iepart,
    	b.iepartnumber as IEpartNumber,
		coalesce('['+'"'+replace( --escape /
			replace( --escape "
				replace( --replace carriage return (ascii 13)
					replace( --replace form feed (ascii 12) 
						replace( --replace vertical tab (ascii 11)
							replace( --replace line feed (ascii 10)
								replace( --replace horizontal tab (ascii 09)
									replace( --replace backspace (ascii 08)
										replace( --escape \
											b.medianumber
										,'\', '\\')
									,char(8), ' ')
								,char(9), ' ')
							,char(10), ' ')
						,char(11), ' ')
					,char(12), ' ')
				,char(13), ' ')
				,'"', '\"')
			,'/', '\/')+'"'+']','') as  PARTSMANUALMEDIANUMBER	
		,Replace(
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
																,'<I>',' ')
															,'</I>',' ')
														,'<BR>',' ')
													,'<TABLE BORDER=0>' ,' ')
												,'<TR>',' ')
											,'<TD COLSPAN=3 ALIGN=CENTER>',' ')
										,'</TABLE>',' ')
									,'<B>',' ')
								,'</B>',' ')
							,'<TD>',' ')
						,'</TD>',' ')
					,'<TR>',' ')
				,'</TR>',' ')
			,'@@@@@',' ') As IECAPTION
		,b.LASTMODIFIEDDATE InsertDate
		,row_number() over (Partition by cast(a.iesystemcontrolnumber as VARCHAR) order by isnull(d.dateupdated, '1900-01-01') desc, b.LASTMODIFIEDDATE desc) RowRank
		,d.IEPUBDATE as [PubDate]
		,case when len(trim(b.IECONTROLNUMBER)) = 0 then null else	
		coalesce('['+'"'+replace( --escape /
			replace( --escape "
				replace( --replace carriage return (ascii 13)
					replace( --replace form feed (ascii 12) 
						replace( --replace vertical tab (ascii 11)
							replace( --replace line feed (ascii 10)
								replace( --replace horizontal tab (ascii 09)
									replace( --replace backspace (ascii 08)
										replace( --escape \
											b.IECONTROLNUMBER
										,'\', '\\')
									,char(8), ' ')
								,char(9), ' ')
							,char(10), ' ')
						,char(11), ' ')
					,char(12), ' ')
				,char(13), ' ')
				,'"', '\"')
			,'/', '\/')+'"'+']','') 
		end as  ControlNumber,
		
replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[iePartName_id-ID],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/') as [iePartName_id-ID],

replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[iePartName_zh-CN],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/') as [iePartName_zh-CN],

replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[iePartName_fr-FR],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/') as [iePartName_fr-FR],

replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[iePartName_de-DE],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/') as [iePartName_de-DE],

replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[iePartName_it-IT],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/') as [iePartName_it-IT],

replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[iePartName_pt-BR],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/') as [iePartName_pt-BR],

replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[iePartName_es-ES],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/') as [iePartName_es-ES],

replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[iePartName_ru-RU],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/') as [iePartName_ru-RU],

replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[iePartName_ja-JP],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/') as [iePartName_ja-JP],

e.MEDIAORIGIN [mediaOrigin],
b.ORGCODE [orgCode]

	from [SISWEB_OWNER_SHADOW].LNKPARTSIESNP a	--10M
	inner join [SISWEB_OWNER_SHADOW].LNKMEDIAIEPART b  --3M
		on  a.IESYSTEMCONTROLNUMBER = b.IESYSTEMCONTROLNUMBER
	inner join #InsertRecords c --Add filter to limit to changed records
		 on c.IESYSTEMCONTROLNUMBER=b.IESYSTEMCONTROLNUMBER 
	left outer join [SISWEB_OWNER].LNKIEDATE d --4M
		on a.IESYSTEMCONTROLNUMBER = d.IESYSTEMCONTROLNUMBER and d.LANGUAGEINDICATOR='E'
	inner join [SISWEB_OWNER].[MASMEDIA] e   --90K
		 on e.MEDIANUMBER=b.MEDIANUMBER
--Get translated values
left outer join
(
Select 
[PARTNAME], 
[8] [iePartName_id-ID], 
[C] [iePartName_zh-CN], 
[F] [iePartName_fr-FR], 
[G] [iePartName_de-DE], 
[L] [iePartName_it-IT], 
[P] [iePartName_pt-BR], 
[S] [iePartName_es-ES], 
[R] [iePartName_ru-RU], 
[J] [iePartName_ja-JP]
From 
(
SELECT [PARTNAME]
      ,[LANGUAGEINDICATOR]
      ,[TRANSLATEDPARTNAME]
FROM [SISWEB_OWNER].[LNKTRANSLATEDSPN]
) p
Pivot
(
Max([TRANSLATEDPARTNAME]) 
For [LANGUAGEINDICATOR] in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
) pvt
) tr on tr.PARTNAME = b.IEPARTNAME

		where  1=1
	and e.MEDIASOURCE in ('A' , 'C')
	and a.SNPTYPE = 'P'
	) x
where RowRank = 1
)

SET @RowCount= @@RowCount
--print  cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + @RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Target [SISSEARCH].[BASICPARTS_2]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

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
  inner join [SISWEB_OWNER].[MASMEDIA] c on a.MEDIANUMBER= c.MEDIANUMBER and c.MEDIAORIGIN<>'EM'  -- EMP parts are processed separately
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
Update BP
Set BP.GraphicControlNumber = nullif(nullif(R.GraphicControlNumber, ''), '[""]')
From [SISSEARCH].[BASICPARTS_2] BP
Inner join #RecordsToStringResult_GCN R on BP.ID = R.ID

SET @RowCount = @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated Target [SISSEARCH].[EXPANDEDMININGPRODUCTPARTS] (GraphicControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--End graphic control number logic

SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LOGID = @SPStartLogID, @DATAVALUE = @RowCount


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


