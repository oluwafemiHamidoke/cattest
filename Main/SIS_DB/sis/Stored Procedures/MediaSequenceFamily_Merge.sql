-- =============================================
-- Create Date: 11052022
-- Description: Load MediaSequence & Related Table data into MediaSequenceFamily
-- =============================================
CREATE PROCEDURE [sis].[MediaSequenceFamily_Merge]
AS
BEGIN
	SET XACT_ABORT
		,NOCOUNT ON;

BEGIN TRY
		DECLARE @AFFECTED_ROWS INT = 0
			,@LOGMESSAGE VARCHAR(MAX)
			,@ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
			,@ProcessID UNIQUEIDENTIFIER = NEWID()
			,@DEFAULT_ORGCODE VARCHAR(12) = SISWEB_OWNER_STAGING._getDefaultORGCODE();

		EXEC sis.WriteLog @PROCESSID = @ProcessID
			,@LOGTYPE = 'Information'
			,@NAMEOFSPROC = @ProcName
			,@LOGMESSAGE = 'Execution started'
			,@DATAVALUE = NULL;

		BEGIN TRANSACTION;


			SET @AFFECTED_ROWS = NULL

			EXEC sis.WriteLog @PROCESSID = @ProcessID
				,@LOGTYPE = 'Information'
				,@NAMEOFSPROC = @ProcName
				,@LOGMESSAGE = 'Begin Merge'
				,@DATAVALUE = @AFFECTED_ROWS;

			MERGE sis.MediaSequenceFamily AS TARGET
			USING(
			SELECT  
			     med.Media_ID
				,med.Media_Number
				,msec.MediaSection_ID
				,mseq.Arrangement_Indicator
				,mseq.CCR_Indicator
				,mseq.IEPart_ID
				,mseq.IE_ID
				,mseq.IESystemControlNumber
				,mseq.NPR_Indicator
				,mseq.Serviceability_Indicator
				,mseq.Sequence_Number
				,mseq.TypeChange_Indicator
				,mseqe.MediaSequence_ID
				,mseqe.SerialNumberRange_ID
				,medt.Language_ID
				,medt.Media_Origin
				,snp.SerialNumberPrefix_ID
				,snp.Serial_Number_Prefix
				,snr.End_Serial_Number
				,snr.Start_Serial_Number
			FROM sis.SerialNumberPrefix snp
			INNER JOIN sis.MediaSequence_Effectivity mseqe ON (snp.SerialNumberPrefix_ID = mseqe.SerialNumberPrefix_ID)
			INNER JOIN sis.SerialNumberRange snr ON (snr.SerialNumberRange_ID = mseqe.SerialNumberRange_ID)
			INNER JOIN sis_shadow.MediaSequence mseq ON (mseq.MediaSequence_ID = mseqe.MediaSequence_ID)
			INNER JOIN sis.MediaSection msec ON (msec.MediaSection_ID = mseq.MediaSection_ID)
			INNER JOIN sis.Media med ON (med.Media_ID = msec.Media_ID)
			INNER JOIN sis.Media_Translation medt ON (medt.Media_ID = med.Media_ID)
			) AS SOURCE
			ON (
					TARGET.[Language_ID] 		 		= SOURCE.[Language_ID] 		 		  AND
					TARGET.[MediaSection_ID] 		 	= SOURCE.[MediaSection_ID] 			  AND
					TARGET.[MediaSequence_ID] 		 	= SOURCE.[MediaSequence_ID] 		  AND
					TARGET.[Media_ID] 		 			= SOURCE.[Media_ID] 		 		  AND
					TARGET.[SerialNumberPrefix_ID] 		= SOURCE.[SerialNumberPrefix_ID]	  AND
					TARGET.[SerialNumberRange_ID] 		= SOURCE.[SerialNumberRange_ID] 	  
				)
				WHEN MATCHED AND 
					(
					TARGET.Media_Number              <> SOURCE.Media_Number               OR
					TARGET.Arrangement_Indicator     <> SOURCE.Arrangement_Indicator      OR
					TARGET.CCR_Indicator             <> SOURCE.CCR_Indicator              OR
					TARGET.IEPart_ID                 <> SOURCE.IEPart_ID                  OR
					TARGET.IE_ID                     <> SOURCE.IE_ID                      OR
					TARGET.IESystemControlNumber     <> SOURCE.IESystemControlNumber      OR
					TARGET.NPR_Indicator             <> SOURCE.NPR_Indicator              OR
					TARGET.Serviceability_Indicator  <> SOURCE.Serviceability_Indicator   OR
					TARGET.Sequence_Number           <> SOURCE.Sequence_Number            OR
					TARGET.TypeChange_Indicator      <> SOURCE.TypeChange_Indicator       OR
					TARGET.Media_Origin              <> SOURCE.Media_Origin               OR
					TARGET.Serial_Number_Prefix      <> SOURCE.Serial_Number_Prefix       OR
					TARGET.End_Serial_Number         <> SOURCE.End_Serial_Number          OR
					TARGET.Start_Serial_Number       <> SOURCE.Start_Serial_Number
					)
						THEN
							UPDATE
							SET TARGET.Media_Number              = SOURCE.Media_Number              ,
								TARGET.Arrangement_Indicator     = SOURCE.Arrangement_Indicator     ,
								TARGET.CCR_Indicator             = SOURCE.CCR_Indicator             ,
								TARGET.IEPart_ID                 = SOURCE.IEPart_ID                 ,
								TARGET.IE_ID                     = SOURCE.IE_ID                     ,
								TARGET.IESystemControlNumber     = SOURCE.IESystemControlNumber     ,
								TARGET.NPR_Indicator             = SOURCE.NPR_Indicator             ,
								TARGET.Serviceability_Indicator  = SOURCE.Serviceability_Indicator  ,
								TARGET.Sequence_Number           = SOURCE.Sequence_Number           ,
								TARGET.TypeChange_Indicator      = SOURCE.TypeChange_Indicator      ,
								TARGET.Media_Origin              = SOURCE.Media_Origin              ,
								TARGET.Serial_Number_Prefix      = SOURCE.Serial_Number_Prefix      ,
								TARGET.End_Serial_Number         = SOURCE.End_Serial_Number         ,
								TARGET.Start_Serial_Number       = SOURCE.Start_Serial_Number
				WHEN NOT MATCHED BY TARGET
						THEN
							INSERT (
								Media_ID
								,Media_Number
								,MediaSection_ID
								,Arrangement_Indicator
								,CCR_Indicator
								,IEPart_ID
								,IE_ID
								,IESystemControlNumber
								,NPR_Indicator
								,Serviceability_Indicator
								,Sequence_Number
								,TypeChange_Indicator
								,MediaSequence_ID
								,SerialNumberRange_ID
								,Language_ID
								,Media_Origin
								,SerialNumberPrefix_ID
								,Serial_Number_Prefix
								,End_Serial_Number
								,Start_Serial_Number	
								)
							VALUES (
								 SOURCE.Media_ID
								,SOURCE.Media_Number
								,SOURCE.MediaSection_ID
								,SOURCE.Arrangement_Indicator
								,SOURCE.CCR_Indicator
								,SOURCE.IEPart_ID
								,SOURCE.IE_ID
								,SOURCE.IESystemControlNumber
								,SOURCE.NPR_Indicator
								,SOURCE.Serviceability_Indicator
								,SOURCE.Sequence_Number
								,SOURCE.TypeChange_Indicator
								,SOURCE.MediaSequence_ID
								,SOURCE.SerialNumberRange_ID
								,SOURCE.Language_ID
								,SOURCE.Media_Origin
								,SOURCE.SerialNumberPrefix_ID
								,SOURCE.Serial_Number_Prefix
								,SOURCE.End_Serial_Number
								,SOURCE.Start_Serial_Number	
								)
					WHEN NOT MATCHED BY SOURCE
						THEN
							DELETE;

			EXEC sis.WriteLog @PROCESSID = @ProcessID
				,@LOGTYPE = 'Information'
				,@NAMEOFSPROC = @ProcName
				,@LOGMESSAGE = 'Merge Completed'
				,@DATAVALUE = @AFFECTED_ROWS;


		COMMIT;

		WAITFOR DELAY '00:00:01'

		EXEC sis.WriteLog @PROCESSID = @ProcessID
			,@LOGTYPE = 'Information'
			,@NAMEOFSPROC = @ProcName
			,@LOGMESSAGE = 'Execution Completed'
			,@DATAVALUE = NULL;
END TRY

BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE()
			,@ERRORLINE INT = ERROR_LINE();

		SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s', CAST(@ERRORLINE AS VARCHAR(10)), CAST(@ERRORMESSAGE AS VARCHAR(4000)));

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		EXEC sis.WriteLog @PROCESSID = @ProcessID
			,@LOGTYPE = 'Error'
			,@NAMEOFSPROC = @ProcName
			,@LOGMESSAGE = @LOGMESSAGE
			,@DATAVALUE = NULL;

		RAISERROR (
				@LOGMESSAGE
				,17
				,1
				)
		WITH NOWAIT;
END CATCH
END
GO