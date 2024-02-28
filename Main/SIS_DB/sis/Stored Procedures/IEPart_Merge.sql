
-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181002
-- Description: Merge external table [sis_stage].[IEPart] into [sis].[IEPart]
-- Modified By: Kishor Padmanabhan
-- Modified Date: 20220919
-- Modified Reason: Moved Part and OfParts column to MediaSequence from IEPart
-- Associated User Story: 21373
-- =============================================
CREATE PROCEDURE [sis].[IEPart_Merge]
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

MERGE [sis].[IEPart] AS x
    USING [sis_stage].[IEPart] AS s
    ON (s.Base_English_Control_Number = x.Base_English_Control_Number)
    WHEN MATCHED AND EXISTS
    (
    SELECT s.IEPart_ID, s.Part_ID,  s.Publish_Date, s.Update_Date, s.IE_Control_Number, s.PartName_for_NULL_PartNum
    EXCEPT
    SELECT x.IEPart_ID, x.Part_ID, x.Publish_Date, x.Update_Date, x.IE_Control_Number, x.PartName_for_NULL_PartNum
    )
    THEN
            UPDATE SET  x.IEPart_ID = s.IEPart_ID, 
                        x.Part_ID = s.Part_ID,  
                        x.Publish_Date = s.Publish_Date,
                        x.Update_Date = s.Update_Date, 
                        x.IE_Control_Number = s.IE_Control_Number, 
                        x.PartName_for_NULL_PartNum = s.PartName_for_NULL_PartNum,
                        x.LastModified_Date = GETDATE()
    WHEN NOT MATCHED BY TARGET
    THEN
INSERT (IEPart_ID, Part_ID, Base_English_Control_Number, Publish_Date, Update_Date, IE_Control_Number, PartName_for_NULL_PartNum, LastModified_Date)
VALUES (s.IEPart_ID, s.Part_ID, s.Base_English_Control_Number, s.Publish_Date, s.Update_Date, s.IE_Control_Number, s.PartName_for_NULL_PartNum, GETDATE())
    OUTPUT $ACTION,
    COALESCE(inserted.Base_English_Control_Number, deleted.Base_English_Control_Number) Number
INTO @MERGE_RESULTS;

SELECT @MERGED_ROWS = @@ROWCOUNT;

SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
													,(SELECT MR.ACTIONTYPE
															,MR.Number
														FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
														,WITHOUT_ARRAY_WRAPPER),'IEPart Modified Rows');
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

Update STATISTICS sis.IEPart with fullscan

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

END TRY

BEGIN CATCH

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
DECLARE @ERROELINE INT= ERROR_LINE()

SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

END CATCH

END
