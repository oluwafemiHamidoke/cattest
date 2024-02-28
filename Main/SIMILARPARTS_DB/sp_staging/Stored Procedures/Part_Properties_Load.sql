CREATE PROCEDURE [sp_staging].[Part_Properties_Load](@DEBUG      BIT = 'FALSE')
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
        Part_ID        VARCHAR(20) NOT NULL,
        Attribute_ID   VARCHAR(20) NOT NULL
        );

--Fetch LastRefresh_Date
SELECT @LastRefresh_Date = COALESCE(MAX(LastModified_Date),'1900-01-01') FROM [sp].[Part_Properties];

--Load
If Object_ID('tempdb..#PartProperties') is not null Drop table #PartProperties

CREATE TABLE #PartProperties (
	[Part_ID]           INT             NOT NULL,
	[Attribute_ID]      INT             NOT NULL,
	[Property_Value]    VARCHAR(1000)   NULL,
	[LastModified_Date] DATETIME2(7)    NOT NULL,
	CONSTRAINT [PK_PartPropertiesTemp] PRIMARY KEY CLUSTERED ([Part_ID] ASC, [Attribute_ID] ASC)
	)

DROP TABLE IF EXISTS #PartSource

SELECT DISTINCT 
		c.ID AS Part_ID, 
		a.PART_NUMBER AS Part_Number,
		b.Class_ID AS Class_ID,
		a.REFRESHED_TS AS LastModified_Date
		INTO #PartSource
	FROM sp_staging.PART_CLASS a
	inner join [sp].Class b ON a.CLASS_ID = b.Class_Number
	inner join sp_staging.PART c ON a.PART_NUMBER=c.PART_NUMBER
	

--Insert Part Properties in #PartProperties without REFRESHED_TS where clause to re-load any sp.Part_Properties records dropped to avoid FK errors in Part_Load
INSERT INTO #PartProperties ([Part_ID], [Attribute_ID], [Property_Value], [LastModified_Date])
SELECT DISTINCT 
		c.Part_ID AS Part_ID,
		d.Attribute_ID AS Attribute_ID,
		a.VALUE AS Property_Value,
		a.REFRESHED_TS AS LastModified_Date
	FROM sp_staging.PART_ATTRIBUTES a
	inner join sp_staging.PART b ON b.ID = a.PART_ID
	inner join [sp].Part c ON c.Part_Number = b.PART_NUMBER
	inner join [sp].Attribute d ON d.Attribute_Number = a.ATTRIBUTE_ID
	inner join #PartSource s ON c.Part_ID=s.Part_ID

--Merge #PartProperties to [sp].Part_Properties
MERGE [sp].Part_Properties AS x USING #PartProperties AS s
    ON (s.Part_ID = x.Part_ID AND
        s.Attribute_ID = x.Attribute_ID)
    WHEN MATCHED AND EXISTS
    (
    SELECT s.Part_ID, s.Attribute_ID, s.Property_Value, s.LastModified_Date
    EXCEPT
    SELECT x.Part_ID, x.Attribute_ID, x.Property_Value, x.LastModified_Date
    )
    THEN
        UPDATE SET  x.Part_ID = s.Part_ID,
                    x.Attribute_ID = s.Attribute_ID,
                    x.Property_Value = s.Property_Value,
                    x.LastModified_Date = s.LastModified_Date
    WHEN NOT MATCHED BY TARGET
    THEN
        INSERT (Part_ID, Attribute_ID, Property_Value, LastModified_Date)
        VALUES (s.Part_ID, s.Attribute_ID, s.Property_Value, s.LastModified_Date)
    WHEN NOT MATCHED BY SOURCE
    THEN DELETE
    OUTPUT $ACTION,
    COALESCE(inserted.Part_ID, deleted.Part_ID) Part_ID,
    COALESCE(inserted.Attribute_ID, deleted.Attribute_ID) Attribute_ID
    INTO @MERGE_RESULTS;

SELECT @MERGED_ROWS = @@ROWCOUNT;

SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(
    SELECT
        (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,
        (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated,
        (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
        (SELECT MR.ACTIONTYPE, MR.Part_ID, MR.Attribute_ID FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),'Part_Properties Modified Rows');

EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = '[sp].Part_Properties Updated', @DATAVALUE = @MERGED_ROWS;;

EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;

END TRY

BEGIN CATCH

	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
			@ERRORLINE INT= ERROR_LINE();

	SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
	EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;

END CATCH

END
