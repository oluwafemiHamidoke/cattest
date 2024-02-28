-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20230330
-- Description: Merges a complex low performing query into [sis_stage].[CCRUpdateTypes_Translation] for SIS2 to access
-- =============================================

CREATE PROCEDURE [sis_stage].[CCRUpdateTypes_Translation_Load]
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

          MERGE [sis_stage].[CCRUpdateTypes_Translation]  AS x
            USING (
				select distinct
					ut.[CCRUpdateTypes_ID],
					l.[Language_ID],
					m.[UPDATETYPEDESCRIPTION]
					from [SISWEB_OWNER].[MASCCRUPDATETYPES] m
					Inner join [sis_stage].[CCRUpdateTypes] ut on ut.[UpdateTypeIndicator] = m.[UPDATETYPEINDICATOR]
					Inner join [sis_stage].[Language] l on l.Legacy_Language_Indicator = m.[LANGUAGEINDICATOR]
					where l.[Default_Language] =1
					
					
           ) AS S
		   ON (		s.[CCRUpdateTypes_ID]	= x.[CCRUpdateTypes_ID]
				and s.[Language_ID]	= x.[Language_ID]
				and s.[UPDATETYPEDESCRIPTION] = x.[UpdateTypeDescription]
		   
		   )
		   WHEN NOT MATCHED BY TARGET
            THEN
            INSERT ([CCRUpdateTypes_ID], [Language_ID], [UpdateTypeDescription])
            VALUES (s.[CCRUpdateTypes_ID], s.[Language_ID], s.[UPDATETYPEDESCRIPTION])
			;
            
        SELECT @MERGED_ROWS = @@ROWCOUNT;

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

        Update STATISTICS [sis_stage].[CCRUpdateTypes_Translation] with fullscan

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

    END TRY

    BEGIN CATCH

        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ERROELINE INT= ERROR_LINE()

        SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

    END CATCH

END