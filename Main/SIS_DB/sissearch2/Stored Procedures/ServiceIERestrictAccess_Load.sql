/****** Object:  StoredProcedure [sissearch2].[ServiceIERestrictAccess_Load]    Script Date: 8/23/2022 9:22:14 AM ******/
Create  Procedure [sissearch2].[ServiceIERestrictAccess_Load] 
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

EXEC @SPStartLogID = sissearch2.WriteLog @TIME = @SPStartTime, @NAMEOFSPROC = @ProcName;

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Declare @PriorToTruncCount int

Select @PriorToTruncCount = count(*) from [sissearch2].[ServiceIE_RestrictAccess]
Truncate table [sissearch2].[ServiceIE_RestrictAccess]

SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @PriorToTruncCount, @LOGID = @StepLogID, 
@LOGMESSAGE = 'Truncated [sissearch2].[ServiceIE_RestrictAccess]';


--Stage R2S Set

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

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
--v4
--Change to SIS2IEEFFECTIVITY
select
a.IESystemControlNumber as iesystemcontrolnumber
,c.[Dealer_Code] as RestrictionCode
from [sis].[IE] a
inner join [sis].[IE_Dealer_Relation] b on a.IE_ID=b.IE_ID
inner join [sis].[Dealer] c on b.Dealer_ID=c.Dealer_ID
inner join [sis].[IE_InfoType_Relation] d on a.IE_ID=d.IE_ID
inner join [sis].[ServiceLetter_RestrictionCodes] e on d.InfoType_ID=e.InfoTypeID

UNION
 
--get IEs with region code effectivity
select 
 a.IESystemControlNumber
,c.[OrgCode] RestrictionCode
from [sis].[IE] a
inner join [sis].[IE_InfoType_Relation] b on a.IE_ID=b.IE_ID
inner join [sis].[ServiceLetter_RestrictionCodes] c on b.InfoType_ID=c.InfoTypeID
where a.IE_ID not in (select distinct IE_ID from [sis].[IE_Dealer_Relation]) 
) x
Where RestrictionCode is not null


SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - Inserted Records Loaded to Temp Count: ' + cast(@RowCount as varchar(50))

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString';

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

Insert into [sissearch2].[ServiceIE_RestrictAccess] (IESystemControlNumber,RestrictionCode)
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
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LOGID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Target [sissearch2].[ServiceIE_RestrictAccess]';

SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LOGID = @SPStartLogID,@DATAVALUE = @RowCount

DELETE FROM sissearch2.LOG WHERE DATEDIFF(DD, LogDateTime, GetDate())>30 and NameofSproc= @ProcName

END TRY

BEGIN CATCH 
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT= ERROR_LINE()

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC sissearch2.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error
END CATCH


End