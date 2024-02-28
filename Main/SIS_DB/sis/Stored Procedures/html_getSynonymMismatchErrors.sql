CREATE PROCEDURE [sis].[html_getSynonymMismatchErrors] @HTMLPAYLOAD NVARCHAR(MAX) OUTPUT
AS
BEGIN
	DECLARE @TIME_OFFSET_IN_MINUTES INT = -65;
	DECLARE @HTML NVARCHAR(MAX);
	DECLARE @QUERY NVARCHAR(MAX)=
			N'IF EXISTS
		(
		SELECT A.SYNONYM_SCHEMA,count(*) AS BASEOBJECT_SCHEMA_COUNT FROM 
		(
		select
		distinct
		schema_name(schema_id) AS SYNONYM_SCHEMA, ltrim(rtrim(substring(base_object_name,2,charindex(''].'',base_object_name)-2))) AS BASE_TABLE_SCHEMA
		from sys.synonyms
		) A
		GROUP BY  A.SYNONYM_SCHEMA
		HAVING COUNT(*)>1
		)
		SELECT A.SYNONYM_SCHEMA,A.BASE_TABLE_SCHEMA,A.BASE_TABLE_NAME AS BASE_TABLE_NAME,getdate() LOGDATETIME FROM 
		(
		select
		distinct
		schema_name(schema_id) AS SYNONYM_SCHEMA, base_object_name,ltrim(rtrim(substring(base_object_name,2,charindex(''].'',base_object_name)-2))) AS BASE_TABLE_SCHEMA
		,ltrim(rtrim(
		substring(base_object_name,charindex(''].'',base_object_name)+3,LEN(base_object_name)-charindex(''].'',base_object_name)-3)
		)) AS BASE_TABLE_NAME
		from sys.synonyms
		) A
		';
	DECLARE @ORDERBY NVARCHAR(MAX) = N'ORDER BY SYNONYM_SCHEMA,BASE_TABLE_SCHEMA,BASE_TABLE_NAME';
	DECLARE @ROWCOUNT INT;

	CREATE TABLE #I (SYNONYM_SCHEMA VARCHAR(50) NOT NULL
					,BASE_TABLE_SCHEMA VARCHAR(50) NOT NULL
					,BASE_TABLE_NAME VARCHAR(50) NOT NULL
					,LOGDATETIME DATETIME NOT NULL);

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