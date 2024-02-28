

-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20190830
-- Modify Date: 20200302 Added Media_ID to [IE_Effectivity]
-- Description: Full load [sis_stage].IE_Effectivity
--Exec [sis_stage].[IE_Effectivity_Load]
-- =============================================
CREATE PROCEDURE [sis_stage].[IE_Effectivity_Load]

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
Insert into [sis_stage].[IE_Effectivity]
(
 [IE_ID]
,[SerialNumberPrefix_ID]
,[SerialNumberRange_ID]
,[Media_ID]
)
Select Distinct 
 ie.[IE_ID]
,snp.[SerialNumberPrefix_ID]
,snr.[SerialNumberRange_ID]
,m.Media_ID
FROM [sis_stage].[IE] ie
inner join [SISWEB_OWNER].[LNKIESNP] x on x.IESYSTEMCONTROLNUMBER = ie.IESystemControlNumber and x.TYPEINDICATOR = 'S'
inner join [sis_stage].[SerialNumberPrefix] snp on  x.[SNP] = snp.[Serial_Number_Prefix]
inner join [sis_stage].[SerialNumberRange] snr on x.[BEGINNINGRANGE] = snr.[Start_Serial_Number] and x.[ENDRANGE] = snr.[End_Serial_Number]
inner join [sis_stage].[Media] m on x.[MEDIANUMBER] = m.[Media_Number]

--select 'IE_Effectivity' Table_Name, @@RowCount Record_Count  

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'IE_Effectivity Load', @DATAVALUE = @@RowCount;


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