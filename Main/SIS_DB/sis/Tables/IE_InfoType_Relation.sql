CREATE TABLE [sis].[IE_InfoType_Relation] (
    [InfoType_ID] INT NOT NULL,
    [IE_ID]       INT NOT NULL,
    CONSTRAINT [PK_IE_InfoType_Relation] PRIMARY KEY CLUSTERED ([InfoType_ID] ASC, [IE_ID] ASC),
    CONSTRAINT [FK_IE_InfoType_Relation_IE] FOREIGN KEY ([IE_ID]) REFERENCES [sis].[IE] ([IE_ID]),
    CONSTRAINT [FK_IE_InfoType_Relation_InfoType] FOREIGN KEY ([InfoType_ID]) REFERENCES [sis].[InfoType] ([InfoType_ID])
);
GO
Create nonclustered index IX_IE_InfoType_Relation_IE_ID on sis.IE_InfoType_Relation (IE_ID)  ;
