CREATE TABLE [sis].[SerialNumberPrefix] (
    [SerialNumberPrefix_ID]     INT         NOT NULL,
    [Serial_Number_Prefix]      VARCHAR (3) NOT NULL,
    [Classic_Product_Indicator] BIT         NOT NULL,
    [CCR_Indicator]             BIT         DEFAULT ((0)) NOT NULL,
    [Is_Telematics_Flash]       BIT         Not Null default 1,
    [LastModified_Date] DATETIME2(0) NOT NULL DEFAULT(GETDATE()),
    CONSTRAINT [PK_SerialNumberPrefix] PRIMARY KEY NONCLUSTERED ([SerialNumberPrefix_ID] ASC)
);




GO
CREATE CLUSTERED INDEX [IX_SerialNumberPrefix_Serial_Number_Prefix]
    ON [sis].[SerialNumberPrefix]([Serial_Number_Prefix] ASC);



