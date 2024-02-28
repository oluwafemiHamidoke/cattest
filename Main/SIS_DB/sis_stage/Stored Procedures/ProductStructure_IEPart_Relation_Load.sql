
-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20180214
-- Description: Full load [sis_stage].[[ProductStructure_IEPart_Relation_Translatione_Load]
--Exec [sis_stage].[[ProductStructure_IEPart_Relation_Load]
-- =============================================
CREATE PROCEDURE sis_stage.ProductStructure_IEPart_Relation_Load
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
Insert into [sis_stage].[ProductStructure_IEPart_Relation]
(
[ProductStructure_ID]
 ,[IEPart_ID]
 ,[Media_ID]
 ,[SerialNumberPrefix_ID]
 ,[SerialNumberRange_ID]
)
SELECT distinct 
      cast(l.[PSID] as int) PSID
	  ,iep.[IEPart_ID] IEPart_ID
	  ,m.Media_ID
	  ,snp.SerialNumberPrefix_ID
	  ,snr.SerialNumberRange_ID
  FROM [SISWEB_OWNER].[LNKIEPSID] l
inner join [SISWEB_OWNER].[LNKMEDIAIEPART] ie on l.[IESYSTEMCONTROLNUMBER] = ie.[IESYSTEMCONTROLNUMBER]
inner join SISWEB_OWNER.LNKPARTSIESNP pies on l.[IESYSTEMCONTROLNUMBER] = pies.[IESYSTEMCONTROLNUMBER]
inner join [sis_stage].[IEPart] iep on CASE
												 WHEN ie.IETYPE = 'L' THEN CASE ie.BASEENGCONTROLNO
																			   WHEN '-' THEN ie.IESYSTEMCONTROLNUMBER + '-' + ie.MEDIANUMBER
																			   ELSE ie.BASEENGCONTROLNO + '-' + ie.MEDIANUMBER
																		   END
												 ELSE CASE ie.BASEENGCONTROLNO
														  WHEN '-' THEN ie.IESYSTEMCONTROLNUMBER
														  ELSE ie.BASEENGCONTROLNO
													  END
											 END = iep.[Base_English_Control_Number]
inner join [sis_stage].[Media] m on m.Media_Number = l.MEDIANUMBER
inner join [sis_stage].[SerialNumberPrefix] snp on  pies.[SNP] = snp.[Serial_Number_Prefix] --1057402
inner join [sis_stage].[SerialNumberRange] snr on pies.[BEGINNINGRANGE] = snr.[Start_Serial_Number] and pies.[ENDRANGE] = snr.[End_Serial_Number]

--select '[ProductStructure_IEPart_Relation' Table_Name, @@RowCount Record_Count
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'ProductStructure_IEPart_Relation Load' , @DATAVALUE = @@RowCount;

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
