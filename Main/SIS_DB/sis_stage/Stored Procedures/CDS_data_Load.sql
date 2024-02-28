-- =============================================
-- Create Date: 12072022
-- Description: Load proc for below tables
-- CDS_BlobDetails
-- CDS_CIDCodeDetails
-- CDS_FMICodeDetails
-- CDS_MIDCodeDetails
-- CDS_TroubleshootingInfo
-- =============================================
CREATE PROCEDURE [sis_stage].[CDS_data_Load] (@DEBUG BIT = 'FALSE')
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @ProcName VARCHAR(200) = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID),
        		@ProcessID uniqueidentifier = NewID(),
                @DEFAULT_ORGCODE VARCHAR(12) = SISWEB_OWNER_STAGING._getDefaultORGCODE();

        EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution started', @DATAVALUE = NULL;

		BEGIN TRANSACTION;

				-- CDS_CIDCodeDetails
				INSERT INTO sis_stage.CIDCodeDetails ([CIDCode], [CIDType], [CIDDescription])
				SELECT DISTINCT CIDCode, CIDType, CIDDescription
				FROM CDS.CDS_CIDCodeDetails

                EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'CIDCodeDetails', @DATAVALUE = @@RowCount;


				-- CDS_FMICodeDetails
				INSERT INTO sis_stage.FMICodeDetails ([FMICode], [FMIType], [FMIDescription])
				SELECT DISTINCT FMICode, FMIType, FMIDescription
				FROM CDS.CDS_FMICodeDetails

				EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'FMICodeDetails', @DATAVALUE = @@RowCount;


				-- CDS_MIDCodeDetails
				INSERT INTO sis_stage.MIDCodeDetails ([MIDCode], [MIDType], [MIDDescription])
				SELECT DISTINCT MIDCode, MIDType, MIDDescription
				FROM CDS.CDS_MIDCodeDetails

				EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'MIDCodeDetails', @DATAVALUE = @@RowCount;


				-- CDS_BlobDetails
				INSERT INTO sis_stage.TroubleshootingIllustrationDetails
				    ([SerialNumberPrefix_ID], [SerialNumberRange_ID], [BlobRefID], [BlobType],[Media_ID])
				SELECT DISTINCT SerialNumberPrefix_ID, SerialNumberRange_ID, BlobRefID, BlobType, sm.Media_ID
				FROM CDS.CDS_BlobDetails cbd
				JOIN sis.SerialNumberPrefix snp ON snp.Serial_Number_Prefix = cbd.SNP
				JOIN sis.SerialNumberRange snr ON snr.Start_Serial_Number = cbd.SNBegin AND snr.End_Serial_Number = cbd.SNEnd
				LEFT JOIN sis.Media sm ON sm.Media_Number = cbd.MediaNo	

                EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'TroubleshootingIllustrationDetails', @DATAVALUE = @@RowCount;

				-- CDS_ConfigurationInfo

				INSERT INTO [sis_stage].[ConfigurationInfo]
				(
					[Configuration_ID],
					[Name],
					[UpdatedBy],
					[UpdatedTime],
					[CreatedBy],
					[CreatedTime],
					[IsDeleted],
					[Abbreviation]
				)
				SELECT 
					[ID],
					[Name],
					[UpdatedBy],
					[UpdatedTime],
					[CreatedBy],
					[CreatedTime],
					[IsDeleted],
					[Abbreviation]
				FROM 
				[CDS].[CDS_ConfigurationInfo]
  

				-- CDS_TroubleshootingInfo
					INSERT INTO sis_stage.TroubleshootingInfo(
				    [SerialNumberPrefix_ID],
				    [SerialNumberRange_ID],
				    [CodeID],
				    [MIDCodeDetails_ID],
				    [CIDCodeDetails_ID],
				    [FMICodeDetails_ID],
				    [TroubleshootingIllustrationDetails_ID],
				    [IE_ID],
				    [InfoType_ID],
				    [hasGuidedTroubleshooting],
				    [UpdatedTime])
				SELECT DISTINCT snp.SerialNumberPrefix_ID,
				    snr.SerialNumberRange_ID,
				    CodeID,
				    MIDCodeDetails_ID,
				    CIDCodeDetails_ID,
				    FMICodeDetails_ID,
				    TroubleshootingIllustrationDetails_ID,
				    IE_ID,
				    68 InfoType_ID,
				    IsCovered,
				    UpdatedTime
				FROM CDS.CDS_TroubleshootingInfo cti
				JOIN sis_stage.MIDCodeDetails mid ON cti.MID = mid.MIDCode
				JOIN sis_stage.CIDCodeDetails cid ON cti.CIDCode = cid.CIDCode AND cti.CIDType = cid.CIDType
				JOIN sis_stage.FMICodeDetails FMI ON cti.FMICode = FMI.FMICode AND cti.FMIType = FMI.FMIType
				LEFT JOIN sis_stage.IE ie ON LOWER(cti.IEControlNumber) = ie.IESystemControlNumber
				JOIN sis_stage.SerialNumberPrefix snp ON cti.Prefix = snp.Serial_Number_Prefix
				JOIN sis_stage.SerialNumberRange snr ON cti.BeginRange = snr.Start_Serial_Number AND cti.EndRange = snr.End_Serial_Number
				LEFT JOIN sis_stage.TroubleshootingIllustrationDetails tid ON tid.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID AND tid.SerialNumberRange_ID = snr.SerialNumberRange_ID
				WHERE cti.CodeIsDeleted = 0

                EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'TroubleshootingInfo', @DATAVALUE = @@RowCount;


		;WITH TroubleshootingInfo2_CTE AS
				(
					SELECT DISTINCT snp.SerialNumberPrefix_ID,
				    snr.SerialNumberRange_ID,
				    CodeID,
				    MIDCodeDetails_ID,
				    CIDCodeDetails_ID,
				    FMICodeDetails_ID,
				    TroubleshootingIllustrationDetails_ID,
		--		     IE_ID,
				    68 InfoType_ID,
				    IsCovered,
				    UpdatedTime
				FROM CDS.CDS_TroubleshootingInfo cti
				JOIN sis_stage.MIDCodeDetails mid ON cti.MID = mid.MIDCode
				JOIN sis_stage.CIDCodeDetails cid ON cti.CIDCode = cid.CIDCode AND cti.CIDType = cid.CIDType
				JOIN sis_stage.FMICodeDetails FMI ON cti.FMICode = FMI.FMICode AND cti.FMIType = FMI.FMIType
				LEFT JOIN sis_stage.IE ie ON LOWER(cti.IEControlNumber) = ie.IESystemControlNumber
				JOIN sis_stage.SerialNumberPrefix snp ON cti.Prefix = snp.Serial_Number_Prefix
				JOIN sis_stage.SerialNumberRange snr ON cti.BeginRange = snr.Start_Serial_Number AND cti.EndRange = snr.End_Serial_Number
				LEFT JOIN sis_stage.TroubleshootingIllustrationDetails tid ON tid.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID AND tid.SerialNumberRange_ID = snr.SerialNumberRange_ID
				WHERE cti.CodeIsDeleted = 0
				 )
				INSERT INTO  sis_stage.TroubleshootingInfo2
					(
				    [SerialNumberPrefix_ID],
				    [SerialNumberRange_ID],
				    [CodeID],
				    [MIDCodeDetails_ID],
				    [CIDCodeDetails_ID],
				    [FMICodeDetails_ID],
				    [TroubleshootingIllustrationDetails_ID],
				    [InfoType_ID],
				    [hasGuidedTroubleshooting],
				    [UpdatedTime])
					SELECT * FROM TroubleshootingInfo2_CTE;


        EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'TroubleshootingInfo2 Load', @DATAVALUE = @@RowCount;



		;WITH TroubleshootingInfoIERelation_CTE AS
			(
				SELECT DISTINCT 
				tr.TroubleshootingInfo_ID,
				snp.SerialNumberPrefix_ID,
				snr.SerialNumberRange_ID,
				cti.CodeID,
				mid.MIDCodeDetails_ID,
				cid.CIDCodeDetails_ID,
				FMI.FMICodeDetails_ID,
				tid.TroubleshootingIllustrationDetails_ID,
				IE_ID,
				68 InfoType_ID,
				IsCovered,
				cti.UpdatedTime
				FROM CDS.CDS_TroubleshootingInfo cti
				JOIN sis_stage.MIDCodeDetails mid ON cti.MID = mid.MIDCode
				JOIN sis_stage.CIDCodeDetails cid ON cti.CIDCode = cid.CIDCode AND cti.CIDType = cid.CIDType
				JOIN sis_stage.FMICodeDetails FMI ON cti.FMICode = FMI.FMICode AND cti.FMIType = FMI.FMIType
				LEFT JOIN sis_stage.IE ie ON LOWER(cti.IEControlNumber) = ie.IESystemControlNumber
				JOIN sis_stage.SerialNumberPrefix snp ON cti.Prefix = snp.Serial_Number_Prefix
				JOIN sis_stage.SerialNumberRange snr ON cti.BeginRange = snr.Start_Serial_Number AND cti.EndRange = snr.End_Serial_Number
				LEFT JOIN sis_stage.TroubleshootingIllustrationDetails tid ON tid.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID AND tid.SerialNumberRange_ID = snr.SerialNumberRange_ID
				LEFT JOIN sis_stage.TroubleshootingInfo2 tr
				ON
				(
					tr.SerialNumberPrefix_ID=snp.SerialNumberPrefix_ID
				AND tr.SerialNumberRange_ID=snr.SerialNumberRange_ID
				AND tr.CodeID=cti.CodeID
				AND tr.MIDCodeDetails_ID=mid.MIDCodeDetails_ID
				AND tr.CIDCodeDetails_ID=cid.CIDCodeDetails_ID
				AND tr.FMICodeDetails_ID=FMI.FMICodeDetails_ID
				AND ISNULL(tr.TroubleshootingIllustrationDetails_ID,999999999)=ISNULL(tid.TroubleshootingIllustrationDetails_ID,999999999)
				AND tr.InfoType_ID=68
				AND ISNULL(tr.hasGuidedTroubleshooting,999999999)=ISNULL(cti.IsCovered,999999999)
				AND tr.UpdatedTime=cti.UpdatedTime
				)
				WHERE cti.CodeIsDeleted = 0
			)
			INSERT INTO  sis_stage.TroubleshootingInfoIERelation 
			SELECT distinct TroubleshootingInfo_ID,IE_ID FROM TroubleshootingInfoIERelation_CTE

			EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'TroubleshootingInfoIERelation Load', @DATAVALUE = @@RowCount;


		;WITH TroubleshootingConfigurationInfo_CTE AS
				(
					SELECT DISTINCT 
					snp.SerialNumberPrefix_ID,
				    snr.SerialNumberRange_ID,
					con.Configuration_ID,
				    CodeID,
				    MIDCodeDetails_ID,
				    CIDCodeDetails_ID,
				    FMICodeDetails_ID,
				    TroubleshootingIllustrationDetails_ID,
				    68 InfoType_ID,
				    IsCovered,
				    cti.UpdatedTime
				FROM CDS.CDS_TroubleshootingConfigurationInfo cti
				JOIN sis_stage.MIDCodeDetails mid ON cti.MID = mid.MIDCode
				JOIN sis_stage.CIDCodeDetails cid ON cti.CIDCode = cid.CIDCode AND cti.CIDType = cid.CIDType
				JOIN sis_stage.FMICodeDetails FMI ON cti.FMICode = FMI.FMICode AND cti.FMIType = FMI.FMIType
				LEFT JOIN sis_stage.IE ie ON LOWER(cti.IEControlNumber) = ie.IESystemControlNumber
				JOIN sis_stage.SerialNumberPrefix snp ON cti.Prefix = snp.Serial_Number_Prefix
				JOIN sis_stage.SerialNumberRange snr ON cti.BeginRange = snr.Start_Serial_Number AND cti.EndRange = snr.End_Serial_Number
				LEFT JOIN sis_stage.TroubleshootingIllustrationDetails tid ON tid.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID AND tid.SerialNumberRange_ID = snr.SerialNumberRange_ID
				 JOIN  [sis_stage].[ConfigurationInfo] con ON con.Configuration_ID=cti.ConfigurationID
				WHERE cti.CodeIsDeleted = 0
				 )
				INSERT INTO  sis_stage.TroubleshootingConfigurationInfo
					(
				    [SerialNumberPrefix_ID],
				    [SerialNumberRange_ID],
					[Configuration_ID],
				    [CodeID],
				    [MIDCodeDetails_ID],
				    [CIDCodeDetails_ID],
				    [FMICodeDetails_ID],
				    [TroubleshootingIllustrationDetails_ID],
				    [InfoType_ID],
				    [hasGuidedTroubleshooting],
				    [UpdatedTime])
					SELECT * FROM TroubleshootingConfigurationInfo_CTE;

            EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'TroubleshootingConfigurationInfo Load', @DATAVALUE = @@RowCount;


			;WITH TroubleshootingConfigurationInfoIERelation_CTE AS
			(
				SELECT DISTINCT 
				tr.TroubleshootingConfigurationInfo_ID,
				snp.SerialNumberPrefix_ID,
				snr.SerialNumberRange_ID,
				con.Configuration_ID,
				cti.CodeID,
				mid.MIDCodeDetails_ID,
				cid.CIDCodeDetails_ID,
				FMI.FMICodeDetails_ID,
				tid.TroubleshootingIllustrationDetails_ID,
				IE_ID,
				68 InfoType_ID,
				IsCovered,
				cti.UpdatedTime
				FROM CDS.CDS_TroubleshootingConfigurationInfo cti
				JOIN sis_stage.MIDCodeDetails mid ON cti.MID = mid.MIDCode
				JOIN sis_stage.CIDCodeDetails cid ON cti.CIDCode = cid.CIDCode AND cti.CIDType = cid.CIDType
				JOIN sis_stage.FMICodeDetails FMI ON cti.FMICode = FMI.FMICode AND cti.FMIType = FMI.FMIType
				LEFT JOIN sis_stage.IE ie ON LOWER(cti.IEControlNumber) = ie.IESystemControlNumber
				JOIN sis_stage.SerialNumberPrefix snp ON cti.Prefix = snp.Serial_Number_Prefix
				JOIN sis_stage.SerialNumberRange snr ON cti.BeginRange = snr.Start_Serial_Number AND cti.EndRange = snr.End_Serial_Number
				LEFT JOIN sis_stage.TroubleshootingIllustrationDetails tid ON tid.SerialNumberPrefix_ID = snp.SerialNumberPrefix_ID AND tid.SerialNumberRange_ID = snr.SerialNumberRange_ID
				JOIN  [sis_stage].[ConfigurationInfo] con ON con.Configuration_ID=cti.ConfigurationID
				JOIN sis_stage.TroubleshootingConfigurationInfo tr
				ON
				(
					tr.SerialNumberPrefix_ID=snp.SerialNumberPrefix_ID
				AND tr.SerialNumberRange_ID=snr.SerialNumberRange_ID
				AND tr.Configuration_ID=con.Configuration_ID
				AND tr.CodeID=cti.CodeID
				AND tr.MIDCodeDetails_ID=mid.MIDCodeDetails_ID
				AND tr.CIDCodeDetails_ID=cid.CIDCodeDetails_ID
				AND tr.FMICodeDetails_ID=FMI.FMICodeDetails_ID
				AND ISNULL(tr.TroubleshootingIllustrationDetails_ID,999999999)=ISNULL(tid.TroubleshootingIllustrationDetails_ID,999999999)
				AND tr.InfoType_ID=68
				AND ISNULL(tr.hasGuidedTroubleshooting,999999999)=ISNULL(cti.IsCovered,999999999)
				AND tr.UpdatedTime=cti.UpdatedTime
				)
				WHERE cti.CodeIsDeleted = 0
			)
			INSERT INTO  sis_stage.TroubleshootingConfigurationInfoIERelation 
			SELECT distinct TroubleshootingConfigurationInfo_ID,IE_ID FROM TroubleshootingConfigurationInfoIERelation_CTE;

				EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'TroubleshootingConfigurationInfoIERelation Load', @DATAVALUE = @@RowCount;
		
		COMMIT;

		WAITFOR DELAY '00:00:01'
		EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Information', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = 'Execution completed' , @DATAVALUE = NULL;

	END TRY
	BEGIN CATCH
		DECLARE @ERRORMESSAGE NVARCHAR(4000) = ERROR_MESSAGE(),
		    @ERRORLINE INT = ERROR_LINE(),
		    @LOGMESSAGE VARCHAR(MAX);

		SET @LOGMESSAGE = FORMATMESSAGE('LINE %s: %s', CAST(@ERRORLINE AS VARCHAR(10)), CAST(@ERRORMESSAGE AS VARCHAR(4000)));

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

	    EXEC sis_stage.WriteLog @PROCESSID = @ProcessID, @LOGTYPE = 'Error', @NAMEOFSPROC = @ProcName, @LOGMESSAGE = @LOGMESSAGE , @DATAVALUE = NULL;

		RAISERROR ( @LOGMESSAGE, 17, 1 )
		WITH NOWAIT;
	END CATCH

END
GO
