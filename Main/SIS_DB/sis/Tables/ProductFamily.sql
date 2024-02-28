CREATE TABLE [sis].[ProductFamily] (
    [ProductFamily_ID] INT          NOT NULL,
    [Family_Code]      VARCHAR (50) NOT NULL,
    [Is_Telematics_Flash] BIT DEFAULT((0)) NOT NULL,
    [LastModified_Date] DATETIME2(0) NOT NULL DEFAULT(GETDATE()),
    CONSTRAINT [PK_Product_Family] PRIMARY KEY CLUSTERED ([ProductFamily_ID] ASC),
    CONSTRAINT [UQ_Family_Code] UNIQUE NONCLUSTERED ([Family_Code] ASC)
);

