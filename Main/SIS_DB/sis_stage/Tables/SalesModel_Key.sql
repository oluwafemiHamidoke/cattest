CREATE TABLE [sis_stage].[SalesModel_Key] (
    [SalesModel_ID] INT          IDENTITY (1, 1) NOT NULL,
    [Sales_Model]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_SalesModel_Key] PRIMARY KEY CLUSTERED ([SalesModel_ID] ASC)
);