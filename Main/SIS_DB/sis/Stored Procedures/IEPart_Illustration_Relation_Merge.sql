-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181002
-- Description: Merge external table [sis_stage].[IEPart_Illustration_Relation] into [sis].[IEPart_Illustration_Relation]
-- =============================================
CREATE PROCEDURE [sis].[IEPart_Illustration_Relation_Merge]
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

MERGE [sis].[IEPart_Illustration_Relation] AS x
USING [sis_stage].[IEPart_Illustration_Relation] AS s
    ON (s.Illustration_Relation_ID = x.Illustration_Relation_ID and s.IEPart_ID = x.IEPart_ID and s.Illustration_ID = x.Illustration_ID)
    WHEN MATCHED AND EXISTS
    (
        SELECT s.Illustration_Relation_ID, s.Illustration_ID, s.IEPart_ID, s.Graphic_Number
        EXCEPT
        SELECT x.Illustration_Relation_ID, x.Illustration_ID, x.IEPart_ID, x.Graphic_Number
    )
    THEN
    UPDATE SET x.Illustration_Relation_ID = s.Illustration_Relation_ID, x.Illustration_ID = s.Illustration_ID, x.IEPart_ID = s.IEPart_ID, x.Graphic_Number = s.Graphic_Number
    WHEN NOT MATCHED BY TARGET
    THEN
    INSERT(Illustration_Relation_ID, Illustration_ID, IEPart_ID, Graphic_Number)
    VALUES (s.Illustration_Relation_ID, s.Illustration_ID, s.IEPart_ID, s.Graphic_Number)
    OUTPUT $ACTION,
        COALESCE(inserted.Illustration_Relation_ID, deleted.Illustration_Relation_ID) Number
        INTO @MERGE_RESULTS;
    SELECT @MERGED_ROWS = @@ROWCOUNT;
    SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
        ,(SELECT MR.ACTIONTYPE
            ,MR.Number
            FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
            ,WITHOUT_ARRAY_WRAPPER),'IE Part Illustration Relation Modified Rows');
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

Update STATISTICS sis.IEPart_Illustration_Relation with fullscan

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

END TRY

BEGIN CATCH

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
DECLARE @ERROELINE INT= ERROR_LINE()

SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

END CATCH

END
