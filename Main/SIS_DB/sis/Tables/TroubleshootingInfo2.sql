CREATE TABLE [sis].[TroubleshootingInfo2](
	[TroubleshootingInfo_ID] [int] NOT NULL,
	[SerialNumberPrefix_ID] [int] NOT NULL,
	[SerialNumberRange_ID] [int] NOT NULL,
	[CodeID] [int] NOT NULL,
	[MIDCodeDetails_ID] [int] NOT NULL,
	[CIDCodeDetails_ID] [int] NOT NULL,
	[FMICodeDetails_ID] [int] NOT NULL,
	[TroubleshootingIllustrationDetails_ID] [int] NULL,
	[InfoType_ID] [int] NOT NULL,
	[hasGuidedTroubleshooting] [bit] NULL,
	[UpdatedTime] [datetime] NULL,
 CONSTRAINT [PK_TroubleshootingInfo2_TroubleshootingInfo_ID] PRIMARY KEY CLUSTERED 
(
	[TroubleshootingInfo_ID] ASC
),
CONSTRAINT  [FK_TroubleshootingInfo2_CIDCodeDetails] FOREIGN KEY([CIDCodeDetails_ID]) REFERENCES [sis].[CIDCodeDetails] ([CIDCodeDetails_ID]),
CONSTRAINT  [FK_TroubleshootingInfo2_FMICodeDetails] FOREIGN KEY([FMICodeDetails_ID]) REFERENCES [sis].[FMICodeDetails] ([FMICodeDetails_ID]),
CONSTRAINT  [FK_TroubleshootingInfo2_TroubleshootingIllustrationDetails] FOREIGN KEY([TroubleshootingIllustrationDetails_ID]) REFERENCES [sis].[TroubleshootingIllustrationDetails] ([TroubleshootingIllustrationDetails_ID]),
CONSTRAINT  [FK_TroubleshootingInfo2_MIDCodeDetails] FOREIGN KEY([MIDCodeDetails_ID]) REFERENCES [sis].[MIDCodeDetails] ([MIDCodeDetails_ID]),
CONSTRAINT  [FK_TroubleshootingInfo2_SerialNumberPrefix] FOREIGN KEY([SerialNumberPrefix_ID]) REFERENCES [sis].[SerialNumberPrefix] ([SerialNumberPrefix_ID]),
CONSTRAINT  [FK_TroubleshootingInfo2_SerialNumberRange] FOREIGN KEY([SerialNumberRange_ID]) REFERENCES [sis].[SerialNumberRange] ([SerialNumberRange_ID]),
CONSTRAINT  [FK_TroubleshootingInfo2_InfoType] FOREIGN KEY([InfoType_ID]) REFERENCES [sis].[InfoType] ([InfoType_ID])
);
GO
CREATE NONCLUSTERED INDEX [TroubleshootingInfo2_SerialNumberRangeID]
ON [sis].[TroubleshootingInfo2] ([SerialNumberRange_ID]);