CREATE TABLE [sis_stage].[ProductFamily_Key] (
    [ProductFamily_ID] INT          IDENTITY (1, 1) NOT NULL,
    [Family_Code]      VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Product_Family_Key] PRIMARY KEY CLUSTERED ([ProductFamily_ID] ASC)
);