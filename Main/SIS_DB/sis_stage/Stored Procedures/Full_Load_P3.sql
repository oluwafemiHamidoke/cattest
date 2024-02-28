-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180424
-- Description: High level load sequence for sis schema
/*
Exec [sis_stage].Full_Load_P3
*/
-- =============================================
CREATE PROCEDURE [sis_stage].[Full_Load_P3]
--(
    -- Add the parameters for the stored procedure here
    --<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>,
    --<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
--)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

BEGIN TRY

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
		@ProcessID uniqueidentifier = NewID()

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution started', NULL)

Exec [sis_stage].[Supersession_Part_Relation_Load]
RAISERROR ('[Supersession_Part_Relation_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[SupersessionChain_Load]
RAISERROR ('[SupersessionChain_Load]', 0, 1) WITH NOWAIT

Exec [sis_stage].[CDS_data_Load]
RAISERROR ('[CDS_data_Load]', 0, 1) WITH NOWAIT

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution completed', NULL)

--Run remote sprocs to move data, update targets, and update control
--EXEC sp_execute_remote N'ETLDB',  N'Exec [sis_stage].[Supersession_vDiff_Local]' 
--EXEC sp_execute_remote N'ETLDB',  N'Exec [sis_stage].[Supersession_Merge]' 

--Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
--Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Remote Diff & Merge Completed', NULL)

END TRY

BEGIN CATCH 

	DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
			@ERROELINE INT= ERROR_LINE(),
			@ErrorSeverity INT = ERROR_SEVERITY(),
			@ErrorState INT = ERROR_STATE()

	Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
	Values (@ProcessID, GETDATE(), 'Error', @ProcName, 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE, NULL)

    RAISERROR (@ERRORMESSAGE, -- Message text.  
               @ErrorSeverity, -- Severity.  
               @ErrorState -- State.  
               );  

END CATCH

END
