CREATE  Procedure [sissearch2].[Media_RestrictAccess_Load] 
As
Begin

BEGIN TRY

SET NOCOUNT ON

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

Select @PriorToTruncCount = count(*) from [sissearch2].[Media_RestrictAccess]
Truncate table [sissearch2].[Media_RestrictAccess]

SET @RowCount= @@RowCount


SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @PriorToTruncCount, @LogID = @StepLogID, 
@LOGMESSAGE = 'Truncated [sissearch2].[Media_RestrictAccess]';


--Stage R2S Set

SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;

If Object_ID('Tempdb..#RecordsToString') is not null
Begin 
Drop table #RecordsToString
End

Select [Media_Number], 
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
select
m.[Media_Number] [Media_Number]
,d.Dealer_Code as RestrictionCode
from sis.Media m
inner join sis.MediaSection ms on m.Media_ID=ms.Media_ID
inner join [sis_shadow].[MediaSequence] mq on ms.MediaSection_ID=mq.MediaSection_ID
inner join  [sis].[IE_Dealer_Relation] b on b.IE_ID=mq.IE_ID
inner join sis.Dealer d on b.Dealer_ID=d.Dealer_ID
inner join [sis].[Media_InfoType_Relation] i on i.Media_ID = m.Media_ID
inner join [sis].[ServiceLetter_RestrictionCodes] c on i.InfoType_ID=c.[InfoTypeID]
Union --Prevent  duplicates
select
m.[Media_Number] [Media_Number]
,a.[OrgCode] RestrictionCode
from sis.Media m
inner join sis.MediaSection ms on m.Media_ID=ms.Media_ID
inner join [sis_shadow].[MediaSequence] mq on ms.MediaSection_ID=mq.MediaSection_ID
inner join [sis].[Media_InfoType_Relation] i on  i.Media_ID = m.Media_ID 
inner join [sis].[ServiceLetter_RestrictionCodes] a on a.InfoTypeID=i.InfoType_ID
where m.Media_Number not in 
(
select
m.[Media_Number] [Media_Number]
from sis.Media m
inner join sis.MediaSection ms on m.Media_ID=ms.Media_ID
inner join [sis_shadow].[MediaSequence] mq on ms.MediaSection_ID=mq.MediaSection_ID
inner join  [sis].[IE_Dealer_Relation] b on b.IE_ID=mq.IE_ID
inner join [sis].[Media_InfoType_Relation] i on i.Media_ID = m.Media_ID --Changed from lnkieinfotype to lnkmediainfotype
inner join [sis].[ServiceLetter_RestrictionCodes] c on i.InfoType_ID=c.[InfoTypeID] --Explodes to all restriction codes x infotype
)

) x
where RestrictionCode is not null
group by Media_Number, RestrictionCode

SET @RowCount= @@RowCount

SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Inserted Records Loaded to Temp #RecordsToString';


SET @StepStartTime= GETDATE()
EXEC @StepLogID = sissearch2.WriteLog @TIME = @StepStartTime, @NAMEOFSPROC = @ProcName;


Insert into [sissearch2].[Media_RestrictAccess] ([Media_Number],[RestrictionCode])
Select  
    a.[Media_Number],
	--coalesce(f.String,'') As [RestrictionCode]
	replace(coalesce(f.String,''), '"INTERNAL"', '"001","014"') As [RestrictionCode] --Updated per Lu.
from  #RecordsToString a
cross apply 
(
	SELECT  '[' + stuff
	(
		(SELECT '","'+ cast([RestrictionCode] as varchar(MAX))        
		FROM #RecordsToString as b 
		where a.[Media_Number]=b.[Media_Number] 
		order by b.[Media_Number], cast([RestrictionCode] as varchar(MAX))
		FOR XML PATH(''), TYPE).value('.', 'varchar(max)')   
	,1,2,'') + '"'+']'     
) f (String)
Group by 
a.[Media_Number],
f.String

SET @RowCount= @@RowCount


SET @LAPSETIME = DATEDIFF(SS, @StepStartTime, GETDATE());
EXEC sissearch2.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @DATAVALUE = @RowCount, @LogID = @StepLogID, 
@LOGMESSAGE =  'Inserted into Target [sissearch2].[Media_RestrictAccess]';

SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
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
GO


