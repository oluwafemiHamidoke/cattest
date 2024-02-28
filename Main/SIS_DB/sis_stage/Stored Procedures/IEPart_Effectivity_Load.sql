
-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180130
-- Modify Date: 20200728 -- Adding SNPTYPE https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/6775/
-- Description: Full load [sis_stage].IEPart_Effectivity
--Exec [sis_stage].[IEPart_Effectivity_Load]
-- Modified By: Kishor Padmanabhan
-- Modified Date: 20220912
-- Modified Reason: Included Media_ID in IEPart_Effiectivity table
-- Associated User Story: 22637
-- Modified Date: 20220919
-- Modified Reason: Moved Part and OfParts column to MediaSequence from IEPart
-- Associated User Story: 21373
-- =============================================
CREATE PROCEDURE [sis_stage].[IEPart_Effectivity_Load]
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

    -- Insert statements for procedure here
BEGIN TRY

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
		@ProcessID uniqueidentifier = NewID()

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

--Load 
Insert into [sis_stage].[IEPart_Effectivity]
(
 [IEPart_ID]
,[SerialNumberPrefix_ID]
,[SerialNumberRange_ID]
,SerialNumberPrefix_Type
,Media_ID
)
Select Distinct 
 ie.[IEPart_ID]
,snp.[SerialNumberPrefix_ID]
,snr.[SerialNumberRange_ID]
,s.SNPTYPE
,m.Media_ID
FROM [SISWEB_OWNER].[LNKPARTSIESNP] s
inner join [SISWEB_OWNER].[LNKMEDIAIEPART] i on s.[IESYSTEMCONTROLNUMBER] = i.[IESYSTEMCONTROLNUMBER]
inner join [sis_stage].[IEPart] ie on ie.[Base_English_Control_Number] =  CASE
													 WHEN i.IETYPE = 'L' THEN CASE i.BASEENGCONTROLNO
																				  WHEN '-' THEN i.IESYSTEMCONTROLNUMBER + '-' + i.MEDIANUMBER
																				  ELSE i.BASEENGCONTROLNO + '-' + i.MEDIANUMBER
																			  END
													 ELSE CASE i.BASEENGCONTROLNO
															  WHEN '-' THEN i.IESYSTEMCONTROLNUMBER
															  ELSE i.BASEENGCONTROLNO
														  END
												 END --and cast(ie.[Part] as varchar(50)) = isnull(i.PART, 1)
inner join [sis_stage].[SerialNumberPrefix] snp on  s.[SNP] = snp.[Serial_Number_Prefix] --1057402
inner join [sis_stage].[SerialNumberRange] snr on s.[BEGINNINGRANGE] = snr.[Start_Serial_Number] and s.[ENDRANGE] = snr.[End_Serial_Number]
INNER JOIN [sis_stage].[Media] m ON i.[MEDIANUMBER] = m.[Media_Number]

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'IEPart_Effectivity Load', @DATAVALUE = @@RowCount;


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
