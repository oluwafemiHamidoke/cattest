-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20230330
-- Description: Load data into [sis_stage].[CCRRepairTypes_Translation] for SIS2 to access
-- =============================================

CREATE PROCEDURE [sis_stage].[CCRRepairTypes_Translation_Load]
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

         MERGE [sis_stage].[CCRRepairTypes_Translation]  AS x
            USING (
				select distinct
					ut.[CCRRepairTypes_ID],
					l.[Language_ID],
					M.[RepairType],
					m.[REPAIRTYPEDESCRIPTION]
					from [SISWEB_OWNER].[MASCCRREPAIRTYPES] m
					Inner join [sis_stage].[CCRRepairTypes] ut on ut.[RepairTypeIndicator] = m.[REPAIRTYPEINDICATOR]
					Inner join sis.[Language] l on l.Legacy_Language_Indicator = m.[LANGUAGEINDICATOR]
					where l.[Default_Language] =1
					
					
           ) AS S
		   ON (		s.[CCRRepairTypes_ID]	= x.[CCRRepairTypes_ID]
				and s.[Language_ID]			= x.[Language_ID]
				and s.[RepairType]			= x.[RepairType]
				and s.[REPAIRTYPEDESCRIPTION] = x.[RepairTypeDescription]
		   
		   )
		   WHEN NOT MATCHED BY TARGET
            THEN
            INSERT ([CCRRepairTypes_ID], [Language_ID], [RepairType], [RepairTypeDescription])
            VALUES (s.[CCRRepairTypes_ID], s.[Language_ID], s.[RepairType], s.[REPAIRTYPEDESCRIPTION])
			;

        SELECT @MERGED_ROWS = @@ROWCOUNT;

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

        --Update STATISTICS [sis_stage].[CCRRepairTypes_Translation] with fullscan
        --No need to update statistics as we are truncating table before load.

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

    END TRY

    BEGIN CATCH

        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ERROELINE INT= ERROR_LINE()

        SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

    END CATCH

END