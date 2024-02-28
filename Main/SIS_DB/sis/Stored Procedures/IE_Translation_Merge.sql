
/* ==================================================================================================================================================== 
Author:			Paul B. Felix (+Davide Moraschi)
Create date:	2018-10-02
Modify date:	2019-09-04 Copied from [sis].[SMCS_Translation_Merge] and renamed
Modify date:	2020-03-02 Added [IEControlNumber] and [Published_Date] to [sis_stage].[IE_Translation]
Modify date:	2020-03-23 Added File_Location and Mime_Type https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/5972/
Modify date:	2021-01-27 Added [Date_Updated] https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/9581/
-- Description: Merge external table [sis_stage].[IE_Translation_Diff] into [sis].[IE_Translation]
Modified By:	Kishor Padmanabhan
Modified At:	20220905
Modified Reason: Add LastModified_Date column in IE_Translation table.
Work Item  :	22323
====================================================================================================================================================== */
CREATE PROCEDURE sis.IE_Translation_Merge
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE @PROCNAME VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID);
		DECLARE @PROCESSID UNIQUEIDENTIFIER = NEWID();

		INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Execution started',NULL);

		----Soft Delete
		--Update x
		--Set x.[isDeleted] = 1
		--FROM [sis].[IE_Translation] x
		--Inner join [sis_stage].[IE_Translation_Diff] s on ON s.IE_ID = x.IE_ID AND 
		--													s.Language_ID = x.Language_ID
		--Where s.Operation = 'Delete'
		--Insert into [sis].[Log] ([ProcessID],[LogDateTime],[LogType],[NameofSproc],[LogMessage],[DataValue])
		--Values (@ProcessID, GETDATE(), 'Information', @ProcName, 'IE_Translation Soft Delete', @@RowCount)
		--Update
		UPDATE x
		  SET x.Title = s.Title,x.IEControlNumber = s.IEControlNumber,x.Published_Date = s.Published_Date,x.File_Location = s.File_Location,x.Mime_Type = s.Mime_Type,x.
		  Date_Updated = s.Date_Updated,x.EnglishControlNumber = s.EnglishControlNumber, x.LastModified_Date = s.LastModified_Date
		  ,x.File_Size_Byte = s.File_Size_Byte
		FROM sis.IE_Translation x
			 INNER JOIN sis_stage.IE_Translation_Diff s ON s.IE_ID = x.IE_ID AND 
														   s.Language_ID = x.Language_ID
		WHERE s.Operation = 'Update';

		INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE_Translation Update',@@ROWCOUNT);

		--Insert
		INSERT INTO sis.IE_Translation (IE_ID,Language_ID,Title,IEControlNumber,Published_Date,File_Location,Mime_Type,Date_Updated,EnglishControlNumber, LastModified_Date, File_Size_Byte) 
			   SELECT IE_ID,Language_ID,Title,IEControlNumber,Published_Date,File_Location,Mime_Type,Date_Updated,EnglishControlNumber, LastModified_Date, File_Size_Byte
			   FROM sis_stage.IE_Translation_Diff
			   WHERE Operation = 'Insert';

		INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'IE_Translation Insert',@@ROWCOUNT);

  		Update STATISTICS sis.IE_Translation with fullscan 

		INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Information',@PROCNAME,'Execution completed',NULL);
	END TRY
	BEGIN CATCH

		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ERROELINE INT = ERROR_LINE();

		INSERT INTO sis.Log(ProcessID,LogDateTime,LogType,NameofSproc,LogMessage,DataValue)
		VALUES (@PROCESSID,GETDATE(),'Error',@PROCNAME,'LINE ' + CAST(@ERROELINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE,NULL);
	END CATCH;
END;