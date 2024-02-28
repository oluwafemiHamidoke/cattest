
CREATE   PROCEDURE [SISSEARCH].[SetProcTimeStamp] (
	@SPROCNAME varchar(200), 
	@TIMESTAMP DATETIME=null, 
	@LogType VARCHAR(100)= 'TimeStamp',
	@LogMessage VARCHAR(100)= null
)
AS BEGIN
	DECLARE @RESULT DATETIME
	SET @RESULT = COALESCE(@TIMESTAMP, SYSUTCDATETIME())
	PRINT 'RESULT ' + cast(@RESULT as varchar(100))
	INSERT INTO SISSEARCH.LOG 
		(LogDateTime, LogType, NameofSproc, LogMessage, DataValue) 
	VALUES 
		(CURRENT_TIMESTAMP, @LogType, @SPROCNAME, @LogMessage, cast(@RESULT as varchar(100)))
END