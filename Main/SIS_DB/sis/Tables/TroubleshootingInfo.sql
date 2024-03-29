CREATE TABLE [sis].[TroubleshootingInfo](
	[TroubleshootingInfo_ID]        [int]               NOT NULL,
	[SerialNumberPrefix_ID]         [int]               NOT NULL,
	[SerialNumberRange_ID]          [int]               NOT NULL,
	[CodeID]                        [int]               NOT NULL,
	[MIDCodeDetails_ID]             [int]               NOT NULL,
	[CIDCodeDetails_ID]             [int]               NOT NULL,
	[FMICodeDetails_ID]             [int]               NOT NULL,
	[TroubleshootingIllustrationDetails_ID] [int]       NULL,
	[IE_ID]                         [int]               NULL,
	[InfoType_ID]                   [int]               NOT NULL,
	[hasGuidedTroubleshooting]      [bit]               NULL,
	[UpdatedTime]                   [datetime]          NULL,
	CONSTRAINT [PK_TroubleshootingInfo_TroubleshootingInfo_ID] PRIMARY KEY CLUSTERED ([TroubleshootingInfo_ID] ASC),
	CONSTRAINT [FK_TroubleshootingInfo_CIDCodeDetails] FOREIGN KEY([CIDCodeDetails_ID]) REFERENCES [sis].[CIDCodeDetails] ([CIDCodeDetails_ID]),
	CONSTRAINT [FK_TroubleshootingInfo_FMICodeDetails] FOREIGN KEY([FMICodeDetails_ID]) REFERENCES [sis].[FMICodeDetails] ([FMICodeDetails_ID]),
	CONSTRAINT [FK_TroubleshootingInfo_TroubleshootingIllustrationDetails] FOREIGN KEY([TroubleshootingIllustrationDetails_ID]) REFERENCES [sis].[TroubleshootingIllustrationDetails] ([TroubleshootingIllustrationDetails_ID]),
	CONSTRAINT [FK_TroubleshootingInfo_IE] FOREIGN KEY([IE_ID]) REFERENCES [sis].[IE] ([IE_ID]),
	CONSTRAINT [FK_TroubleshootingInfo_MIDCodeDetails] FOREIGN KEY([MIDCodeDetails_ID]) REFERENCES [sis].[MIDCodeDetails] ([MIDCodeDetails_ID]),
	CONSTRAINT [FK_TroubleshootingInfo_SerialNumberPrefix] FOREIGN KEY([SerialNumberPrefix_ID]) REFERENCES [sis].[SerialNumberPrefix] ([SerialNumberPrefix_ID]),
	CONSTRAINT [FK_TroubleshootingInfo_SerialNumberRange] FOREIGN KEY([SerialNumberRange_ID]) REFERENCES [sis].[SerialNumberRange] ([SerialNumberRange_ID]),
	CONSTRAINT [FK_TroubleshootingInfo_InfoType] FOREIGN KEY([InfoType_ID]) REFERENCES [sis].[InfoType] ([InfoType_ID])

);

GO
CREATE NONCLUSTERED INDEX [IX_TroubleshootingInfo_IDs]
   ON [sis].[TroubleshootingInfo] (SerialNumberPrefix_ID, SerialNumberRange_ID, MIDCodeDetails_ID, CIDCodeDetails_ID, FMICodeDetails_ID, IE_ID)
   INCLUDE (hasGuidedTroubleshooting, CodeID);
GO
CREATE NONCLUSTERED INDEX [TroubleshootingInfo_SerialNumberRangeID]
   ON [sis].[TroubleshootingInfo] (SerialNumberRange_ID);
GO

CREATE NONCLUSTERED INDEX [TroubleshootingInfo_IEID]
ON [sis].[TroubleshootingInfo] ([IE_ID]);
GO

CREATE NONCLUSTERED INDEX [IX_TroubleshootingInfo_CodeID] ON 
[sis].[TroubleshootingInfo] ([CodeID]) 
INCLUDE (SerialNumberPrefix_ID, SerialNumberRange_ID, CIDCodeDetails_ID, MIDCodeDetails_ID, FMICodeDetails_ID);
GO
