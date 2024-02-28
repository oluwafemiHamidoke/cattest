CREATE PROCEDURE [SISWEB_OWNER_STAGING].[VALIDATE_PERSIST_PERCENT]
AS
BEGIN

	DECLARE	 @PROCESSID				UNIQUEIDENTIFIER	= NEWID()
			,@PROCNAME				VARCHAR(200)		= OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			,@LOGMESSAGE			VARCHAR(MAX)	
			,@Synonym_names			VARCHAR(200)		= 'LNKMEDIAIEPART,LNKPARTSIESNP,LNKIEPSID,LNKCONSISTLIST,LNKIEIMAGE,LNKMEDIAIEPART_SNP_TOPLEVEL,LNKPARTSIESNP_LNKIEPSID_RANGE,LNKPARTSIESNP_LNKIEPSID_NORANGE'
			,@Table_name			VARCHAR(50)
			,@Base_table_with_schema VARCHAR(100)

    SET @LOGMESSAGE = 'Execution started'
   
    EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE =@LOGMESSAGE,@DATAVALUE = NULL

	WHILE len(@Synonym_names) > 0
	BEGIN
		SET @Table_name = LEFT(@Synonym_names, charindex(',', @Synonym_names+',')-1)

		SELECT @Base_table_with_schema = base_object_name 
		FROM sys.synonyms
		WHERE schema_id = SCHEMA_ID('SISWEB_OWNER')
			AND name = @Table_name

		SELECT OBJECT_NAME(ss.object_id) as [table], ss.stats_id, ss.name, filter_definition, last_updated, rows,
		rows_sampled, steps, unfiltered_rows, modification_counter, persisted_sample_percent,
		(rows_sampled * 100)/rows AS sample_percent
		FROM sys.stats ss
		INNER JOIN sys.stats_columns sc
			ON ss.stats_id = sc.stats_id AND ss.object_id = sc.object_id
		INNER JOIN sys.all_columns ac
			ON ac.column_id = sc.column_id AND ac.object_id = sc.object_id
		CROSS APPLY sys.dm_db_stats_properties(ss.object_id, ss.stats_id) shr
		WHERE ss.[object_id] in (OBJECT_ID(@Base_table_with_schema))
			AND persisted_sample_percent < 100

		IF @@ROWCOUNT > 0
		BEGIN
			SET @LOGMESSAGE = 'Persist_sample_percent not 100 for ' + @Base_table_with_schema
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL
		END

		SET @Synonym_names = STUFF(@Synonym_names, 1, CHARINDEX(',', @Synonym_names+','), '')
	END

	--LNKRELATEDPARTIES does not use a synonym so just query it directly
	SELECT OBJECT_NAME(ss.object_id) as [table], ss.stats_id, ss.name, filter_definition, last_updated, rows,
	rows_sampled, steps, unfiltered_rows, modification_counter, persisted_sample_percent,
	(rows_sampled * 100)/rows AS sample_percent
	FROM sys.stats ss
	INNER JOIN sys.stats_columns sc
		ON ss.stats_id = sc.stats_id AND ss.object_id = sc.object_id
	INNER JOIN sys.all_columns ac
		ON ac.column_id = sc.column_id AND ac.object_id = sc.object_id
	CROSS APPLY sys.dm_db_stats_properties(ss.object_id, ss.stats_id) shr
	WHERE ss.[object_id] in (OBJECT_ID('SISWEB_OWNER.LNKRELATEDPARTIES'))
		AND persisted_sample_percent < 100

	IF @@ROWCOUNT > 0
	BEGIN
		SET @LOGMESSAGE = 'Persist_sample_percent not 100 for SISWEB_OWNER.LNKRELATEDPARTIES'
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL
	END

    SET @LOGMESSAGE = 'Execution completed'
   
    EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE =@LOGMESSAGE,@DATAVALUE = NULL

END
