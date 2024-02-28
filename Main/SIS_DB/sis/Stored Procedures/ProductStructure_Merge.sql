
-- =============================================
-- Author:      Paul B. Felix (Modifications by Davide M.)
-- Create Date: 20181002
-- Modify Date: 20200325 Added [Parentage], [MiscSpnIndicator] see https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/5988/
-- Description: Merge external table [sis_stage].[ProductStructure] into [sis].[ProductStructure]
-- =============================================
CREATE PROCEDURE [sis].[ProductStructure_Merge]
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

MERGE [sis].[ProductStructure] AS x
    USING [sis_stage].[ProductStructure] AS s
    ON (s.ProductStructure_ID = x.ProductStructure_ID)
    WHEN MATCHED AND EXISTS
    (
    SELECT s.ParentProductStructure_ID, s.Parentage, s.MiscSpnIndicator
    EXCEPT
    SELECT x.ParentProductStructure_ID, x.Parentage, x.MiscSpnIndicator
    )
    THEN
        UPDATE SET 
                x.ParentProductStructure_ID = s.ParentProductStructure_ID, 
                x.Parentage = s.Parentage, 
                x.MiscSpnIndicator = s.MiscSpnIndicator,
                x.LastModified_Date = GETDATE()
    WHEN NOT MATCHED BY TARGET
    THEN
INSERT (ProductStructure_ID, ParentProductStructure_ID, Parentage, MiscSpnIndicator, LastModified_Date)
VALUES (s.ProductStructure_ID, s.ParentProductStructure_ID, s.Parentage, s.MiscSpnIndicator, GETDATE())
    OUTPUT $ACTION,
    COALESCE(inserted.ProductStructure_ID, deleted.ProductStructure_ID) Number
INTO @MERGE_RESULTS;

SELECT @MERGED_ROWS = @@ROWCOUNT;

SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
													,(SELECT MR.ACTIONTYPE
															,MR.Number
														FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
														,WITHOUT_ARRAY_WRAPPER),'Product Structure Modified Rows');
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

Update STATISTICS sis.ProductStructure with fullscan

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

END TRY

BEGIN CATCH

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
DECLARE @ERROELINE INT= ERROR_LINE()

SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

END CATCH

END
