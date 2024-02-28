CREATE TABLE [sis_stage].[Media_ProductFamily_Effectivity] (
    [Media_ID]         INT NOT NULL,
    [ProductFamily_ID] INT NOT NULL,
    CONSTRAINT [PK_Media_ProductFamily_Effectivity] PRIMARY KEY CLUSTERED ([Media_ID] ASC, [ProductFamily_ID] ASC)
);