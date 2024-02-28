-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20230418
-- Description: Merges a complex low performing query into [sis_stage].[CCRVirtualIE_Effectivity] for SIS2 to access
-- =============================================

CREATE PROCEDURE [sis_stage].[CCRVirtualIE_Effectivity_Load]
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

         MERGE [sis_stage].[CCRTechdocSNP_Effectivity]  AS x
            USING (
                select distinct LCT.[UPDATERID], 
								SNP.[SerialNumberPrefix_ID], 
								SNR.[SerialNumberRange_ID]
				from [SISWEB_OWNER].[LNKCCRTECHDOCSNP] LCT
				Inner join [sis].[SerialNumberPrefix] snp on snp.[Serial_Number_Prefix] = LCT.SNP
				Inner join [sis].[SerialNumberRange] snr on snr.[Start_Serial_Number] = LCT.[BEGINNINGRANGE] 
							and snr.[End_Serial_Number] = LCT.ENDRANGE
										
           ) AS S
		   ON (		s.[UPDATERID]				= x.[Update_ID]
				and s.[SerialNumberPrefix_ID]	= x.[SerialNumberPrefix_ID]
				and s.[SerialNumberRange_ID]	= x.[SerialNumberRange_ID]		   
		   )
		   WHEN NOT MATCHED BY TARGET
            THEN
            INSERT ([Update_ID], [SerialNumberPrefix_ID], [SerialNumberRange_ID])
            VALUES (s.[UPDATERID], s.[SerialNumberPrefix_ID], s.[SerialNumberRange_ID])
		  WHEN NOT MATCHED BY SOURCE
		  THEN DELETE
           ;

        SELECT @MERGED_ROWS = @@ROWCOUNT;

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

        Update STATISTICS [sis_stage].[CCRVirtualIE_Effectivity] with fullscan

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

    END TRY

    BEGIN CATCH

        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ERROELINE INT= ERROR_LINE()

        SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

    END CATCH

END