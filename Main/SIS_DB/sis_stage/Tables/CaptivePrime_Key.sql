CREATE TABLE [sis_stage].[CaptivePrime_Key] (
    [CaptivePrime_ID]               INT IDENTITY (1, 1) NOT NULL,
    [Prime_SerialNumberPrefix_ID]   INT NOT NULL,
    [Captive_SerialNumberPrefix_ID] INT NOT NULL,
    [Captive_SerialNumberRange_ID]  INT NOT NULL,
    [Media_ID]                      INT NULL,
    CONSTRAINT [PK_CaptivePrime_Key] PRIMARY KEY CLUSTERED ([CaptivePrime_ID] ASC)
);



