﻿-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181002
-- Description: Merge external table [sis_stage].[Part_AsShippedPart_Relation] into [sis].[Part_AsShippedPart_Relation]
-- =============================================
CREATE PROCEDURE [sis].[Part_AsShippedPart_Relation_Merge]
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

MERGE [sis].[Part_AsShippedPart_Relation] AS x
    USING [sis_stage].[Part_AsShippedPart_Relation] AS s
    ON (s.Part_ID = x.Part_ID and s.AsShippedPart_ID = x.AsShippedPart_ID)
    WHEN MATCHED AND EXISTS
    (
    SELECT s.Part_AsShippedPart_Relation_ID, s.Quantity, s.Sequence_Number
    EXCEPT
    SELECT x.Part_AsShippedPart_Relation_ID, x.Quantity, x.Sequence_Number
    )
    THEN
UPDATE SET x.Part_AsShippedPart_Relation_ID = s.Part_AsShippedPart_Relation_ID, x.Quantity = s.Quantity, x.Sequence_Number = s.Sequence_Number
    WHEN NOT MATCHED BY TARGET
    THEN
INSERT (Part_AsShippedPart_Relation_ID, Part_ID, AsShippedPart_ID, Quantity, Sequence_Number)
VALUES (s.Part_AsShippedPart_Relation_ID, s.Part_ID, s.AsShippedPart_ID, s.Quantity, s.Sequence_Number)
    OUTPUT $ACTION,
    COALESCE(inserted.Part_ID, deleted.Part_ID) Number
INTO @MERGE_RESULTS;

SELECT @MERGED_ROWS = @@ROWCOUNT;

SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
													,(SELECT MR.ACTIONTYPE
															,MR.Number
														FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
														,WITHOUT_ARRAY_WRAPPER),'Part AsShippedPart Relation Modified Rows');
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

Update STATISTICS sis.Part_AsShippedPart_Relation with fullscan

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

END TRY

BEGIN CATCH

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
DECLARE @ERROELINE INT= ERROR_LINE()

SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

END CATCH

END
