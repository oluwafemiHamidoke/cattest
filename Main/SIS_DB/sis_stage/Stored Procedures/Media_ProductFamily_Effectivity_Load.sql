


-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20191114
-- Description: Full load [sis_stage].Media_ProductFamily_Effectivity
--Exec [sis_stage].[Media_ProductFamily_Effectivity_Load]
-- =============================================
Create PROCEDURE [sis_stage].[Media_ProductFamily_Effectivity_Load]

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
BEGIN TRY

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
		@ProcessID uniqueidentifier = NewID()


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

--Load 
Insert into [sis_stage].[Media_ProductFamily_Effectivity]
(
 [Media_ID]
,[ProductFamily_ID]
)
--IE_ProductFamily_Effectivity
SELECT Distinct 
 sm.Media_ID
,spf.ProductFamily_ID
FROM [SISWEB_OWNER].[LNKIESNP] iesnp
inner join [SISWEB_OWNER].[MASPRODUCT] p on p.PRODUCTCODE = iesnp.SNP
inner join sis_stage.Media sm on sm.Media_Number = iesnp.MEDIANUMBER
inner join sis_stage.ProductFamily spf on spf.Family_Code = p.PRODUCTCODE
where TYPEINDICATOR = 'P'

--select 'IE_ProductFamily_Effectivity' Table_Name, @@RowCount Record_Count  

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Media_ProductFamily_Effectivity Load', @DATAVALUE = @@RowCount;

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;

END TRY

BEGIN CATCH 

	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
			@ERRORLINE INT= ERROR_LINE(),
			@LOGMESSAGE VARCHAR(MAX);

	SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
	EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;

END CATCH

END