
-- =============================================
-- Author:      Davide Moraschi
-- Create Date: 20200623
-- Description: Load data into CaptivePrime_Serial
-- =============================================
CREATE PROCEDURE sis_stage.CaptivePrime_Serial_Load (@FORCE_LOAD BIT = 'FALSE' -- not used, for future enhancements and consistency with other procs
												   ,@DEBUG      BIT = 'FALSE') 
AS
BEGIN
	SET XACT_ABORT,NOCOUNT ON;
	BEGIN TRY
		DECLARE @MERGED_ROWS INT              = 0
			   ,@PROCNAME    VARCHAR(200)     = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			   ,@PROCESSID   UNIQUEIDENTIFIER = NEWID()
			   ,@LOGMESSAGE  VARCHAR(MAX);

		DECLARE @MERGE_RESULTS_CAPTIVEPRIME_SERIAL TABLE (ACTIONTYPE                    NVARCHAR(10)
														 ,Media_ID                      INT NOT NULL
														 ,Prime_SerialNumber            CHAR(8) NOT NULL
														 ,Captive_SerialNumber          CHAR(8) NOT NULL
														 ,Prime_SerialNumberPrefix_ID   INT NOT NULL
														 ,Captive_SerialNumberPrefix_ID INT NOT NULL
		                                                 ,Prime_SerialNumberRange_ID    INT NOT NULL
		                                                 ,Captive_SerialNumberRange_ID  INT NOT NULL
														 ,Attachment_Type               CHAR(2) NOT NULL);

		BEGIN TRANSACTION;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'CaptivePrime_Serial Load started',@DATAVALUE = NULL;

		BEGIN
			SET @LOGMESSAGE = 'Executing load: ' + IIF(@FORCE_LOAD = 1,'Force Load = TRUE','Force Load = FALSE');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;

			/* MERGE Country command */
			WITH CaptivePrime_Serial_VALUES
				 AS (SELECT PSNP.SerialNumberPrefix_ID AS Prime_SerialNumberPrefix_ID,
				            CSNP.SerialNumberPrefix_ID AS Captive_SerialNumberPrefix_ID,
				            CAST(C2P.PRIMESERIALNUMBER AS CHAR(8)) AS Prime_SerialNumber,
				            CAST(C2P.CAPTIVESERIALNUMBER AS CHAR(8)) AS Captive_SerialNumber,
				            M.Media_ID,
				            PSNR.SerialNumberRange_ID As Prime_SerialNumberRange_ID,
				            CSNR.SerialNumberRange_ID As Captive_SerialNumberRange_ID,
				            CAST(C2P.ATTACHMENTTYPE AS CHAR(2)) AS Attachment_Type
					 FROM SISWEB_OWNER.LNKCAPTIVETOPRIME AS C2P
						  JOIN sis_stage.Media AS M ON M.Media_Number = C2P.MEDIANUMBER
						  JOIN sis_stage.SerialNumberPrefix AS PSNP ON PSNP.Serial_Number_Prefix = CAST(LEFT(C2P.PRIMESERIALNUMBER,3) AS VARCHAR(3))
						  JOIN sis_stage.SerialNumberPrefix AS CSNP ON CSNP.Serial_Number_Prefix = CAST(LEFT(C2P.CAPTIVESERIALNUMBER,3) AS VARCHAR(3))
                          JOIN sis_stage.SerialNumberRange  As PSNR ON PSNR.Start_Serial_Number = try_cast(Substring(ltrim(rtrim(C2P.PRIMESERIALNUMBER)), 4, 5) as int) and PSNR.End_Serial_Number = try_cast(Substring(ltrim(rtrim(C2P.PRIMESERIALNUMBER)), 4, 5) as int)
                          JOIN sis_stage.SerialNumberRange  As CSNR ON CSNR.Start_Serial_Number = try_cast(Substring(ltrim(rtrim(C2P.CAPTIVESERIALNUMBER)), 4, 5) as int) and CSNR.End_Serial_Number = try_cast(Substring(ltrim(rtrim(C2P.CAPTIVESERIALNUMBER)), 4, 5) as int))
				 MERGE INTO sis.CaptivePrime_Serial tgt
				 USING CaptivePrime_Serial_VALUES src
				 ON src.Media_ID = tgt.Media_ID AND 
					src.Prime_SerialNumber = tgt.Prime_SerialNumber AND 
					src.Captive_SerialNumber = tgt.Captive_SerialNumber
				 WHEN NOT MATCHED BY TARGET
					   THEN
					   INSERT(Media_ID,Prime_SerialNumber,Captive_SerialNumber,Prime_SerialNumberPrefix_ID,Captive_SerialNumberPrefix_ID,Prime_SerialNumberRange_ID,Captive_SerialNumberRange_ID,Attachment_Type)
					   VALUES (src.Media_ID,src.Prime_SerialNumber,src.Captive_SerialNumber,src.Prime_SerialNumberPrefix_ID,src.Captive_SerialNumberPrefix_ID,src.Prime_SerialNumberRange_ID,src.Captive_SerialNumberRange_ID,src.Attachment_Type)
				 WHEN NOT MATCHED BY SOURCE
					   THEN DELETE
				 -- should not happen as prefix is a function of the serial number, but just in case
				 WHEN MATCHED AND EXISTS
				 (
					 SELECT src.Prime_SerialNumberPrefix_ID,src.Captive_SerialNumberPrefix_ID,src.Prime_SerialNumberRange_ID,src.Captive_SerialNumberRange_ID,src.Attachment_Type
					 EXCEPT
					 SELECT tgt.Prime_SerialNumberPrefix_ID,tgt.Captive_SerialNumberPrefix_ID,tgt.Prime_SerialNumberRange_ID,tgt.Captive_SerialNumberRange_ID,tgt.Attachment_Type
				 )
					   THEN UPDATE SET tgt.Prime_SerialNumberPrefix_ID = src.Prime_SerialNumberPrefix_ID,tgt.Captive_SerialNumberPrefix_ID = src.Captive_SerialNumberPrefix_ID,
                        tgt.Prime_SerialNumberRange_ID = src.Prime_SerialNumberRange_ID,tgt.Captive_SerialNumberRange_ID = src.Captive_SerialNumberRange_ID,tgt.Attachment_Type = src.Attachment_Type
				 OUTPUT $ACTION,COALESCE(inserted.Media_ID,deleted.Media_ID) Media_ID,COALESCE(inserted.Prime_SerialNumber,deleted.Prime_SerialNumber) Prime_SerialNumber,COALESCE(
				 inserted.Captive_SerialNumber,deleted.Captive_SerialNumber) Captive_SerialNumber,COALESCE(inserted.Prime_SerialNumberPrefix_ID,deleted.Prime_SerialNumberPrefix_ID)
				 Prime_SerialNumberPrefix_ID,COALESCE(inserted.Captive_SerialNumberPrefix_ID,deleted.Captive_SerialNumberPrefix_ID) Captive_SerialNumberPrefix_ID,
                COALESCE(inserted.Captive_SerialNumberRange_ID,deleted.Captive_SerialNumberRange_ID) Captive_SerialNumberRange_ID,
                COALESCE(inserted.Prime_SerialNumberRange_ID,deleted.Prime_SerialNumberRange_ID) Captive_SerialNumberRange_ID,
                COALESCE(inserted.Attachment_Type,deleted.Attachment_Type) Attachment_Type
						INTO @MERGE_RESULTS_CAPTIVEPRIME_SERIAL;

			/* MERGE command */

			SELECT @MERGED_ROWS = @@ROWCOUNT;
			SET @LOGMESSAGE = IIF(@DEBUG = 'TRUE',
			(
				SELECT
				(
					SELECT COUNT(*)
					FROM @MERGE_RESULTS_CAPTIVEPRIME_SERIAL AS MR
					WHERE MR.ACTIONTYPE = 'INSERT'
				) AS Inserted,
				(
					SELECT COUNT(*)
					FROM @MERGE_RESULTS_CAPTIVEPRIME_SERIAL AS MR
					WHERE MR.ACTIONTYPE = 'UPDATE'
				) AS Updated,
				(
					SELECT COUNT(*)
					FROM @MERGE_RESULTS_CAPTIVEPRIME_SERIAL AS MR
					WHERE MR.ACTIONTYPE = 'DELETE'
				) AS Deleted,
				(
					SELECT MR.ACTIONTYPE,MR.Media_ID,MR.Prime_SerialNumber,MR.Captive_SerialNumber,MR.Prime_SerialNumberPrefix_ID,MR.Captive_SerialNumberPrefix_ID,MR.
					Attachment_Type
					FROM @MERGE_RESULTS_CAPTIVEPRIME_SERIAL AS MR FOR JSON AUTO
				) AS Modified_Rows FOR JSON PATH,WITHOUT_ARRAY_WRAPPER
			),'Modified Rows');
			EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = @MERGED_ROWS;
		END;
		COMMIT;

		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Information',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = 'CaptivePrime_Serial Load completed',@DATAVALUE = NULL;
	END TRY
	BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
			   ,@ERRORLINE    INT            = ERROR_LINE();

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		SET @LOGMESSAGE = 'LINE ' + CAST(@ERRORLINE AS VARCHAR(10)) + ': ' + @ERRORMESSAGE;
		EXEC sis_stage.WriteLog @PROCESSID = @PROCESSID,@LOGTYPE = 'Error',@NAMEOFSPROC = @PROCNAME,@LOGMESSAGE = @LOGMESSAGE,@DATAVALUE = NULL;
	END CATCH;
END;