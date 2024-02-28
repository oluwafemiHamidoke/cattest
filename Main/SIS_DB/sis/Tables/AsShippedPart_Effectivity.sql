CREATE TABLE [sis].[AsShippedPart_Effectivity] (
    [AsShippedPart_Effectivity_ID] INT NOT NULL,
    [AsShippedPart_ID]             INT NOT NULL,
    [SerialNumberPrefix_ID]        INT NOT NULL,
    [SerialNumberRange_ID]         INT NOT NULL,
    CONSTRAINT [PK_AsShippedPart_Effectivity] PRIMARY KEY CLUSTERED ([AsShippedPart_Effectivity_ID] ASC),
    CONSTRAINT [FK_AsShippedPart_Effectivity_AsShippedPart] FOREIGN KEY ([AsShippedPart_ID]) REFERENCES [sis].[AsShippedPart] ([AsShippedPart_ID]),
    CONSTRAINT [FK_AsShippedPart_Effectivity_SerialNumberPrefix] FOREIGN KEY ([SerialNumberPrefix_ID]) REFERENCES [sis].[SerialNumberPrefix] ([SerialNumberPrefix_ID]),
    CONSTRAINT [FK_AsShippedPart_Effectivity_SerialNumberRange] FOREIGN KEY ([SerialNumberRange_ID]) REFERENCES [sis].[SerialNumberRange] ([SerialNumberRange_ID])
);
GO

CREATE NONCLUSTERED INDEX NCI_AsShippedPart_Effectivity_Part ON [sis].[AsShippedPart_Effectivity] 
([AsShippedPart_ID] ASC);
GO
Create nonclustered index IX_AsShippedPart_Effectivity_SerialNumberPrefix_ID on sis.AsShippedPart_Effectivity (SerialNumberPrefix_ID);
GO
Create nonclustered index IX_AsShippedPart_Effectivity_SerialNumberRange_ID on sis.AsShippedPart_Effectivity (SerialNumberRange_ID);
GO
CREATE NONCLUSTERED INDEX [IDX_AsShippedPart_Effectivity_ID_SNR_ID]
ON [sis].[AsShippedPart_Effectivity] ([SerialNumberPrefix_ID])
INCLUDE ([AsShippedPart_ID],[SerialNumberRange_ID])