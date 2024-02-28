/* ==================================================================================================================================================== 
Author		:	Sooraj Parameswaran
Create date	:	2022-05-20
Description	:	Full Load to sis_stage.Part_IE_Effectivity. Truncate sis_stage.Part_IE_Effectivity before load.
====================================================================================================================================================== */

CREATE PROCEDURE [sis_stage].[Part_IE_Effectivity_Load]

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

	BEGIN TRY

		Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
				@ProcessID uniqueidentifier = NewID()


		EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

		--Load 
		Insert into [sis_stage].[Part_IE_Effectivity]
		(
			[IE_ID]
			,[Part_ID]
			,[Media_ID]
			,[SerialNumberPrefix_ID]
			,[SerialNumberRange_ID]
		)
		Select distinct
			ie.[IE_ID]
			,p.Part_ID
			,m.Media_ID
			,snp.[SerialNumberPrefix_ID]
			,snr.[SerialNumberRange_ID]
		FROM [sis_stage].[IE] ie
		inner join [SISWEB_OWNER].[LNKIEMEDIAPART] iemediapart on iemediapart.IESYSTEMCONTROLNUMBER = ie.IESystemControlNumber
		inner join [sis_stage].[Part] p on p.Part_Number = iemediapart.PARTNUMBER
		inner join [sis_stage].[SerialNumberPrefix] snp on  iemediapart.[SNP] = snp.[Serial_Number_Prefix]
		inner join [sis_stage].[SerialNumberRange] snr on iemediapart.[BEGINNINGRANGE] = snr.[Start_Serial_Number] and iemediapart.[ENDRANGE] = snr.[End_Serial_Number]
		inner join [sis_stage].[Media] m on iemediapart.MEDIANUMBER = m.[Media_Number]

		EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Part_IE_Effectivity Load', @DATAVALUE = @@RowCount;

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