CREATE PROCEDURE [sp_staging].[Class_Attribute_Relation_Load](@DEBUG      BIT = 'FALSE')
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
        Attribute_ID    VARCHAR(20) NOT NULL
        );

--Fetch LastRefresh_Date
SELECT @LastRefresh_Date = COALESCE(MAX(LastModified_Date),'1900-01-01') FROM [sp].[Class_Attribute_Relation];

--Load
If Object_ID('tempdb..#ClassAttributeRelation') is not null Drop table #ClassAttributeRelation

CREATE TABLE #ClassAttributeRelation (
	[Class_ID]          INT             NOT NULL,
	[Attribute_ID]      INT             NOT NULL,
	[LastModified_Date] DATETIME2(7)    NOT NULL,
	CONSTRAINT [PK_ClassAttributeRelationTemp] PRIMARY KEY CLUSTERED ([Class_ID] ASC, [Attribute_ID] ASC)
	)

Insert into #ClassAttributeRelation ([Class_ID], [Attribute_ID], [LastModified_Date])
Select Distinct c.Class_ID as Class_ID,
	b.Attribute_ID as Attribute_ID,
	a.REFRESHED_TS as LastModified_Date
From [sp_staging].[CLASS_ATTRIBUTES] a
inner join sp.Attribute b on b.Attribute_Number = a.ATTRIBUTE_ID
inner join sp.Class c on c.Class_Number = a.CLASS_ID
Where a.REFRESHED_TS > @LastRefresh_Date

--Merge #ClassAttributeRelation to sp.Class_Attribute_Relation
MERGE sp.Class_Attribute_Relation AS x USING #ClassAttributeRelation AS s
    ON (s.Class_ID = x.Class_ID AND
        s.Attribute_ID = x.Attribute_ID)
    WHEN MATCHED AND EXISTS
    (
    SELECT s.Class_ID, s.Attribute_ID, s.LastModified_Date
    EXCEPT
    SELECT x.Class_ID, x.Attribute_ID, x.LastModified_Date
    )
    THEN
        UPDATE SET  x.Class_ID = s.Class_ID,
                    x.Attribute_ID = s.Attribute_ID,
                    x.LastModified_Date = s.LastModified_Date
    WHEN NOT MATCHED BY TARGET
    THEN
        INSERT (Class_ID, Attribute_ID, LastModified_Date)
        VALUES (s.Class_ID, s.Attribute_ID, s.LastModified_Date)
    OUTPUT $ACTION,
    COALESCE(inserted.Class_ID, deleted.Class_ID) Class_ID,
    COALESCE(inserted.Attribute_ID, deleted.Attribute_ID) Attribute_ID
    INTO @MERGE_RESULTS;

SELECT @MERGED_ROWS = @@ROWCOUNT;

SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(
    SELECT
        (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,
        (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated,
        (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
        (SELECT MR.ACTIONTYPE, MR.Class_ID, MR.Attribute_ID FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ),'Class_Attribute_Relation Modified Rows');

EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'sp.Class_Attribute_Relation Updated', @DATAVALUE = @MERGED_ROWS;;

EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;

END TRY

BEGIN CATCH

	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
			@ERRORLINE INT= ERROR_LINE();

	SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
	EXEC sp_staging.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;

END CATCH

END