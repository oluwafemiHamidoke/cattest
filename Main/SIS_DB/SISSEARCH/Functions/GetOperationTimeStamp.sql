CREATE   FUNCTION [SISSEARCH].[GetOperationTimeStamp]
--
-- This function retrieves the last valid datetime stored using SetOperationTimeStamp SPROC.
-- If no value has been introduced, returns Jan  1 1900 12:00AM
-- 
-- The current logic uses a special LogType from SISSEARCH.LOG pulling the last value
-- in DataValue that can be formatted as datetime.
--
-- Example:
-- 
--		DECLARE @LastInsertDate DATETIME
--		SELECT @LastInsertDate=[SISSEARCH].[GetOperationTimeStamp]('wake up', default)
--
	(
	@OPERATION varchar(200),  -- Name of the Operation (SPROC for now) that we want to retrieve the timestamp
	@LogType VARCHAR(200)='TimeStamp' -- matching LogType to query for
	)
	RETURNS DATETIME -- returns the datetime if exists or the big bang timestamp
AS BEGIN
	DECLARE @TIMESTAMP DATETIME

	SELECT TOP 1  @TIMESTAMP=CONVERT(datetime, DataValue)
		FROM  SISSEARCH.LOG
		WHERE NameofSproc = @OPERATION AND LogType = @LogType AND
			DataValue IS NOT NULL AND TRY_CONVERT(datetime, DataValue) IS NOT NULL
		ORDER BY LogID DESC

	RETURN COALESCE(@TIMESTAMP, '') -- return timestamp or datetime('')=Jan  1 1900 12:00AM
END