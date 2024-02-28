CREATE TABLE [sp].[Class_Attribute_Relation] (
    [Class_ID]              INT             NOT NULL,
    [Attribute_ID]          INT             NOT NULL,
    [LastModified_Date]     DATETIME2(7)    NOT NULL,
    CONSTRAINT [PK_Class_Attribute_Relation_Class_ID_Attribute_ID] PRIMARY KEY CLUSTERED ([Class_ID] ASC, [Attribute_ID] ASC),
    CONSTRAINT [FK_Class_Attribute_Relation_Attribute_ID] FOREIGN KEY ([Attribute_ID]) REFERENCES [sp].[Attribute] ([Attribute_ID]),
    CONSTRAINT [FK_Class_Attribute_Relation_Class_ID] FOREIGN KEY ([Class_ID]) REFERENCES [sp].[Class] ([Class_ID])
);
GO
CREATE NONCLUSTERED INDEX NCI_Class_Attribute_Relation_Attribute_ID
ON [sp].[Class_Attribute_Relation] ([Attribute_ID])

