CREATE TABLE [sis].[Product_Relation] (
    [SerialNumberPrefix_ID] INT  NOT NULL,
    [SalesModel_ID]         INT  NOT NULL,
    [ProductSubfamily_ID]   INT  NOT NULL,
    [ProductFamily_ID]      INT  NOT NULL,
    [Shipped_Date]          DATE NOT NULL,
    CONSTRAINT [PK_Product_Relation] PRIMARY KEY CLUSTERED ([SerialNumberPrefix_ID] ASC, [SalesModel_ID] ASC, [ProductSubfamily_ID] ASC, [ProductFamily_ID] ASC),
    CONSTRAINT [FK_Product_Relation_ProductFamily] FOREIGN KEY ([ProductFamily_ID]) REFERENCES [sis].[ProductFamily] ([ProductFamily_ID]),
    CONSTRAINT [FK_Product_Relation_ProductSubfamily] FOREIGN KEY ([ProductSubfamily_ID]) REFERENCES [sis].[ProductSubfamily] ([ProductSubfamily_ID]),
    CONSTRAINT [FK_Product_Relation_SalesModel] FOREIGN KEY ([SalesModel_ID]) REFERENCES [sis].[SalesModel] ([SalesModel_ID]),
    CONSTRAINT [FK_Product_Relation_SerialNumberPrefix] FOREIGN KEY ([SerialNumberPrefix_ID]) REFERENCES [sis].[SerialNumberPrefix] ([SerialNumberPrefix_ID])
);
GO
CREATE NONCLUSTERED INDEX IDX_Product_Relation_ProductFamily_ID ON [sis].[Product_Relation] (SerialNumberPrefix_ID,ProductFamily_ID)
GO
CREATE NONCLUSTERED INDEX [IX_NCL_SerialNumberPrefix_ID] 
    ON [sis].[Product_Relation]([SerialNumberPrefix_ID])