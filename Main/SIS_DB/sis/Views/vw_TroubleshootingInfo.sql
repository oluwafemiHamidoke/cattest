CREATE VIEW [sis].[vw_TroubleshootingInfo]
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
	FROM sis.TroubleshootingInfo2 TI
	JOIN  sis.TroubleshootingInfoIERelation TR
	ON
	TR.TroubleshootingInfo_ID=TI.TroubleshootingInfo_ID