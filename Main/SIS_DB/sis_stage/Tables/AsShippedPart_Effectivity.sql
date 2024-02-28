CREATE TABLE [sis_stage].[AsShippedPart_Effectivity] (
    [AsShippedPart_Effectivity_ID] INT NULL,
    [AsShippedPart_ID]             INT NOT NULL,
    [SerialNumberPrefix_ID]        INT NOT NULL,
    [SerialNumberRange_ID]         INT NOT NULL,
    CONSTRAINT [PK_AsShippedPart_Effectivity] PRIMARY KEY CLUSTERED ([AsShippedPart_ID] ASC, [SerialNumberPrefix_ID] ASC, [SerialNumberRange_ID] ASC)
);