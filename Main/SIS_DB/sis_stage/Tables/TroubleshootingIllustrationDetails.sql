CREATE TABLE [sis_stage].[TroubleshootingIllustrationDetails](
	[TroubleshootingIllustrationDetails_ID]        [int] IDENTITY(1,1) NOT NULL,
	[SerialNumberPrefix_ID]                        [int]               NOT NULL,
	[SerialNumberRange_ID]                         [int]               NOT NULL,
	[BlobRefID]                                    [int]               NOT NULL,
    	[BlobType]                                     [nvarchar](200)     NOT NULL,
	[Media_ID]				       [int]               NULL,
	CONSTRAINT [PK_TroubleshootingIllustrationDetails_TroubleshootingIllustrationDetails_ID] PRIMARY KEY CLUSTERED ([TroubleshootingIllustrationDetails_ID] ASC)
	)

GO
