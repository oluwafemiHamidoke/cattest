CREATE  Procedure [SISSEARCH].[SERVICEIERESTRICTACCESS_2_LOAD] 
As
/*---------------
Date: 10-10-2017
Object Description:  Loading changed data into SISSEARCH.SERVICEIERESTRICTACCESS_2 from base tables
Modifiy Date: 20210310 - Davide. Changed DATEUPDATED to LASTMODDIFIEDDATE, see: https://dev.azure.com/sis-cat-com/sis2-ui/_workitems/edit/9566/
Exec [SISSEARCH].[SERVICEIERESTRICTACCESS_2_LOAD]
Truncate table [SISSEARCH].[SERVICEIERESTRICTACCESS_2]
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

Select @PriorToTruncCount = count(*) from [SISSEARCH].[SERVICEIERESTRICTACCESS_2]
Truncate table [SISSEARCH].[SERVICEIERESTRICTACCESS_2]

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Truncated [SISSEARCH].[SERVICEIERESTRICTACCESS_2] Count: ' +  cast(@PriorToTruncCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @PriorToTruncCount, @LOGID = @StepLogID, 
@LOGMESSAGE = 'Truncated [SISSEARCH].[SERVICEIERESTRICTACCESS_2]';


--Stage R2S Set

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
Drop table #RecordsToString
End

Select iesystemcontrolnumber, 
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
--select Distinct
-- a.[IESYSTEMCONTROLNUMBER]
--,b.[EFFECTIVITY] as RestrictionCode
--from [SISWEB_OWNER].[LNKMEDIAIE] a
----Inner join [SISWEB_OWNER].[LNKMEDIAEFFECTIVITY] b on a.[MEDIANUMBER] = b.[MEDIANUMBER]
--inner join [SISWEB_OWNER].[LNKIEEFFECTIVITY] b on a.MEDIANUMBER = b.MEDIANUMBER
--Inner join [SISWEB_OWNER].[LNKIEINFOTYPE] d on a.[IESYSTEMCONTROLNUMBER] = d.[IESYSTEMCONTROLNUMBER] --Explodes to all media + ie + infotype
--Inner join [sis].[ServiceLetter_RestrictionCodes] c on d.[INFOTYPEID]=c.[InfoTypeID] --Explodes to all all OrgCodes

--UNION

--select Distinct 
-- d.[IESYSTEMCONTROLNUMBER]
--,a.[OrgCode] RestrictionCode
--from [sis].[ServiceLetter_RestrictionCodes] a --base view
--inner join [SISWEB_OWNER].[LNKIEINFOTYPE] c on a.[InfoTypeID]=c.[INFOTYPEID] --Limit to InfoTypes found in lnkinfotype
--inner join [SISWEB_OWNER].[LNKMEDIAIE] d on d.[IESYSTEMCONTROLNUMBER]=c.[IESYSTEMCONTROLNUMBER] --Explode to IE level
--where d.IESYSTEMCONTROLNUMBER not in (select distinct iescn from [SISWEB_OWNER].[LNKIEEFFECTIVITY]) 

--v2
--select Distinct
-- b.IESCN [IESYSTEMCONTROLNUMBER]
--,b.[EFFECTIVITY] as RestrictionCode
--from [SISWEB_OWNER].[LNKIEEFFECTIVITY] b
--Inner join [SISWEB_OWNER].[LNKIEINFOTYPE] d on b.IESCN = d.[IESYSTEMCONTROLNUMBER] --Explodes to all media + ie + infotype
--Inner join [sis].[ServiceLetter_RestrictionCodes] c on d.[INFOTYPEID]=c.[InfoTypeID] --Explodes to all all OrgCodes

--UNION

--select Distinct 
-- c.[IESYSTEMCONTROLNUMBER]
--,a.[OrgCode] RestrictionCode
--from [sis].[ServiceLetter_RestrictionCodes] a --base view
--inner join [SISWEB_OWNER].[LNKIEINFOTYPE] c on a.[InfoTypeID]=c.[INFOTYPEID] --Limit to InfoTypes found in lnkinfotype
--inner join [SISWEB_OWNER].[LNKIEEFFECTIVITY] d on d.IESCN = c.IESYSTEMCONTROLNUMBER

----v3
----get IEs with dealer code effectivity
--select Distinct
--b.[IESCN] as iesystemcontrolnumber
--,b.[EFFECTIVITY] as RestrictionCode
--from [SISWEB_OWNER].[LNKIEEFFECTIVITY] b
--Inner join [SISWEB_OWNER].[LNKIEINFOTYPE] d on b.[IESCN] = d.[IESYSTEMCONTROLNUMBER] --Explodes to all media + ie + infotype
--Inner join [sis].[ServiceLetter_RestrictionCodes] c on d.[INFOTYPEID]=c.[InfoTypeID] --Explodes to all all OrgCodes
 
--UNION
 
----get IEs with region code effectivity
--select Distinct 
-- c.IESYSTEMCONTROLNUMBER
--,a.[OrgCode] RestrictionCode
--from [sis].[ServiceLetter_RestrictionCodes] a --base view
--inner join [SISWEB_OWNER].[LNKIEINFOTYPE] c on a.[InfoTypeID]=c.[INFOTYPEID] --Limit to InfoTypes found in lnkinfotype
--where c.IESYSTEMCONTROLNUMBER not in (select distinct IESCN from [SISWEB_OWNER].[LNKIEEFFECTIVITY])  

--v4
--Change to SIS2IEEFFECTIVITY
select
b.IESYSTEMCONTROLNUMBER as iesystemcontrolnumber
,b.[EFFECTIVITY] as RestrictionCode
from [SISWEB_OWNER].[SIS2IEEFFECTIVITY] b
Inner join [SISWEB_OWNER].[LNKIEINFOTYPE] d on b.IESYSTEMCONTROLNUMBER = d.[IESYSTEMCONTROLNUMBER] --Explodes to all media + ie + infotype
Inner join [sis].[ServiceLetter_RestrictionCodes] c on d.[INFOTYPEID]=c.[InfoTypeID] --Explodes to all all OrgCodes
 
UNION
 
--get IEs with region code effectivity
select 
 c.IESYSTEMCONTROLNUMBER
,a.[OrgCode] RestrictionCode
from [sis].[ServiceLetter_RestrictionCodes] a --base view
inner join [SISWEB_OWNER].[LNKIEINFOTYPE] c on a.[InfoTypeID]=c.[INFOTYPEID] --Limit to InfoTypes found in lnkinfotype
where c.IESYSTEMCONTROLNUMBER not in (select distinct IESYSTEMCONTROLNUMBER from [SISWEB_OWNER].[SIS2IEEFFECTIVITY])  

) x
Where RestrictionCode is not null


SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString';

SET @StepStartTime= GETDATE()
EXEC @StepLogID = SISSEARCH.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into [SISSEARCH].[SERVICEIERESTRICTACCESS_2] (IESystemControlNumber,RestrictionCode)
Select  
    a.iesystemcontrolnumber,
	replace(coalesce(f.String,''), '"INTERNAL"', '"001","014","013","053"') As [RestrictionCode] --Updated per Lu.
from  #RecordsToString a
cross apply 
(
	SELECT  '[' + stuff
	(
		(SELECT '","'+ cast([RestrictionCode] as varchar(MAX))        
		FROM #RecordsToString as b 
		where a.iesystemcontrolnumber=b.iesystemcontrolnumber
		order by b.iesystemcontrolnumber, cast([RestrictionCode] as varchar(MAX))
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')   
	,1,2,'') + '"'+']'     
) f (String)
Group by 
a.iesystemcontrolnumber,
f.String

SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted into Target Count: ' + Cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Target [SISSEARCH].[SERVICEIERESTRICTACCESS_2]';

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
