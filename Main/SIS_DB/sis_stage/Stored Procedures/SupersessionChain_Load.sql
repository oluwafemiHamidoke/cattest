-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180403
-- Description: Full load [sis_stage].SupersessionChain & SupersessionChain_Part_Relation
--Exec [sis_stage].[SupersessionChain_Load]
--Table swap method.
--Proc is loading either the version of target not referenced by associated view.  The view will point to this newly loaded target.
-- =============================================
CREATE PROCEDURE [sis_stage].[SupersessionChain_Load]

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

BEGIN TRY

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
		@ProcessID uniqueidentifier = NewID(),
        @ORGCODE_SEPARATOR VARCHAR(1) = SISWEB_OWNER_STAGING._getDefaultORGCODESeparator(),
		@DEFAULT_ORGCODE VARCHAR(12) = SISWEB_OWNER_STAGING._getDefaultORGCODE();

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started' , @DATAVALUE = NULL;

--This portion of code is common to all versions of the target
if OBJECT_ID('tempdb..#Chain') is not null
Drop table #Chain

if OBJECT_ID('tempdb..#ChainEMP') is not null
Drop table #ChainEMP

if OBJECT_ID('tempdb..#Supersession') is not null
Drop table #Supersession

if OBJECT_ID('tempdb..#SupersessionEMP') is not null
Drop table #SupersessionEMP

--Get natural keys from SupersessionChain_Part_Relation
select --top 10000
t.Part_Number To_Part_Number,
f.Part_Number From_Part_Number
into #Supersession
from [sis_stage].[Supersession_Part_Relation] [Child]
inner join [sis_stage].[Part] t on t.Part_ID = Child.Supersession_Part_ID
inner join [sis_stage].[Part] f on f.Part_ID = Child.Part_ID
where Child.isExpandedMiningProduct = 0

select --top 10000
       t.Part_Number To_Part_Number,
       t.Org_Code To_Org_Code,
       f.Part_Number From_Part_Number,
       f.Org_Code From_Org_Code
into #SupersessionEMP
from [sis_stage].[Supersession_Part_Relation] [Child]
    inner join [sis_stage].[Part] t on t.Part_ID = Child.Supersession_Part_ID
    inner join [sis_stage].[Part] f on f.Part_ID = Child.Part_ID
where Child.isExpandedMiningProduct = 1


--where t.Part_Number in ('7C5132','1110301','1216002','6V1355','3211099')
--or f.Part_Number in ('7C5132','1110301','1216002','6V1355','3211099')

CREATE NONCLUSTERED INDEX IX_Supersession  
ON #Supersession (From_Part_Number)  
INCLUDE (To_Part_Number);  

