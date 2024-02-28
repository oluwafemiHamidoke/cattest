
-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180214
-- Description: Full load [sis_stage].[ProductStructure_Translatione_Load]
--Exec [sis_stage].[ProductStructure_Translation_Load]
-- =============================================
CREATE PROCEDURE [sis_stage].[ProductStructure_Translation_Load]
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
Insert into [sis_stage].[ProductStructure_Translation]
(
 [ProductStructure_ID]
,[Language_ID]
,[Description]
)
SELECT cast([PRODUCTSTRUCTUREID] as int) [PRODUCTSTRUCTUREID]
,l.[Language_ID]
,max([PRODUCTSTRUCTUREDESCRIPTION]) Description
  FROM [SISWEB_OWNER].[MASPRODUCTSTRUCTURE] p
  inner join
	(
	Select l.[Language_ID], m.[LANGUAGEINDICATOR]
	From [sis_stage].[Language] l
	inner join [SISWEB_OWNER].[MASLANGUAGE] m on l.Legacy_Language_Indicator = m.LANGUAGEINDICATOR and l.Default_Language=1
	) l on p.LANGUAGEINDICATOR = l.LANGUAGEINDICATOR
  Group by
 cast([PRODUCTSTRUCTUREID] as int)
 ,l.[Language_ID]

--select 'ProductStructure_Translation' Table_Name, @@RowCount Record_Count
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'ProductStructure_Translation Load' , @DATAVALUE = @@RowCount;

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
