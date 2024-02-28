CREATE TABLE [sis_stage].[ProductSubfamily_Translation] (
    [ProductSubfamily_ID] INT           NOT NULL,
    [Language_ID]         INT           NOT NULL,
    [Subfamily_Name]      VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_Product_Subfamily_Translation] PRIMARY KEY CLUSTERED ([ProductSubfamily_ID] ASC, [Language_ID] ASC)
);