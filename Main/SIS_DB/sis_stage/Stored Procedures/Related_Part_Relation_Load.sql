-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180307
-- Description: Full load [sis_stage].Related_Part_Relation
-- Modified By: Anup Kushwaha
-- Modified Date: 20220930
-- Modified Reason: Added LastModified_Date column to Related_Part_Relation
-- Associated User Story: 22942
-- Exec [sis_stage].[Related_Part_Relation_Load]
-- =============================================
CREATE PROCEDURE [sis_stage].[Related_Part_Relation_Load]

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

BEGIN TRY

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
		@ProcessID uniqueidentifier = NewID(),
        @DEFAULT_ORGCODE VARCHAR(12) = SISWEB_OWNER_STAGING._getDefaultORGCODE()

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started' , @DATAVALUE = NULL;

-- Insert statements for procedure here

-- Prepare temporary table except values E & K- for 6475
DROP TABLE IF EXISTS #RPR_Type_indicator_without_EK;
Select TYPEINDICATOR into #RPR_Type_indicator_without_EK from [SISWEB_OWNER].[LNKRELATEDPARTINFO] group by TYPEINDICATOR;
Delete from #RPR_Type_indicator_without_EK where TYPEINDICATOR in ('E','K');
Create index IX_TYPEINDICATORS on #RPR_Type_indicator_without_EK(TYPEINDICATOR);

--Load 
Insert into [sis_stage].[Related_Part_Relation]
(
 [Related_Part_ID]
,[Part_ID]
,[Type_Indicator]
,[Relation_Type]
,[LastModified_Date]
)
Select Distinct
 r.Part_ID [Related_Part_ID]
,p.Part_ID [Part_ID]
,rp.TYPEINDICATOR [Type_Indicator]
,rp.RELATION_TYPE [RELATION_TYPE]
,rp.LASTMODIFIEDDATE [LastModified_Date]
From [SISWEB_OWNER].[LNKRELATEDPARTINFO] rp
inner join [sis_stage].[Part] p on rp.PARTNUMBER = p.Part_Number and p.Org_Code = @DEFAULT_ORGCODE --The part that has related parts
inner join [sis_stage].[Part] r on rp.RELATEDPARTNUMBER = r.Part_Number and r.Org_Code = @DEFAULT_ORGCODE --This is the related parts
inner join #RPR_Type_indicator_without_EK rpr on rpr.TYPEINDICATOR = rp.TYPEINDICATOR;

DROP TABLE IF EXISTS #RPR_Type_indicator_without_EK;

--select 'Related_Part_Relation' Table_Name, @@RowCount Record_Count
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Related_Part_Relation Load' , @DATAVALUE = @@RowCount;

--Insert natural keys into key table
Insert into [sis_stage].[Related_Part_Relation_Key] (Related_Part_ID, Part_ID, Type_Indicator)
Select s.Related_Part_ID, s.Part_ID, s.Type_Indicator
From [sis_stage].[Related_Part_Relation] s
Left outer join [sis_stage].[Related_Part_Relation_Key] k on s.Related_Part_ID = k.Related_Part_ID and s.Part_ID = k.Part_ID and s.Type_Indicator = k.Type_Indicator
Where k.Related_Part_Relation_ID is null

--Key table load
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Related_Part_Relation Key Load' , @DATAVALUE = @@RowCount;

--Update stage table with surrogate keys from key table
Update s
Set Related_Part_Relation_ID = k.Related_Part_Relation_ID
From [sis_stage].[Related_Part_Relation] s
inner join [sis_stage].[Related_Part_Relation_Key] k on s.Related_Part_ID = k.Related_Part_ID and s.Part_ID = k.Part_ID and s.Type_Indicator = k.Type_Indicator
where s.Related_Part_Relation_ID is null

--Surrogate Update
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Related_Part_Relation Update Surrogate' , @DATAVALUE = @@RowCount;

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
