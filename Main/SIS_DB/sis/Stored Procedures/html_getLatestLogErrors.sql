CREATE PROCEDURE sis.html_getLatestLogErrors @HTMLPAYLOAD NVARCHAR(MAX) OUTPUT
AS
BEGIN
	DECLARE @TIME_OFFSET_IN_MINUTES INT = -65;
	DECLARE @HTML NVARCHAR(MAX);
	DECLARE @QUERY NVARCHAR(MAX)= --N'SELECT TOP (5) L.LogDateTime,L.NameofSproc,L.LogMessage FROM sis_stage.Log AS L WHERE         L.LogType = ''Error'' ';
			N'SELECT ''01. sis_stage.Log'' AS Source,L.LogDateTime,L.NameofSproc,L.LogMessage FROM sis_stage.Log AS L WHERE LogDateTime >= DATEADD(minute,' + CAST(
			@TIME_OFFSET_IN_MINUTES AS NVARCHAR(5)) +
			',GETDATE()) AND L.LogType = ''Error'' UNION ALL SELECT ''02. sis.Log'' AS Source,L.LogDateTime,L.NameofSproc,L.LogMessage FROM sis.Log AS L WHERE LogDateTime >= DATEADD(minute,'
			+ CAST(@TIME_OFFSET_IN_MINUTES AS NVARCHAR(5)) +
			',GETDATE()) AND L.LogType = ''Error'' UNION ALL SELECT ''03. SISSEARCH.Log'' AS Source,L.LogDateTime,L.NameofSproc,L.LogMessage FROM SISSEARCH.LOG AS L WHERE LogDateTime >= DATEADD(minute,'
			+ CAST(@TIME_OFFSET_IN_MINUTES AS NVARCHAR(5)) +
			',GETDATE()) AND L.LogType = ''Error'' UNION ALL SELECT ''04. admin.Log'' AS Source,L.LogDateTime,L.NameofSproc,L.LogMessage FROM admin.Log AS L WHERE LogDateTime >= DATEADD(minute,'
			+ CAST(@TIME_OFFSET_IN_MINUTES AS NVARCHAR(5)) + ',GETDATE()) AND L.LogType = ''Error''';
	DECLARE @ORDERBY NVARCHAR(MAX) = N'ORDER BY Source, LogDateTime DESC';
	DECLARE @ROWCOUNT INT;

	PRINT @QUERY;

	CREATE TABLE #I (Source      VARCHAR(50) NOT NULL
					,LogDateTime DATETIME NOT NULL
					,NameofSproc VARCHAR(200) NOT NULL
					,LogMessage  VARCHAR(MAX) NOT NULL);

	INSERT INTO #I
	EXEC (@QUERY);
	IF NOT EXISTS(SELECT 1 FROM #I)
	BEGIN
		SET @HTMLPAYLOAD = NULL;
		RETURN;
	END;

	EXEC sis.html_QueryToHtmlTable @HTML = @HTML OUTPUT,@QUERY = N'select * from #I',@ORDERBY = @ORDERBY;
	SET @HTMLPAYLOAD = @HTML;
	RETURN;
END;