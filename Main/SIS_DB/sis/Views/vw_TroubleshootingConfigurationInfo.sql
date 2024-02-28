CREATE VIEW [sis].[vw_TroubleshootingConfigurationInfo]
AS
SELECT
	TI.SerialNumberPrefix_ID, 
	TI.SerialNumberRange_ID, 
	TI.CodeID, 
	TI.MIDCodeDetails_ID, 
	TI.CIDCodeDetails_ID, 
	TI.FMICodeDetails_ID, 
	TI.TroubleshootingIllustrationDetails_ID, 
	TR.IE_ID, 
	TI.hasGuidedTroubleshooting, 
	TI.UpdatedTime
	FROM sis_stage.TroubleshootingConfigurationInfo TI
	JOIN  sis_stage.TroubleshootingConfigurationInfoIERelation TR
	ON
	TR.TroubleshootingConfigurationInfo_ID=TI.TroubleshootingConfigurationInfo_ID