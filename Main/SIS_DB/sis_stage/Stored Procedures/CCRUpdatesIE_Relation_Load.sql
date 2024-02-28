-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20230418
-- Description: Merges a complex low performing query into [sis_stage].[CCRUpdatesIE_Relation] for SIS2 to access
-- =============================================

CREATE PROCEDURE [sis_stage].[CCRUpdatesIE_Relation_Load]
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

        MERGE [sis_stage].[CCRUpdatesIE_Relation]  AS x
            USING (
               select   LU.UPDATERID,
						CO.Operation_ID, 
						LU.UPDATETYPEINDICATOR, 
						IE.IE_ID
				from	[SISWEB_OWNER_STAGING].[LNKCCRUPDATES] LU
				inner join [sis_stage].CCROperations CO on CO.Operation_ID = LU.OPERATIONRID
				inner join [sis_stage].IE IE on IE.[IESystemControlNumber] = LU.[IESYSTEMCONTROLNUMBER]
										
           ) AS S
		   ON (		s.[updaterid]				= x.[Update_ID]
				and s.[Operation_ID]			= x.[Operation_ID]
				and s.[UpdateTypeIndicator]		= x.[UpdateTypeIndicator]	
				and s.IE_ID						= x.IE_ID

		   )
		   WHEN NOT MATCHED BY TARGET
            THEN
            INSERT ([Update_ID], [Operation_ID], [UpdateTypeIndicator], IE_ID )
            VALUES (s.[updaterid], s.[Operation_ID], s.[UpdateTypeIndicator], s.IE_ID)
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
