-- =============================================
-- Author:      Davide Moraschi, Ajit Junghare
-- Create Date: 20200211
-- Description: Helper procedure. Writes to the SISSEARCH.LOG table.
-- Sample Use:  EXEC sis_stage.WriteLog @NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;
-- Edit : Remove processID
-- =============================================

CREATE PROCEDURE SISSEARCH.WriteLog (
									@LOGTYPE     VARCHAR(100) = 'Information'
								   ,@TIME		 datetime = null 
								   ,@NAMEOFSPROC VARCHAR(200)
								   ,@LOGMESSAGE  VARCHAR(MAX) = null
								   ,@DATAVALUE   bigint = NULL
								   ,@ISUPDATE	 bit = 0
								   ,@LAPSETIME	 bigint = NULL
								   ,@LOGID		 bigint = NULL) 
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		if @TIME is null
			set @TIME = getdate()

		if (@ISUPDATE = 0) 
			BEGIN
			INSERT INTO SISSEARCH.LOG(LogDateTime,LogType,LapseTime, NameofSproc,LogMessage,DataValue)
			VALUES (@TIME,@LOGTYPE,@LAPSETIME, @NAMEOFSPROC,@LOGMESSAGE,@DATAVALUE);

			RETURN @@IDENTITY;
			END 
		else
			BEGIN
			UPDATE SISSEARCH.LOG
			SET LapseTime= @LAPSETIME,
				LogMessage= @LOGMESSAGE,
				DataValue= @DATAVALUE
				where LogID= @LOGID;

				RETURN @@IDENTITY;
			END
		
	END TRY
	BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
			   ,@ERROELINE    INT            = ERROR_LINE();
		INSERT INTO SISSEARCH.LOG(LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (SYSUTCDATETIME(),'Error',@NAMEOFSPROC,'LINE ' + CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE,NULL);
	END CATCH;
END;