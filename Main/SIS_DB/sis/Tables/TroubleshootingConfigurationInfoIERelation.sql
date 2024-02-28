CREATE TABLE [sis].[TroubleshootingConfigurationInfoIERelation](
	[TroubleshootingConfigurationInfo_ID] [int] NOT NULL,
	[IE_ID] [int] NULL,
	CONSTRAINT [FK_TroubleshootingConfigurationInfoIERelation_IE_ID] FOREIGN KEY([IE_ID]) REFERENCES [sis].[IE] ([IE_ID]),
	CONSTRAINT [FK_TroubleshootingConfigurationInfoIERelation_TroubleshootingConfigurationInfo_ID] FOREIGN KEY([TroubleshootingConfigurationInfo_ID]) REFERENCES [sis].[TroubleshootingConfigurationInfo] ([TroubleshootingConfigurationInfo_ID])
);
GO
CREATE NONCLUSTERED INDEX [TroubleshootingConfigurationInfoIERelation_IEID]
ON [sis].[TroubleshootingConfigurationInfoIERelation] ([IE_ID])