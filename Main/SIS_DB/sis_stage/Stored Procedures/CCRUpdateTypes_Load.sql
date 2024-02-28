-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20230330
-- Description: Merges a complex low performing query into [sis_stage].[CCRUpdateTypes] for SIS2 to access
-- =============================================

CREATE PROCEDURE [sis_stage].[CCRUpdateTypes_Load]
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

         MERGE [sis_stage].[CCRUpdateTypes]  AS x
            USING (

                select 
                    distinct
					m.[UPDATETYPEINDICATOR],
					m.[SEQUENCENUMBER],
					m.[LASTMODIFIEDDATE]
                    from [SISWEB_OWNER].[MASCCRUPDATETYPES] m
					
					
           ) AS S
		   ON (		s.[UPDATETYPEINDICATOR]	= x.[UpdateTypeIndicator]
				and s.[SEQUENCENUMBER] = x.[SequenceNumber]
		   
		   )
		   WHEN NOT MATCHED BY TARGET
            THEN
            INSERT ([UpdateTypeIndicator],[SequenceNumber],[LastModifiedDate])
                VALUES (s.[UPDATETYPEINDICATOR],s.[SEQUENCENUMBER],s.[LASTMODIFIEDDATE])
        ;

        SELECT @MERGED_ROWS = @@ROWCOUNT;

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

        Update STATISTICS [sis_stage].[CCRUpdateTypes] with fullscan

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

    END TRY

    BEGIN CATCH

        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ERROELINE INT= ERROR_LINE()

        SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

    END CATCH

END