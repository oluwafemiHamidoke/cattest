-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180130
-- Modify date:	2020-03-16 Removed natural Key InfoTypeID
-- Description: Full load [sis_stage].Media_InfoType_Relation
--Exec [sis_stage].[Media_InfoType_Relation_Load]
-- =============================================
CREATE PROCEDURE [sis_stage].[Media_InfoType_Relation_Load]

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
BEGIN TRY

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
		@ProcessID uniqueidentifier = NewID()


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

--Load 
Insert into [sis_stage].[Media_InfoType_Relation]
(
 [Media_ID]
,[InfoType_ID]
)
Select 
 m.Media_ID
,i.InfoType_ID
FROM [SISWEB_OWNER].[LNKMEDIAINFOTYPE] mi
Inner join sis_stage.Media m on mi.MEDIANUMBER = m.Media_Number
inner join sis_stage.InfoType i on i.InfoType_ID = mi.INFOTYPEID

--Load EMP data
Insert into [sis_stage].[Media_InfoType_Relation]
(
 [Media_ID]
,[InfoType_ID]
)
Select
 m.Media_ID
,5 as InfoType_ID
FROM [EMP_STAGING].[MASMEDIA] mm
Inner join sis_stage.Media m on mm.MEDIANUMBER = m.Media_Number


--select 'Media_InfoType_Relation' Table_Name, @@RowCount Record_Count  
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Media_InfoType_Relation Load', @DATAVALUE = @@RowCount;

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