-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20191119
-- Modify Date: 20200302 changed GETDATE for SYSUTCDATETIME
-- Description: Helper procedure. Writes to the PRODUCTSEARCH.Log table.
-- Sample Use:  EXEC PRODUCTSEARCH.WriteLog @LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;
-- =============================================
CREATE PROCEDURE PRODUCTSEARCH.WriteLog (@LOGTYPE     VARCHAR(100) = 'Information'
								   ,@NAMEOFSPROC VARCHAR(200)
								   ,@LOGMESSAGE  VARCHAR(MAX)
								   ,@DATAVALUE   VARCHAR(20) = null) 
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		INSERT INTO [PRODUCTSEARCH].[LOG](LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (SYSUTCDATETIME(),@LOGTYPE,@NAMEOFSPROC,@LOGMESSAGE,@DATAVALUE);
	END TRY
	BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
			   ,@ERROELINE    INT            = ERROR_LINE();
		INSERT INTO [PRODUCTSEARCH].[LOG](LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (SYSUTCDATETIME(),'Error',@NAMEOFSPROC,'LINE ' + CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE,NULL);
	END CATCH;
END;