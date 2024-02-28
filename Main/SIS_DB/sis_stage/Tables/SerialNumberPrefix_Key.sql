CREATE TABLE [sis_stage].[SerialNumberPrefix_Key] (
    [SerialNumberPrefix_ID] INT         IDENTITY (1, 1) NOT NULL,
    [Serial_Number_Prefix]  VARCHAR (3) NOT NULL,
    CONSTRAINT [PK_Product_Key] PRIMARY KEY CLUSTERED ([SerialNumberPrefix_ID] ASC)
);