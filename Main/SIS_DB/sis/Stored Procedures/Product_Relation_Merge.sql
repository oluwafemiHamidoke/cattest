-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181002
-- Description: Merge external table [sis_stage].[Product_Relation] into [sis].[Product_Relation]
-- =============================================
CREATE PROCEDURE [sis].[Product_Relation_Merge]
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

MERGE [sis].[Product_Relation] AS x
    USING [sis_stage].[Product_Relation] AS s
    ON (s.SerialNumberPrefix_ID = x.SerialNumberPrefix_ID and s.SalesModel_ID = x.SalesModel_ID and s.ProductSubfamily_ID = x.ProductSubfamily_ID and s.ProductFamily_ID = x.ProductFamily_ID)
    WHEN MATCHED AND EXISTS
    (
    SELECT s.Shipped_Date
    EXCEPT
    SELECT x.Shipped_Date
    )
    THEN
UPDATE SET x.Shipped_Date = s.Shipped_Date
    WHEN NOT MATCHED BY TARGET
    THEN
INSERT (SerialNumberPrefix_ID, SalesModel_ID, ProductSubfamily_ID, ProductFamily_ID, Shipped_Date)
VALUES (s.SerialNumberPrefix_ID, s.SalesModel_ID, s.ProductSubfamily_ID, s.ProductFamily_ID, s.Shipped_Date)
    OUTPUT $ACTION,
    COALESCE(inserted.SerialNumberPrefix_ID, deleted.SerialNumberPrefix_ID) Number
INTO @MERGE_RESULTS;

SELECT @MERGED_ROWS = @@ROWCOUNT;

SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
													,(SELECT MR.ACTIONTYPE
															,MR.Number
														FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
														,WITHOUT_ARRAY_WRAPPER),'Product Relation Modified Rows');

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

Update STATISTICS sis.Product_Relation with fullscan

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

END TRY

BEGIN CATCH

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
DECLARE @ERROELINE INT= ERROR_LINE()

SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

END CATCH

END
