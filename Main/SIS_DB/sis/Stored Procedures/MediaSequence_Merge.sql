-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181002
-- Description: Merge external table [sis_stage].[MediaSequence] into [sis].[MediaSequence]
-- Modified By: Kishor Padmanabhan
-- Modified Date: 20220919
-- Modified Reason: Moved Part and OfParts column to MediaSequence from IEPart
-- Associated User Story: 21373
-- Modified Reason: Added LastModified_Date column to MediaSequence
-- Associated User Story: 22559
-- =============================================
CREATE PROCEDURE [sis].[MediaSequence_Merge]
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

MERGE [sis_shadow].[MediaSequence] AS x
    USING [sis_stage].[MediaSequence] AS s
    ON (
        s.MediaSection_ID = x.MediaSection_ID 
        and s.IEPart_ID = x.IEPart_ID 
        and s.IE_ID = x.IE_ID 
        and s.Sequence_Number = x.Sequence_Number)
    WHEN MATCHED AND EXISTS
    (
    SELECT s.MediaSequence_ID, s.Serviceability_Indicator, s.Arrangement_Indicator, s.TypeChange_Indicator, s.NPR_Indicator, s.CCR_Indicator, s.IESystemControlNumber, s.Part, s.Of_Parts
    EXCEPT
    SELECT x.MediaSequence_ID, x.Serviceability_Indicator, x.Arrangement_Indicator, x.TypeChange_Indicator, x.NPR_Indicator, x.CCR_Indicator, x.IESystemControlNumber, x.Part, x.Of_Parts
    )
    THEN
UPDATE SET 
    x.MediaSequence_ID = s.MediaSequence_ID,
    x.Serviceability_Indicator = s.Serviceability_Indicator,  
    x.Arrangement_Indicator=s.Arrangement_Indicator, 
    x.TypeChange_Indicator=s.TypeChange_Indicator, 
    x.NPR_Indicator=s.NPR_Indicator, 
    x.CCR_Indicator=s.CCR_Indicator, 
    x.IESystemControlNumber=s.IESystemControlNumber
    ,x.Part = s.Part
    ,x.Of_Parts = s.Of_Parts
    ,x.LastModified_Date = GETDATE()
    WHEN NOT MATCHED BY TARGET
    THEN
INSERT (MediaSequence_ID, MediaSection_ID, IEPart_ID, IE_ID, Sequence_Number, Serviceability_Indicator, Arrangement_Indicator, TypeChange_Indicator, NPR_Indicator, CCR_Indicator, IESystemControlNumber, Part, Of_Parts, LastModified_Date)
VALUES (s.MediaSequence_ID, s.MediaSection_ID, s.IEPart_ID, s.IE_ID, s.Sequence_Number, s.Serviceability_Indicator, s.Arrangement_Indicator, s.TypeChange_Indicator, s.NPR_Indicator, s.CCR_Indicator, s.IESystemControlNumber, s.Part, s.Of_Parts, GETDATE())
    OUTPUT $ACTION,
    COALESCE(inserted.MediaSection_ID, deleted.MediaSection_ID) Number
INTO @MERGE_RESULTS;

SELECT @MERGED_ROWS = @@ROWCOUNT;

SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',(SELECT(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
													,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
													,(SELECT MR.ACTIONTYPE
															,MR.Number
														FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows FOR JSON PATH
														,WITHOUT_ARRAY_WRAPPER),'MediaSequence Modified Rows');
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

-- Always update stats on the table that just got laoded which always be the table behind [sis_shadow].[MediaSequence]
DECLARE @TableToLoad varchar(500) = (select sis.fn_get_table_from_synonym('sis_shadow','MediaSequence'))
DECLARE @sql_UpdateStatsOnLiveTableUpdate nvarchar(500)= 'Update STATISTICS '+@TableToLoad+' with fullscan'
EXECUTE sp_executesql @sql_UpdateStatsOnLiveTableUpdate


EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

END TRY

BEGIN CATCH

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
DECLARE @ERROELINE INT= ERROR_LINE()

SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

END CATCH

END
