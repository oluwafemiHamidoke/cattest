CREATE TABLE [sis_stage].[ProductStructure] (
    [ProductStructure_ID]       INT      NOT NULL,
    [ParentProductStructure_ID] INT      NULL,
    [Parentage]                 TINYINT  CONSTRAINT [DF_ProductStructure_Parentage_1] DEFAULT ((0)) NOT NULL,
    [MiscSpnIndicator]          CHAR (1) CONSTRAINT [DF_ProductStructure_MiscSpnIndicator_1] DEFAULT ('Y') NOT NULL,
    CONSTRAINT [PK_ProductStructure] PRIMARY KEY CLUSTERED ([ProductStructure_ID] ASC)
);

