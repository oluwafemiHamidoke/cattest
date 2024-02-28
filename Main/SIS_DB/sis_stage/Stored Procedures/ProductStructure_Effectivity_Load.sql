
/* ====================================================================================================================================================
Author:			Paul B. Felix
Create date:	2019-10-09
Description: Full load [sis_stage].ProductStructure_Effectivity
Exec [sis_stage].[ProductStructure_Effectivity_Load]
Truncate table [sis_stage].[ProductStructure_Effectivity]
====================================================================================================================================================== */
CREATE PROCEDURE [sis_stage].[ProductStructure_Effectivity_Load]
AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			DECLARE @PROCNAME  VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
				   ,@PROCESSID UNIQUEIDENTIFIER = NEWID()
				   ,@NULLID    INT              = 0;

	EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID, @LOGTYPE = 'Information', @NAMEOFSPROC = @PROCNAME, @LOGMESSAGE = 'Execution started' , @DATAVALUE = NULL;

	--Load
	INSERT INTO sis_stage.ProductStructure_Effectivity ([ProductStructure_ID],[Media_ID],[SerialNumberPrefix_ID],[SerialNumberRange_ID])
/*
	--IE
	SELECT Distinct
	 r.ProductStructure_ID
	,r.Media_ID
	,e.SerialNumberPrefix_ID
	,e.SerialNumberRange_ID
	FROM [sis_stage].[IE] i
	Inner Join sis_stage.ProductStructure_IE_Relation r on i.IE_ID = r.IE_ID
	Inner Join sis_stage.IE_Effectivity e on e.IE_ID = r.IE_ID
	--Inner Join sis_stage.SerialNumberPrefix snp on snp.SerialNumberPrefix_ID = e.SerialNumberPrefix_ID
	--Inner Join sis_stage.SerialNumberRange snr on snr.SerialNumberRange_ID = e.SerialNumberRange_ID
	Union
*/
	--IEPart
	SELECT Distinct
        r.ProductStructure_ID
       ,r.Media_ID 
       ,r.SerialNumberPrefix_ID
       ,r.SerialNumberRange_ID
	FROM sis_stage.ProductStructure_IEPart_Relation r
    inner join sis_stage.media m on m.Media_ID=r.Media_ID
    inner Join sis_stage.SerialNumberPrefix snp on snp.SerialNumberPrefix_ID = r.SerialNumberPrefix_ID
    inner Join sis_stage.SerialNumberRange snr on snr.SerialNumberRange_ID = r.SerialNumberRange_ID
    inner join sis_stage.MediaSection mc on mc.Media_ID=r.Media_ID
	inner join sis_stage.MediaSequence ms on mc.MediaSection_ID=ms.MediaSection_ID and ms.IEPart_ID= r.IEPart_ID


	--select 'IE' Table_Name, @@RowCount Record_Count
    EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID, @LOGTYPE = 'Information', @NAMEOFSPROC = @PROCNAME, @LOGMESSAGE = 'ProductStructure_Effectivity Load' , @DATAVALUE = @@ROWCOUNT;

    EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID, @LOGTYPE = 'Information', @NAMEOFSPROC = @PROCNAME, @LOGMESSAGE = 'Execution completed' , @DATAVALUE = NULL;

		END TRY
		BEGIN CATCH
			DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
			    @ERRORLINE INT= ERROR_LINE(),
		    	@LOGMESSAGE VARCHAR(MAX);

	        SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
            EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID, @LOGTYPE = 'Error', @NAMEOFSPROC = @PROCNAME, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;
		END CATCH;
	END;
