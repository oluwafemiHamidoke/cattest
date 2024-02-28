CREATE PROCEDURE [sis].[MediaSequence_Refresh_shadow_Table]   AS BEGIN
SET XACT_ABORT,
	NOCOUNT ON;
BEGIN TRY
	DECLARE @AFFECTED_ROWS INT = 0,
		@LOGMESSAGE VARCHAR(MAX),
		@ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID),
		@ProcessID UNIQUEIDENTIFIER = NEWID(),
		@DEFAULT_ORGCODE VARCHAR(12) = SISWEB_OWNER_STAGING._getDefaultORGCODE();

	EXEC sis.WriteLog @PROCESSID = @ProcessID,
	@LOGTYPE = 'Information',
	@NAMEOFSPROC = @ProcName,
	@LOGMESSAGE = 'Execution started',
	@DATAVALUE = NULL;
	BEGIN TRANSACTION;
        MERGE [sis_shadow].[MediaSequence] AS TARGET
                USING
            (SELECT [MediaSequence_ID]
            ,[MediaSection_ID]
            ,[IEPart_ID]
            ,[Sequence_Number]
            ,[Serviceability_Indicator]
            ,[IE_ID]
            ,[Arrangement_Indicator]
            ,[TypeChange_Indicator]
            ,[NPR_Indicator]
            ,[CCR_Indicator]
            ,[IESystemControlNumber]
            ,[Part]
            ,[Of_Parts]
            ,[LastModified_Date]
        FROM [sis].[MediaSequence]
            ) AS SOURCE
            ON
            (
                TARGET.[MediaSequence_ID]               =  SOURCE.[MediaSequence_ID]            AND   
                TARGET.[MediaSection_ID]                =  SOURCE.[MediaSection_ID]             AND
                TARGET.[IEPart_ID]                      =  SOURCE.[IEPart_ID]                   AND
                TARGET.[Sequence_Number]                =  SOURCE.[Sequence_Number]             AND
                TARGET.[IE_ID]                          =  SOURCE.[IE_ID]  
            )
            WHEN MATCHED AND
            (

                TARGET.[Serviceability_Indicator]		<>  SOURCE.[Serviceability_Indicator]   OR
                TARGET.[Arrangement_Indicator]          <>  SOURCE.[Arrangement_Indicator]      OR
                TARGET.[TypeChange_Indicator]           <>  SOURCE.[TypeChange_Indicator]       OR
                TARGET.[NPR_Indicator]                  <>  SOURCE.[NPR_Indicator]              OR
                TARGET.[CCR_Indicator]                  <>  SOURCE.[CCR_Indicator]              OR
                TARGET.[IESystemControlNumber]          <>  SOURCE.[IESystemControlNumber]      OR
                TARGET.[Part]                           <>  SOURCE.[Part]                       OR
                TARGET.[Of_Parts]                       <>  SOURCE.[Of_Parts]                   OR
                TARGET.[LastModified_Date]              <>  SOURCE.[LastModified_Date]      
            )
                    THEN
                UPDATE
                SET
                TARGET.[Serviceability_Indicator]		=  SOURCE.[Serviceability_Indicator]   ,
                TARGET.[Arrangement_Indicator]          =  SOURCE.[Arrangement_Indicator]      ,
                TARGET.[TypeChange_Indicator]           =  SOURCE.[TypeChange_Indicator]       ,
                TARGET.[NPR_Indicator]                  =  SOURCE.[NPR_Indicator]              ,
                TARGET.[CCR_Indicator]                  =  SOURCE.[CCR_Indicator]              ,
                TARGET.[IESystemControlNumber]          =  SOURCE.[IESystemControlNumber]      ,
                TARGET.[Part]                           =  SOURCE.[Part]                       ,
                TARGET.[Of_Parts]                       =  SOURCE.[Of_Parts]                   ,
                TARGET.[LastModified_Date]              =  SOURCE.[LastModified_Date] 
            WHEN NOT MATCHED BY TARGET
                THEN
            INSERT(
                [MediaSequence_ID]
                ,[MediaSection_ID]
                ,[IEPart_ID]
                ,[Sequence_Number]
                ,[Serviceability_Indicator]
                ,[IE_ID]
                ,[Arrangement_Indicator]
                ,[TypeChange_Indicator]
                ,[NPR_Indicator]
                ,[CCR_Indicator]
                ,[IESystemControlNumber]
                ,[Part]
                ,[Of_Parts]
                ,[LastModified_Date]
            )
            VALUES
            (
                SOURCE.[MediaSequence_ID]
                ,SOURCE.[MediaSection_ID]
                ,SOURCE.[IEPart_ID]
                ,SOURCE.[Sequence_Number]
                ,SOURCE.[Serviceability_Indicator]
                ,SOURCE.[IE_ID]
                ,SOURCE.[Arrangement_Indicator]
                ,SOURCE.[TypeChange_Indicator]
                ,SOURCE.[NPR_Indicator]
                ,SOURCE.[CCR_Indicator]
                ,SOURCE.[IESystemControlNumber]
                ,SOURCE.[Part]
                ,SOURCE.[Of_Parts]
                ,SOURCE.[LastModified_Date]
                
            )

            WHEN NOT MATCHED BY SOURCE
                                THEN
                                    DELETE;

                set @AFFECTED_ROWS = @@ROWCOUNT 
                EXEC sis.WriteLog @PROCESSID = @ProcessID,
                    @LOGTYPE = 'Information',
                    @NAMEOFSPROC = @ProcName,
                    @LOGMESSAGE = 'Merged into sis_shadow.MediaSequence',
                    @DATAVALUE = @AFFECTED_ROWS;
	

	COMMIT;
	
	EXEC sis.WriteLog @PROCESSID = @ProcessID,
	@LOGTYPE = 'Information',
	@NAMEOFSPROC = @ProcName,
	@LOGMESSAGE = 'Execution Completed',
	@DATAVALUE = NULL;
END TRY 
BEGIN CATCH
	DECLARE @ERRORMESSAGE2 NVARCHAR(4000) = ERROR_MESSAGE()
		,@ERRORLINE2 INT = ERROR_LINE();

	SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s', CAST(@ERRORLINE2 AS VARCHAR(10)), CAST(@ERRORMESSAGE2 AS VARCHAR(4000)));

	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

	EXEC sis.WriteLog @PROCESSID = @ProcessID
		,@LOGTYPE = 'Error'
		,@NAMEOFSPROC = @ProcName
		,@LOGMESSAGE = @LOGMESSAGE
		,@DATAVALUE = NULL;

	RAISERROR (
			@LOGMESSAGE
			,17
			,1
			)
	WITH NOWAIT;
END CATCH
END
GO