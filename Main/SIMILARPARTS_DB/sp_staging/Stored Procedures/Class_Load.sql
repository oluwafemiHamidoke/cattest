CREATE PROCEDURE [sp_staging].[Class_Load](@DEBUG      BIT = 'FALSE')
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
    SET NOCOUNT ON

BEGIN TRY

DECLARE @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
        @MERGED_ROWS  INT  = 0,
		@ProcessID uniqueidentifier = NewID(),
		@LOGMESSAGE VARCHAR(MAX),
		@LastRefresh_Date DATETIME2(7);

EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

DECLARE @MERGE_RESULTS TABLE (
        ACTIONTYPE      NVARCHAR(10),
        Class_Number    VARCHAR(20) NOT NULL,
        Class_Name      VARCHAR(100) NOT NULL
        );

--Fetch LastRefresh_Date
SELECT @LastRefresh_Date = COALESCE(MAX(LastModified_Date),'1900-01-01') FROM [sp].[Class];

--Load temp Table
If Object_ID('tempdb..#Class') is not null Drop table #Class

CREATE TABLE #Class (
	[Class_ID]			INT				PRIMARY KEY,
	[Class_Number]		INT				UNIQUE,
	[Class_Name]		VARCHAR(1000)	NOT NULL,
	[Parent_Class_ID]	INT				NULL,
	[Class_File_Name]	NVARCHAR(200)	NULL,
	[Class_Level]		INT				NOT NULL,
	[Class_Hierarchy]	NVARCHAR(1000)	NULL,
	[Class_Path]		NVARCHAR(1000)	NULL,
	[LastModified_Date] DATETIME2(7)    NOT NULL
	)

--Insert Group Details in #Class
DECLARE @Format_ID      VARCHAR(MAX);
DECLARE @Format_Name    VARCHAR(MAX);
DECLARE @Refreshed_Date DATETIME2(7);
DECLARE db_cursor CURSOR FOR
SELECT Distinct GROUP_ID_PATH, PATH , REFRESHED_TS FROM [sp_staging].PDT WHERE REFRESHED_TS > @LastRefresh_Date

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @Format_ID, @Format_Name, @Refreshed_Date
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
		INSERT INTO #Class(Class_ID, Class_Number, Class_Name, Parent_Class_ID, Class_Level, LastModified_Date)
		SELECT @Group_ID, @Group_ID, @Group_Name, @Parent_ID, @Class_Level, @Refreshed_Date
		Where Not Exists (Select 1 From #Class Where Class_Number = @Group_ID)

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
	Update a
	SET a.Class_Hierarchy = ISNULL(b.Class_Hierarchy, '/') + CAST(a.Class_ID as nvarchar(100)) + '/' ,
		a.Class_Path = iif(ISNULL(b.Class_Path, '') != '', b.Class_Path + '->', '') + a.Class_Name
	From #Class a
	left join #Class b ON a.Parent_Class_ID = b.Class_ID

    FETCH NEXT FROM db_cursor INTO @Format_ID, @Format_Name, @Refreshed_Date
END

CLOSE db_cursor
DEALLOCATE db_cursor

--Insert Class Details in #Class
Insert into #Class (Class_ID, Class_Number, Class_Name, Parent_Class_ID, Class_File_Name, Class_Level, Class_Path, LastModified_Date)
SELECT Distinct
		a.CLASS_IDENTIFIER as Class_ID,
		a.CLASS_IDENTIFIER as Class_Number,
		a.CLASS_NAME as Class_Name,
		b.Class_ID as Parent_Class_ID,
		'c_' + CAST(a.CLASS_IDENTIFIER AS nvarchar) + '_0.png' as Class_File_Name,
		HIERARCHY_LEVEL_INDICATOR + 1 as Class_Level,
		Replace(a.PATH_VALUE + ' / ' + a.CLASS_NAME, ' / ', ' ->') as Class_Path,
		a.REFRESHED_TS as LastModified_Date
FROM sp_staging.[PARTS_HIERARCHY_CLASSIFICATION] a
inner join #Class b on b.Class_Number = a.GROUP_IDENTIFIER
Where a.CLASS_IDENTIFIER NOT IN (Select Class_Number From #Class)
And a.REFRESHED_TS > @LastRefresh_Date

--update Class_Hierarchy
Update a
SET a.Class_Hierarchy = ISNULL(b.Class_Hierarchy, '/') + CAST(a.Class_ID as nvarchar(100)) + '/'
From #Class a
left join #Class b ON a.Parent_Class_ID = b.Class_ID
Where a.Class_Hierarchy IS NULL

--Merge #Class to sp.Class
MERGE sp.Class AS x USING #Class AS s ON (s.Class_Number = x.Class_Number)
    WHEN MATCHED AND EXISTS
    (
    SELECT s.Class_ID, s.Class_Name, s.Parent_Class_ID, s.Class_File_Name, s.Class_Level, s.Class_Hierarchy, s.Class_Path, s.LastModified_Date
    EXCEPT
    SELECT x.Class_ID, x.Class_Name, x.Parent_Class_ID, x.Class_File_Name, x.Class_Level, x.Class_Hierarchy, x.Class_Path, x.LastModified_Date
    )
    THEN
        UPDATE SET  x.Class_Name = s.Class_Name,
                    x.Parent_Class_ID = s.Parent_Class_ID,
                    x.Class_File_Name = s.Class_File_Name,
                    x.Class_Level = s.Class_Level,
                    x.Class_Hierarchy = s.Class_Hierarchy,
                    x.Class_Path = s.Class_Path,
                    x.LastModified_Date = s.LastModified_Date
    WHEN NOT MATCHED BY TARGET
    THEN
        INSERT (Class_ID, Class_Number, Class_Name, Parent_Class_ID, Class_File_Name, Class_Level, Class_Hierarchy, Class_Path, LastModified_Date)
        VALUES (s.Class_ID, s.Class_Number, s.Class_Name, s.Parent_Class_ID, s.Class_File_Name, s.Class_Level, s.Class_Hierarchy, s.Class_Path, s.LastModified_Date)
    OUTPUT $ACTION,
    COALESCE(inserted.Class_Number, deleted.Class_Number) Class_Number,
    COALESCE(inserted.Class_Name, deleted.Class_Name) Class_Name
    INTO @MERGE_RESULTS;

SELECT @MERGED_ROWS = @@ROWCOUNT;

SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(
    SELECT
        (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,
        (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated,
        (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
        (SELECT MR.ACTIONTYPE, MR.Class_Number, MR.Class_Name FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),'Class Modified Rows');

EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'sp.Class Updated', @DATAVALUE = @MERGED_ROWS;;

EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;

END TRY

BEGIN CATCH

	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
			@ERRORLINE INT= ERROR_LINE();

	SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
	EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;

END CATCH

END
