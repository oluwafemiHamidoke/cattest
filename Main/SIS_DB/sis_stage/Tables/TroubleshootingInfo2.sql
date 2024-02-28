CREATE TABLE [sis_stage].[TroubleshootingInfo2](
	[TroubleshootingInfo_ID] [int] IDENTITY(1,1) NOT NULL,
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
)
)