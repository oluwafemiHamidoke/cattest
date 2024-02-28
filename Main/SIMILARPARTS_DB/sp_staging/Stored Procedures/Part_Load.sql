CREATE PROCEDURE [sp_staging].[Part_Load](@DEBUG      BIT = 'FALSE')
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
BEGIN TRY

DECLARE @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
        @MERGED_ROWS  INT  = 0,
		@ProcessID uniqueidentifier = NewID(),
		@LOGMESSAGE VARCHAR(MAX),
        @LastRefresh_Date DATETIME2(7);

EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

DECLARE @MERGE_RESULTS TABLE (
        ACTIONTYPE      NVARCHAR(10),
        Class_ID        VARCHAR(20) NOT NULL,
        Part_ID         VARCHAR(100) NOT NULL
        );

--Fetch LastRefresh_Date from [sp].[Part]
SELECT @LastRefresh_Date = COALESCE(MAX(LastModified_Date),'1900-01-01') FROM [sp].[Part];

If Object_ID('tempdb..#PartSource') is not null Drop table #PartSource

SELECT distinct 
	c.ID AS Part_ID, 
	a.PART_NUMBER as Part_Number,
	b.Class_ID as Class_ID,
	a.REFRESHED_TS as LastModified_Date
	into #PartSource
FROM sp_staging.PART_CLASS a
INNER JOIN [sp].Class b on a.CLASS_ID = b.Class_Number
INNER JOIN sp_staging.PART c on a.PART_NUMBER=c.PART_NUMBER

--Delete Records from sp.Part_Properties for which the Part_ID is going to change to avoid FK Error
DELETE x 
FROM sp.Part_Properties x
	JOIN 
	(
	SELECT x.Part_ID
	FROM sp.Part x
	JOIN  #PartSource s 
	ON s.Part_Number=x.Part_Number 
	AND s.Part_ID!=x.Part_ID
	) ps
	ON x.Part_ID=ps.Part_ID

SELECT @MERGED_ROWS=@@ROWCOUNT

EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Deleted Records from sp.Part_Properties', @DATAVALUE = @MERGED_ROWS;;

--Merge #Part to [sp].Part
MERGE [sp].[Part] AS x USING 
#PartSource s
    ON (s.Part_Number = x.Part_Number)
    WHEN MATCHED AND EXISTS
    (
    SELECT s.Part_ID, s.Class_ID, s.LastModified_Date
    EXCEPT
    SELECT x.Part_ID, x.Class_ID, x.LastModified_Date
    )
    THEN
        UPDATE SET  x.Part_ID = s.Part_ID,
                    x.Class_ID = s.Class_ID,
                    x.LastModified_Date = s.LastModified_Date
    WHEN NOT MATCHED BY TARGET
    THEN
        INSERT (Part_ID, Class_ID, Part_Number, LastModified_Date)
        VALUES (s.Part_ID, s.Class_ID, s.Part_Number, s.LastModified_Date)
    OUTPUT $ACTION,
    COALESCE(inserted.Class_ID, deleted.Class_ID) Class_ID,
    COALESCE(inserted.Part_ID, deleted.Part_ID) Part_ID
    INTO @MERGE_RESULTS;

SELECT @MERGED_ROWS = @@ROWCOUNT;

SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(
    SELECT
        (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,
        (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated,
        (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
        (SELECT MR.ACTIONTYPE, MR.Class_ID, MR.Part_ID FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),'Part Modified Rows');

EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = '[sp].Part Updated', @DATAVALUE = @MERGED_ROWS;;

EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;

END TRY

BEGIN CATCH

	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
			@ERRORLINE INT= ERROR_LINE();

	SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
	EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;

END CATCH

END
