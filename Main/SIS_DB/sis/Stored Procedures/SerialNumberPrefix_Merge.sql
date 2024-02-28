
-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181002
-- Description: Merge external table [sis_stage].[SerialNumberPrefix] into [sis].[SerialNumberPrefix]
-- =============================================
CREATE PROCEDURE [sis].[SerialNumberPrefix_Merge]
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

MERGE [sis].[SerialNumberPrefix] AS x
    USING [sis_stage].[SerialNumberPrefix] AS s
    ON (s.Serial_Number_Prefix = x.Serial_Number_Prefix)
    WHEN MATCHED AND EXISTS
    (
    SELECT s.SerialNumberPrefix_ID, s.Classic_Product_Indicator, s.CCR_Indicator, s.Is_Telematics_Flash
    EXCEPT
    SELECT x.SerialNumberPrefix_ID, x.Classic_Product_Indicator, x.CCR_Indicator, x.Is_Telematics_Flash
    )
    THEN
        UPDATE SET  x.SerialNumberPrefix_ID = s.SerialNumberPrefix_ID, 
                    x.Classic_Product_Indicator = s.Classic_Product_Indicator, 
                    x.CCR_Indicator = s.CCR_Indicator,
					x.Is_Telematics_Flash = s.Is_Telematics_Flash,
                    x.LastModified_Date = GETDATE()
    WHEN NOT MATCHED BY TARGET
    THEN
INSERT (SerialNumberPrefix_ID, Serial_Number_Prefix, Classic_Product_Indicator, CCR_Indicator, Is_Telematics_Flash, LastModified_Date)
VALUES (s.SerialNumberPrefix_ID, s.Serial_Number_Prefix, s.Classic_Product_Indicator, s.CCR_Indicator, Is_Telematics_Flash, GETDATE())
    OUTPUT $ACTION,
    COALESCE(inserted.Serial_Number_Prefix, deleted.Serial_Number_Prefix) Number
INTO @MERGE_RESULTS;

SELECT @MERGED_ROWS = @@ROWCOUNT;

SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
													,(SELECT MR.ACTIONTYPE
															,MR.Number
														FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
														,WITHOUT_ARRAY_WRAPPER),'SerialNumberPrefix Modified Rows');
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

Update STATISTICS sis.SerialNumberPrefix with fullscan

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

END TRY

BEGIN CATCH

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
DECLARE @ERROELINE INT= ERROR_LINE()

SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

END CATCH

END
