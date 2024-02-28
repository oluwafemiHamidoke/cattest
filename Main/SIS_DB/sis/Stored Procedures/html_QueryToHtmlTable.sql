
-- Modified from an original found here: https://stackoverflow.com/questions/7070053/convert-a-sql-query-result-table-to-an-html-table-for-email/14854865
-- Description: Turns a query into a formatted HTML table. Useful for emails. 
-- Any ORDER BY clause needs to be passed in the separate ORDER BY parameter.
-- =============================================
CREATE PROC [sis].[html_QueryToHtmlTable]
	(@QUERY   NVARCHAR(MAX) --A query to turn into HTML format. It should not include an ORDER BY clause.
	,@ORDERBY NVARCHAR(MAX) = NULL --An optional ORDER BY clause. It should contain the words 'ORDER BY'.
	,@HTML    NVARCHAR(MAX) = NULL OUTPUT --The HTML output of the procedure.
)
AS
	BEGIN
		SET NOCOUNT ON;

		IF @ORDERBY IS NULL
			BEGIN
				SET @ORDERBY = N'';
		END;

		SET @ORDERBY = REPLACE(@ORDERBY,N'''',N'''''');

		DECLARE @REALQUERY NVARCHAR(MAX) = N'
    DECLARE @headerRow nvarchar(MAX);
    DECLARE @cols nvarchar(MAX); 
	DECLARE @beginhtml nvarchar(MAX);
	DECLARE @endhtml nvarchar(MAX);   

    SELECT * INTO #dynSql FROM (' + @QUERY + ') sub;

    SELECT @cols = COALESCE(@cols + N'', N'''''''', '', N'''') + N''['' + name + N''] AS ''''td''''''
    FROM tempdb.sys.columns 
    WHERE object_id = object_id(''tempdb..#dynSql'')
    ORDER BY column_id;

    SET @cols = N''SET @html = CAST(( SELECT '' + @cols + '' FROM #dynSql ' + @ORDERBY + ' FOR XML PATH(''''tr''''), ELEMENTS ) AS nvarchar(max))''    

    EXEC sys.sp_executesql @cols, N''@html nvarchar(MAX) OUTPUT'', @html=@html OUTPUT

    SELECT @headerRow = COALESCE(@headerRow + N'''', N'''') + N''<th>'' + name + N''</th>'' 
    FROM tempdb.sys.columns 
    WHERE object_id = object_id(''tempdb..#dynSql'')
    ORDER BY column_id;

	SET @beginhtml = N''<!DOCTYPE html><html><head><title>Generated from SQL Server</title><style>table.log{font-family:Arial,Helvetica,sans-serif;border:1px solid #b4b4b4;width:100%;text-align:left;border-collapse:collapse}table.log td,table.log th{border:1px solid #b4b4b4;padding:5px 4px}table.log tbody td{font-size:13px}table.log thead{background:#cfcfcf}table.log thead th{font-size:15px;font-weight:400;color:#4c4c4c;text-align:left;border-left:0 solid #d0e4f5}table.log thead th:first-child{border-left:none}table.log tfoot td{font-size:14px}</style></head><body>'';
	SET @endhtml = N''</body></html>'';
    SET @headerRow = N''<thead><tr>'' + @headerRow + N''</tr></thead>'';

    SET @html = @beginhtml + N''<table class="log">'' + @headerRow + @html + N''</table>'' +@endhtml;    
    ';

		EXEC sys.sp_executesql @REALQUERY
							  ,N'@html nvarchar(MAX) OUTPUT'
							  ,@HTML = @HTML OUTPUT;
	END;