-- =============================================
-- Author:      Prashant Shrivastava
-- Create Date: 20231013
-- Description: load data into [sis_stage].[IELevel]
-- =============================================

CREATE PROCEDURE [sis_stage].[IELevel_Load]
(@DEBUG      BIT = 'FALSE')
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY

         DECLARE @LOGMESSAGE                    VARCHAR(MAX);

        DECLARE @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
        DECLARE @ProcessID uniqueidentifier = NewID()

        EXEC [sis_stage].WriteLog @PROCESSID = @ProcessID,@LOGTYPE = 'Information',@NAMEOFSPROC = @ProcName,@LOGMESSAGE = 'Execution started',@DATAVALUE = NULL;

         INSERT INTO [sis_stage].[IELevel]  ([IE_ID], [LevelSequenceNumber], [LevelID],[ParentID])
         SELECT  Distinct
				ie.[IE_ID],
				m.[LEVELSEQUENCENUMBER],
				m.[LEVELID]	,
				m.[PARENTID]					
	 FROM [SISWEB_OWNER_STAGING].[LNKIELEVEL] m
	 Inner join [sis_stage].[IE] ie on m.[IESYSTEMCONTROLNUMBER] = ie.[IESystemControlNumber]
         
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
