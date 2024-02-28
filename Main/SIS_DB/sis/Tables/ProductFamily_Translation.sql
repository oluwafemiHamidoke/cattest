CREATE TABLE [sis].[ProductFamily_Translation] (
    [ProductFamily_ID] INT           NOT NULL,
    [Language_ID]      INT           NOT NULL,
    [Family_Name]      VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_Product_Family_Translation] PRIMARY KEY CLUSTERED ([ProductFamily_ID] ASC, [Language_ID] ASC),
    CONSTRAINT [FK_ProductFamily_Translation_Language] FOREIGN KEY ([Language_ID]) REFERENCES [sis].[Language_Details] ([Language_ID]),
    CONSTRAINT [FK_ProductFamily_Translation_Product_Family] FOREIGN KEY ([ProductFamily_ID]) REFERENCES [sis].[ProductFamily] ([ProductFamily_ID])
);