CREATE  Procedure [sissearch2].[Basic_ServiceMedia_Load] 
As
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

EXEC @SPStartLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


If Object_ID('Tempdb..#DeletedRecords') is not null
  Begin 
     Drop table #DeletedRecords
  End
Select
	[Media_Number]
	into #DeletedRecords
	from  [sissearch2].[Basic_ServiceMedia]
Except 
Select
	a.[Media_Number]
	from [sis].[Media] a
	inner join
	(select Media_ID from [sis].[Media_Effectivity] 
	 union
	 select Media_ID from [sis].[Media_ProductFamily_Effectivity] 
	) b
	on  a.Media_ID=b.Media_ID
	inner join [sis].[Media_Translation] c on  c.Media_ID=a.Media_ID and c.Language_ID=38
	inner join [sis].[Media_InfoType_Relation] d on d.Media_ID=a.Media_ID and d.InfoType_ID not in
	(SELECT [InfoTypeID] FROM [sissearch2].[Ref_ExcludeInfoType] where [Search2_Status] = 1 and [Selective_Exclude] = 0) 
	left join [sissearch2].[Ref_Selective_ExcludeInfoType] E
	on E.InfoTypeID  = d.InfoType_ID and E.[Excluded_Values] = c.Media_Origin
	where E.InfoTypeID IS NULL


SET @RowCount= @@RowCount


SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Records Detected',@DATAVALUE = @RowCount, @LogID = @StepLogID

-- Delete Idenified Deleted Records in Target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


Delete [sissearch2].[Basic_ServiceMedia] 
From [sissearch2].[Basic_ServiceMedia] a
inner join #DeletedRecords d on a.[Media_Number] = d.[Media_Number]

SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Records from Target [sissearch2].[Basic_ServiceMedia]',@DATAVALUE = @RowCount, @LogID = @StepLogID

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;
	
Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [sissearch2].[Basic_ServiceMedia]

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
Declare @Logmessage as varchar(50) = 'Latest Insert Date in Target '+cast (@LastInsertDate as varchar(25))
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = @Logmessage , @LogID = @StepLogID


--Identify Inserted records from Source
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

 If Object_ID('Tempdb..#InsertRecords') is not null
Begin 
 Drop table #InsertRecords
End
	Select
		a.[Media_Number]
	into #InsertRecords
	from [sis].[Media] a
	inner join 
	(select Media_ID from [sis].[Media_Effectivity] 
	 union
	 select Media_ID from [sis].[Media_ProductFamily_Effectivity] 
	) b on  a.Media_ID=b.Media_ID
	inner join [sis].[Media_Translation] c on  c.Media_ID=a.Media_ID and c.Language_ID=38
	inner join [sis].[Media_InfoType_Relation] d on d.Media_ID=a.Media_ID and d.InfoType_ID not in
	(SELECT [InfoTypeID] FROM [sissearch2].[Ref_ExcludeInfoType] where [Search2_Status] = 1 and [Selective_Exclude] = 0) 
	left join [sissearch2].[Ref_Selective_ExcludeInfoType] E
	on E.InfoTypeID  = d.InfoType_ID and E.[Excluded_Values] = c.Media_Origin
	where E.InfoTypeID IS NULL
	AND c.LastModified_Date  > @LastInsertDate
	group by a.[Media_Number]
	order by  a.[Media_Number]

SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted Records Detected #InsertRecords',@DATAVALUE = @RowCount, @LogID = @StepLogID

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_iesystemcontrolnumber 
    ON #InsertRecords([Media_Number])

--Delete Inserted records from Target 	

Delete [sissearch2].Basic_ServiceMedia 
From [sissearch2].Basic_ServiceMedia a
inner join #InsertRecords d on a.[Media_Number] = d.[Media_Number]


SET @RowCount= @@RowCount   

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Deleted Inserted Records from Target [sissearch2].[BasicServiceMedia]',@DATAVALUE = @RowCount, @LogID = @StepLogID

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

