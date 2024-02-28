-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181002
-- Description: Merge external table [sis_stage].[Part_AsShippedEngine_Relation] into [sis].[Part_AsShippedEngine_Relation]
-- =============================================
CREATE PROCEDURE [sis].[Part_AsShippedEngine_Relation_Merge]
(@DEBUG      BIT = 'FALSE')
AS
BEGIN
    SET NOCOUNT ON

BEGIN TRY

DECLARE @MERGED_ROWS                   INT              = 0
       ,@LOGMESSAGE                    VARCHAR(MAX);


Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
Declare @ProcessID uniqueidentifier = NewID()

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

DECLARE @MERGE_RESULTS TABLE
(ACTIONTYPE         NVARCHAR(10)
,Number         VARCHAR(50) NOT NULL
);

MERGE [sis].[Part_AsShippedEngine_Relation] AS x
    USING [sis_stage].[Part_AsShippedEngine_Relation] AS s
    ON (s.AsShippedEngine_ID = x.AsShippedEngine_ID and s.Part_ID = x.Part_ID and s.Sequence_Number = x.Sequence_Number)
    WHEN MATCHED AND EXISTS
    (
    SELECT s.Part_AsShippedEngine_Relation_ID, s.Quantity, s.Change_Level_Number, s.Assembly, s.Less_Indicator, s.Indentation
    EXCEPT
    SELECT x.Part_AsShippedEngine_Relation_ID, x.Quantity, x.Change_Level_Number, x.Assembly, x.Less_Indicator, x.Indentation
    )
    THEN
UPDATE SET x.Part_AsShippedEngine_Relation_ID = s.Part_AsShippedEngine_Relation_ID, x.Quantity = s.Quantity, x.Change_Level_Number = s.Change_Level_Number, x.Assembly = s.Assembly, x.Less_Indicator = s.Less_Indicator, x.Indentation = s.Indentation
    WHEN NOT MATCHED BY TARGET
    THEN
INSERT (Part_AsShippedEngine_Relation_ID, AsShippedEngine_ID, Part_ID, Quantity, Sequence_Number, Change_Level_Number, Assembly, Less_Indicator, Indentation)
VALUES (s.Part_AsShippedEngine_Relation_ID, s.AsShippedEngine_ID, s.Part_ID, s.Quantity, s.Sequence_Number, s.Change_Level_Number, s.Assembly, s.Less_Indicator, s.Indentation)
OUTPUT $ACTION,
    COALESCE(inserted.AsShippedEngine_ID, deleted.AsShippedEngine_ID) Number
INTO @MERGE_RESULTS;

SELECT @MERGED_ROWS = @@ROWCOUNT;

SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT
    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted,
    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated,
    (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted,
    (SELECT MR.ACTIONTYPE, MR.Number FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH, WITHOUT_ARRAY_WRAPPER),'Part AsShippedEngine Relation Modified Rows');
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

Update STATISTICS sis.Part_AsShippedEngine_Relation with fullscan

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

END TRY

BEGIN CATCH

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
DECLARE @ERROELINE INT= ERROR_LINE()

SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

END CATCH

END
