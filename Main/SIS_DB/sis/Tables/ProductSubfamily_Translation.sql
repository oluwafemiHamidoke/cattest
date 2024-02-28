CREATE TABLE [sis].[ProductSubfamily_Translation] (
    [ProductSubfamily_ID] INT           NOT NULL,
    [Language_ID]         INT           NOT NULL,
    [Subfamily_Name]      VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_Product_Subfamily_Translation] PRIMARY KEY CLUSTERED ([ProductSubfamily_ID] ASC, [Language_ID] ASC),
    CONSTRAINT [FK_ProductSubfamily_Translation_Language] FOREIGN KEY ([Language_ID]) REFERENCES [sis].[Language_Details] ([Language_ID]),
    CONSTRAINT [FK_ProductSubfamily_Translation_Product_Subfamily] FOREIGN KEY ([ProductSubfamily_ID]) REFERENCES [sis].[ProductSubfamily] ([ProductSubfamily_ID])
);