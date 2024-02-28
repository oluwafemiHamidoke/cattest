-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181002
-- Description: Truncate tables in sis schema.  Full reload.
-- =============================================
CREATE PROCEDURE [sis].[Truncate_All]

AS
BEGIN
    SET NOCOUNT ON

BEGIN TRY

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
Declare @ProcessID uniqueidentifier = NewID()

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution started', NULL)

--Truncate all tables in sis schema
Truncate table [sis].[AsShippedEngine]
Truncate table [sis].[AsShippedPart]
Truncate table [sis].[AsShippedPart_Effectivity]
Truncate table [sis].[CaptivePrime]
Truncate table [sis].[IEPart]
Truncate table [sis].[IEPart_Effectivity]
Truncate table [sis].[IEPart_Illustration_Relation]
Truncate table [sis].[Illustration]
Truncate table [sis].[Illustration_File]
Truncate table [sis].[Language]
Truncate table [sis].[Media]
Truncate table [sis].[Media_Effectivity]
Truncate table [sis].[Media_Translation]
Truncate table [sis].[Part]
Truncate table [sis].[Part_AsShippedEngine_Relation]
Truncate table [sis].[Part_AsShippedPart_Relation]
Truncate table [sis].[Part_IEPart_Relation]
Truncate table [sis].[Part_IEPart_Relation_Translation]
Truncate table [sis].[Part_Translation]
Truncate table [sis].[MediaSection]
Truncate table [sis].[MediaSection_Translation]
Truncate table [sis].[MediaSequence]
Truncate table [sis].[MediaSequence_Effectivity]
Truncate table [sis].[MediaSequence_Translation]
Truncate table [sis].[Product_Relation]
Truncate table [sis].[ProductFamily]
Truncate table [sis].[ProductFamily_Translation]
Truncate table [sis].[ProductStructure]
Truncate table [sis].[ProductStructure_IEPart_Relation]
Truncate table [sis].[ProductStructure_Translation]
Truncate table [sis].[ProductSubfamily]
Truncate table [sis].[ProductSubfamily_Translation]
Truncate table [sis].[Related_Part_Relation]
Truncate table [sis].[SalesModel]
Truncate table [sis].[SerializedComponent_Effectivity]
Truncate table [sis].[SerialNumberPrefix]
Truncate table [sis].[SerialNumberRange]
Truncate table [sis].[Supersession_Part_Relation]
Truncate table [sis].[SupersessionChain]
Truncate table [sis].[SupersessionChain_Part_Relation]

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Truncate All Complete', @@RowCount)

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'Execution completed', NULL)

END TRY

BEGIN CATCH 

DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
DECLARE @ERROELINE INT= ERROR_LINE()

Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Error', @ProcName, 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE, NULL)

END CATCH

END