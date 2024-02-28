CREATE TABLE [sis_stage].[AsShippedPart_Effectivity_Key] (
    [AsShippedPart_Effectivity_ID] INT IDENTITY (1, 1) NOT NULL,
    [AsShippedPart_ID]             INT NOT NULL,
    [SerialNumberPrefix_ID]        INT NOT NULL,
    [SerialNumberRange_ID]         INT NOT NULL,
    CONSTRAINT [PK_AsShippedPart_Effectivity_Key] PRIMARY KEY CLUSTERED ([AsShippedPart_Effectivity_ID] ASC)
);