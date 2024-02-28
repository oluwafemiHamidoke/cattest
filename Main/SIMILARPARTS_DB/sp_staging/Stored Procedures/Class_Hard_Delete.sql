CREATE PROCEDURE [sp_staging].[Class_Hard_Delete]
AS
BEGIN

SET NOCOUNT ON

BEGIN TRY

	DECLARE @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
		  @MERGED_ROWS  INT  = 0,
			@ProcessID uniqueidentifier = NewID(),
			@LOGMESSAGE VARCHAR(MAX),
			@LastRefresh_Date DATETIME2(7);

	EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

	IF Object_ID('tempdb..#Class') is not null Drop table #Class

	CREATE TABLE #Class (
		[Class_ID]			INT				PRIMARY KEY,
		[Class_Number]		INT				UNIQUE,
		[Class_Name]		VARCHAR(1000)	NOT NULL,
		[Parent_Class_ID]	INT				NULL,
		[Class_File_Name]	NVARCHAR(200)	NULL,
		[Class_Level]		INT				NOT NULL,
		[Class_Hierarchy]	NVARCHAR(1000)	NULL,
		[Class_Path]		NVARCHAR(1000)	NULL
		)

	DECLARE @Format_ID      VARCHAR(MAX);
	DECLARE @Format_Name    VARCHAR(MAX);

	DECLARE db_cursor CURSOR FOR
	SELECT DISTINCT GROUP_ID_PATH, PATH  FROM [sp_staging].PDT

	OPEN db_cursor
	FETCH NEXT FROM db_cursor INTO @Format_ID, @Format_Name
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @Group_ID INT
		DECLARE @Group_Name VARCHAR(MAX)

		DECLARE @Class_Level INT
		DECLARE @Parent_ID INT
		SET @Class_Level = 1
		SET @Parent_ID  = NULL

		--- internal cursor starts
		DECLARE db_internal_cursor1 CURSOR FOR
		SELECT value FROM STRING_SPLIT(@Format_ID, '/');

		OPEN db_internal_cursor1
		FETCH NEXT FROM db_internal_cursor1 INTO @Group_ID

			DECLARE db_internal_cursor2 CURSOR FOR
			SELECT TRIM(value) FROM STRING_SPLIT(@Format_Name, '/');

			OPEN db_internal_cursor2
			FETCH NEXT FROM db_internal_cursor2 INTO @Group_Name

				WHILE @@FETCH_STATUS = 0
				BEGIN
					INSERT INTO #Class(Class_ID, Class_Number, Class_Name, Parent_Class_ID, Class_Level)
					SELECT @Group_ID, @Group_ID, @Group_Name, @Parent_ID, @Class_Level
					WHERE Not Exists (SELECT 1 FROM #Class WHERE Class_Number = @Group_ID)

					SELECT @Parent_ID = Class_ID FROM #Class WHERE Class_Number = @Group_ID
					SET @Class_Level = @Class_Level + 1
					FETCH NEXT FROM db_internal_cursor1 INTO @Group_ID
					FETCH NEXT FROM db_internal_cursor2 INTO @Group_Name
				END

			CLOSE db_internal_cursor2
			DEALLOCATE db_internal_cursor2
		CLOSE db_internal_cursor1
		DEALLOCATE db_internal_cursor1

		--- internal cursor ends

		--update Class_Hierarchy
		UPDATE a
		SET a.Class_Hierarchy = ISNULL(b.Class_Hierarchy, '/') + CAST(a.Class_ID AS NVARCHAR(100)) + '/' ,
			a.Class_Path = iif(ISNULL(b.Class_Path, '') != '', b.Class_Path + '->', '') + a.Class_Name
		FROM #Class a
		LEFT JOIN #Class b ON a.Parent_Class_ID = b.Class_ID

	    FETCH NEXT FROM db_cursor INTO @Format_ID, @Format_Name 
	END

	CLOSE db_cursor
	DEALLOCATE db_cursor

	--Insert Class Details in #Class
	INSERT INTO #Class (Class_ID, Class_Number, Class_Name, Parent_Class_ID, Class_File_Name, Class_Level, Class_Path)
	SELECT DISTINCT
			a.CLASS_IDENTIFIER AS Class_ID,
			a.CLASS_IDENTIFIER AS Class_Number,
			a.CLASS_NAME AS Class_Name,
			b.Class_ID AS Parent_Class_ID,
			'c_' + CAST(a.CLASS_IDENTIFIER AS NVARCHAR) + '_0.png' as Class_File_Name,
			HIERARCHY_LEVEL_INDICATOR + 1 AS Class_Level,
			REPLACE(a.PATH_VALUE + ' / ' + a.CLASS_NAME, ' / ', ' ->') as Class_Path
		FROM sp_staging.[PARTS_HIERARCHY_CLASSIFICATION] a
		INNER JOIN #Class b ON b.Class_Number = a.GROUP_IDENTIFIER
		WHERE a.CLASS_IDENTIFIER NOT IN (SELECT Class_Number FROM #Class)

	--update Class_Hierarchy
	UPDATE a
	SET a.Class_Hierarchy = ISNULL(b.Class_Hierarchy, '/') + CAST(a.Class_ID AS NVARCHAR(100)) + '/'
	FROM #Class a
	LEFT JOIN #Class b ON a.Parent_Class_ID = b.Class_ID
	WHERE a.Class_Hierarchy IS NULL

	--Delete Step for sp.Class Hard_Delete
	DELETE x
	FROM sp.Class x
	LEFT JOIN #Class s
	ON s.Class_Number = x.Class_Number
	WHERE s.Class_Number IS NULL 


	EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;

END TRY

BEGIN CATCH

	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
			@ERRORLINE INT= ERROR_LINE();

	SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
	EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;

END CATCH

END
