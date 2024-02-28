-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20231013
-- Description: Load into [sis_stage].[IELevel_Translation] 
-- =============================================

CREATE PROCEDURE [sis_stage].[IELevel_Translation_Load]
(@DEBUG      BIT = 'FALSE')
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY

        DECLARE @LOGMESSAGE                    VARCHAR(MAX);

        DECLARE @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
        DECLARE @ProcessID uniqueidentifier = NewID()

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

         INSERT into [sis_stage].[IELevel_Translation]  
         SELECT Distinct
			ut.[IELevel_ID],
			l.[Language_ID],
			m.[LEVELDESCRIPTION]
	 FROM [SISWEB_OWNER_STAGING].[LNKIELEVEL] m
	 Inner join [sis_stage].[IE] ie on ie.[IESystemControlNumber] = m.[IESYSTEMCONTROLNUMBER]
	 Inner join [sis_stage].[IELevel] ut on ie.IE_ID = ut.IE_ID
			   		 and ut.[LevelSequenceNumber] = m.[LEVELSEQUENCENUMBER]
	 Inner join [sis_stage].[Language] l on l.Legacy_Language_Indicator = m.[LEVELLANGUAGEINDICATOR]
	 WHERE l.[Default_Language] =1
            
        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @@ROWCOUNT;

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution completed',@DATAVALUE = NULL;

    END TRY

    BEGIN CATCH

        DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ERROELINE INT= ERROR_LINE()

        SET @LOGMESSAGE = FORMATMESSAGE('LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE);
        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Error',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

    END CATCH

END;
