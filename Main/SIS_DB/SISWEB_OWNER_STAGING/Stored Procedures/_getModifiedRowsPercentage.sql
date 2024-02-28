CREATE PROCEDURE [SISWEB_OWNER_STAGING].[_getModifiedRowsPercentage] (
		@SISWEB_OWNER_TABLE				VARCHAR(100) = ''
        , @SISWEB_OWNER_STAGING_TABLE	VARCHAR(100) = ''
		, @EMP_STAGING_TABLE			VARCHAR(100) = ''
	)
AS 
BEGIN
	DECLARE @MODIFIED_ROWS_PERCENTAGE		DECIMAL(12,4) = 100
		, @SISWEB_OWNER_ROWCOUNT			DECIMAL(12,3) = 0
        , @SISWEB_OWNER_STAGING_ROWCOUNT	DECIMAL(12,3) = 0
		, @EMP_STAGING_ROWCOUNT				DECIMAL(12,3) = 0
		, @sql								NVARCHAR(MAX) = '';

	SET @sql = N'SELECT @SISWEB_OWNER_ROWCOUNT = COUNT_BIG(*) FROM SISWEB_OWNER.' + @SISWEB_OWNER_TABLE;
	EXECUTE sp_executesql @sql, N'@SISWEB_OWNER_ROWCOUNT DECIMAL(12,4) OUTPUT', @SISWEB_OWNER_ROWCOUNT output;

	SET @sql = N'SELECT @SISWEB_OWNER_STAGING_ROWCOUNT = COUNT_BIG(*) FROM SISWEB_OWNER_STAGING.' + @SISWEB_OWNER_TABLE;
	EXECUTE sp_executesql @sql, N'@SISWEB_OWNER_STAGING_ROWCOUNT DECIMAL(12,4) OUTPUT', @SISWEB_OWNER_STAGING_ROWCOUNT output;

	IF @EMP_STAGING_TABLE != ''
	BEGIN
		SET @sql = N'SELECT @EMP_STAGING_ROWCOUNT = COUNT_BIG(*) FROM EMP_STAGING.' + @EMP_STAGING_TABLE;
		EXECUTE sp_executesql @sql, N'@EMP_STAGING_ROWCOUNT DECIMAL(12,4) OUTPUT', @EMP_STAGING_ROWCOUNT output;
	END
	
	IF @SISWEB_OWNER_ROWCOUNT > 0
    BEGIN
        SELECT @MODIFIED_ROWS_PERCENTAGE = ABS(((@SISWEB_OWNER_STAGING_ROWCOUNT + @EMP_STAGING_ROWCOUNT) - @SISWEB_OWNER_ROWCOUNT) * 100 / @SISWEB_OWNER_ROWCOUNT);
    END;
	
	
	-- This is a debug added to find the root cause for frequent MODIFIED_ROWS_PERCENTAGE error ============
	Declare @ProcessID uniqueidentifier = NewID(), 
			@LOGMESSAGE VARCHAR(MAX);

	SET @LOGMESSAGE = FORMATMESSAGE('Row count for SISWEB_OWNER_%s', CAST(@SISWEB_OWNER_TABLE AS VARCHAR(100)))
	EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Debug', @NAMEOFSPROC = 'SISWEB_OWNER_STAGING._getModifiedRowsPercentage', @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @SISWEB_OWNER_ROWCOUNT;
	
	SET @LOGMESSAGE = FORMATMESSAGE('Row count for SISWEB_OWNER_STAGING_%s', CAST(@SISWEB_OWNER_STAGING_TABLE AS VARCHAR(100)))	
	EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Debug', @NAMEOFSPROC = 'SISWEB_OWNER_STAGING._getModifiedRowsPercentage', @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @SISWEB_OWNER_STAGING_ROWCOUNT;
	
	SET @LOGMESSAGE = FORMATMESSAGE('Row count for EMP_STAGING_%s', CAST(@EMP_STAGING_TABLE AS VARCHAR(100)))	
	EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Debug', @NAMEOFSPROC = 'SISWEB_OWNER_STAGING._getModifiedRowsPercentage', @LOGMESSAGE = @LOGMESSAGE, @DATAVALUE = @EMP_STAGING_ROWCOUNT;
	
	EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Debug', @NAMEOFSPROC = 'SISWEB_OWNER_STAGING._getModifiedRowsPercentage', @LOGMESSAGE = 'Modified Row Percentage ', @DATAVALUE = @MODIFIED_ROWS_PERCENTAGE;
	-- ================================================

	RETURN @MODIFIED_ROWS_PERCENTAGE;
END