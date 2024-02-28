CREATE PROCEDURE [sis].[IEPart_Effective_Date_Merge]
AS
	BEGIN
		SET NOCOUNT ON;

		BEGIN TRY

			DECLARE @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
			DECLARE @ProcessID UNIQUEIDENTIFIER = NewID();
			DECLARE @LOGMESSAGEDESC                    VARCHAR(MAX);

			EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;
			--Delete
			Delete ie_effective_date
				   FROM sis.IEPart_Effective_Date ie_effective_date
					inner join sis_stage.IEPart_Effective_Date_Diff ie_effective_date_diff
					on	(
						ie_effective_date.IEPart_ID				= ie_effective_date_diff.IEPart_ID				and
						ie_effective_date.Media_ID				= ie_effective_date_diff.Media_ID				and
						ie_effective_date.SerialNumberPrefix_ID	= ie_effective_date_diff.SerialNumberPrefix_ID	and
						ie_effective_date.SerialNumberRange_ID	= ie_effective_date_diff.SerialNumberRange_ID	and
						ie_effective_date.DayEffective			= ie_effective_date_diff.DayEffective
						)
				   WHERE Operation = 'Delete';

			EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'IEPart_Effective_Date Delete',@DATAVALUE = @@ROWCOUNT;

			--Insert
			INSERT INTO sis.IEPart_Effective_Date (
							 IEPart_ID,[Media_ID], [SerialNumberPrefix_ID], [SerialNumberRange_ID], [DayEffective], [DayNotEffective] 
							) 
				   SELECT	IEPart_ID, [Media_ID], [SerialNumberPrefix_ID], [SerialNumberRange_ID], [DayEffective], [DayNotEffective] 
				   FROM sis_stage.IEPart_Effective_Date_Diff
				   WHERE Operation = 'Insert';

            EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'IEPart_Effective_Date Insert',@DATAVALUE = @@ROWCOUNT;


            Update STATISTICS sis.IEPart_Effective_Date with fullscan

            EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

		END TRY
		BEGIN CATCH

			DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE();
			DECLARE @ERROELINE INT = ERROR_LINE();

			SET @LOGMESSAGEDESC = 'LINE ' + CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE;

			EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGEDESC,@DATAVALUE = NULL;

			END CATCH;
	END;
GO

