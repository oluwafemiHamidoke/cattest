CREATE TABLE [sis_stage].[IE_Effectivity] (
    [IE_ID]                 INT NOT NULL,
    [SerialNumberPrefix_ID] INT NOT NULL,
    [SerialNumberRange_ID]  INT NOT NULL,
    [Media_ID]              INT CONSTRAINT [DF_IE_Effectivity_Media_ID_stage] DEFAULT ((-1)) NOT NULL,
    CONSTRAINT [PK_IE_Effectivity] PRIMARY KEY CLUSTERED ([IE_ID] ASC, [SerialNumberPrefix_ID] ASC, [SerialNumberRange_ID] ASC, [Media_ID] ASC)
);