-- =============================================
-- Author:      Rishabh Khatreja
-- Create Date: 20221101
-- Description: Merge external table [sis_stage].[AsShippedPart_Level_Relation] into [sis].[AsShippedPart_Level_Relation]
-- =============================================
CREATE PROCEDURE [sis].[AsShippedPart_Level_Relation_Merge]
    (@FORCE_LOAD BIT = 'FALSE',
    @DEBUG      BIT = 'FALSE') 
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        DECLARE @MERGED_ROWS               INT              = 0
		    ,@CURRENT_ROWCOUNT             DECIMAL(12,3)    = 0
            ,@STAGING_ROWCOUNT			   DECIMAL(12,3)    = 0
		    ,@MODIFIED_ROWS_PERCENTAGE     DECIMAL(12,4)    = 0
            ,@LOGMESSAGE                   VARCHAR(MAX);

        DECLARE @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
        DECLARE @ProcessID uniqueidentifier = NewID()

        EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

        IF @FORCE_LOAD = 'FALSE'
            BEGIN
		        SELECT @STAGING_ROWCOUNT = COUNT_BIG(*) FROM  [sis_stage].[AsShippedPart_Level_Relation];
                SELECT @CURRENT_ROWCOUNT = COUNT_BIG(*) FROM [sis].[AsShippedPart_Level_Relation];
                SELECT @MODIFIED_ROWS_PERCENTAGE = (@STAGING_ROWCOUNT - @CURRENT_ROWCOUNT) / @CURRENT_ROWCOUNT;
		        IF @DEBUG = 'TRUE'
                    BEGIN
                        PRINT FORMATMESSAGE('@STAGING_ROWCOUNT=%s',FORMAT(@STAGING_ROWCOUNT,'G','en-us'));
                        PRINT FORMATMESSAGE('@CURRENT_ROWCOUNT=%s',FORMAT(@CURRENT_ROWCOUNT,'G','en-us'));
                        PRINT FORMATMESSAGE('@MODIFIED_ROWS_PERCENTAGE=%s',FORMAT(@MODIFIED_ROWS_PERCENTAGE,'P','en-us'));
                    END;
            END; 

        DECLARE @MERGE_RESULTS TABLE
            (ACTIONTYPE     NVARCHAR(10)
            ,Number         VARCHAR(50) NOT NULL);

        IF  (@FORCE_LOAD = 1 OR @MODIFIED_ROWS_PERCENTAGE BETWEEN-0.10 AND 0.10)
            BEGIN
                MERGE [sis].[AsShippedPart_Level_Relation] AS x
                USING [sis_stage].[AsShippedPart_Level_Relation] AS s
                ON (s.SerialNumberPrefix_ID = x.SerialNumberPrefix_ID and s.SerialNumberRange_ID = x.SerialNumberRange_ID and s.PartLevel = x.PartLevel
                    and s.Part_ID = x.Part_ID and s.PartOrder = x.PartOrder and s.PartSequenceNumber = x.PartSequenceNumber)
                WHEN MATCHED AND EXISTS
                    (
                    SELECT s.PartNumber,s.ParentPartNumber,s.AttachmentSerialNumber,s.PartType
                    EXCEPT
                    SELECT x.PartNumber,x.ParentPartNumber,x.AttachmentSerialNumber,x.PartType
                    )
                THEN
                    UPDATE SET x.SerialNumberPrefix_ID = s.SerialNumberPrefix_ID,
                        x.SerialNumberRange_ID = s.SerialNumberRange_ID,
                        x.PartLevel = s.PartLevel,
                        x.Part_ID = s.Part_ID,
                        x.PartOrder = s.PartOrder,
                        x.PartSequenceNumber = s.PartSequenceNumber,
                        x.PartNumber = s.PartNumber,
                        x.ParentPartNumber = s.ParentPartNumber,
                        x.AttachmentSerialNumber = s.AttachmentSerialNumber,
                        x.PartType = s.PartType
                WHEN NOT MATCHED BY TARGET
                THEN
                    INSERT(PartSequenceNumber, SerialNumberPrefix_ID, SerialNumberRange_ID, PartNumber, Part_ID, ParentPartNumber, AttachmentSerialNumber, PartOrder, PartLevel, PartType)
                    VALUES(s.PartSequenceNumber, s.SerialNumberPrefix_ID, s.SerialNumberRange_ID, s.PartNumber, s.Part_ID, s.ParentPartNumber, s.AttachmentSerialNumber, s.PartOrder, s.PartLevel, s.PartType)
                WHEN NOT MATCHED BY SOURCE
                THEN DELETE
                OUTPUT $ACTION,
                    COALESCE(inserted.Part_ID, deleted.Part_ID) Number
                    INTO @MERGE_RESULTS;
                SELECT @MERGED_ROWS = @@ROWCOUNT;
                SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
                    (SELECT
                        (SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'INSERT') AS Inserted
                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'UPDATE') AS Updated
                        ,(SELECT COUNT(*) FROM @MERGE_RESULTS AS MR WHERE MR.ACTIONTYPE = 'DELETE') AS Deleted
                        ,(SELECT MR.ACTIONTYPE, MR.Number
                            FROM @MERGE_RESULTS AS MR FOR JSON AUTO) AS  Modified_Rows
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
                    ,'AsShippedPart_Level_Relation Modified Rows');

                EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

                Update STATISTICS sis.AsShippedPart_Level_Relation with fullscan

                EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

            END
        ELSE
            BEGIN
	            EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,
		            @LOGMESSAGE = 'Skipping load: Row difference outside range (±10%)',@DATAVALUE = NULL;
            END

    END TRY

    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ERROELINE INT= ERROR_LINE()

        SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
        EXEC sis.WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

    END CATCH

END
