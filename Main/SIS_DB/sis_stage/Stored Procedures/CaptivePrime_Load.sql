-- =============================================
-- Author:      Paul B. Felix + D. Moraschi
-- Create Date: 20180710
-- Modify Date: 20200625 https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/6508/ 
--						 https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/6454/
-- Modify Date: 20200908 https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/7192/
-- Description: Full load [sis_stage].CaptivePrime
--Exec [sis_stage].CaptivePrime_Load
-- =============================================
CREATE PROCEDURE [sis_stage].[CaptivePrime_Load]

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

BEGIN TRY

Declare @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
		@ProcessID uniqueidentifier = NewID()

EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started' , @DATAVALUE = NULL;

--Load 
Insert into [sis_stage].[CaptivePrime] ([Prime_SerialNumberPrefix_ID], [Captive_SerialNumberPrefix_ID], [Captive_SerialNumberRange_ID], [Media_ID], [Document_Title], [Configuration_Type])
Select --Source includes media in grain
p.SerialNumberPrefix_ID, c.SerialNumberPrefix_ID, r.SerialNumberRange_ID, me.Media_ID, m.DOCUMENTTITLE, m.CONFIGURATIONTYPE
From [SISWEB_OWNER].[MASSNP] m
inner join [sis_stage].SerialNumberPrefix p on m.PRIMESERIALNUMBERPREFIX = p.Serial_Number_Prefix
inner join [sis_stage].SerialNumberPrefix c on m.CAPTIVESERIALNUMBERPREFIX = c.Serial_Number_Prefix
inner join [sis_stage].SerialNumberRange r on m.BEGINNINGRANGE = r.Start_Serial_Number and m.ENDRANGE = r.End_Serial_Number
JOIN sis_stage.Media me on me.Media_Number=m.MEDIANUMBER
-- Davide 20200625: filtering duplicate document titles with same prime/captive prefix but incorrect begin and end range.
 WHERE
		m.PRIMESERIALNUMBERPREFIX = m.CAPTIVESERIALNUMBERPREFIX AND
		CHARINDEX(CAST(m.BEGINNINGRANGE AS VARCHAR)+'-',m.DOCUMENTTITLE) > 0
		AND (
			CHARINDEX(CAST(m.ENDRANGE AS VARCHAR),m.DOCUMENTTITLE) > 0
			OR (CHARINDEX('UP',m.DOCUMENTTITLE) > 0 AND m.ENDRANGE=99999)
			)
;

WITH D([Prime_SerialNumberPrefix_ID], [Captive_SerialNumberPrefix_ID], [Captive_SerialNumberRange_ID], [Media_ID], [Document_Title], [Configuration_Type], R) 
AS (
Select --Source includes media in grain
p.SerialNumberPrefix_ID, c.SerialNumberPrefix_ID, r.SerialNumberRange_ID, me.Media_ID, m.DOCUMENTTITLE, m.CONFIGURATIONTYPE, RANK()OVER(PARTITION BY p.SerialNumberPrefix_ID, c.SerialNumberPrefix_ID, r.SerialNumberRange_ID, me.Media_ID ORDER BY ID DESC) R
From [SISWEB_OWNER].[MASSNP] m
inner join [sis_stage].SerialNumberPrefix p on m.PRIMESERIALNUMBERPREFIX = p.Serial_Number_Prefix
inner join [sis_stage].SerialNumberPrefix c on m.CAPTIVESERIALNUMBERPREFIX = c.Serial_Number_Prefix
inner join [sis_stage].SerialNumberRange r on m.BEGINNINGRANGE = r.Start_Serial_Number and m.ENDRANGE = r.End_Serial_Number
JOIN sis_stage.Media me on me.Media_Number=m.MEDIANUMBER
-- Davide 20200625: filtering duplicate document titles with different prime/captive prefix and multiple begin and end range.
 WHERE
		m.PRIMESERIALNUMBERPREFIX <> m.CAPTIVESERIALNUMBERPREFIX
)
Insert into [sis_stage].[CaptivePrime] ([Prime_SerialNumberPrefix_ID], [Captive_SerialNumberPrefix_ID], [Captive_SerialNumberRange_ID], [Media_ID], [Document_Title], [Configuration_Type])
SELECT [Prime_SerialNumberPrefix_ID], [Captive_SerialNumberPrefix_ID], [Captive_SerialNumberRange_ID], [Media_ID], [Document_Title], [Configuration_Type]
FROM D
WHERE R = 1
;

--select 'CaptivePrime' Table_Name, @@RowCount Record_Count
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'CaptivePrime Load' , @DATAVALUE = @@RowCount;

--Insert natural keys into key table
Insert into [sis_stage].[CaptivePrime_Key] (Prime_SerialNumberPrefix_ID, Captive_SerialNumberPrefix_ID, Captive_SerialNumberRange_ID,Media_ID)
Select s.Prime_SerialNumberPrefix_ID, s.Captive_SerialNumberPrefix_ID, s.Captive_SerialNumberRange_ID,s.Media_ID
From [sis_stage].[CaptivePrime] s
Left outer join [sis_stage].[CaptivePrime_Key] k on s.Prime_SerialNumberPrefix_ID = k.Prime_SerialNumberPrefix_ID and s.Captive_SerialNumberPrefix_ID = k.Captive_SerialNumberPrefix_ID and s.Captive_SerialNumberRange_ID = k.Captive_SerialNumberRange_ID and s.Media_ID = k.Media_ID
Where k.CaptivePrime_ID is null

--Key table load
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'CaptivePrime Key Load' , @DATAVALUE = @@RowCount;

Insert into [sis_stage].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'CaptivePrime Key Load', @@RowCount)

--Update stage table with surrogate keys from key table
Update s
Set CaptivePrime_ID = k.CaptivePrime_ID
From [sis_stage].[CaptivePrime] s
inner join [sis_stage].[CaptivePrime_Key] k on s.Prime_SerialNumberPrefix_ID = k.Prime_SerialNumberPrefix_ID and s.Captive_SerialNumberPrefix_ID = k.Captive_SerialNumberPrefix_ID and s.Captive_SerialNumberRange_ID = k.Captive_SerialNumberRange_ID and s.Media_ID = k.Media_ID
where s.CaptivePrime_ID is null

--Surrogate Update
EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'CaptivePrime Update Surrogate' , @DATAVALUE = @@RowCount;

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
