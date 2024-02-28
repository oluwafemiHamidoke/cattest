CREATE TABLE [sis].[As_Shipped_Relation] (
    [As_Built_Relation] INT NOT NULL,
    [Child_Item_ID]     INT NOT NULL,
    [Parent_Item_ID]    INT NULL,
    [Product_ID]        INT NOT NULL,
    CONSTRAINT [PK_As_Built_Relation] PRIMARY KEY CLUSTERED ([As_Built_Relation] ASC)
);
GO
