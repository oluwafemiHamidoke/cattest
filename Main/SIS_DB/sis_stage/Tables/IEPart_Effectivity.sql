CREATE TABLE [sis_stage].[IEPart_Effectivity] (
    [IEPart_ID]               INT      NOT NULL,
    [SerialNumberPrefix_ID]   INT      NOT NULL,
    [SerialNumberRange_ID]    INT      NOT NULL,
    [SerialNumberPrefix_Type] CHAR (1) DEFAULT ('N') NOT NULL,
    [Media_ID] INT NOT NULL, 
    CONSTRAINT [PK_IEPart_Effectivity] PRIMARY KEY CLUSTERED ([IEPart_ID] ASC, [SerialNumberPrefix_ID] ASC, [SerialNumberRange_ID] ASC, [SerialNumberPrefix_Type] ASC, [Media_ID] ASC)
);

