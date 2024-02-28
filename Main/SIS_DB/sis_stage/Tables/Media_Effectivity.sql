CREATE TABLE [sis_stage].[Media_Effectivity] (
    [Media_ID]              INT NOT NULL,
    [SerialNumberPrefix_ID] INT NOT NULL,
    [SerialNumberRange_ID]  INT NOT NULL,
    CONSTRAINT [PK_Media_Effectivity] PRIMARY KEY CLUSTERED ([Media_ID] ASC, [SerialNumberPrefix_ID] ASC, [SerialNumberRange_ID] ASC)
);