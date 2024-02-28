CREATE PROCEDURE [SISSEARCH].[SetOperationTimeStamp]
--
-- This SPROC sets @TIMESTAMP for a given @OPERATION for later recovery using
-- [SISSEARCH].[fn_GetOperationTimeStamp] function.
--
-- If no @TIMESTAMP has been introduced, sets the current UTC time
-- If @TIMESTAMP is '', sets Jan  1 1900 12:00AM
-- 
-- Examples:
--
--	This example sets Jan  1 1900 12:00AM timestamp for operation '1234'
--
--		EXEC [SISSEARCH].[SetOperationTimeStamp] @OPERATION='1234', @TIMESTAMP=''
--		SELECT @@IDENTITY,[SISSEARCH].[fn_GetOperationTimeStamp]('1234', default), '**'
--
--
--	This example sets the current UTC timestamp for operation '1234'
--
--		EXEC [SISSEARCH].[SetOperationTimeStamp]  @OPERATION='1234'
--		SELECT @@IDENTITY,[SISSEARCH].[fn_GetOperationTimeStamp]('1234', default), '**'
--
	(
	@OPERATION varchar(200), 
	@TIMESTAMP DATETIME=null, 
	@LogType VARCHAR(100)= 'TimeStamp',
	@LogMessage VARCHAR(max)= null
)
AS BEGIN
	INSERT INTO SISSEARCH.LOG 
		(LogDateTime, LogType, NameofSproc, LogMessage, DataValue) 
	VALUES 
		(CURRENT_TIMESTAMP, @LogType, @OPERATION, @LogMessage, cast(COALESCE(@TIMESTAMP, GETUTCDATE()) as varchar(20)))
END