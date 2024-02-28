


CREATE  Procedure [SISSEARCH].[SIS2NPRPARTHISTORYPERSIST_LOAD]
As
-- =============================================
-- Author:      Paul B. Felix
-- Create Date: 20181019
-- Modify Date: 20200206	removed PERSIST tables dependencies
-- Description: Maintain LNKMEDIAIEPART LASTMODIFIEDDATE
-- Exec SISSEARCH.SIS2NPRPARTHISTORYPERSIST_LOAD
-- =============================================

Begin

BEGIN TRY

SET NOCOUNT ON

Declare @LastInsertDate Datetime

Declare @SPStartTime DATETIME,
		@StepStartTime DATETIME,
		@ProcName VARCHAR(200),
		@SPStartLogID BIGINT,
		@StepLogID BIGINT,
		@RowCount BIGINT,
		@LAPSETIME BIGINT
SET @SPStartTime= GETDATE()
SET @ProcName= OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
 
EXEC @SPStartLogID = SISSEARCH.WriteLog @TIME = @SPStartTime, @NAMEOFSPROC = @ProcName;

/*
[SISWEB_OWNER].[SIS2NPRPARTHISTORY] is being truncated and reloaded.  We need to know the last modified date for 
records in this table so we can trigger modifications when records are updated.  This
section of code adds a last modified date to the [SISWEB_OWNER].[SIS2NPRPARTHISTORY] by maintaining a persistent 
version of the table which includes a last modified date (based on the insert date).

 Davide 20200206
[SISWEB_OWNER_STAGING].[SIS2NPRPARTHISTORY_Merge] procedure now maintains the [SISWEB_OWNER].[SIS2NPRPARTHISTORY] table which is not TRUNCATEd anymore. 
We can therefore eliminate the part of the code that does the MERGE with [SISWEB_OWNER].[SIS2NPRPARTHISTORYPERSIST] and the UPDATE back to [SISWEB_OWNER].[SIS2NPRPARTHISTORY]
*/

--Load persistent table
--The pkey includes all fields in source.  Update will never occcur.  Handling Insert & Delete.

--SET @StepStartTime= GETDATE()
--INSERT INTO SISSEARCH.LOG (LogDateTime, LogType, NameofSproc) VALUES(@StepStartTime, 'Information', @ProcName)
--SET @StepLogID= @@IDENTITY

--Merge [SISWEB_OWNER].[SIS2NPRPARTHISTORYPERSIST] as tgt
--Using
--	(
--	SELECT [PARTNUMBER]
--      ,[HISTORYCHAIN]
--  FROM [SISWEB_OWNER].[SIS2NPRPARTHISTORY]
--	) as src
--On
--	(
--	tgt.[PARTNUMBER] = src.[PARTNUMBER] and
--    tgt.[HISTORYCHAIN] = src.[HISTORYCHAIN]
--	)
--WHEN NOT MATCHED BY TARGET THEN  
--	INSERT ([PARTNUMBER],[HISTORYCHAIN],[LASTMODIFIEDDATE]) 
--	VALUES ([PARTNUMBER],[HISTORYCHAIN],getdate()) 
--WHEN NOT MATCHED BY SOURCE THEN 
--	Delete;

----Add LastModifiedDate to source if it does not exist.
--IF NOT EXISTS (
--  SELECT * 
--  FROM   sys.columns
--  WHERE  object_id = OBJECT_ID(N'[SISWEB_OWNER].[SIS2NPRPARTHISTORY]') 
--         AND name = 'LASTMODIFIEDDATE'
--)
--Alter table [SISWEB_OWNER].[SIS2NPRPARTHISTORY]
--Add [LASTMODIFIEDDATE] datetime2(6) NULL

----Update source last modified date
--Update src
--set src.[LASTMODIFIEDDATE] = tgt.LASTMODIFIEDDATE
--From [SISWEB_OWNER].[SIS2NPRPARTHISTORY] src
--inner join [SISWEB_OWNER].[SIS2NPRPARTHISTORYPERSIST] tgt on 
--	tgt.[PARTNUMBER] = src.[PARTNUMBER] and
--	tgt.[HISTORYCHAIN] = src.[HISTORYCHAIN] 
--Where src.[LASTMODIFIEDDATE] <> tgt.LASTMODIFIEDDATE or src.[LASTMODIFIEDDATE] is null

--SET @RowCount= @@RowCount
--Print cast(getdate() as varchar(50)) + ' - SIS2NPRPARTHISTORY LASTMODIFIEDDATE Updates: ' +  cast(@RowCount as varchar(50))

--UPDATE SISSEARCH.LOG
--SET LapseTime= DATEDIFF(SS, @StepStartTime, GETDATE()),
--	LogMessage= 'SIS2NPRPARTHISTORY LASTMODIFIEDDATE Updates',
--	DataValue= @RowCount
--	where LogID= @StepLogID


--Finish
SET @LAPSETIME = DATEDIFF(SS, @SPStartTime, GETDATE());
EXEC SISSEARCH.WriteLog @NAMEOFSPROC = @ProcName, @ISUPDATE = 1,@LAPSETIME = @LAPSETIME, @LOGMESSAGE = 'ExecutedSuccessfully', @LOGID = @SPStartLogID

DELETE FROM SISSEARCH.LOG WHERE DATEDIFF(DD, LogDateTime, GetDate())>30 and NameofSproc= @ProcName

END TRY

BEGIN CATCH 
 DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
         @ERROELINE INT= ERROR_LINE()

declare @error nvarchar(max) = 'LINE '+ CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE
EXEC SISSEARCH.WriteLog @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName,@LOGMESSAGE = @error
END CATCH


End