insert into [sissearch2].[Basic_ServiceMedia]
       (
       [ID]
	  ,[BaseEngMediaNumber]
      ,[Media_Number]
      ,[MediaTitle_en-US]
	  ,[MediaTitle_in-ID]
	  ,[MediaTitle_zh-CN]
	  ,[MediaTitle_fr-FR]
	  ,[MediaTitle_de-DE]
	  ,[MediaTitle_it-IT]
	  ,[MediaTitle_pt-BR]
      ,[MediaTitle_es-ES]
	  ,[MediaTitle_ru-RU]
	  ,[MediaTitle_ja-JP]
      ,[InsertDate]
	  ,[isMedia]
	  ,[UpdatedDate]
	  ,[PubDate]
	  ,[PIPPSPNumber]

	  ,[MediaNumber_id-ID]
	  ,[MediaNumber_zh-CN]
	  ,[MediaNumber_fr-FR]
	  ,[MediaNumber_de-DE]
	  ,[MediaNumber_it-IT]
	  ,[MediaNumber_pt-BR]
      ,[MediaNumber_es-ES]
	  ,[MediaNumber_ru-RU]
	  ,[MediaNumber_ja-JP]

	  ,[PubDate_id-ID]
	  ,[PubDate_zh-CN]
	  ,[PubDate_fr-FR]
	  ,[PubDate_de-DE]
	  ,[PubDate_it-IT]
	  ,[PubDate_pt-BR]
      ,[PubDate_es-ES]
	  ,[PubDate_ru-RU]
	  ,[PubDate_ja-JP]

	  ,[UpdatedDate_id-ID]
	  ,[UpdatedDate_zh-CN]
	  ,[UpdatedDate_fr-FR]
	  ,[UpdatedDate_de-DE]
	  ,[UpdatedDate_it-IT]
	  ,[UpdatedDate_pt-BR]
      ,[UpdatedDate_es-ES]
	  ,[UpdatedDate_ru-RU]
	  ,[UpdatedDate_ja-JP]
	  ,[Media_Origin]
	  )
	  select a.Media_Number as [ID], 
	a.Media_Number,
		'["' + replace( --escape /
			replace( --escape "
				replace( --replace carriage return (ascii 13)
					replace( --replace form feed (ascii 12) 
						replace( --replace vertical tab (ascii 11)
							replace( --replace line feed (ascii 10)
								replace( --replace horizontal tab (ascii 09)
									replace( --replace backspace (ascii 08)
										replace( --escape \
											max(a.Media_Number) --This is the language specific version of the media number
										,'\', '\\')
									,char(8), ' ')
								,char(9), ' ')
							,char(10), ' ')
						,char(11), ' ')
					,char(12), ' ')
				,char(13), ' ')
				,'"', '\"')
			,'/', '\/')  + '"]' as  MEDIANUMBER,
		replace( --escape /
			replace( --escape "
				replace( --replace carriage return (ascii 13)
					replace( --replace form feed (ascii 12) 
						replace( --replace vertical tab (ascii 11)
							replace( --replace line feed (ascii 10)
								replace( --replace horizontal tab (ascii 09)
									replace( --replace backspace (ascii 08)
										replace( --escape \
											max(c.TITLE) --Limited to English temporarily per Lu
										,'\', '\\')
									,char(8), ' ')
								,char(9), ' ')
							,char(10), ' ')
						,char(11), ' ')
					,char(12), ' ')
				,char(13), ' ')
				,'"', '\"')
			,'/', '\/') as  MEDIATITLE,

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[MediaTitle_id-ID],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaTitle_id-ID],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[MediaTitle_zh-CN],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaTitle_zh-CN],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[MediaTitle_fr-FR],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaTitle_fr-FR],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[MediaTitle_de-DE],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaTitle_de-DE],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[MediaTitle_it-IT],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaTitle_it-IT],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[MediaTitle_pt-BR],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaTitle_pt-BR],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[MediaTitle_es-ES],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaTitle_es-ES],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[MediaTitle_ru-RU],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaTitle_ru-RU],

max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr.[MediaTitle_ja-JP],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) as [MediaTitle_ja-JP],

		min(c.LASTMODIFIED_DATE) [InsertDate], --Must be updated to insert date
		1 as [isMedia], 
		max(c.UPDATED_DATE) as UpdatedDate,
		max(tr3.PUBDATE) as PubDate, 
		max(a.[PIPPS_Number]) PIPPSPNumber,

