CREATE TABLE [sis].[IEPart_Illustration_Relation] (
    [Illustration_Relation_ID] INT NOT NULL,
    [Illustration_ID]          INT NOT NULL,
    [IEPart_ID]                INT NOT NULL,
    [Graphic_Number]           INT NOT NULL,
    CONSTRAINT [PK_Illustration_Relation] PRIMARY KEY CLUSTERED ([Illustration_Relation_ID] ASC),
    CONSTRAINT [FK_IEPart_Illustration_Relation_IEPart] FOREIGN KEY ([IEPart_ID]) REFERENCES [sis].[IEPart] ([IEPart_ID]),
    CONSTRAINT [FK_Illustration_Relation_Illustration] FOREIGN KEY ([Illustration_ID]) REFERENCES [sis].[Illustration] ([Illustration_ID])
);
GO
Create nonclustered index IX_IEPart_Illustration_Relation_IEPart_ID on sis.IEPart_Illustration_Relation (IEPart_ID)  ;