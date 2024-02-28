CREATE  Procedure [SISSEARCH].[MEDIARESTRICTACCESS_2_LOAD] 
As
/*---------------
Date: 10-10-2017
Object Description:  Loading changed data into SISSEARCH.MEDIARESTRICTACCESS_2 from base tables
Modifiy Date: 20210311 - Davide. Changed MEDIAUPDATEDDATE to LASTMODDIFIEDDATE, see: https://dev.azure.com/sis-cat-com/sis2-ui/_workitems/edit/9566/
Exec [SISSEARCH].[MEDIARESTRICTACCESS_2_LOAD]
Truncate table [SISSEARCH].[MEDIARESTRICTACCESS_2]
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

Declare @PriorToTruncCount int

Select @PriorToTruncCount = count(*) from [SISSEARCH].[MEDIARESTRICTACCESS_2]
Truncate table [SISSEARCH].[MEDIARESTRICTACCESS_2]

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Truncated [SISSEARCH].[MEDIARESTRICTACCESS_2] Count: ' +  cast(@PriorToTruncCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @PriorToTruncCount, @LOGID = @StepLogID, 
@LOGMESSAGE = 'Truncated [SISSEARCH].[MEDIARESTRICTACCESS_2]';


--Stage R2S Set

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
Drop table #RecordsToString
End

Select [BaseEngMediaNumber], 
  	replace( --escape /
		replace( --escape "
			replace( --escape carriage return (ascii 13)
				replace( --escape form feed (ascii 12) 
					replace( --escape vertical tab (ascii 11)
						replace( --escape line feed (ascii 10)
							replace( --escape horizontal tab (ascii 09)
								replace( --escape backspace (ascii 08)
									replace( --escape \
										isnull([RestrictionCode],'')
									,'\', '\\')
								,char(8), ' ')
							,char(9), ' ')
						,char(10), ' ')
					,char(11), ' ')
				,char(12), ' ')
			,char(13), ' ')
			,'"', '\"')
		,'/', '\/') as [RestrictionCode]
into #RecordsToString
From 
(
--v1
--select Distinct --Added distinct
--a.[BASEENGLISHMEDIANUMBER] [BaseEngMediaNumber]
--,b.EFFECTIVITY as RestrictionCode
--from [SISWEB_OWNER].[MASMEDIA] a --changed from lnkmediaie to masmedia
----Inner join [SISWEB_OWNER].[LNKMEDIAEFFECTIVITY] b on a.BASEENGLISHMEDIANUMBER = b.[MEDIANUMBER]
--inner join [SISWEB_OWNER].[LNKIEEFFECTIVITY] b on a.BASEENGLISHMEDIANUMBER = b.MEDIANUMBER
--inner join [SISWEB_OWNER].LNKMEDIAINFOTYPE i on i.MEDIANUMBER = a.BASEENGLISHMEDIANUMBER --Changed from lnkieinfotype to lnkmediainfotype
--inner join [sis].[ServiceLetter_RestrictionCodes] c on i.[INFOTYPEID]=c.[InfoTypeID] --Explodes to all restriction codes x infotype

--Union --Prevent  duplicates

--select Distinct --Added distinct
--d.[BASEENGLISHMEDIANUMBER] [BaseEngMediaNumber]
--,a.[OrgCode] RestrictionCode
--from [sis].[ServiceLetter_RestrictionCodes] a
--inner join [SISWEB_OWNER].[LNKMEDIAINFOTYPE] c on a.[InfoTypeID]=c.[INFOTYPEID]
--inner join [SISWEB_OWNER].[MASMEDIA] d on d.BASEENGLISHMEDIANUMBER=c.[MEDIANUMBER]

----v3
--select Distinct --Added distinct
--a.[BASEENGLISHMEDIANUMBER] [BaseEngMediaNumber]
--,b.EFFECTIVITY as RestrictionCode
--from [SISWEB_OWNER].[MASMEDIA] a --changed from lnkmediaie to masmedia
--inner join [SISWEB_OWNER].[LNKIEEFFECTIVITY] b on a.BASEENGLISHMEDIANUMBER = b.MEDIANUMBER
--inner join [SISWEB_OWNER].LNKMEDIAINFOTYPE i on i.MEDIANUMBER = a.BASEENGLISHMEDIANUMBER --Changed from lnkieinfotype to lnkmediainfotype
--inner join [sis].[ServiceLetter_RestrictionCodes] c on i.[INFOTYPEID]=c.[InfoTypeID] --Explodes to all restriction codes x infotype
 
--Union --Prevent  duplicates
 
--select Distinct --Added distinct
--d.[BASEENGLISHMEDIANUMBER] [BaseEngMediaNumber]
--,a.[OrgCode] RestrictionCode
--from [sis].[ServiceLetter_RestrictionCodes] a
--inner join [SISWEB_OWNER].[LNKMEDIAINFOTYPE] c on a.[InfoTypeID]=c.[INFOTYPEID]
--inner join [SISWEB_OWNER].[MASMEDIA] d on d.BASEENGLISHMEDIANUMBER=c.[MEDIANUMBER]
--where c.MEDIANUMBER not in (select distinct MEDIANUMBER from  [SISWEB_OWNER].[LNKIEEFFECTIVITY])

--v4
select
a.[BASEENGLISHMEDIANUMBER] [BaseEngMediaNumber]
,b.EFFECTIVITY as RestrictionCode
from [SISWEB_OWNER].[MASMEDIA] a --changed from lnkmediaie to masmedia
inner join [SISWEB_OWNER].[SIS2IEEFFECTIVITY] b on a.BASEENGLISHMEDIANUMBER = b.MEDIANUMBER
inner join [SISWEB_OWNER].LNKMEDIAINFOTYPE i on i.MEDIANUMBER = a.BASEENGLISHMEDIANUMBER --Changed from lnkieinfotype to lnkmediainfotype
inner join [sis].[ServiceLetter_RestrictionCodes] c on i.[INFOTYPEID]=c.[InfoTypeID] --Explodes to all restriction codes x infotype
 
Union --Prevent  duplicates
 
select
d.[BASEENGLISHMEDIANUMBER] [BaseEngMediaNumber]
,a.[OrgCode] RestrictionCode
from [sis].[ServiceLetter_RestrictionCodes] a
inner join [SISWEB_OWNER].[LNKMEDIAINFOTYPE] c on a.[InfoTypeID]=c.[INFOTYPEID]
inner join [SISWEB_OWNER].[MASMEDIA] d on d.BASEENGLISHMEDIANUMBER=c.[MEDIANUMBER]
where c.MEDIANUMBER not in (select MEDIANUMBER from  [SISWEB_OWNER].[SIS2IEEFFECTIVITY] group by MEDIANUMBER)
) x
where RestrictionCode is not null
group by BaseEngMediaNumber, RestrictionCode


SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString';


SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


Insert into [SISSEARCH].[MEDIARESTRICTACCESS_2] ([BaseEngMediaNumber],[RestrictionCode])
Select  
    a.[BaseEngMediaNumber],
	--coalesce(f.String,'') As [RestrictionCode]
	replace(coalesce(f.String,''), '"INTERNAL"', '"001","014"') As [RestrictionCode] --Updated per Lu.
from  #RecordsToString a
cross apply 
(
	SELECT  '[' + stuff
	(
		(SELECT '","'+ cast([RestrictionCode] as varchar(MAX))        
		FROM #RecordsToString as b 
		where a.[BaseEngMediaNumber]=b.[BaseEngMediaNumber] 
		order by b.[BaseEngMediaNumber], cast([RestrictionCode] as varchar(MAX))
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')   
	,1,2,'') + '"'+']'     
) f (String)
Group by 
a.[BaseEngMediaNumber],
f.String

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Target [SISSEARCH].[MEDIARESTRICTACCESS_2]';

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
