CREATE TABLE [sis].[CCRUpdatesIE_Relation](
	[Update_ID] [int] NOT NULL,
	[Operation_ID] [int] NOT NULL,
	[UpdateTypeIndicator] [char](1) NOT NULL,
	[IE_ID] [int] NOT NULL,
	[LastModifiedDate] [datetime2](6) NULL,
 CONSTRAINT [PK_CCRUPDATES] PRIMARY KEY CLUSTERED 	
(
	[Update_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [sis].[CCRUpdatesIE_Relation]  WITH CHECK ADD  CONSTRAINT [FK_CCRUpdatesIE_Relation_IE_ID] FOREIGN KEY([IE_ID])
REFERENCES [sis].[IE] ([IE_ID])
GO

ALTER TABLE [sis].[CCRUpdatesIE_Relation] CHECK CONSTRAINT [FK_CCRUpdatesIE_Relation_IE_ID]
GO

ALTER TABLE [sis].[CCRUpdatesIE_Relation]  WITH CHECK ADD  CONSTRAINT [FK_CCRUpdatesIE_Relation_Operation_ID] FOREIGN KEY([Operation_ID])
REFERENCES [sis].[CCROperations] ([Operation_ID])
GO

ALTER TABLE [sis].[CCRUpdatesIE_Relation] CHECK CONSTRAINT [FK_CCRUpdatesIE_Relation_Operation_ID]
GO

CREATE NONCLUSTERED INDEX [CCRUpdatesIE_Relation_IEID]
ON [sis].[CCRUpdatesIE_Relation] ([IE_ID])
GO