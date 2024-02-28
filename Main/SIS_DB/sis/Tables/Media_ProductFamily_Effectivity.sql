CREATE TABLE [sis].[Media_ProductFamily_Effectivity] (
    [Media_ID]         INT NOT NULL,
    [ProductFamily_ID] INT NOT NULL,
    [LastModified_Date] DATETIME2(0) NOT NULL DEFAULT(GETDATE()),
    CONSTRAINT [PK_Media_ProductFamily_Effectivity] PRIMARY KEY CLUSTERED ([ProductFamily_ID] ASC, [Media_ID] ASC),
    CONSTRAINT [FK_Media_ProductFamily_Effectivity_Media] FOREIGN KEY ([Media_ID]) REFERENCES [sis].[Media] ([Media_ID]),
    CONSTRAINT [FK_Media_ProductFamily_Effectivity_ProductFamily] FOREIGN KEY ([ProductFamily_ID]) REFERENCES [sis].[ProductFamily] ([ProductFamily_ID])
);
GO
CREATE NONCLUSTERED INDEX [Media_ProductFamily_Effectivity_Media_ID]
ON [sis].[Media_ProductFamily_Effectivity] ([Media_ID])

