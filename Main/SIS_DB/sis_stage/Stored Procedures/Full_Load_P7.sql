
-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20200111
-- Description: Execute remote sprocs to update statistics
/*
Exec [sis_stage].Full_Load_P7
*/
-- =============================================
CREATE PROCEDURE sis_stage.Full_Load_P7 (@FORCE_LOAD BIT = 'FALSE'
									   ,@DEBUG      BIT = 'FALSE') 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @PROCNAME    VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
		   ,@PROCESSID   UNIQUEIDENTIFIER = NEWID()
		   ,@LOGMESSAGE  VARCHAR(MAX)
		   ,@TABLESCHEMA NVARCHAR(128)
		   ,@TABLENAME   NVARCHAR(128)
		   ,@STATEMENT   NVARCHAR(300);

	EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

	BEGIN TRY

		DELETE FROM util.CommandLog WHERE CommandLog.StartTime <= GETDATE() - 90;

		IF @FORCE_LOAD = 'FALSE'
		BEGIN
			DECLARE updatestats CURSOR
			FOR SELECT DISTINCT 
					   sch.name AS TABLE_SCHEMA,o.name AS TABLE_NAME
				FROM sys.stats AS s
					 INNER JOIN sys.stats_columns AS sc ON s.stats_id = sc.stats_id AND 
														   s.object_id = sc.object_id
					 INNER JOIN sys.columns AS c ON c.object_id = sc.object_id AND 
													c.column_id = sc.column_id
					 INNER JOIN sys.objects AS o ON s.object_id = o.object_id
					 INNER JOIN sys.schemas AS sch ON o.schema_id = sch.schema_id
					 OUTER APPLY sys.dm_db_stats_properties (s.object_id,s.stats_id) AS sp
				WHERE o.type IN ('V','U') AND 
					  sch.name NOT IN ('dbo','sys','bailu','util','sis_stage','SISWEB_OWNER_STAGING','SISWEB_OWNER_SHADOW','SISWEB_OWNER_SWAP') AND 
					  (sp.rows > sp.rows_sampled OR 
					   sp.modification_counter > 0
					  );

			OPEN updatestats;

			FETCH NEXT FROM updatestats INTO @TABLESCHEMA
											,@TABLENAME;
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @STATEMENT = 'UPDATE STATISTICS ' + '[' + @TABLESCHEMA + ']' + '.' + '[' + @TABLENAME + ']' + ' WITH FULLSCAN';

				IF @DEBUG = 'TRUE'
					PRINT @STATEMENT;--,0,1) WITH NOWAIT;
				EXEC sp_executesql @STATEMENT;

				FETCH NEXT FROM updatestats INTO @TABLESCHEMA
												,@TABLENAME;
			END;

			CLOSE updatestats;
			DEALLOCATE updatestats;
		END;

		IF @FORCE_LOAD = 'TRUE'
		BEGIN

			DECLARE updatestats CURSOR
			FOR SELECT TABLE_SCHEMA,TABLE_NAME
				FROM INFORMATION_SCHEMA.TABLES
				WHERE TABLE_TYPE = 'BASE TABLE' AND 
					  TABLE_SCHEMA IN ('sis','SISWEB_OWNER')
				ORDER BY TABLE_SCHEMA,TABLE_NAME;

			OPEN updatestats;

			FETCH NEXT FROM updatestats INTO @TABLESCHEMA
											,@TABLENAME;
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @STATEMENT = 'UPDATE STATISTICS ' + '[' + @TABLESCHEMA + ']' + '.' + '[' + @TABLENAME + ']' + ' WITH FULLSCAN';

				RAISERROR(@STATEMENT,0,1) WITH NOWAIT;
				EXEC sp_executesql @STATEMENT;

				FETCH NEXT FROM updatestats INTO @TABLESCHEMA
												,@TABLENAME;
			END;

			CLOSE updatestats;
			DEALLOCATE updatestats;
		END;

		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;
	END TRY
	BEGIN CATCH

		DECLARE @ERRORMESSAGE  NVARCHAR(4000) = ERROR_MESSAGE()
			   ,@ERRORLINE     INT            = ERROR_LINE()
			   ,@ERRORSEVERITY INT            = ERROR_SEVERITY()
			   ,@ERRORSTATE    INT            = ERROR_STATE()
			   ,@ERRORNUM      INT            = ERROR_NUMBER();

		SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @ERRORNUM;

		RAISERROR(@ERRORMESSAGE, -- Message text.  
		@ERRORSEVERITY, -- Severity.  
		@ERRORSTATE -- State.  
		);
	END CATCH;
END;