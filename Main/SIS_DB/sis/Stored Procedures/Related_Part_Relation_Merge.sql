-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181002
-- Description: Merge external table [sis_stage].[Related_Part_Relation] into [sis].[Related_Part_Relation]
-- Modified By: Anup Kushwaha
-- Modified Date: 20220930
-- Modified Reason: Added LastModified_Date column to Related_Part_Relation
-- Associated User Story: 22942
-- =============================================
CREATE PROCEDURE [sis].[Related_Part_Relation_Merge]
(@DEBUG      BIT = 'FALSE')
AS
BEGIN
    SET NOCOUNT ON

BEGIN TRY

DECLARE @MERGED_ROWS   INT = 0
       ,@LOGMESSAGE    VARCHAR(MAX);

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
Declare @ProcessID uniqueidentifier = NewID()

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

DECLARE @MERGE_RESULTS TABLE
(ACTIONTYPE     NVARCHAR(10)
,Number         VARCHAR(50) NOT NULL
);

MERGE [sis].[Related_Part_Relation] AS x
    USING [sis_stage].[Related_Part_Relation] AS s
    ON (s.Related_Part_ID = x.Related_Part_ID and s.Part_ID = x.Part_ID and s.Type_Indicator = x.Type_Indicator)
    WHEN MATCHED AND EXISTS
    (
    SELECT s.Related_Part_Relation_ID, s.LastModified_Date, s.Relation_Type
    EXCEPT
    SELECT x.Related_Part_Relation_ID, x.LastModified_Date, x.Relation_Type
    )
    THEN
UPDATE SET x.Related_Part_Relation_ID = s.Related_Part_Relation_ID, x.Relation_Type = s.Relation_Type,
    x.LastModified_Date = s.LastModified_Date
    WHEN NOT MATCHED BY TARGET
    THEN
INSERT (Related_Part_Relation_ID, Related_Part_ID, Part_ID, Type_Indicator, Relation_Type, LastModified_Date)
VALUES (s.Related_Part_Relation_ID, s.Related_Part_ID, s.Part_ID, s.Type_Indicator , s.Relation_Type, s.LastModified_Date)
    OUTPUT $ACTION,
    COALESCE(inserted.Related_Part_ID, deleted.Related_Part_ID) Number
INTO @MERGE_RESULTS;

SELECT @MERGED_ROWS = @@ROWCOUNT;

SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT
    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
   ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
   ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
   ,(SELECT MR.ACTIONTYPE, MR.Number FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows
   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),'Related Product Relation Modified Rows');

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

Update STATISTICS sis.Related_Part_Relation with fullscan

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

END TRY

BEGIN CATCH

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
DECLARE @ERROELINE INT= ERROR_LINE()

SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

END CATCH

END
