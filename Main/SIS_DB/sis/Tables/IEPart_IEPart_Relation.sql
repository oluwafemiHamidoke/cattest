CREATE TABLE [sis].[IEPart_IEPart_Relation]
(
	[IEPart_ID]			int NOT NULL,
	[Related_IEPart_ID]	int NOT NULL,
	[Media_ID]          int NOT NULL,
	CONSTRAINT [PK_IEPart_Relation] 
	PRIMARY KEY CLUSTERED ([IEPart_ID] ASC, [Related_IEPart_ID] ASC, [Media_ID] ASC),
	CONSTRAINT [FK_IEPart_IEPart_Relation_IEPart] FOREIGN KEY ([IEPart_ID]) REFERENCES [sis].[IEPart] ([IEPart_ID]),
	CONSTRAINT [FK_IEPart_IEPart_Relation_Related_IEPart] FOREIGN KEY ([Related_IEPart_ID]) REFERENCES [sis].[IEPart] ([IEPart_ID]),
    CONSTRAINT [FK_Media_ID] FOREIGN KEY ([Media_ID]) REFERENCES [sis].[Media] ([Media_ID])
);

GO
CREATE NONCLUSTERED INDEX [IDX_IEPART_IEPART_Relation]
ON [sis].[IEPart_IEPart_Relation] ([Related_IEPart_ID],[Media_ID])
GO
CREATE NONCLUSTERED INDEX [IEPart_IEPart_Relation_Media_ID]
ON [sis].[IEPart_IEPart_Relation] ([Media_ID])