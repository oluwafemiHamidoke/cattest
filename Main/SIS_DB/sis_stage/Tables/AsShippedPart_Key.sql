CREATE TABLE [sis_stage].[AsShippedPart_Key] (
    [AsShippedPart_ID] INT IDENTITY (1, 1) NOT NULL,
    [Part_ID]          INT NOT NULL,
    CONSTRAINT [PK_AsShippedPart_Key] PRIMARY KEY CLUSTERED ([AsShippedPart_ID] ASC)
);