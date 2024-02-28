-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20230330
-- Description: Merges a complex low performing query into [sis_stage].[CCRSegments] for SIS2 to access
-- =============================================

CREATE PROCEDURE [sis_stage].[CCRSegments_Load]
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

        MERGE [sis_stage].[CCRSegments]  AS x
            USING (

                select 
                    distinct
                    m.[SEGMENTRID],
					m.[CCRMEDIARID],
					m.[SEGMENT],
					m.[COMPONENTCODE],
					m.[JOBCODE],
					m.[MODIFIERCODE],
					m.[HOURS],
					m.[LASTMODIFIEDDATE]
                    from [SISWEB_OWNER].[MASCCRSEGMENTS] m
					INNER JOIN [sis_stage].[CCRMedia] cm ON m.CCRMEDIARID = cm.CCRMedia_ID
					-- we need this join as [CCRMedia] is not loaded with some IDs due to join with [SerialNumberRange]
										
           ) AS S
		   ON (		s.[SEGMENTRID]	= x.[Segment_ID]
				and s.[CCRMEDIARID] = x.[CCRMedia_ID]
				and s.[SEGMENT]		= x.[Segment]
				and s.[COMPONENTCODE] = x.[ComponentCode]
				and s.[JOBCODE]		= x.[JobCode]
				and s.[MODIFIERCODE]= x.[ModifierCode]
				and s.[HOURS]		= x.[Hours]
				and s.[LASTMODIFIEDDATE] = x.[LastModifiedDate]
		   
		   )
		   WHEN NOT MATCHED BY TARGET
            THEN
            INSERT ([Segment_ID], [CCRMedia_ID], [Segment], [ComponentCode], [JobCode], [ModifierCode], [Hours], [LastModifiedDate])
                VALUES (s.[SEGMENTRID] , s.[CCRMEDIARID] , s.[SEGMENT], s.[COMPONENTCODE], s.[JOBCODE], s.[MODIFIERCODE], s.[HOURS], s.[LASTMODIFIEDDATE])
           ;

        SELECT @MERGED_ROWS = @@ROWCOUNT;

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

        Update STATISTICS [sis_stage].[CCRSegments] with fullscan

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

    END TRY

    BEGIN CATCH

        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ERROELINE INT= ERROR_LINE()

        SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

    END CATCH

END