-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20191119
-- Modify Date: 20200302 changed GETDATE for SYSUTCDATETIME
-- Description: Helper procedure. Writes to the sis_stage.Log table.
-- Sample Use:  EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;
-- =============================================
CREATE PROCEDURE sis_stage.WriteLog (@PROCESSID   UNIQUEIDENTIFIER
								   ,@LOGTYPE     VARCHAR(100)
								   ,@NAMEOFSPROC VARCHAR(200)
								   ,@LOGMESSAGE  VARCHAR(MAX)
								   ,@DATAVALUE   VARCHAR(20)) 
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,SYSUTCDATETIME(),@LOGTYPE,@NAMEOFSPROC,@LOGMESSAGE,@DATAVALUE);
	END TRY
	BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
			   ,@ERROELINE    INT            = ERROR_LINE();
		INSERT INTO sis_stage.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,SYSUTCDATETIME(),'Error',@NAMEOFSPROC,'LINE ' + CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE,NULL);
	END CATCH;
END;