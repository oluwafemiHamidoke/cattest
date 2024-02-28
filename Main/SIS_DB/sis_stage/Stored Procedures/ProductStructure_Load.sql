
-- =============================================
-- Author:      Paul B. Felix (Modifications by Davide M.)
-- Create Date: 20180214
-- Modify Date: 20200325 Added [Parentage], [MiscSpnIndicator] see https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/5988/
-- Description: Full load [sis_stage].[ProductStructure_Load]
--Exec [sis_stage].[ProductStructure_Load]
-- =============================================
CREATE PROCEDURE [sis_stage].[ProductStructure_Load]
--(
--    -- Add the parameters for the stored procedure here
--    <@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>,
--    <@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
--)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

BEGIN TRY

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
		@ProcessID uniqueidentifier = NewID()

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started' , @DATAVALUE = NULL;

    -- Insert statements for procedure here

--Load
Insert into [sis_stage].[ProductStructure]
(
 [ProductStructure_ID]
,[ParentProductStructure_ID]
,[Parentage]
,[MiscSpnIndicator]
)
SELECT cast([PRODUCTSTRUCTUREID] as int) [PRODUCTSTRUCTUREID]
      ,nullif(max(cast([PARENTPRODUCTSTRUCTUREID] as int)), 0) [PARENTPRODUCTSTRUCTUREID] --Taking max, but there are situations where parent is different for same child.  Exception reported.
	  ,PARENTAGE
	  ,MISCSPNINDICATOR
  FROM [SISWEB_OWNER].[MASPRODUCTSTRUCTURE]
  Group by
 cast([PRODUCTSTRUCTUREID] as int)
	,PARENTAGE
	,MISCSPNINDICATOR

--select 'ProductStructure' Table_Name, @@RowCount Record_Count
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'ProductStructure Load' , @DATAVALUE = @@RowCount;


EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed' , @DATAVALUE = NULL;


END TRY

BEGIN CATCH

	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
			@ERRORLINE INT= ERROR_LINE(),
			@LOGMESSAGE VARCHAR(MAX);

	SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s',CAST(@ERRORLINE AS VARCHAR(10)),CAST(@ERRORMESSAGE AS VARCHAR(4000)));
    EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;

END CATCH

END
