-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20230418
-- Description: Merges a complex low performing query into [sis_stage].[CCRGroupIE_Effectivity] for SIS2 to access
-- =============================================

CREATE PROCEDURE [sis_stage].[CCRGroupIE_Effectivity_Load]
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

          MERGE [sis_stage].[CCRGroupIE_Effectivity]  AS x
            USING (
                select distinct snp.[SerialNumberPrefix_ID], 
								O.[Operation_ID], 
								MS.[IEPart_ID]
				from [SISWEB_OWNER].LNKCCRGROUPIESCN LG
				Inner join [sis_stage].[SerialNumberPrefix] snp on snp.[Serial_Number_Prefix] = LG.SNP
				Inner join [sis_stage].CCROperations O on O.[Operation_ID] = LG.OPERATIONRID
				Inner join [sis_stage].[MediaSequence] MS on MS.[IESystemControlNumber] = LG.IESYSTEMCONTROLNUMBER
										
           ) AS S
		   ON (		s.[SerialNumberPrefix_ID]	= x.[SerialNumberPrefix_ID]
				and s.[Operation_ID]			= x.[Operation_ID]
				and s.[IEPart_ID]				= x.[IEPart_ID]		   
		   )
		   WHEN NOT MATCHED BY TARGET
            THEN
            INSERT ([SerialNumberPrefix_ID], [Operation_ID], [IEPart_ID])
            VALUES (s.[SerialNumberPrefix_ID], s.[Operation_ID], s.[IEPart_ID])
		  WHEN NOT MATCHED BY SOURCE
		  THEN DELETE
           ;

        SELECT @MERGED_ROWS = @@ROWCOUNT;

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;

        Update STATISTICS [sis_stage].[CCRGroupIE_Effectivity] with fullscan

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

    END TRY

    BEGIN CATCH

        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ERROELINE INT= ERROR_LINE()

        SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

    END CATCH

END