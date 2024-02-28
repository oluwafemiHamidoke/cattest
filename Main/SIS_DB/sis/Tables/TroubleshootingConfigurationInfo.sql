CREATE TABLE [sis].[TroubleshootingConfigurationInfo](
	[TroubleshootingConfigurationInfo_ID] [int] NOT NULL,
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
),
CONSTRAINT [FK_TroubleshootingConfigurationInfo_Configuration_ID] FOREIGN KEY([Configuration_ID]) REFERENCES [sis].[ConfigurationInfo] ([Configuration_ID]),
CONSTRAINT [FK_TroubleshootingConfigurationInfo_CIDCodeDetails] FOREIGN KEY([CIDCodeDetails_ID]) REFERENCES [sis].[CIDCodeDetails] ([CIDCodeDetails_ID]),
CONSTRAINT [FK_TroubleshootingConfigurationInfo_FMICodeDetails] FOREIGN KEY([FMICodeDetails_ID]) REFERENCES [sis].[FMICodeDetails] ([FMICodeDetails_ID]),
CONSTRAINT [FK_TroubleshootingConfigurationInfo_TroubleshootingIllustrationDetails] FOREIGN KEY([TroubleshootingIllustrationDetails_ID]) REFERENCES [sis].[TroubleshootingIllustrationDetails] ([TroubleshootingIllustrationDetails_ID]),
CONSTRAINT [FK_TroubleshootingConfigurationInfo_MIDCodeDetails] FOREIGN KEY([MIDCodeDetails_ID]) REFERENCES [sis].[MIDCodeDetails] ([MIDCodeDetails_ID]),
CONSTRAINT [FK_TroubleshootingConfigurationInfo_SerialNumberPrefix] FOREIGN KEY([SerialNumberPrefix_ID]) REFERENCES [sis].[SerialNumberPrefix] ([SerialNumberPrefix_ID]),
CONSTRAINT [FK_TroubleshootingConfigurationInfo_SerialNumberRange] FOREIGN KEY([SerialNumberRange_ID]) REFERENCES [sis].[SerialNumberRange] ([SerialNumberRange_ID]),
CONSTRAINT [FK_TroubleshootingConfigurationInfo_InfoType] FOREIGN KEY([InfoType_ID]) REFERENCES [sis].[InfoType] ([InfoType_ID])
);
GO
CREATE NONCLUSTERED INDEX [TroubleshootingConfigurationInfo_SerialNumberRangeID]
ON [sis].[TroubleshootingConfigurationInfo] ([SerialNumberRange_ID])