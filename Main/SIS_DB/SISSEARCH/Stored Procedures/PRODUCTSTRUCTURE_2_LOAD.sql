




CREATE  Procedure [SISSEARCH].[PRODUCTSTRUCTURE_2_LOAD]
As
/*---------------
Date: 10-10-2017
Object Description:  Loading changed data into SISSEARCH.SNP from base tables
Exec [SISSEARCH].[PRODUCTSTRUCTURE_2_LOAD]
Truncate table [SISSEARCH].[PRODUCTSTRUCTURE_2]
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
from  [SISSEARCH].[PRODUCTSTRUCTURE_2]
Except
Select IESYSTEMCONTROLNUMBER
from [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART]

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
@LOGMESSAGE =  'Deleted Records Detected';

-- Delete Idenified Deleted Records in Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete from
[SISSEARCH].[PRODUCTSTRUCTURE_2]
where  Iesystemcontrolnumber  in (Select Iesystemcontrolnumber From #DeletedRecords)

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Records from Target Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
@LOGMESSAGE =  'Deleted Records from Target [SISSEARCH].[PRODUCTSTRUCTURE_2] ';

--Get Maximum insert date from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select  @LastInsertDate=coalesce(Max(InsertDate),'1900-01-01') From [SISSEARCH].[PRODUCTSTRUCTURE_2]
--Print cast(getdate() as varchar(50)) + ' - Latest Insert Date in Target: ' + cast(@LastInsertDate as varchar(50))

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
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Detected Count: ' +  cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
@LOGMESSAGE =  'Inserted Records Detected into  #InsertRecords';

--NCI on temp
CREATE NONCLUSTERED INDEX NIX_InsertRecords_iesystemcontrolnumber
    ON #InsertRecords(IESYSTEMCONTROLNUMBER)

--Delete Inserted records from Target
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Delete from [SISSEARCH].[PRODUCTSTRUCTURE_2]
where Iesystemcontrolnumber in
 (Select IESYSTEMCONTROLNUMBER from  #InsertRecords)

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Deleted Inserted Records from Target Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
@LOGMESSAGE =  'Deleted Inserted Records from [SISSEARCH].[PRODUCTSTRUCTURE_2]';

--Stage R2S Set
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin
 Drop table #RecordsToString
End

;with CTE_PRODUCTSTRUCTURE_2 as
(
--lnkiepsid Distinct 1698 (3 sec)
--lnkiepsid + LNKMEDIAIEPART  Distnct 142,694 (11 min)
--lnkiepsid + LNKMEDIAIEPART + LNKPARTSIESNP  Distnct 8,348,271 (2 min)
--lnkiepsid + LNKMEDIAIEPART + LNKPARTSIESNP + lnkproduct  Distnct 8,242,019 (2 MIn)
--lnkiepsid + LNKMEDIAIEPART + LNKPARTSIESNP + lnkproduct + masproductstructure Distinct 8,292,440 (3 Min)
--lnkiepsid + LNKMEDIAIEPART + LNKPARTSIESNP + lnkproduct + masproductstructure + MASMEDIA Distinct 8,292,440 (2.5 Min)
--Total (19 Min)
SELECT distinct --top 1000
     c.IESYSTEMCONTROLNUMBER,
	 c.IESYSTEMCONTROLNUMBER as id,
	 CASE
		WHEN d.PRODUCTCODE not in ('EPG', 'IENG', 'MENG', 'TENG', 'ATCH', 'WKTL')
			and b.PARENTPRODUCTSTRUCTUREID in ('00000514','00000062','00000210','00000847','00001895','00000001')
		THEN '88888888_'+cast(b.PARENTPRODUCTSTRUCTUREID as varchar)+'_'+ cast(a.PSID as Varchar)
		ELSE
			CASE
			WHEN b.PARENTPRODUCTSTRUCTUREID <> '00000000'
			THEN cast(b.PARENTPRODUCTSTRUCTUREID as varchar)+'_'+cast(a.PSID As varchar)
			ELSE cast(a.PSID As varchar)+'_'+cast(a.PSID As varchar)
			END
	END as [PSID],
	CASE
			WHEN b.PARENTPRODUCTSTRUCTUREID <> '00000000'
			THEN cast(b.PARENTPRODUCTSTRUCTUREID as varchar)
			ELSE cast(a.PSID As varchar)
            END as [SYSTEMPSID],
	e.LASTMODIFIEDDATE [InsertDate]

From [SISWEB_OWNER_SHADOW].LNKIEPSID a With(NolocK) --4.9M
inner join [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART] e  With(NolocK) --3M
	on e.MEDIANUMBER=a.MEDIANUMBER and a.IESYSTEMCONTROLNUMBER=e.IESYSTEMCONTROLNUMBER
inner join  [SISWEB_OWNER_SHADOW].[LNKPARTSIESNP] c With(NolocK) --10M
	on c.IESYSTEMCONTROLNUMBER=e.IESYSTEMCONTROLNUMBER and c.MEDIANUMBER=e.MEDIANUMBER
inner join #InsertRecords f --Add filter to limit to changed records
 on e.IESYSTEMCONTROLNUMBER=f.IESYSTEMCONTROLNUMBER
inner join [SISWEB_OWNER].LNKPRODUCT d With(NolocK) --7K
	on c.SNP=d.SNP
inner join [SISWEB_OWNER].MASPRODUCTSTRUCTURE b With(NolocK) --20K
	on a.PSID=b.PRODUCTSTRUCTUREID and b.LANGUAGEINDICATOR='E'
inner join [SISWEB_OWNER].[MASMEDIA] g With(NolocK) --90K
	on g.MEDIANUMBER=e.MEDIANUMBER and g.MEDIASOURCE in ('A', 'C')
Where c.SNPTYPE = 'P'
 )

 Select IESYSTEMCONTROLNUMBER,
  id,
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
into #RecordsToString
From CTE_PRODUCTSTRUCTURE_2;

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString';

--NCI to cover R2S Insert
CREATE NONCLUSTERED INDEX [IX_RecordsToString_ID]
ON #RecordsToString ([id] ASC)
INCLUDE ([IESYSTEMCONTROLNUMBER],[PSID],[SYSTEMPSID],[InsertDate])
--Print cast(getdate() as varchar(50)) + ' - Nonclustered index added temp'

--Records to String --PSID
--Below Script took 12 min

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into [SISSEARCH].[PRODUCTSTRUCTURE_2] (Iesystemcontrolnumber,ID,[PSID],InsertDate)
Select
    a.IESYSTEMCONTROLNUMBER,
	a.id,
	coalesce(f.PSID,'') As [PSID],
	min(a.InsertDate) InsertDate --There may be different insert dates for each part.  Select the min to ensure future inserts are not missed.
from  #RecordsToString a
cross apply
(
	SELECT  '[' + stuff
	(
		(SELECT '","'  + cast([PSID] as varchar(MAX))
		FROM #RecordsToString as b
		where a.id=b.id
		order by b.id
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
	,1,2,'') + '"'+']'
) f (PSID)
Group by
a.IESYSTEMCONTROLNUMBER,
a.id,
f.PSID
SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
@LOGMESSAGE =  'Inserted into Target [SISSEARCH].[PRODUCTSTRUCTURE_2]';

--Create distinct list of ID & SYSTEMPSID records

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select distinct id, [SYSTEMPSID] into #RecordsToStringSystem From #RecordsToString

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp #RecordsToStringSystem Count: ' + cast(@@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToStringSystem ';

--Records to String --PSID
SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Select
	a.id,
	coalesce(f.[SYSTEMPSID],'') As [SYSTEMPSID]
into #SYSTEMPSID
from #RecordsToString a
cross apply
(
	SELECT  '[' + stuff
	(
		(SELECT '","'  + cast([SYSTEMPSID] as varchar(MAX))
		FROM #RecordsToStringSystem as b
		where a.id=b.id
		order by b.id
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
	,1,2,'') + '"'+']'
) f ([SYSTEMPSID])
Group by
a.id,
f.[SYSTEMPSID]

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Temp #SYSTEMPSID Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
@LOGMESSAGE =  'Inserted into Temp #SYSTEMPSID';

--Update SYSTEMPSID in target

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Update t
Set t.[SYSTEM] = s.[SYSTEMPSID], t.[SYSTEMPSID] = s.[SYSTEMPSID]
From [SISSEARCH].[PRODUCTSTRUCTURE_2] t
Inner join #SYSTEMPSID s on t.[ID] = s.[id]

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Update Target Field [SYSTEM] Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID,
@LOGMESSAGE =  'Update Target Field [SYSTEM]';


SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
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
