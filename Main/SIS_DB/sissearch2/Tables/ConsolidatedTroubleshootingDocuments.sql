CREATE TABLE [sissearch2].[ConsolidatedTroubleshootingDocuments](
	[ID] varchar(200) NOT NULL,
	[Codes] [varchar](500) NULL,
	[SerialNumbers] [varchar](500) NULL,
	[hasGuidedTroubleshooting] [bit] NULL,
	[InformationType] [varchar](500) NOT NULL,
	[Profile] [varchar](500) NULL,
   PRIMARY KEY CLUSTERED ([ID] ASC) 
);

GO
ALTER TABLE [sissearch2].[ConsolidatedTroubleshootingDocuments] ENABLE CHANGE_TRACKING WITH(TRACK_COLUMNS_UPDATED = OFF);