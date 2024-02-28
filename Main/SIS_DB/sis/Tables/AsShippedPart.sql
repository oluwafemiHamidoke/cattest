CREATE TABLE [sis].[AsShippedPart] (
    [AsShippedPart_ID] INT NOT NULL,
    [Part_ID]          INT NOT NULL,
    CONSTRAINT [PK_AsShippedPart] PRIMARY KEY CLUSTERED ([AsShippedPart_ID] ASC),
    CONSTRAINT [FK_AsShippedPart_Part] FOREIGN KEY ([Part_ID]) REFERENCES [sis].[Part] ([Part_ID])
);
GO
CREATE NONCLUSTERED INDEX NCI_AsShippedPart_Part ON [sis].[AsShippedPart] 
([Part_ID] ASC);