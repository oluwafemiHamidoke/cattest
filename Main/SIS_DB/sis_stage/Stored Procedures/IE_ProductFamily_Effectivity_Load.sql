-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20190830
-- Description: Full load [sis_stage].IE_ProductFamily_Effectivity
--Exec [sis_stage].[IE_ProductFamily_Effectivity_Load]
-- =============================================
CREATE PROCEDURE [sis_stage].[IE_ProductFamily_Effectivity_Load]

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
Insert into [sis_stage].[IE_ProductFamily_Effectivity]
(
 [IE_ID]
,[ProductFamily_ID]
,[Media_ID]
)
--IE_ProductFamily_Effectivity
SELECT Distinct 
 si.IE_ID
,spf.ProductFamily_ID
,med.Media_ID
FROM [SISWEB_OWNER].[LNKIESNP] iesnp
inner join [SISWEB_OWNER].[MASPRODUCT] p on p.PRODUCTCODE = iesnp.SNP
inner join sis_stage.IE si on si.IESystemControlNumber = iesnp.IESYSTEMCONTROLNUMBER
inner join sis_stage.ProductFamily spf on spf.Family_Code = p.PRODUCTCODE
inner join sis_stage.Media med on med.Media_Number = iesnp.MEDIANUMBER
where TYPEINDICATOR = 'P'

--select 'IE_ProductFamily_Effectivity' Table_Name, @@RowCount Record_Count  

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'IE_ProductFamily_Effectivity Load', @DATAVALUE = @@RowCount;

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