'["' + 
max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr2.[mediaNumber_id-ID],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) + '"]'as [mediaNumber_id-ID],

'["' + 
max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr2.[mediaNumber_zh-CN],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) + '"]' as [mediaNumber_zh-CN],

'["' + 
max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr2.[mediaNumber_fr-FR],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) + '"]' as [mediaNumber_fr-FR],

'["' + 
max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr2.[mediaNumber_de-DE],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) + '"]' as [mediaNumber_de-DE],

'["' + 
max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr2.[mediaNumber_it-IT],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) + '"]' as [mediaNumber_it-IT],

'["' + 
max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr2.[mediaNumber_pt-BR],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) + '"]' as [mediaNumber_pt-BR],

'["' + 
max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr2.[mediaNumber_es-ES],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) + '"]' as [mediaNumber_es-ES],

'["' + 
max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr2.[mediaNumber_ru-RU],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) + '"]' as [mediaNumber_ru-RU],

'["' + 
max(replace(replace(replace(replace(replace(replace(replace(replace(replace(isnull(tr2.[mediaNumber_ja-JP],'')
,'\', '\\'),char(8), ' '),char(9), ' '),char(10), ' '),char(11), ' '),char(12), ' '),char(13), ' '),'"', '\"'),'/', '\/')) + '"]' as [mediaNumber_ja-JP],

max(tr3.[pubdate_id-ID]) as [pubdate_id-ID],
max(tr3.[pubdate_zh-CN]) as [pubdate_zh-CN],
max(tr3.[pubdate_fr-FR]) as [pubdate_fr-FR],
max(tr3.[pubdate_de-DE]) as [pubdate_de-DE],
max(tr3.[pubdate_it-IT]) as [pubdate_it-IT],
max(tr3.[pubdate_pt-BR]) as [pubdate_pt-BR],
max(tr3.[pubdate_es-ES]) as [pubdate_es-ES],
max(tr3.[pubdate_ru-RU]) as [pubdate_ru-RU],
max(tr3.[pubdate_ja-JP]) as [pubdate_ja-JP],

max(tr4.[updateddate_id-ID]) as [updateddate_id-ID],
max(tr4.[updateddate_zh-CN]) as [updateddate_zh-CN],
max(tr4.[updateddate_fr-FR]) as [updateddate_fr-FR],
max(tr4.[updateddate_de-DE]) as [updateddate_de-DE],
max(tr4.[updateddate_it-IT]) as [updateddate_it-IT],
max(tr4.[updateddate_pt-BR]) as [updateddate_pt-BR],
max(tr4.[updateddate_es-ES]) as [updateddate_es-ES],
max(tr4.[updateddate_ru-RU]) as [updateddate_ru-RU],
max(tr4.[updateddate_ja-JP]) as [updateddate_ja-JP],

max(c.MEDIA_ORIGIN)
from [sis].[Media] a
inner join (
    select Media_ID from [sis].[Media_Effectivity]
	union
	select Media_ID from [sis].[Media_ProductFamily_Effectivity]
	    )b on  a.Media_ID = b.Media_ID
inner join [sis].[Media_Translation] c on c.Media_ID = a.Media_ID and c.Language_ID = 38
inner join [sis].[Media_InfoType_Relation] d on d.Media_ID = a.Media_ID
    and d.InfoType_ID not in ( SELECT [InfoTypeID] FROM [sissearch2].[Ref_ExcludeInfoType] where [Search2_Status] = 1 and [Selective_Exclude] = 0)
left join [sissearch2].[Ref_Selective_ExcludeInfoType] E on E.InfoTypeID  = d.InfoType_ID and E.[Excluded_Values] = c.Media_Origin
inner join #InsertRecords i on i.Media_Number = a.Media_Number --limit to updated records
--Get translated values
left outer join
(
    Select
        Media_Number,
        [8] [MediaTitle_id-ID],
        [C] [MediaTitle_zh-CN],
        [F] [MediaTitle_fr-FR],
        [G] [MediaTitle_de-DE],
        [L] [MediaTitle_it-IT],
        [P] [MediaTitle_pt-BR],
        [S] [MediaTitle_es-ES],
        [R] [MediaTitle_ru-RU],
        [J] [MediaTitle_ja-JP]
    From (
        select M.Media_Number,L.Legacy_Language_Indicator,MT.Title
        from sis.Media M
        JOIN sis.Media_Translation MT ON M.Media_ID = MT.Media_ID
        JOIN [sis].[Language] L ON MT.Language_ID = L.Language_ID
        where L.Legacy_Language_Indicator in ('8','C','F','G','L','P','S','R','J')
    ) p
    Pivot (
       Max(Title)
       For  [Legacy_Language_Indicator] in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
    ) pvt
) tr on tr.Media_Number = a.Media_Number
--Get translated values
left outer join
(
    Select
        Media_Number,
        [8] [mediaNumber_id-ID],
        [C] [mediaNumber_zh-CN],
        [F] [mediaNumber_fr-FR],
        [G] [mediaNumber_de-DE],
        [L] [mediaNumber_it-IT],
        [P] [mediaNumber_pt-BR],
        [S] [mediaNumber_es-ES],
        [R] [mediaNumber_ru-RU],
        [J] [mediaNumber_ja-JP]
    From (
        select M.Media_Number, L.Legacy_Language_Indicator, MT.Media_Number AS MEDIA_NUMBER2
        from sis.Media M
        JOIN sis.Media_Translation MT ON M.Media_ID=MT.Media_ID
        JOIN sis.Language L ON MT.Language_ID=L.Language_ID
        where L.Legacy_Language_Indicator in ('8','C','F','G','L','P','S','R','J')
    ) p
    Pivot (
        Max(MEDIA_NUMBER2)
        For  [Legacy_Language_Indicator] in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
    ) pvt
) tr2 on tr2.Media_Number = a.Media_Number
--Get translated values
left outer join
(
	SELECT 
		pvt.Media_Number, 
		q.E PUBDATE, -- if PUBDATE is incorrect, change it to pvt.E
		IIF(pvt.[8] IS NULL, NULL, q.[8]) [pubdate_id-ID],
		IIF(pvt.[C] IS NULL, NULL, q.[C]) [pubdate_zh-CN],
		IIF(pvt.[F] IS NULL, NULL, q.[F]) [pubdate_fr-FR],
		IIF(pvt.[G] IS NULL, NULL, q.[G]) [pubdate_de-DE],
		IIF(pvt.[L] IS NULL, NULL, q.[L]) [pubdate_it-IT],
		IIF(pvt.[P] IS NULL, NULL, q.[P]) [pubdate_pt-BR],
		IIF(pvt.[S] IS NULL, NULL, q.[S]) [pubdate_es-ES],
		IIF(pvt.[R] IS NULL, NULL, q.[R]) [pubdate_ru-RU],
		IIF(pvt.[J] IS NULL, NULL, q.[J]) [pubdate_ja-JP]
	FROM (
        select M.Media_Number, L.[Legacy_Language_Indicator], MT.Published_Date
        from sis.Media M
        JOIN sis.Media_Translation MT ON M.Media_ID=MT.Media_ID
        JOIN sis.Language L ON MT.Language_ID=L.Language_ID
        where L.Legacy_Language_Indicator in ('E','8','C','F','G','L','P','S','R','J')
	) p
	PIVOT (
	    MAX(Published_Date)
	    FOR [Legacy_Language_Indicator] IN ([E], [8], [C], [F], [G], [L], [P], [S], [R], [J])
	) pvt
	-- !5744 - **outer** join PIVOTTED MASSMEDIA with PIVOTTED LNKMEDIAIE&LNKIEDATE in order to 
	--         obtain a full recordset
	--FULL OUTER JOIN (
	INNER JOIN (
		--
		-- !5744 - 4. Relate IESYSTEMCONTROLNUMBER with MEDIANUMBER->BASEENGLISHMEDIANUMBER
		--
		SELECT m.Media_Number AS BASEENGLISHMEDIANUMBER, 
			MAX(E) AS E, 
			MAX([8]) AS [8],
			MAX(C) AS C,
			MAX(F) AS F,
			MAX(G) AS G, 
			MAX(L) AS L, 
			MAX(P) AS P,
			MAX(S) AS S, 
			MAX(R) AS R,
			MAX(J) AS J
		FROM (
			--
			-- !5744 - 3. When IE has no language, detault to E date 
			--
			SELECT 
				IE_ID,
				IESystemControlNumber,
				E,
				ISNULL([8], E) [8],
				ISNULL([C], E) [C],
				ISNULL([F], E) [F],
				ISNULL([G], E) [G],
				ISNULL([L], E) [L],
				ISNULL([P], E) [P],
				ISNULL([S], E) [S],
				ISNULL([R], E) [R],
				ISNULL([J], E) [J]
			FROM (
				--
				-- !5744 - 1. Get dates for each language in the language set 
				--
                select  i.IE_ID, i.IESystemControlNumber,L.Legacy_Language_Indicator,iet.Date_Updated
                from  [sis].[IE] i
                join  [sis].[IE_Translation] iet on i.IE_ID=iet.IE_ID
                JOIN sis.Language L ON iet.Language_ID=L.Language_ID
                where L.Legacy_Language_Indicator in ('E','8','C','F','G','L','P','S','R','J')
                ) AS src
			--
			-- !5744 - 2. Pivot the table
			--
			PIVOT (
			    MAX([Date_Updated])
			    FOR Legacy_Language_Indicator in ([E], [8], [C], [F], [G], [L], [P], [S], [R], [J])
			) AS s
		) AS p
		INNER JOIN sis.IE_Effectivity iee on iee.IE_ID=p.IE_ID
		JOIN sis.Media m on iee.Media_ID=m.Media_ID
		GROUP BY m.Media_Number
		UNION
        SELECT m.Media_Number AS BASEENGLISHMEDIANUMBER, 
			Published_Date AS E, 
			Published_Date AS [8],
			Published_Date AS C,
			Published_Date AS F,
			Published_Date AS G, 
			Published_Date AS L, 
			Published_Date AS P,
			Published_Date AS S, 
			Published_Date AS R,
			Published_Date AS J
		FROM sis.Media m join sis.Media_Translation mt on m.Media_ID=mt.Media_ID
		LEFT JOIN  sis.IE_Effectivity iee on iee.Media_ID=m.Media_ID
		WHERE iee.Media_ID IS NULL
	) q ON q.BASEENGLISHMEDIANUMBER = pvt.Media_Number
) tr3 on tr3.Media_Number = a.Media_Number

--Get translated values
left outer join
(
    Select
        Media_Number,
        [8] [updateddate_id-ID],
        [C] [updateddate_zh-CN],
        [F] [updateddate_fr-FR],
        [G] [updateddate_de-DE],
        [L] [updateddate_it-IT],
        [P] [updateddate_pt-BR],
        [S] [updateddate_es-ES],
        [R] [updateddate_ru-RU],
        [J] [updateddate_ja-JP]
    From (
        select M.Media_Number,L.Legacy_Language_Indicator,MT.LastModified_Date
        from sis.Media M
        JOIN sis.Media_Translation MT ON M.Media_ID=MT.Media_ID
        JOIN sis.Language L ON MT.Language_ID=L.Language_ID
        where L.Legacy_Language_Indicator in ('8','C','F','G','L','P','S','R','J')
    ) p
    Pivot (
        Max(LastModified_Date)
        For Legacy_Language_Indicator in ([8], [C], [F], [G], [L], [P], [S], [R], [J])
    ) pvt
) tr4 on tr4.Media_Number = a.Media_Number
join sis.Media_Translation mt1 on a.Media_ID=mt1.Media_ID
left join [sissearch2].[Ref_Selective_ExcludeInfoType] E1 on E1.InfoTypeID  = d.InfoType_ID and E1.[Excluded_Values] = c.Media_Origin
where mt1.Language_ID in ( select Language_ID from sis.[Language] where Language_Code='en')
Group by a.Media_Number


SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'Inserted into Target [sissearch2].[Basic_ServiceMedia]',@DATAVALUE = @RowCount, @LogID = @StepLogID

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LogID = @SPStartLogID,@DATAVALUE = @RowCount

DELETE FROM sissearch2.Log WHERE DATEDIFF(DD, LogDateTime, GetDate())>30 and NameofSproc= @ProcName


END TRY

BEGIN CATCH 
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT= ERROR_LINE()

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC sissearch2.WriteLog @LogTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error
END CATCH

End
