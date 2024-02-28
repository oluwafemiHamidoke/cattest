CREATE TABLE [sis_stage].[ProductFamily_Translation] (
    [ProductFamily_ID] INT           NOT NULL,
    [Language_ID]      INT           NOT NULL,
    [Family_Name]      VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_Product_Family_Translation] PRIMARY KEY CLUSTERED ([ProductFamily_ID] ASC, [Language_ID] ASC)
);