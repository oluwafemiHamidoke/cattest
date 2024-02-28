-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181002
-- Description: Merge external table [sis_stage].[Illustration] into [sis].[Illustration]
-- =============================================
CREATE PROCEDURE [sis].[Illustration_Merge]
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

MERGE [sis].[Illustration] AS x
    USING [sis_stage].[Illustration] AS s
    ON (s.Graphic_Control_Number = x.Graphic_Control_Number)
    WHEN MATCHED AND EXISTS
    (
    SELECT s.Illustration_ID
    EXCEPT
    SELECT x.Illustration_ID
    )
    THEN
UPDATE SET x.Illustration_ID = s.Illustration_ID
    WHEN NOT MATCHED BY TARGET
    THEN
INSERT(Illustration_ID, Graphic_Control_Number)
VALUES(s.Illustration_ID, s.Graphic_Control_Number)
    OUTPUT $ACTION,
    COALESCE(inserted.Graphic_Control_Number, deleted.Graphic_Control_Number) Number
INTO @MERGE_RESULTS;
SELECT @MERGED_ROWS = @@ROWCOUNT;
SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
        ,(SELECT MR.ACTIONTYPE
            ,MR.Number
            FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
            ,WITHOUT_ARRAY_WRAPPER),'Illustration Modified Rows');

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

Update STATISTICS sis.Illustration with fullscan

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

END TRY

BEGIN CATCH

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
DECLARE @ERROELINE INT= ERROR_LINE()

SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

END CATCH

END
