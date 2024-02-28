
-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181002
-- Description: Merge external table [sis_stage].[Part_IEPart_Relation] into [sis].[Part_IEPart_Relation]
-- =============================================
CREATE PROCEDURE [sis].[Part_IEPart_Relation_Merge]
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

MERGE [sis].[Part_IEPart_Relation] AS x
    USING [sis_stage].[Part_IEPart_Relation] AS s
    ON (s.Part_ID = x.Part_ID and s.IEPart_ID = x.IEPart_ID and s.Sequence_Number = x.Sequence_Number)
    WHEN MATCHED AND EXISTS
    (
    SELECT 
        s.Part_IEPart_Relation_ID, 
        s.Reference_Number, 
        s.Graphic_Number, 
        s.Quantity, 
        s.Serviceability_Indicator, 
        s.Parentage, 
        s.CCR_Indicator
    EXCEPT
    SELECT 
        x.Part_IEPart_Relation_ID, 
        x.Reference_Number, 
        x.Graphic_Number, 
        x.Quantity, 
        x.Serviceability_Indicator, 
        x.Parentage, 
        x.CCR_Indicator
    )
    THEN
        UPDATE SET 
            x.Part_IEPart_Relation_ID = s.Part_IEPart_Relation_ID, 
            x.Reference_Number = s.Reference_Number, 
            x.Graphic_Number = s.Graphic_Number,
            x.Quantity = s.Quantity, 
            x.Serviceability_Indicator = s.Serviceability_Indicator, 
            x.Parentage = s.Parentage, 
            x.CCR_Indicator = s.CCR_Indicator,
            x.LastModified_Date = GETDATE()
    WHEN NOT MATCHED BY TARGET
    THEN
        INSERT (
                Part_IEPart_Relation_ID, 
                Part_ID, 
                IEPart_ID, 
                Sequence_Number, 
                Reference_Number, 
                Graphic_Number, 
                Quantity, 
                Serviceability_Indicator, 
                Parentage, 
                CCR_Indicator,
                LastModified_Date
                )
        VALUES (
                s.Part_IEPart_Relation_ID, 
                s.Part_ID, 
                s.IEPart_ID, 
                s.Sequence_Number, 
                s.Reference_Number, 
                s.Graphic_Number, 
                s.Quantity, 
                s.Serviceability_Indicator, 
                s.Parentage, 
                s.CCR_Indicator,
                GETDATE()
                )
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
														,WITHOUT_ARRAY_WRAPPER),'Part IEPart Relation Modified Rows');
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

Update STATISTICS sis.Part_IEPart_Relation with fullscan

EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

END TRY

BEGIN CATCH

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
DECLARE @ERROELINE INT= ERROR_LINE()

SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

END CATCH

END
