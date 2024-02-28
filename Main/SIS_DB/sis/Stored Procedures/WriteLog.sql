-- =============================================
-- Author:      Airin A
-- Create Date: 20211018
-- Description: Helper procedure. Writes to the sis.Log table.
-- Sample Use:  EXEC sis.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;
-- =============================================
CREATE PROCEDURE sis.WriteLog (@PROCESSID   UNIQUEIDENTIFIER
								   ,@LOGTYPE     VARCHAR(100)
								   ,@NAMEOFSPROC VARCHAR(200)
								   ,@LOGMESSAGE  VARCHAR(MAX)
								   ,@DATAVALUE   VARCHAR(20)) 
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,SYSUTCDATETIME(),@LOGTYPE,@NAMEOFSPROC,@LOGMESSAGE,@DATAVALUE);
	END TRY
	BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
			   ,@ERROELINE    INT            = ERROR_LINE();
		INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,SYSUTCDATETIME(),'Error',@NAMEOFSPROC,'LINE ' + CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE,NULL);
	END CATCH;
END;