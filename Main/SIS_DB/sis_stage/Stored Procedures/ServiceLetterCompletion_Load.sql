/* ==================================================================================================================================================== 
Author:			Kishor Padmanabhan
Create date:	2022-11-01
Update by : Prashant Shrivastava
Update date: 2023-06-06
Update Description: joining sis_stage table instead of sis.
====================================================================================================================================================== */
CREATE PROCEDURE [sis_stage].[ServiceLetterCompletion_Load]
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    DECLARE @ProcName  VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
          ,@ProcessID UNIQUEIDENTIFIER = NEWID();

    EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

    --Load ServiceLetterCompletion
    INSERT INTO sis_stage.ServiceLetterCompletion (Media_ID, SerialNumberPrefix_ID,SerialNumberRange_ID,Completion_Date)
    SELECT DISTINCT
			    M.[Media_ID]
			  , SP.[SerialNumberPrefix_ID]
			  , SR.[SerialNumberRange_ID]
			  , MAX(PWP.CMPLT_DT) AS Completion_Date -- to take the latest completion date
			FROM [sis_stage].[Media] M 
			INNER JOIN [PIS].[WHS_PIP_PSP_PGM] PWP ON M.[PIPPS_Number] = 
				CASE WHEN LEFT(PWP.[PIP_PSP_NO],2)='95' THEN STUFF(PWP.[PIP_PSP_NO],1,2,'PS')
					 WHEN LEFT(PWP.[PIP_PSP_NO],2)='94' THEN STUFF(PWP.[PIP_PSP_NO],1,2,'PI') END
			INNER JOIN [sis_stage].[SerialNumberPrefix] SP ON SP.[Serial_Number_Prefix] = PWP.[SER_NO_PFX]
			INNER JOIN [sis_stage].[SerialNumberRange] SR ON SR.[End_Serial_Number] = TRY_CAST(PWP.[SER_NO_BDY] AS INT) AND SR.[Start_Serial_Number]  = TRY_CAST(PWP.SER_NO_BDY AS INT)
			  WHERE [SER_NO_BDY] != 'ue' -- skipping bad data
			  GROUP BY M.[Media_ID], SP.[SerialNumberPrefix_ID], SR.[SerialNumberRange_ID]


    UPDATE [sis_stage].[ServiceLetterCompletion]
		SET Completion_Date='9999-12-31' 
		WHERE Completion_Date = '0001-01-01'

    EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'ServiceLetterCompletion Load', @DATAVALUE = @@RowCount;

    EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed', @DATAVALUE = NULL;
  END TRY
  BEGIN CATCH
    DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
            @ERRORLINE INT= ERROR_LINE(),
            @LOGMESSAGE VARCHAR(MAX);

    SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
    EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;
  END CATCH
END