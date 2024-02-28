-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180627
-- Description: High level load sequence for sis schema
/*
Exec [sis_stage].Full_Load_P4
*/
-- =============================================
CREATE PROCEDURE [sis_stage].[Full_Load_P4]
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

Exec [sis_stage].[AsShipped_DDLPrep]
RAISERROR ('[AsShipped_DDLPrep]', 0, 1) WITH NOWAIT

Exec [sis_stage].[AsShipped_EngineSourePrep]
RAISERROR ('[AsShipped_EngineSourePrep]]', 0, 1) WITH NOWAIT

Exec [sis_stage].[AsShipped_MachineSourcePrep]
RAISERROR ('[AsShipped_MachineSourcePrep]', 0, 1) WITH NOWAIT

Exec [sis_stage].[AsShipped_MachineSource2Prep]
RAISERROR ('[AsShipped_MachineSource2Prep]', 0, 1) WITH NOWAIT

Exec [sis_stage].[AsShipped_MachineSource3Prep]
RAISERROR ('[AsShipped_MachineSource3Prep]', 0, 1) WITH NOWAIT

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution completed', NULL)

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
