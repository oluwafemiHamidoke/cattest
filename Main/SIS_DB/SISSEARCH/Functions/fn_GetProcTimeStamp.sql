--Declare @LastInsertDate datetime
--Declare @ProcName VARCHAR(200)

--SET @ProcName = 'SISSEARCH.CONSISTPARTS_2_LOAD'

---- select top 1 * from sissearch.log where NameofSproc = @ProcName ORDER BY DataValue DESC
--select MAX(TRY_CONVERT(datetime, DataValue)) 
--	from sissearch.log 
--	where NameofSproc = @ProcName
--	GROUP BY DataValue 
--	ORDER BY DataValue DESC

--select @LastInsertDate=MAX(TRY_CONVERT(datetime, DataValue)) 
--	from sissearch.log 
--	where NameofSproc = @ProcName AND DataValue IS NOT NULL 
--	GROUP BY DataValue 
--	ORDER BY DataValue DESC

--print 'HEIU' + cast(@LastInsertDate as varchar(200))

-- SET @LastInsertDate = '2017-01-02 10:20:00AM'

--SELECT CURRENT_TIMEZONE(), GETUTCDATE(), SYSUTCDATETIME()


-- INSERT INTO SISSEARCH.LOG (LogDateTime, LogType, NameofSproc, DataValue) VALUES (CURRENT_TIMESTAMP, 'TimeStamp', @ProcName, CAST(@LastInsertDate as varchar(100)))



CREATE   FUNCTION [SISSEARCH].[fn_GetProcTimeStamp] (@SPROCNAME varchar(200))
	RETURNS DATETIME
AS BEGIN
	DECLARE @TIMESTAMP DATETIME

	SELECT TOP 1 @TIMESTAMP=TRY_CONVERT(datetime, DataValue) 
		FROM SISSEARCH.LOG WHERE 
			NameofSproc = @SPROCNAME AND
			LogType = 'ProcTimeStamp'
		ORDER BY DataValue DESC

	RETURN COALESCE(@TIMESTAMP, '')
END