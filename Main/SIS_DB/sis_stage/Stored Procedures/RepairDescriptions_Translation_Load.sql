-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20230426
-- Description: Load data into [sis_stage].[RepairDescriptions_Translation] for SIS2 to access
-- =============================================

CREATE PROCEDURE [sis_stage].[RepairDescriptions_Translation_Load]
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

         MERGE [sis_stage].[RepairDescriptions_Translation]  AS x
            USING (
				select distinct
					ut.[RepairDescriptions_ID],
					l.[Language_ID],
					m.[REPAIRDESCRIPTION]
					from [SISWEB_OWNER].[MASREPAIRDESCRIPTIONS] m
					Inner join [sis_stage].[RepairDescriptions] ut on ut.[RepairCode] = m.[REPAIRCODE] and ut.[RepairType] = m.[REPAIRTYPE]
					Inner join [sis_stage].[Language] l on l.Legacy_Language_Indicator = m.[LANGUAGEINDICATOR]
					where l.[Default_Language] =1
					
					
           ) AS S
		   ON (		S.[RepairDescriptions_ID]	= x.[RepairDescriptions_ID]
				and S.[Language_ID]			= x.[Language_ID]
				and S.[REPAIRDESCRIPTION] = x.[RepairDescription]
		   
		   )
		   WHEN NOT MATCHED BY TARGET
            THEN
            INSERT ([RepairDescriptions_ID], [Language_ID], [RepairDescription])
            VALUES (S.[RepairDescriptions_ID], S.[Language_ID], S.[REPAIRDESCRIPTION])
			;

        SELECT @MERGED_ROWS = @@ROWCOUNT;

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

        --Update STATISTICS [sis_stage].[RepairDescriptions_Translation] with fullscan

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

    END TRY

    BEGIN CATCH

        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ERROELINE INT= ERROR_LINE()

        SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

    END CATCH

END