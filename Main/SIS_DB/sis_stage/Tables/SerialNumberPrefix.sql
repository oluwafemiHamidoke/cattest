CREATE TABLE [sis_stage].[SerialNumberPrefix] (
    [SerialNumberPrefix_ID]     INT         NULL,
    [Serial_Number_Prefix]      VARCHAR (3) NOT NULL,
    [Classic_Product_Indicator] BIT         NOT NULL,
    [CCR_Indicator]             BIT         DEFAULT ((0)) NOT NULL,
    [Is_Telematics_Flash]       BIT         Not Null default 1,
    CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED ([Serial_Number_Prefix] ASC) WITH (FILLFACTOR = 100)
);

