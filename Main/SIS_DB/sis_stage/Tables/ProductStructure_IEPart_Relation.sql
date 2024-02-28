﻿CREATE TABLE [sis_stage].[ProductStructure_IEPart_Relation] (
    [ProductStructure_ID] INT NOT NULL,
    [IEPart_ID]           INT NOT NULL,
    [Media_ID]            INT NOT NULL,
	[SerialNumberPrefix_ID] INT NOT NULL DEFAULT 0,
	[SerialNumberRange_ID]  INT NOT NULL DEFAULT 0,
    CONSTRAINT [PK_ProductStructure_IEPart_Relation] PRIMARY KEY CLUSTERED ([ProductStructure_ID] ASC, [IEPart_ID] ASC, [Media_ID] ASC, [SerialNumberPrefix_ID] ASC, [SerialNumberRange_ID] ASC)
);