CREATE TABLE [sis_stage].[TroubleshootingConfigurationInfo](
	[TroubleshootingConfigurationInfo_ID] [int] IDENTITY(1,1) NOT NULL,
	[SerialNumberPrefix_ID] [int] NOT NULL,
	[SerialNumberRange_ID] [int] NOT NULL,
	[Configuration_ID] [int] NOT NULL,
	[CodeID] [int] NOT NULL,
	[MIDCodeDetails_ID] [int] NOT NULL,
	[CIDCodeDetails_ID] [int] NOT NULL,
	[FMICodeDetails_ID] [int] NOT NULL,
	[TroubleshootingIllustrationDetails_ID] [int] NULL,
	[InfoType_ID] [int] NOT NULL,
	[hasGuidedTroubleshooting] [bit] NULL,
	[UpdatedTime] [datetime] NULL,
 CONSTRAINT [PK_TroubleshootingConfigurationInfo_TroubleshootingConfigurationInfo_ID] PRIMARY KEY CLUSTERED 
(
	[TroubleshootingConfigurationInfo_ID] ASC
)
)