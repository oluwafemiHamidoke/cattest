CREATE Procedure [sissearch2].[Basic_Parts_Load] As
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

SET @SPStartTime = GETDATE()
SET @ProcName = OBJECT_SCHEMA_NAME(@@PROCID)+ '.' + OBJECT_NAME(@@PROCID)

--Identify Deleted Records From Source

EXEC @SPStartLogID = sissearch2.WriteLog @TIME = @SPStartTime, @NAMEOFSPROC = @ProcName;
SET @StepStartTime = GETDATE() EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#DeletedRecords') is not null
  Begin
    Drop table #DeletedRecords
  End

Select IESystemControlNumber
into #DeletedRecords
From [sissearch2].[Basic_Parts]
Except
Select MS.IESystemControlNumber
FROM [sis_shadow].[MediaSequence] MS
inner join [sis].[IEPart] IP on IP.IEPart_ID = MS.IEPart_ID

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  @RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Records Detected', @DATAVALUE = @RowCount, @LOGID = @StepLogID

-- Delete Idenified Deleted Records in Target

SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete From [sissearch2].[Basic_Parts]
Where  IESystemControlNumber  IN (Select IESystemControlNumber From #DeletedRecords)

SET @RowCount = @@RowCount
--print  cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' + @RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Records from Target [sissearch2].[Basic_Parts]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Get Maximum insert date from Target
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select @LastInsertDate = coalesce(Max(InsertDate), '1900-01-01') From [sissearch2].[Basic_Parts]
--print  cast(getdate() as varchar(50)) + ' - Latest Insert Date in Target: ' + cast(@LastInsertDate as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
Declare @Logmessage as varchar(50) = 'Latest Insert Date in Target '+cast (@LastInsertDate as varchar(25))
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = @Logmessage , @LOGID = @StepLogID

--Identify Inserted records from Source
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

--Query for InsertRecord
If Object_ID('Tempdb..#InsertRecords') is not null
Begin
    Drop table #InsertRecords
End

Select MS.IESystemControlNumber,
	CASE WHEN MS.LastModified_Date > IP.LastModified_Date THEN MS.LastModified_Date
	ELSE IP.LastModified_Date END AS LastModified_Date
into #InsertRecords
From [sis_shadow].[MediaSequence] MS
inner join sis.IEPart IP on IP.IEPart_ID = MS.IEPart_ID
Where MS.LastModified_Date > @LastInsertDate OR IP.LastModified_Date > @LastInsertDate

SET @RowCount= @@RowCount
--print  cast(getdate() as varchar(50)) + ' - Inserted Records Detected Count: ' + @RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Detected #InsertRecords',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_IESystemControlNumber ON #InsertRecords(IESystemControlNumber)
INCLUDE(LastModified_Date)
--Delete Inserted records from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete From [sissearch2].[Basic_Parts]
Where  IESystemControlNumber  IN (Select IESystemControlNumber From #InsertRecords)

SET @RowCount= @@RowCount
--print  cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + @RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Inserted Records from Target [sissearch2].[Basic_Parts]', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into [sissearch2].[Basic_Parts] (
    [ID]
    ,[IESystemControlNumber]
    ,[InformationType]
    ,[MediaNumber]
    ,[IEUpdateDate]
    ,[IEPart]
    ,[IEPartNumber]
    ,[PartsManualMediaNumber]
	,[IECaption]
    ,[InsertDate]
	,[isMedia]
	,[PubDate]
	,[ControlNumber]
	,[IEPartName_id-ID]
	,[IEPartName_zh-CN]
	,[IEPartName_fr-FR]
	,[IEPartName_de-DE]
	,[IEPartName_it-IT]
	,[IEPartName_pt-BR]
	,[IEPartName_es-ES]
	,[IEPartName_ru-RU]
	,[IEPartName_ja-JP]
	,[MediaOrigin]
	,[OrgCode])(
  Select
      [ID],
      [IESystemControlNumber],
      [InformationType],
      [MediaNumber],
      [IEUpdateDate],
      [IEPart],
      [IEPartNumber],
      [PartsManualMediaNumber],
      [IECaption],
      [InsertDate],
      0,
      [PubDate],
      [ControlNumber],
      [IEPartName_id-ID],
      [IEPartName_zh-CN],
      [IEPartName_fr-FR],
      [IEPartName_de-DE],
      [IEPartName_it-IT],
      [IEPartName_pt-BR],
      [IEPartName_es-ES],
      [IEPartName_ru-RU],
      [IEPartName_ja-JP],
      [mediaOrigin],
      [orgCode]
    From
      (
        SELECT
        	Distinct MS.IESystemControlNumber As ID,
        	MS.IESystemControlNumber,
        	'[''5'']' As InformationType,
        	coalesce(
                  '[' + '"' + replace(
                    --escape /
                    replace(
                      --escape "
                      replace(
                        --replace carriage return (ascii 13)
                        replace(
                          --replace form feed (ascii 12)
                          replace(
                            --replace vertical tab (ascii 11)
                            replace(
                              --replace line feed (ascii 10)
                              replace(
                                --replace horizontal tab (ascii 09)
                                replace(
                                  --replace backspace (ascii 08)
                                  replace(
                                    --escape \
                                    	M.Media_Number,
                                    '\', ' \\ ')
                          ,char(8), ' ')
                        ,char(9), ' ')
                      ,char(10), ' ')
                    ,char(11), ' ')
                  ,char(12), ' ')
                ,char(13), ' ')
                ,' "', '\"')
              ,'/', '\/')+'"'+' ] ','') as MediaNumber,
  		isnull(IP.Update_Date , '1900-01-01') as IEUpdateDate,
        	replace( --escape /
              replace( --escape "
                replace( --replace carriage return (ascii 13)
                  replace( --replace form feed (ascii 12)
                    replace( --replace vertical tab (ascii 11)
                      replace( --replace line feed (ascii 10)
                        replace( --replace horizontal tab (ascii 09)
                          replace( --replace backspace (ascii 08)
                            replace( --escape \
							  iif(isnull(P.Part_Number,'NULL') != 'NULL', P.Part_Number, '') + ':'
							  + iif(isnull(P.Part_Number,'NULL') != 'NULL', isnull(PN.PartName,''), IP.PartName_for_NULL_PartNum)
							  + iif(isnull(MST.Modifier, '') != '', ' '+ MST.Modifier, '')
                            ,' \ ', ' \\ ')
                          ,char(8), ' ')
                        ,char(9), ' ')
                      ,char(10), ' ')
                    ,char(11), ' ')
                  ,char(12), ' ')
                ,char(13), ' ')
                ,' "', '\"')
              ,'/', '\/') as IEPart,
        	  iif(isnull(P.Part_Number,'NULL') != 'NULL', P.Part_Number, NULL) as IEPartNumber,
        	  coalesce('['+'"'+replace( --escape /
              replace( --escape "
                replace( --replace carriage return (ascii 13)
                  replace( --replace form feed (ascii 12)
                    replace( --replace vertical tab (ascii 11)
                      replace( --replace line feed (ascii 10)
                        replace( --replace horizontal tab (ascii 09)
                          replace( --replace backspace (ascii 08)
                            replace( --escape \
        						M.Media_Number
                            ,' \ ', ' \\ ')
                          ,char(8), ' ')
                        ,char(9), ' ')
                      ,char(10), ' ')
                    ,char(11), ' ')
                  ,char(12), ' ')
                ,char(13), ' ')
                ,' "', '\"')
              ,'/', '\/')+'"'+' ] ','') as PartsManualMediaNumber,
  		  replace(
  			 replace(
  				 replace(
  					 replace(
  						 replace(
  							 replace(
  								 replace(
  									 replace(
  										 replace(
  											 replace(
  												 replace(
  													 replace(
  														 replace(
  															 replace(
  																 MST.Caption
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
  			,'@@@@@',' ') as IECaption,
        	  IR.LastModified_Date  as InsertDate,
        	  0 as isMedia,
        	  IP.Publish_Date as PubDate,
        	  case when len(trim(IP.IE_Control_Number)) = 0
        				then null else
        	  coalesce(
                  '[' + '"' + replace(
                    --escape /
                    replace(
                      --escape "
                      replace(
                        --replace carriage return (ascii 13)
                        replace(
                          --replace form feed (ascii 12)
                          replace(
                            --replace vertical tab (ascii 11)
                            replace(
                              --replace line feed (ascii 10)
                              replace(
                                --replace horizontal tab (ascii 09)
                                replace(
                                  --replace backspace (ascii 08)
                                  replace(
                                    --escape \
                                    	IP.IE_Control_Number,
                                    '\', ' \\ ')
                          ,char(8), ' ')
                        ,char(9), ' ')
                      ,char(10), ' ')
                    ,char(11), ' ')
                  ,char(12), ' ')
                ,char(13), ' ')
                ,' "', '\"')
              ,'/', '\/')+'"'+' ] ','') end as ControlNumber,

  	    replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(PN.[IEPartName_id-ID],'')
        ,' \ ', ' \\ '),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),' "', '\"'),'/', '\/') as [IEPartName_id-ID],

        replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(PN.[IEPartName_zh-CN],'')
        ,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'" ', ' \ "'),'/', '\/') as [IEPartName_zh-CN],

        replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(PN.[IEPartName_fr-FR],'')
        ,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'" ', ' \ "'),'/', '\/') as [IEPartName_fr-FR],

        replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(PN.[IEPartName_de-DE],'')
        ,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'" ', ' \ "'),'/', '\/') as [IEPartName_de-DE],

        replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(PN.[IEPartName_it-IT],'')
        ,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'" ', ' \ "'),'/', '\/') as [IEPartName_it-IT],

        replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(PN.[IEPartName_pt-BR],'')
        ,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'" ', ' \ "'),'/', '\/') as [IEPartName_pt-BR],

        replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(PN.[IEPartName_es-ES],'')
        ,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'" ', ' \ "'),'/', '\/') as [IEPartName_es-ES],

        replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(PN.[IEPartName_ru-RU],'')
        ,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'" ', ' \ "'),'/', '\/') as [IEPartName_ru-RU],

        replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(PN.[IEPartName_ja-JP],'')
        ,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'" ', ' \ "'),'/', '\/') as [IEPartName_ja-JP],

        MT.Media_Origin as MediaOrigin,
        P.Org_Code as OrgCode,
        row_number() over (Partition by cast(MS.IESystemControlNumber as VARCHAR) order by isnull(IP.Update_Date, '1900-01-01') desc /*, b.LASTMODIFIEDDATE desc*/) RowRank

        FROM [sis_shadow].[MediaSequence] MS
        inner join #InsertRecords IR on IR.IESystemControlNumber = MS.IESystemControlNumber
        inner join [sis].[IEPart] IP on IP.IEPart_ID = MS.IEPart_ID
        inner join [sis].[MediaSection] MSec on MSec.MediaSection_ID = MS.MediaSection_ID
        inner join [sis].[Media] M on M.Media_ID = MSec.Media_ID
        inner join [sis].[Media_Translation] MT on MT.Media_ID = M.Media_ID
        inner join [sis].[IEPart_Effectivity] IPE on IPE.IEPart_ID = MS.IEPart_ID and IPE.Media_ID = M.Media_ID
        left outer join [sis].[Part] P on P.PART_ID = IP.PART_ID and P.Org_Code is not null
        left outer join [sis].[MediaSequence_Translation] MST on MST.MediaSequence_ID = MS.MediaSequence_ID
        left outer join (
        Select
        Part_ID,
        [E] [PartName],
        [8] [IEPartName_id-ID],
        [C] [IEPartName_zh-CN],
        [F] [IEPartName_fr-FR],
        [G] [IEPartName_de-DE],
        [L] [IEPartName_it-IT],
        [P] [IEPartName_pt-BR],
        [S] [IEPartName_es-ES],
        [R] [IEPartName_ru-RU],
        [J] [IEPartName_ja-JP]
        From
        (
        Select Part_ID
              ,L.Legacy_Language_Indicator as LANGUAGEINDICATOR
              ,Part_Name
        From [sis].[Part_Translation] PT
        inner join [sis].[Language] L ON L.Language_ID = PT.Language_ID
        ) p
        Pivot
        (
        Max(Part_Name)
        For [LANGUAGEINDICATOR] in ([E], [8], [C], [F], [G], [L], [P], [S], [R], [J])
        ) pvt
        ) PN on PN.Part_ID = P.Part_ID
        where M.Source in ('A' , 'C')
          and IPE.SerialNumberPrefix_Type = 'P'
    ) x
  where RowRank = 1
)

