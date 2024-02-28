
CREATE PROCEDURE dbo.FlushAndSavePoorPlans (@MAXLOGICALREADS    BIGINT = 0
										  ,@MAXCPUMILLISECONDS BIGINT = 0) 
AS
BEGIN

	DECLARE @HANDLE                 VARBINARY(64)
		   ,@QUERY_HASH             BINARY(8)
		   ,@PLAN                   XML
		   ,@CPU_TIME               INT
		   ,@LOGICAL_READS          BIGINT
		   ,@SQL_TEXT               VARCHAR(MAX)
		   ,@STATEMENT_START_OFFSET INT
		   ,@STATEMENT_END_OFFSET   INT;

	IF EXISTS(SELECT 1 FROM sys.tables WHERE name = '#FlushedQueryPlans')

	BEGIN

		DROP TABLE #FlushedQueryPlans;
	END;

	CREATE TABLE #FlushedQueryPlans ([plan]                 XML
									,query_hash             CHAR(8)
									,cpu_time               INT
									,logical_reads          BIGINT
									,sql_text               VARCHAR(MAX)
									,statement_start_offset INT
									,statement_end_offset   INT
									,server_name            VARCHAR(255)
									,collection_time        DATETIME NOT NULL) 
	ON [PRIMARY];

	DECLARE plan_cursor CURSOR
	FOR SELECT plan_handle,query_hash,cpu_time,logical_reads,st.text,statement_start_offset,statement_end_offset
		FROM sys.dm_exec_requests
			 CROSS APPLY sys.dm_exec_sql_text (sql_handle) AS st
		WHERE logical_reads > @MAXLOGICALREADS AND 
			  cpu_time > @MAXCPUMILLISECONDS AND 
			  session_id <> @@SPID;

	OPEN plan_cursor;

	FETCH NEXT FROM plan_cursor INTO @HANDLE
									,@QUERY_HASH
									,@CPU_TIME
									,@LOGICAL_READS
									,@SQL_TEXT
									,@STATEMENT_START_OFFSET
									,@STATEMENT_START_OFFSET;

	WHILE @@FETCH_STATUS = 0

	BEGIN

		set @PLAN = NULL;

		SELECT @PLAN = query_plan FROM sys.dm_exec_query_plan (@HANDLE);

		INSERT INTO #FlushedQueryPlans
		VALUES (@PLAN,CAST(@QUERY_HASH AS CHAR(8)),@CPU_TIME,@LOGICAL_READS,@SQL_TEXT,@STATEMENT_START_OFFSET,@STATEMENT_END_OFFSET,@@SERVERNAME,GETDATE());

		DBCC FREEPROCCACHE(@HANDLE);

		FETCH NEXT FROM plan_cursor INTO @HANDLE
										,@QUERY_HASH
										,@CPU_TIME
										,@LOGICAL_READS
										,@SQL_TEXT
										,@STATEMENT_START_OFFSET
										,@STATEMENT_START_OFFSET;
	END;

	CLOSE plan_cursor;

	DEALLOCATE plan_cursor;

	SELECT * FROM #FlushedQueryPlans;
END;