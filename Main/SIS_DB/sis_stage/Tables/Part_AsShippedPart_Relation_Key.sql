CREATE TABLE [sis_stage].[Part_AsShippedPart_Relation_Key] (
    [Part_AsShippedPart_Relation_ID] INT IDENTITY (1, 1) NOT NULL,
    [Part_ID]                        INT NOT NULL,
    [AsShippedPart_ID]               INT NOT NULL,
    CONSTRAINT [PK_Part_AsShippedPart_Relation_Key] PRIMARY KEY CLUSTERED ([Part_AsShippedPart_Relation_ID] ASC)
);