SET @RowCount = @@RowCount
--print  cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + @RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Target [sissearch2].[Basic_Parts]',@DATAVALUE = @RowCount, @LOGID = @StepLogID

--Array of GraphicControlNumber
--All IDs have been inserted. Next we need to get an array of GraphicControlNumbers and update the GraphicControlNumber field.

If Object_ID('Tempdb..#RecordsToString_GCN') is not null
  Begin
     Drop table #RecordsToString_GCN
  End;

Select MS.IESystemControlNumber As ID,
    I.Graphic_Control_Number As GraphicControlNumber
into #RecordsToString_GCN
From [sis_shadow].[MediaSequence] MS
inner join #InsertRecords IR on IR.IESystemControlNumber = MS.IESystemControlNumber
inner join sis.IEPart_Illustration_Relation IIR ON IIR.IEPart_ID = MS.IEPart_ID
inner join sis.Illustration I ON I.Illustration_ID = IIR.Illustration_ID
Group By MS.IESystemControlNumber, I.Graphic_Control_Number

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count (GraphicControlNumber): ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Loaded to Temp #RecordsToString_GCN (GraphicControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID]
ON #RecordsToString_GCN ([ID] ASC)
INCLUDE (GraphicControlNumber)
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp (GraphicControlNumber)'

