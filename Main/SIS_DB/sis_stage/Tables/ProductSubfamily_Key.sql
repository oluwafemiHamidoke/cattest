CREATE TABLE [sis_stage].[ProductSubfamily_Key] (
    [ProductSubfamily_ID] INT          IDENTITY (1, 1) NOT NULL,
    [Subfamily_Code]      VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Product_Subfamily_Key] PRIMARY KEY CLUSTERED ([ProductSubfamily_ID] ASC)
);