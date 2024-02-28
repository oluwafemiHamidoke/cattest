CREATE TABLE [sis].[TroubleshootingIllustrationDetails](
	[TroubleshootingIllustrationDetails_ID]        [int]               NOT NULL,
	[SerialNumberPrefix_ID]                        [int]               NOT NULL,
	[SerialNumberRange_ID]                         [int]               NOT NULL,
	[BlobRefID]                                    [int]               NOT NULL,
    	[BlobType]                                     [nvarchar](200)     NOT NULL,
	[Media_ID]                                     [int]               NULL,
	CONSTRAINT [PK_TroubleshootingIllustrationDetails_TroubleshootingIllustrationDetails_ID] PRIMARY KEY CLUSTERED ([TroubleshootingIllustrationDetails_ID] ASC),
	CONSTRAINT [FK_TroubleshootingIllustrationDetails_SerialNumberPrefix] FOREIGN KEY([SerialNumberPrefix_ID]) REFERENCES [sis].[SerialNumberPrefix] ([SerialNumberPrefix_ID]),
	CONSTRAINT [FK_TroubleshootingIllustrationDetails_SerialNumberRange] FOREIGN KEY([SerialNumberRange_ID]) REFERENCES [sis].[SerialNumberRange] ([SerialNumberRange_ID])
)
GO
CREATE NONCLUSTERED INDEX [IX_SerialNumberRange_ID] ON [sis].[TroubleshootingIllustrationDetails]
(
	[SerialNumberRange_ID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_NCL_SerialNumberPrefix_ID] 
ON [sis].[TroubleshootingIllustrationDetails]([SerialNumberPrefix_ID])


