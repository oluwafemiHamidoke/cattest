CREATE TABLE [sis_stage].[AsShippedPart] (
    [AsShippedPart_ID] INT NULL,
    [Part_ID]          INT NOT NULL,
    CONSTRAINT [PK_AsShippedPart] PRIMARY KEY CLUSTERED ([Part_ID] ASC)
);