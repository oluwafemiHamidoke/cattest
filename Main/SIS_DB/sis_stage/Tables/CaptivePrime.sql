CREATE TABLE [sis_stage].[CaptivePrime] (
    [CaptivePrime_ID]               INT           NULL,
    [Prime_SerialNumberPrefix_ID]   INT           NOT NULL,
    [Captive_SerialNumberPrefix_ID] INT           NOT NULL,
    [Captive_SerialNumberRange_ID]  INT           NOT NULL,
    [Media_ID]                      INT           NOT NULL,
    [Document_Title]                VARCHAR (512) NOT NULL,
    [Configuration_Type]            CHAR (1)      NULL,
    CONSTRAINT [PK_CaptivePrime] PRIMARY KEY CLUSTERED ([Prime_SerialNumberPrefix_ID] ASC, [Captive_SerialNumberPrefix_ID] ASC, [Captive_SerialNumberRange_ID] ASC, [Media_ID] ASC) WITH (FILLFACTOR = 100)
);

