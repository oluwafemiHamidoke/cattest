CREATE TABLE [sis].[ProductStructure_IEPart_Relation] (
    [ProductStructure_ID] INT NOT NULL,
    [IEPart_ID]           INT NOT NULL,
    [Media_ID]            INT NOT NULL,
	[SerialNumberPrefix_ID] INT NOT NULL DEFAULT 0,
	[SerialNumberRange_ID]  INT NOT NULL DEFAULT 0,
    [LastModified_Date] DATETIME2(0) NOT NULL DEFAULT(GETDATE()),
    CONSTRAINT [PK_ProductStructure_IEPart_Relation] PRIMARY KEY CLUSTERED ([ProductStructure_ID] ASC, [IEPart_ID] ASC, [Media_ID] ASC, [SerialNumberPrefix_ID] ASC, [SerialNumberRange_ID] ASC),
    CONSTRAINT [FK_ProductStructure_IEPart_Relation_IEPart] FOREIGN KEY ([IEPart_ID]) REFERENCES [sis].[IEPart] ([IEPart_ID]),
    CONSTRAINT [FK_ProductStructure_IEPart_Relation_Media] FOREIGN KEY ([Media_ID]) REFERENCES [sis].[Media] ([Media_ID]),
    CONSTRAINT [FK_ProductStructure_IEPart_Relation_ProductStructure] FOREIGN KEY ([ProductStructure_ID]) REFERENCES [sis].[ProductStructure] ([ProductStructure_ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_ProductStructure_IEPart_Relation_IEPart_ID] ON [sis].[ProductStructure_IEPart_Relation]
(
	[IEPart_ID] ASC,
	[Media_ID] ASC,
	[ProductStructure_ID] ASC

)
GO
CREATE NONCLUSTERED INDEX ProductStructure_IEPart_Relation_SNP_ID ON sis.ProductStructure_IEPart_Relation ([SerialNumberPrefix_ID] ASC)
GO
CREATE NONCLUSTERED INDEX [ProductStructure_IEPart_Relation_Media_ID]
ON [sis].[ProductStructure_IEPart_Relation] ([Media_ID])