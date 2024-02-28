CREATE TABLE [sis].[TroubleshootingInfoIERelation](
	[TroubleshootingInfo_ID] [int] NOT NULL,
	[IE_ID] [int] NULL,
	CONSTRAINT [FK_TroubleshootingInfoIERelation_IE_ID] FOREIGN KEY([IE_ID]) REFERENCES [sis].[IE] ([IE_ID]),
	CONSTRAINT [FK_TroubleshootingInfoIERelation_TroubleshootingInfo_ID] FOREIGN KEY([TroubleshootingInfo_ID]) REFERENCES [sis].[TroubleshootingInfo2] ([TroubleshootingInfo_ID])
);
GO
CREATE NONCLUSTERED INDEX [TroubleshootingInfoIERelation_IEID]
ON [sis].[TroubleshootingInfoIERelation] ([IE_ID])