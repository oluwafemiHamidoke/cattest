CREATE TABLE [sis_stage].[ProductStructure_Effectivity] (
    [ProductStructure_ID]   INT NOT NULL,
    [Media_ID]              INT NOT NULL,
    [SerialNumberPrefix_ID] INT NOT NULL,
    [SerialNumberRange_ID]  INT NOT NULL, 
    CONSTRAINT [PK_ProductStructure_Effectivity] PRIMARY KEY ([ProductStructure_ID], [SerialNumberRange_ID], [Media_ID], [SerialNumberPrefix_ID])
);