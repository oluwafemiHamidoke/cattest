CREATE TABLE [sis].[Part_AsShippedPart_Relation] (
    [Part_AsShippedPart_Relation_ID] INT NOT NULL,
    [Part_ID]                        INT NOT NULL,
    [AsShippedPart_ID]               INT NOT NULL,
    [Quantity]                       INT NOT NULL,
    [Sequence_Number]                INT NULL,
    CONSTRAINT [PK_Part_AsShippedPart_Relation] PRIMARY KEY CLUSTERED ([Part_AsShippedPart_Relation_ID] ASC),
    CONSTRAINT [FK_Part_AsShippedPart_Relation_AsShippedPart] FOREIGN KEY ([AsShippedPart_ID]) REFERENCES [sis].[AsShippedPart] ([AsShippedPart_ID]),
    CONSTRAINT [FK_Part_AsShippedPart_Relation_Part] FOREIGN KEY ([Part_ID]) REFERENCES [sis].[Part] ([Part_ID])
);

GO
CREATE NONCLUSTERED INDEX [IDX_Part_AsshippedPart_Relation_ID]
ON [sis].[Part_AsShippedPart_Relation] ([AsShippedPart_ID])
INCLUDE ([Part_ID])

