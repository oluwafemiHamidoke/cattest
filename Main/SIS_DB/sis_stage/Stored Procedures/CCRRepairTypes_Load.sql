-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20230330
-- Description: Load data into [sis_stage].[CCRRepairTypes] for SIS2 to access
-- =============================================

CREATE PROCEDURE [sis_stage].[CCRRepairTypes_Load]
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
        
         MERGE [sis_stage].[CCRRepairTypes]  AS x
            USING (

                select 
                    distinct
					m.[REPAIRTYPEINDICATOR],
					m.[SEQUENCENUMBER]
                    from [SISWEB_OWNER].[MASCCRREPAIRTYPES] m
					
					
           ) AS S
		   ON (		s.[REPAIRTYPEINDICATOR]	= x.[RepairTypeIndicator]
				and s.[SEQUENCENUMBER] = x.[SequenceNumber]
		   
		   )
		   WHEN NOT MATCHED BY TARGET
            THEN
            INSERT ([RepairTypeIndicator],[SequenceNumber])
                VALUES (s.[REPAIRTYPEINDICATOR],s.[SEQUENCENUMBER])
        ;

        SELECT @MERGED_ROWS = @@ROWCOUNT;

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

        --Update STATISTICS [sis_stage].[CCRRepairTypes] with fullscan
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