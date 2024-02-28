CREATE TABLE [sis_stage].[ProductStructure_Translation] (
    [ProductStructure_ID] INT            NOT NULL,
    [Language_ID]         INT            NOT NULL,
    [Description]         NVARCHAR (250) NULL,
    CONSTRAINT [PK_ProductStructure_Translation] PRIMARY KEY CLUSTERED ([ProductStructure_ID] ASC, [Language_ID] ASC)
);