CREATE TABLE [sis].[ProductStructure_Effectivity] (
    [ProductStructure_ID]   INT NOT NULL,
    [Media_ID]              INT NOT NULL,
    [SerialNumberPrefix_ID] INT NOT NULL,
    [SerialNumberRange_ID]  INT NOT NULL, 
    CONSTRAINT [PK_ProductStructure_Effectivity] PRIMARY KEY ([ProductStructure_ID], [SerialNumberRange_ID], [Media_ID], [SerialNumberPrefix_ID])
);
GO

ALTER TABLE [sis].[ProductStructure_Effectivity]
    ADD CONSTRAINT [FK_ProductStructure_Effectivity_Media] FOREIGN KEY ([Media_ID]) REFERENCES [sis].[Media] ([Media_ID]);
GO
ALTER TABLE [sis].[ProductStructure_Effectivity]
    ADD CONSTRAINT [FK_ProductStructure_Effectivity_ProductStructure] FOREIGN KEY ([ProductStructure_ID]) REFERENCES [sis].[ProductStructure] ([ProductStructure_ID]);
GO
ALTER TABLE [sis].[ProductStructure_Effectivity]
    ADD CONSTRAINT [FK_ProductStructure_Effectivity_SerialNumberPrefxi] FOREIGN KEY ([SerialNumberPrefix_ID]) REFERENCES [sis].[SerialNumberPrefix] ([SerialNumberPrefix_ID]);
GO
ALTER TABLE [sis].[ProductStructure_Effectivity]
    ADD CONSTRAINT [FK_ProductStructure_SerialNumberRange] FOREIGN KEY ([SerialNumberRange_ID]) REFERENCES [sis].[SerialNumberRange] ([SerialNumberRange_ID]);
GO
CREATE NONCLUSTERED INDEX [ProductStructure_Effectivity_SerialNumberRangeID]
ON [sis].[ProductStructure_Effectivity] ([SerialNumberRange_ID])
GO
CREATE NONCLUSTERED INDEX [ProductStructure_Effectivity_Media_ID]
ON [sis].[ProductStructure_Effectivity] ([Media_ID])
GO
CREATE NONCLUSTERED INDEX [IX_NCL_SerialNumberPrefix_ID]
ON [sis].[ProductStructure_Effectivity] ([SerialNumberPrefix_ID])