CREATE TABLE [sis].[CaptivePrime] (
    [CaptivePrime_ID]               INT           NOT NULL,
    [Prime_SerialNumberPrefix_ID]   INT           NOT NULL,
    [Captive_SerialNumberPrefix_ID] INT           NOT NULL,
    [Captive_SerialNumberRange_ID]  INT           NOT NULL,
    [Media_ID]                      INT           NULL,
    [Document_Title]                VARCHAR (512) NULL,
    [Configuration_Type]            CHAR (1)      NULL,
    CONSTRAINT [PK_CaptivePrime] PRIMARY KEY CLUSTERED ([CaptivePrime_ID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CaptivePrime_SerialNumberPrefix] FOREIGN KEY ([Prime_SerialNumberPrefix_ID]) REFERENCES [sis].[SerialNumberPrefix] ([SerialNumberPrefix_ID]),
    CONSTRAINT [FK_CaptivePrime_SerialNumberPrefix1] FOREIGN KEY ([Captive_SerialNumberPrefix_ID]) REFERENCES [sis].[SerialNumberPrefix] ([SerialNumberPrefix_ID]),
    CONSTRAINT [FK_CaptivePrime_SerialNumberRange] FOREIGN KEY ([Captive_SerialNumberRange_ID]) REFERENCES [sis].[SerialNumberRange] ([SerialNumberRange_ID])
);




GO
CREATE NONCLUSTERED INDEX [IX_CaptivePrime_Captive_SerialNumberPrefix_ID]
    ON [sis].[CaptivePrime]([Captive_SerialNumberPrefix_ID] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_CaptiveSerialNumberRange_ID] ON [sis].[CaptivePrime]
(
	[Captive_SerialNumberRange_ID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_NCL_Prime_SerialNumberPrefix_ID]
    ON [sis].[CaptivePrime]([Prime_SerialNumberPrefix_ID]);