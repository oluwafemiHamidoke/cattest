CREATE TABLE [sis].[IE_Illustration_Relation] (
    [Illustration_ID] INT NOT NULL,
    [IE_ID]           INT NOT NULL,
    [Graphic_Number]  INT NOT NULL,
    CONSTRAINT [PK_IE_Illustration_Relation_1] PRIMARY KEY CLUSTERED ([Illustration_ID] ASC, [IE_ID] ASC, [Graphic_Number] ASC),
    CONSTRAINT [FK_IE_Illustration_Relation_IE] FOREIGN KEY ([IE_ID]) REFERENCES [sis].[IE] ([IE_ID]),
    CONSTRAINT [FK_IE_Illustration_Relation_Illustration] FOREIGN KEY ([Illustration_ID]) REFERENCES [sis].[Illustration] ([Illustration_ID])
);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key', @level0type = N'SCHEMA', @level0name = N'sis', @level1type = N'TABLE', @level1name = N'IE_Illustration_Relation', @level2type = N'COLUMN', @level2name = N'IE_ID';
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key', @level0type = N'SCHEMA', @level0name = N'sis', @level1type = N'TABLE', @level1name = N'IE_Illustration_Relation', @level2type = N'COLUMN', @level2name = N'Illustration_ID';
GO

Create nonclustered index IX_IE_Illustration_Relation_IE_ID on sis.IE_Illustration_Relation (IE_ID)  ;