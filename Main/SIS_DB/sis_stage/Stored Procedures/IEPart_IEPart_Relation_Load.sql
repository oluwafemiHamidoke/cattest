CREATE PROCEDURE [sis_stage].[IEPart_IEPart_Relation_Load]
AS
	BEGIN
		 SET NOCOUNT ON;
		 BEGIN TRY
			DECLARE @ProcName  VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
				   ,@ProcessID UNIQUEIDENTIFIER = NEWID();

			EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;


			--Load IE_InfoType_Relation
			INSERT INTO sis_stage.IEPart_IEPart_Relation (IEPart_ID, Related_IEPart_ID,Media_ID)
			select distinct ie1.IEPart_ID, ie2.IEPart_ID, md.Media_ID from SISWEB_OWNER.LNKRELATEDPARTIES lrp
				inner join [sis_stage].[MediaSequence] ie1 on lrp.IESCN = ie1.IESystemControlNumber
				inner join [sis_stage].[MediaSequence] ie2 on lrp.RELATEDIESCN = ie2.IESystemControlNumber
                inner join [sis_stage].[MediaSection] ms on ms.MediaSection_ID = ie2.MediaSection_ID
				inner join [sis_stage].[Media] md on md.Media_ID = ms.Media_ID
			--select 'IE' Table_Name, @@RowCount Record_Count
			EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'IEPart_IEPart_Relation Load', @DATAVALUE = @@RowCount;

			EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;
		 END TRY
		BEGIN CATCH
			DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
					@ERRORLINE INT= ERROR_LINE(),
					@LOGMESSAGE VARCHAR(MAX);

			SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
			EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;
		END CATCH;
	END