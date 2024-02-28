CREATE TABLE [sis_stage].[ProductStructure_IE_Relation] (
    [ProductStructure_ID] INT NOT NULL,
    [IE_ID]               INT NOT NULL,
    [Media_ID]            INT NOT NULL,
    CONSTRAINT [PK_ProductStructure_IE_Relation] PRIMARY KEY CLUSTERED ([ProductStructure_ID] ASC, [IE_ID] ASC, [Media_ID] ASC)
);

