CREATE TABLE [sis_stage].[Product_Relation] (
    [SerialNumberPrefix_ID] INT  NOT NULL,
    [SalesModel_ID]         INT  NOT NULL,
    [ProductSubfamily_ID]   INT  NOT NULL,
    [ProductFamily_ID]      INT  NOT NULL,
    [Shipped_Date]          DATE NOT NULL,
    CONSTRAINT [PK_Product_Relation] PRIMARY KEY CLUSTERED ([SerialNumberPrefix_ID] ASC, [SalesModel_ID] ASC, [ProductSubfamily_ID] ASC, [ProductFamily_ID] ASC)
);