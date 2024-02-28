CREATE TABLE [sis].[IE_StaticIllustration_Relation] (
    [StaticIllustration_ID] INT NOT NULL,
    [IE_ID]                 INT NOT NULL,
    CONSTRAINT [PK_IE_StaticIllustration_Relation] PRIMARY KEY CLUSTERED ([StaticIllustration_ID] ASC, [IE_ID] ASC),
    CONSTRAINT [FK_IE_StaticIllustration_Relation_IE] FOREIGN KEY ([IE_ID]) REFERENCES [sis].[IE] ([IE_ID]),
    CONSTRAINT [FK_IE_StaticIllustration_Relation_StaticIllustration] FOREIGN KEY ([StaticIllustration_ID]) REFERENCES [sis].[StaticIllustration] ([StaticIllustration_ID])
);
GO
CREATE NONCLUSTERED INDEX [IE_StaticIllustration_Relation_IEID]
ON [sis].[IE_StaticIllustration_Relation] ([IE_ID])

