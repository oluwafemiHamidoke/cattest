CREATE TABLE [sis].[ProductStructure_IE_Relation] (
    [ProductStructure_ID] INT NOT NULL,
    [IE_ID]               INT NOT NULL,
    [Media_ID]            INT NOT NULL,
    CONSTRAINT [PK_ProductStructure_IE_Relation] PRIMARY KEY CLUSTERED ([ProductStructure_ID] ASC, [IE_ID] ASC, [Media_ID] ASC),
    CONSTRAINT [FK_ProductStructure_IE_Relation_IE] FOREIGN KEY ([IE_ID]) REFERENCES [sis].[IE] ([IE_ID]),
    CONSTRAINT [FK_ProductStructure_IE_Relation_Media] FOREIGN KEY ([Media_ID]) REFERENCES [sis].[Media] ([Media_ID]),
    CONSTRAINT [FK_ProductStructure_IE_Relation_ProductStructure] FOREIGN KEY ([ProductStructure_ID]) REFERENCES [sis].[ProductStructure] ([ProductStructure_ID])
);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key', @level0type = N'SCHEMA', @level0name = N'sis', @level1type = N'TABLE', @level1name = N'ProductStructure_IE_Relation', @level2type = N'COLUMN', @level2name = N'IE_ID';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key', @level0type = N'SCHEMA', @level0name = N'sis', @level1type = N'TABLE', @level1name = N'ProductStructure_IE_Relation', @level2type = N'COLUMN', @level2name = N'ProductStructure_ID';
GO

Create nonclustered index IX_ProductStructure_IE_Relation_IE_ID on sis.ProductStructure_IE_Relation (IE_ID)  ;
GO

CREATE NONCLUSTERED INDEX IX_ProductStructure_IE_Relation_Media_ID ON [sis].[ProductStructure_IE_Relation] ([Media_ID])
GO