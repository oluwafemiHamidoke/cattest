CREATE TABLE [sis_stage].[Part_AsShippedPart_Relation] (
    [Part_AsShippedPart_Relation_ID] INT NULL,
    [Part_ID]                        INT NOT NULL,
    [AsShippedPart_ID]               INT NOT NULL,
    [Quantity]                       INT NOT NULL,
    [Sequence_Number]                INT NULL,
    CONSTRAINT [PK_Part_AsShippedPart_Relation] PRIMARY KEY CLUSTERED ([Part_ID] ASC, [AsShippedPart_ID] ASC)
);