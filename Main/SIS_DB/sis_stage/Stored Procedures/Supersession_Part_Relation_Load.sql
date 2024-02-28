

-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180322
-- Description: Full load [sis_stage].Supersession_Part_Relation
--Exec [sis_stage].[Supersession_Part_Relation_Load]
-- =============================================
CREATE PROCEDURE [sis_stage].[Supersession_Part_Relation_Load]

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

BEGIN TRY

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
		@ProcessID uniqueidentifier = NewID(),
        @DEFAULT_ORGCODE VARCHAR(12) = SISWEB_OWNER_STAGING._getDefaultORGCODE(),
		@ORGCODE_SEPARATOR VARCHAR(1) = SISWEB_OWNER_STAGING._getDefaultORGCODESeparator();

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started' , @DATAVALUE = NULL;

if OBJECT_ID('tempdb..#PartNumberAndOrgCodeEMP') is not null
Drop table #PartNumberAndOrgCodeEMP

-- truncating table to avoid Supersession_Part_Relation_Load exception
--  "Violation of PRIMARY KEY constraint 'PK_Supersession_Part_Relation'. Cannot insert duplicate key in object "
truncate table [sis_stage].[Supersession_Part_Relation]

--Load
select
    SISWEB_OWNER_STAGING._getPartNumberBySeparator(From_Part_Number_Org_Code,@ORGCODE_SEPARATOR) as From_Part_Number,
    SISWEB_OWNER_STAGING._getOrgCodeBySeparator(From_Part_Number_Org_Code,@ORGCODE_SEPARATOR,@DEFAULT_ORGCODE) as From_Org_Code,
    SISWEB_OWNER_STAGING._getPartNumberBySeparator(To_Part_Number_Org_Code,@ORGCODE_SEPARATOR) as To_Part_Number,
    SISWEB_OWNER_STAGING._getOrgCodeBySeparator(To_Part_Number_Org_Code,@ORGCODE_SEPARATOR,@DEFAULT_ORGCODE) as To_Org_Code,
    isExpandedMiningProduct into #PartNumberAndOrgCodeEMP
From
    (
    Select Distinct
    lag(Part_Number_And_Org_Code, 1) over (Partition By [CHAIN] Order by RowRank asc) From_Part_Number_Org_Code
    ,Part_Number_And_Org_Code To_Part_Number_Org_Code
    ,isExpandedMiningProduct
    From
    (
        SELECT
        [CHAIN]
        ,isExpandedMiningProduct
        ,x.value Part_Number_And_Org_Code
        ,Row_number() Over (Partition By CHAIN Order by Charindex(x.value, [CHAIN]) asc) RowRank
        FROM [SISWEB_OWNER].[SUPERSESSIONCHAINS]
        CROSS APPLY STRING_SPLIT([CHAIN], '|') x
        where isExpandedMiningProduct = 1
    ) x
) rp

CREATE INDEX IX_PARTNUMBERANDORGCODEEMP ON #PartNumberAndOrgCodeEMP(From_Part_Number, From_Org_Code, To_Part_Number, To_Org_Code);

Insert into [sis_stage].[Supersession_Part_Relation]
(
 [Supersession_Part_ID]
,[Part_ID]
,[isExpandedMiningProduct]
)
Select
    r.Part_ID [Supersession_Part_ID]
   ,p.Part_ID [Part_ID]
   ,rp.isExpandedMiningProduct
From
    (
        Select Distinct
            lag(Part_Number_And_Org_Code, 1) over (Partition By [CHAIN] Order by RowRank asc) From_Part_Number
            ,Part_Number_And_Org_Code To_Part_Number
            ,isExpandedMiningProduct
        From
            (
                SELECT
                    [CHAIN]
                    ,isExpandedMiningProduct
                    ,x.value Part_Number_And_Org_Code -- this will not contains org_code
                    ,Row_number() Over (Partition By CHAIN Order by Charindex(x.value, [CHAIN]) asc) RowRank
                FROM [SISWEB_OWNER].[SUPERSESSIONCHAINS]
                    CROSS APPLY STRING_SPLIT([CHAIN], '|') x
                where isExpandedMiningProduct = 0 AND replace(ltrim(rtrim(CHAIN)), '|', '') Not LIKE '%[^a-z0-9A-Z]%'
            ) x
    ) rp
inner join [sis_stage].[Part] p on rp.From_Part_Number = p.Part_Number AND p.Org_Code = @DEFAULT_ORGCODE --The part that has Supersession parts
inner join [sis_stage].[Part] r on rp.To_Part_Number = r.Part_Number and r.Org_Code = @DEFAULT_ORGCODE--This is the Supersession parts
Where From_Part_Number is not null

Insert into [sis_stage].[Supersession_Part_Relation]
(
    [Supersession_Part_ID]
    ,[Part_ID]
    ,[isExpandedMiningProduct]
)
Select
    r.Part_ID [Supersession_Part_ID]
    ,p.Part_ID [Part_ID]
    ,rp.isExpandedMiningProduct
From #PartNumberAndOrgCodeEMP rp
    inner join [sis_stage].[Part] p on rp.From_Part_Number = p.Part_Number AND p.Org_Code = rp.from_org_code  --The part that has Supersession parts
    inner join [sis_stage].[Part] r on rp.To_Part_Number = r.Part_Number and r.Org_Code = rp.to_org_code--This is the Supersession parts
Where From_Part_Number is not null

--select 'Supersession_Part_Relation' Table_Name, @@RowCount Record_Count
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Supersession_Part_Relation Load' , @DATAVALUE = @@RowCount;

--Insert natural keys into key table
Insert into [sis_stage].[Supersession_Part_Relation_Key] (Part_ID, Supersession_Part_ID)
Select s.Part_ID, s.Supersession_Part_ID
From [sis_stage].[Supersession_Part_Relation] s
Left outer join [sis_stage].[Supersession_Part_Relation_Key] k on s.Part_ID = k.Part_ID and s.Supersession_Part_ID = k.Supersession_Part_ID
Where k.Supsersession_Part_Relation_ID is null

--Key table load
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Supersession_Part_Relation Key Load' , @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set Supsersession_Part_Relation_ID = k.Supsersession_Part_Relation_ID
From [sis_stage].[Supersession_Part_Relation] s
inner join [sis_stage].[Supersession_Part_Relation_Key] k on s.Part_ID = k.Part_ID and s.Supersession_Part_ID = k.Supersession_Part_ID
where s.Supsersession_Part_Relation_ID is null

--Surrogate Update
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Supersession_Part_Relation Update Surrogate' , @DATAVALUE = @@RowCount;


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
