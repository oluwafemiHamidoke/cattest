-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20230330
-- Description: Merges a complex low performing query into [sis].[CCRMedia] for SIS2 to access
-- =============================================

CREATE PROCEDURE [sis_stage].[CCRMedia_Load]
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

         MERGE [sis_stage].[CCRMedia]  AS x
            USING (

                select 
                    distinct
                    m.[CCRMEDIARID],
					snp.[SerialNumberPrefix_ID],
					m.[REPAIRTYPEINDICATOR],
					SNR.[SerialNumberRange_ID],
					m.[LASTMODIFIEDDATE]
                 from [SISWEB_OWNER].[MASCCRMEDIA] m
					Inner join [sis_stage].[SerialNumberPrefix] SNP on SNP.[Serial_Number_Prefix] = m.[SNP]
					inner join [sis_stage].[SerialNumberRange] SNR on SNR.[Start_Serial_Number] = m.[BEGINNINGRANGE]
						and SNR.[End_Serial_Number] = m.[ENDRANGE]
           ) AS S
		   ON (		s.[CCRMEDIARID] = x.[CCRMedia_ID]
				and s.[SerialNumberPrefix_ID] = x.[SerialNumberPrefix_ID]
				and s.[REPAIRTYPEINDICATOR] = x.[RepairTypeIndicator]
				and s.SerialNumberRange_ID = x.[SerialNumberRange_ID]
				and s.[LASTMODIFIEDDATE] = x.[LastModifiedDate]
		   
		   )
		   WHEN NOT MATCHED BY TARGET
            THEN
            INSERT ( [CCRMedia_ID],[SerialNumberPrefix_ID],[RepairTypeIndicator],[SerialNumberRange_ID],[LastModifiedDate])
                VALUES (s.[CCRMEDIARID],s.[SerialNumberPrefix_ID],s.[REPAIRTYPEINDICATOR],s.[SerialNumberRange_ID],s.[LASTMODIFIEDDATE])
        ;

        SELECT @MERGED_ROWS = @@ROWCOUNT;

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

        Update STATISTICS [sis_stage].[CCRMedia] with fullscan

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

    END TRY

    BEGIN CATCH

        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ERROELINE INT= ERROR_LINE()

        SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

    END CATCH

END