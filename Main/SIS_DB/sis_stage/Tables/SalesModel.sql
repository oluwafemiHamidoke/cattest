CREATE TABLE [sis_stage].[SalesModel] (
    [SalesModel_ID] INT          NULL,
    [Sales_Model]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_SalesModel] PRIMARY KEY CLUSTERED ([Sales_Model] ASC)
);