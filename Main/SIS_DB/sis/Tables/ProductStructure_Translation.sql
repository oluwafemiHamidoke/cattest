CREATE TABLE [sis].[ProductStructure_Translation] (
    [ProductStructure_ID] INT            NOT NULL,
    [Language_ID]         INT            NOT NULL,
    [Description]         NVARCHAR (250) NULL,
    CONSTRAINT [PK_ProductStructure_Translation] PRIMARY KEY CLUSTERED ([ProductStructure_ID] ASC, [Language_ID] ASC),
    CONSTRAINT [FK_ProductStructure_Translation_Language] FOREIGN KEY ([Language_ID]) REFERENCES [sis].[Language_Details] ([Language_ID]),
    CONSTRAINT [FK_ProductStructure_Translation_ProductStructure] FOREIGN KEY ([ProductStructure_ID]) REFERENCES [sis].[ProductStructure] ([ProductStructure_ID])
);


GO
CREATE NONCLUSTERED INDEX XI_ProductStructure_Translation_Language_ID_Description
ON [sis].[ProductStructure_Translation] ([Language_ID])
INCLUDE ([Description])