--Records to String
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

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
                WHERE    a.Id = b.Id
                ORDER BY b.Id, cast(GraphicControlNumber as varchar(MAX))
				FOR xml path(''), type).value('.', 'varchar(max)') ,1,2,''
			) + '"'+']'
	) f (GraphicControlNumberString)
Group By [ID], f.GraphicControlNumberString

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp RecordsToStringResult_GCN Count (GraphicControlNumber): ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Temp RecordsToStringResult_GCN (GraphicControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

--Add pkey to result
Alter Table #RecordsToStringResult_GCN Alter Column ID varchar(50) Not NULL
ALTER TABLE #RecordsToStringResult_GCN ADD PRIMARY KEY CLUSTERED (ID)
--Print cast(getdate() as varchar(50)) + ' - Add pkey to RecordsToStringResult_GCN (GraphicControlNumber)'

--Insert result into target
SET @StepStartTime = GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

--All IDs have been inserted already.  Update with ControlNumber Array.
Update BP
Set BP.GraphicControlNumber = nullif(nullif(R.GraphicControlNumber, ''), '[""]')
From [sissearch2].[Basic_Parts] BP
Inner join #RecordsToStringResult_GCN R on BP.ID = R.ID

SET @RowCount = @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Updated Target Count (GraphicControlNumber): ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1, @LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Updated Target [sissearch2].[Basic_Parts] (GraphicControlNumber)', @DATAVALUE = @RowCount, @LOGID = @StepLogID

/*
End All
*/

--Drop temp table
Drop Table #DeletedRecords
Drop Table #InsertRecords
Drop Table #RecordsToString_GCN
Drop Table #RecordsToStringResult_GCN

SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LOGID = @SPStartLogID, @DATAVALUE = @RowCount

DELETE FROM sissearch2.LOG WHERE DATEDIFF(DD, LogDateTime, GetDate())>30 and NameofSproc= @ProcName

END TRY

BEGIN CATCH
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT= ERROR_LINE()

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC sissearch2.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error

END CATCH

End