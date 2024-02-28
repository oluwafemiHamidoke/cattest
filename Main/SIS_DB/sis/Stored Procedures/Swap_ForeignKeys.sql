CREATE PROCEDURE [sis].[Swap_ForeignKeys] (
	@SchemaName_old NVARCHAR(500)
	,@TableName_old NVARCHAR(500)
	,@SchemaName_new NVARCHAR(500)
	,@TableName_new NVARCHAR(500)
	)
AS
BEGIN
	SET XACT_ABORT
		,NOCOUNT ON;

	BEGIN TRY
		DECLARE @sql_drop_fks NVARCHAR(max)
			,@sql_create_fks NVARCHAR(max)
			,@AFFECTED_ROWS INT = 0
			,@LOGMESSAGE VARCHAR(MAX)
			,@ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			,@ProcessID UNIQUEIDENTIFIER = NEWID()
			,@DEFAULT_ORGCODE VARCHAR(12) = SISWEB_OWNER_STAGING._getDefaultORGCODE();

		----From
		--Declare @SchemaName_old nvarchar(500) = 'sis_shadow'
		--Declare @TableName_old nvarchar(500) = 'MediaSequence_Base'
		----To
		--Declare @SchemaName_new nvarchar(500) = 'sis'
		--Declare @TableName_new nvarchar(500) = 'MediaSequence_Base'
		EXEC sis.WriteLog @PROCESSID = @ProcessID
			,@LOGTYPE = 'Information'
			,@NAMEOFSPROC = @ProcName
			,@LOGMESSAGE = 'Execution started'
			,@DATAVALUE = NULL;

		BEGIN TRANSACTION;

			-- Generate SQL to Drop Foreign Keys
			SELECT @sql_drop_fks = STRING_AGG('ALTER TABLE [' + SCHEMA_NAME(t_parent.schema_id) + '].[' + t_parent.name + '] DROP CONSTRAINT [' + fk.name + '];' + CHAR(13), ';')
			FROM sys.foreign_keys fk
			INNER JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
			INNER JOIN sys.tables t_parent ON t_parent.object_id = fk.parent_object_id
			INNER JOIN sys.columns c_parent ON fkc.parent_column_id = c_parent.column_id
				AND c_parent.object_id = t_parent.object_id
			INNER JOIN sys.tables t_child ON t_child.object_id = fk.referenced_object_id
			INNER JOIN sys.columns c_child ON c_child.object_id = t_child.object_id
				AND fkc.referenced_column_id = c_child.column_id
			WHERE SCHEMA_NAME(t_child.schema_id) = @SchemaName_old
				AND t_child.name = @TableName_old

			-- Generate SQL to Create Foreign Keys
			SELECT @sql_create_fks = STRING_AGG('ALTER TABLE [' + SCHEMA_NAME(t_parent.schema_id) + '].[' + t_parent.name + ']  WITH CHECK ADD  CONSTRAINT [' + fk.name + '] FOREIGN KEY([' + c_parent.name + '])' + CHAR(13) + 'REFERENCES [' + @SchemaName_new + '].[' + @TableName_new + '] ([' + c_parent.name + ']) ;' + CHAR(13), ';')
			FROM sys.foreign_keys fk
			INNER JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
			INNER JOIN sys.tables t_parent ON t_parent.object_id = fk.parent_object_id
			INNER JOIN sys.columns c_parent ON fkc.parent_column_id = c_parent.column_id
				AND c_parent.object_id = t_parent.object_id
			INNER JOIN sys.tables t_child ON t_child.object_id = fk.referenced_object_id
			INNER JOIN sys.columns c_child ON c_child.object_id = t_child.object_id
				AND fkc.referenced_column_id = c_child.column_id
			WHERE SCHEMA_NAME(t_child.schema_id) = @SchemaName_old
				AND t_child.name = @TableName_old

			EXECUTE sp_executesql @sql_drop_fks

			EXEC sis.WriteLog @PROCESSID = @ProcessID
				,@LOGTYPE = 'Information'
				,@NAMEOFSPROC = @ProcName
				,@LOGMESSAGE = 'Dropped Foreign Keys on old table'
				,@DATAVALUE = @AFFECTED_ROWS;

			EXECUTE sp_executesql @sql_create_fks

			EXEC sis.WriteLog @PROCESSID = @ProcessID
				,@LOGTYPE = 'Information'
				,@NAMEOFSPROC = @ProcName
				,@LOGMESSAGE = 'Created Foreign Keys on new table'
				,@DATAVALUE = @AFFECTED_ROWS;

		COMMIT;

		EXEC sis.WriteLog @PROCESSID = @ProcessID
			,@LOGTYPE = 'Information'
			,@NAMEOFSPROC = @ProcName
			,@LOGMESSAGE = 'Execution Completed'
			,@DATAVALUE = NULL;
	END TRY

	BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
			,@ERRORLINE INT = ERROR_LINE();

		SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s', CAST(@ERRORLINE AS VARCHAR(10)), CAST(@ERRORMESSAGE AS VARCHAR(4000)));

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		EXEC sis.WriteLog @PROCESSID = @ProcessID
			,@LOGTYPE = 'Error'
			,@NAMEOFSPROC = @ProcName
			,@LOGMESSAGE = @LOGMESSAGE
			,@DATAVALUE = NULL;

		RAISERROR (
				@LOGMESSAGE
				,17
				,1
				)
		WITH NOWAIT;
	END CATCH
END
GO