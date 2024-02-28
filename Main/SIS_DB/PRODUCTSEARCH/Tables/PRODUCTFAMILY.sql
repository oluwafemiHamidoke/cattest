CREATE TABLE [PRODUCTSEARCH].[PRODUCTFAMILY] (
    [Product_Family_ID]            INT            IDENTITY (1, 1) NOT NULL,
    [Product_Family_ID_String]     AS             (CONVERT([varchar](50),[Product_Family_ID])),
    [Family_Code]                  VARCHAR (50)   NOT NULL,
    [Family_Name_en-US]            VARCHAR (100)  NULL,
    [Subfamily_Code]               VARCHAR (50)   NOT NULL,
    [Subfamily_Name_en-US]         VARCHAR (100)  NULL,
    [Sales_Model]                  VARCHAR (50)   NOT NULL,
    [Serial_Number_Prefix]         VARCHAR (3)    NULL,
    [Captive_Serial_Number_Prefix] VARCHAR (8000) NULL,
    [Profile]                      VARCHAR (max)  NULL,
    [Product_Instance_Number]      VARCHAR (60)   DEFAULT('N/A'),
    [Product_Instance_Name]        VARCHAR (60)   NULL,
    [isExpandedMiningProduct]      BIT            NOT NULL DEFAULT(0),
    [Aliases]                      VARCHAR (200)  DEFAULT('[]'),
    [Emp_Data]                     VARCHAR (MAX)  NULL
    PRIMARY KEY CLUSTERED ([Product_Family_ID] ASC)
);


GO
ALTER TABLE [PRODUCTSEARCH].[PRODUCTFAMILY] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = OFF);


GO
GRANT VIEW CHANGE TRACKING
    ON OBJECT::[PRODUCTSEARCH].[PRODUCTFAMILY] TO [sissearchdatasource]
    AS [dbo];

