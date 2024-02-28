CREATE TABLE [sis].[ProductSubfamily] (
    [ProductSubfamily_ID] INT          NOT NULL,
    [Subfamily_Code]      VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Product_Subfamily] PRIMARY KEY CLUSTERED ([ProductSubfamily_ID] ASC)
);