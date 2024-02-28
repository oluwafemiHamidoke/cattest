CREATE TABLE [sis_stage].[ProductFamily] (
    [ProductFamily_ID] INT          NULL,
    [Family_Code]      VARCHAR (50) NOT NULL,
    [Is_Telematics_Flash] BIT DEFAULT((0)) NOT NULL,
    CONSTRAINT [PK_Product_Family] PRIMARY KEY CLUSTERED ([Family_Code] ASC)
);