CREATE INDEX IX_SupersessionEMP ON #SupersessionEMP(To_Part_Number, To_Org_Code, From_Part_Number, From_Org_Code);
--Recursive CTE loads all chain framents into temp
with [PathCTE] as
(
	-- Base case: any entry with no from_Part_number is root.
	--123482
	Select Distinct --top 100 
	From_Part_Number,
	convert(nvarchar(max), N'|' + convert(nvarchar, From_Part_Number) + N'|') [Chain]
	From #Supersession s
	where From_Part_Number=To_Part_Number OR From_Part_Number not in (Select To_Part_Number From #Supersession) --Not found as to

	union all

	-- Recursive case: for any entry whose parent is already in the result set,
	-- we can construct the path by appending a single value to the parent path.
	select
	Child.To_Part_Number,
	convert(nvarchar(max), [Parent].[Chain] + convert(nvarchar, Child.To_Part_Number) + N'|') [Chain]
	from #Supersession [Child]
	inner join [PathCTE] [Parent] on 
	Child.From_Part_Number = [Parent].From_Part_Number and 
	charindex(Concat('|',Child.To_Part_Number,'|'), Parent.Chain) = 0 --Child is not already in the chain
	--charindex(
	--Parent.Chain,
	--convert(nvarchar(max), [Parent].[Chain] + convert(nvarchar, Child.To_Part_Number) + N'@')
	--) = 0
	--Parent.Chain not like Concat('%@',Child.To_Part_Number,'@%')
)
Select cast(a.Chain as varchar(8000)) Chain
into #Chain from PathCTE a
OPtion (MaxRecursion 1000);

-- Select cast(a.Chain as varchar(8000)) Chain, From_Part_Number
-- into #Chain from PathCTE a
-- WHERE NOT EXISTS  (select * from #Supersession where From_Part_Number = a.From_Part_Number);


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = '#Chain Load' , @DATAVALUE = @@RowCount;

--Do not include the single product chains.
--Min len of product number is 4 + 2 = 6 for pipes. 2 product chain must be at least 11.
Delete from #Chain
where len(Chain) <= 10

CREATE CLUSTERED INDEX CI_Chain
ON #Chain (Chain);

--Up to this point this procedure takes about 30 seconds to complete.
if OBJECT_ID('[sis_stage].Chain_Temp') is not null
Drop Table [sis_stage].Chain_Temp

--Load all Chains into working table.  Full-Text index requires a user table.
Select cast(Chain as varchar(900)) Chain
into [sis_stage].Chain_Temp
From #Chain 

--Create PKey which will be added to full text index
Alter table [sis_stage].Chain_Temp alter column Chain varchar(900) not null --Full text limit is 900 bytes
ALTER TABLE [sis_stage].Chain_Temp ADD  CONSTRAINT PK_Chain_Temp PRIMARY KEY CLUSTERED ([Chain] ASC)

--If the full text catalog does not already exists, then create it
IF NOT EXISTS (SELECT 1 FROM sys.fulltext_catalogs	WHERE [name] = 'FT_Chain') --Chain Full Text Catalog
CREATE FULLTEXT CATALOG FT_Chain AS DEFAULT; 

--Create full text index on the working table's chain field
CREATE FULLTEXT INDEX ON [sis_stage].Chain_Temp(Chain)   
	KEY INDEX PK_Chain_Temp  
	WITH STOPLIST = SYSTEM;  

Declare @FT_Status int = -1
While @FT_Status <> 0
Begin

	SELECT @FT_Status = FULLTEXTCATALOGPROPERTY(cat.name,'PopulateStatus')
	FROM sys.fulltext_catalogs AS cat
	where name = 'FT_Chain'

	if @FT_Status <> 0
	waitfor delay '00:00:05'

End
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'FullTextIndex Load' , @DATAVALUE = @@RowCount;

--Setup table to store chains to be deleted
if OBJECT_ID('tempdb..#Chain_Delete') is not null
Drop table #Chain_Delete
Create table #Chain_Delete (Chain varchar(900) not null)

--Setup cursor
Declare @Chain varchar(900)
Declare @Chain_Quoted varchar(900)
Declare @Chain_Exclude varchar(900)
Declare @Loop_Count int = 0
Declare Chain_Cursor Cursor Fast_Forward For
Select Chain From [sis_stage].Chain_Temp Where len(Chain) > 10 --Do not include the single product chains.

Open Chain_Cursor

--Get first chain
Fetch Next From Chain_Cursor
Into @Chain

While @@FETCH_STATUS = 0
Begin
	Set @Chain_Exclude = Null
	Set @Chain_Quoted = '"' + @Chain + '"' --Include in quotes

	--Determine if the current chain is contained within another chain
	Select Top 1 @Chain_Exclude = @Chain 
	from [sis_stage].Chain_Temp a
	Where a.Chain <> @Chain and --Not same chain
	contains(a.Chain, @Chain_Quoted) --Current chain_quoted is contained in chain.  Update - No need to quote; using @ instead of | so the full text search does not split the part numbers into individual "words".

	--If a matching chain is found, then mark this chain to be deleted
	If @Chain_Exclude is not null
	Insert into #Chain_Delete Select @Chain

	Fetch Next From Chain_Cursor
	Into @Chain
End
Close Chain_Cursor;
Deallocate Chain_Cursor;

Declare @DeleteCount int
Select @DeleteCount = count(*) from #Chain_Delete
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = '#Chain_Delete Load' , @DATAVALUE = @DeleteCount;

--delete chains that are contained in other chains
Delete t
From [sis_stage].Chain_Temp t
inner join #Chain_Delete d on t.Chain = d.Chain;

DELETE FROM #SupersessionEMP WHERE From_Part_Number = To_Part_Number AND From_Org_Code = To_Org_Code;

with [PathEMPCTE] as
    (
    -- Base case: any entry with no from_Part_number is root.
    --123482
    SELECT DISTINCT
    From_Part_Number as Start_Part_Number,
    From_Org_Code as Start_Org_Code,
    From_Part_Number,
    From_Org_Code,
    To_Part_Number as Last_Part_Number,
    To_Org_Code AS Last_Org_Code,
    CAST(CONCAT('|',main.From_Part_Number,':', main.From_Org_Code, '|', main.To_Part_Number,':', main.To_Org_Code, '|') AS VARCHAR(8000)) as Chain
    FROM #SupersessionEMP main

    union all

    -- Recursive case: for any entry whose parent is already in the result set,
    -- we can construct the path by appending a single value to the parent path.
    SELECT
    parent.Start_Part_Number,
    parent.Start_Org_Code,
    sub.From_Part_Number,
    sub.From_Org_Code,
    sub.To_Part_Number,
    sub.To_Org_Code,
    CONCAT(parent.Chain, sub.To_Part_Number,':', sub.To_Org_Code, '|')
    FROM #SupersessionEMP sub
    inner join [PathEMPCTE] [parent] on
    sub.From_Part_Number=parent.Last_Part_Number and sub.From_Org_Code=parent.Last_Org_Code --Child is not already in the Chain
    --charindex(
    --Parent.Chain,
    --convert(nvarchar(max), [Parent].[Chain] + convert(nvarchar, Child.To_Part_Number) + N'@')
    --) = 0
    --Parent.Chain not like Concat('%@',Child.To_Part_Number,'@%')
    )
SELECT cast(cte.Chain as varchar(8000)) Chain into #ChainEMP  from PathEMPCTE cte
WHERE NOT EXISTS  (select * from #SupersessionEMP where From_Part_Number = cte.Last_Part_Number and From_Org_Code = cte.Last_Org_Code)
AND NOT EXISTS (select top 100 * from #SupersessionEMP WHERE To_Part_Number = cte.Start_Part_Number and To_Org_Code = cte.Start_Org_Code);

INSERT INTO [sis_stage].Chain_Temp SELECT DISTINCT Chain FROM #ChainEMP

--Load chains into SupersessionChain
--Truncate table [sis_stage].[SupersessionChain]
Insert into [sis_stage].[SupersessionChain] (SupersessionChain)
Select replace(substring(Chain, 2, len(Chain)-2), '@', '|') Chain
from [sis_stage].Chain_Temp --Trim leading and trailing delimiter and change delimiter from @ to |.

--select 'SupersessionChain_Part_Relation' Table_Name, @@RowCount Record_Count
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SupersessionChain Load' , @DATAVALUE = @@RowCount;

	--Insert natural keys into key table
Insert into [sis_stage].[SupersessionChain_Key] (SupersessionChain)
Select s.SupersessionChain
From [sis_stage].[SupersessionChain] s
Left outer join [sis_stage].[SupersessionChain_Key] k on s.SupersessionChain = k.SupersessionChain
Where k.SupersessionChain_ID is null

--Key table load
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SupersessionChain Key Load' , @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set SupersessionChain_ID = k.SupersessionChain_ID
From [sis_stage].[SupersessionChain] s
inner join [sis_stage].[SupersessionChain_Key] k on s.SupersessionChain = k.SupersessionChain
where s.SupersessionChain_ID is null

--Surrogate Update
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SupersessionChain Update Surrogate' , @DATAVALUE = @@RowCount;

	--Load SupersessionChain Part Relation by splitting the chains
	--Truncate table [sis_stage].[SupersessionChain_Part_Relation]
Insert into [sis_stage].[SupersessionChain_Part_Relation]
(
    [SupersessionChain_ID]
    ,[Part_ID]
)
Select
    rp.[SupersessionChain_ID]
     ,p.Part_ID [Part_ID]
from(
        select DISTINCT
            [SupersessionChain_ID],
            [SupersessionChain],
            SISWEB_OWNER_STAGING._getPartNumberBySeparator(Part_Number_And_Org_Code,@ORGCODE_SEPARATOR) as Part_Number,
            SISWEB_OWNER_STAGING._getOrgCodeBySeparator(Part_Number_And_Org_Code,@ORGCODE_SEPARATOR,@DEFAULT_ORGCODE) as Org_Code
        From
            (
            SELECT Distinct
                [SupersessionChain_ID],
                [SupersessionChain],
                x.value [Part_Number_And_Org_Code]
            FROM [sis_stage].[SupersessionChain]
            CROSS APPLY STRING_SPLIT([SupersessionChain], '|') x
            ) x
    ) rp
    inner join [sis_stage].[Part] p on rp.[Part_Number] = p.Part_Number and rp.[Org_Code] = p.Org_Code
    Where p.Part_Number is not null
    --4529907


    --select 'SupersessionChain_Part_Relation' Table_Name, @@RowCount Record_Count
	EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'SupersessionChain_Part_Relation Load' , @DATAVALUE = @@RowCount;



--Drop working table
if OBJECT_ID('[sis_stage].Chain_Temp') is not null
Drop Table [sis_stage].Chain_Temp

--Set the working version as the live version using control
--Note - This will need to be done on the target server after refresh completes
--Update [sis_stage].[Control_TableSwap] Set VersionID = @WorkVersion where [Name] = 'SupersessionChain_Part_Relation'
--Update [sis_stage].[Control_TableSwap] Set VersionID = @WorkVersion where [Name] = 'SupersessionChain'

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed' , @DATAVALUE = NULL;

END TRY

BEGIN CATCH

	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
			@ERRORLINE INT= ERROR_LINE(),
			@LOGMESSAGE VARCHAR(MAX);

	SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
    EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;

END CATCH

END
