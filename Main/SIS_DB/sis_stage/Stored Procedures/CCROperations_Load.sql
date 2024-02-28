-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20230330
-- Description: Merges a complex low performing query into [sis_stage].[CCROperations] for SIS2 to access
-- =============================================

CREATE PROCEDURE [sis_stage].[CCROperations_Load]
(@DEBUG      BIT = 'FALSE')
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY

        DECLARE @MERGED_ROWS                   INT              = 0
            ,@LOGMESSAGE                    VARCHAR(MAX);

        Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
        Declare @ProcessID uniqueidentifier = NewID()

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

         MERGE [sis_stage].[CCROperations]  AS x
            USING (

                select 
                    distinct
					m.[OPERATIONRID]
					,m.[SEGMENTRID]
					,m.[OPERATION]
					,m.[OPERATIONNUMBER]
					,m.[COMPONENTCODE]
					,m.[JOBCODE]
					,m.[MODIFIERCODE]
					,m.[LASTMODIFIEDDATE]
                    from [SISWEB_OWNER].[MASCCROPERATIONS] m
					INNER JOIN [sis_stage].CCRSegments s ON s.[Segment_ID] = m.[SEGMENTRID]
										
           ) AS S
		   ON (		s.[OPERATIONRID]	= x.[Operation_ID]
				and s.[SEGMENTRID]		= x.[Segment_ID]
				and s.[OPERATION]		= x.[Operation]
				and s.[OPERATIONNUMBER] = x.[OperationNumber]
				and s.[COMPONENTCODE]	= x.[ComponentCode]
				and s.[JOBCODE]			= x.[JobCode]
				and s.[MODIFIERCODE]	= x.[ModifierCode]
				and s.[LASTMODIFIEDDATE] = x.[LastModifiedDate]
		   
		   )
		   WHEN NOT MATCHED BY TARGET
            THEN
            INSERT ([Operation_ID], [Segment_ID], [Operation], [OperationNumber],[ComponentCode], [JobCode], [ModifierCode], [LastModifiedDate])
                VALUES (s.[OPERATIONRID], s.[SEGMENTRID], s.[OPERATION], s.[OPERATIONNUMBER], s.[COMPONENTCODE], s.[JOBCODE], s.[MODIFIERCODE], s.[LASTMODIFIEDDATE])
          ;

        SELECT @MERGED_ROWS = @@ROWCOUNT;

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

        Update STATISTICS [sis_stage].[CCROperations] with fullscan

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

    END TRY

    BEGIN CATCH

        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ERROELINE INT= ERROR_LINE()

        SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

    END CATCH

END