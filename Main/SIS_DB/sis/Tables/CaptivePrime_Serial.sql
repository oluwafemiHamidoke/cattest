CREATE TABLE [sis].[CaptivePrime_Serial] (
    [Media_ID]                      INT      NOT NULL,
    [Prime_SerialNumber]            CHAR (8) NOT NULL,
    [Captive_SerialNumber]          CHAR (8) NOT NULL,
    [Prime_SerialNumberPrefix_ID]   INT      NOT NULL,
    [Captive_SerialNumberPrefix_ID] INT      NOT NULL,
    [Prime_SerialNumberRange_ID]    INT      NOT NULL,
    [Captive_SerialNumberRange_ID]  INT      NOT NULL,
    [Attachment_Type]               CHAR (2) NULL,
    CONSTRAINT [PK_CaptivePrime_Serial] PRIMARY KEY CLUSTERED ([Media_ID] ASC, [Prime_SerialNumber] ASC, [Captive_SerialNumber] ASC),
    CONSTRAINT [FK_CaptivePrime_Serial_CSerialNumberPrefix] FOREIGN KEY ([Captive_SerialNumberPrefix_ID]) REFERENCES [sis].[SerialNumberPrefix] ([SerialNumberPrefix_ID]),
    CONSTRAINT [FK_CaptivePrime_Serial_Media] FOREIGN KEY ([Media_ID]) REFERENCES [sis].[Media] ([Media_ID]),
    CONSTRAINT [FK_CaptivePrime_Serial_PSerialNumberPrefix] FOREIGN KEY ([Prime_SerialNumberPrefix_ID]) REFERENCES [sis].[SerialNumberPrefix] ([SerialNumberPrefix_ID]),
    CONSTRAINT [FK_CaptivePrime_Serial_PSerialNumberRange] FOREIGN KEY ([Prime_SerialNumberRange_ID]) REFERENCES [sis].[SerialNumberRange] ([SerialNumberRange_ID]),
    CONSTRAINT [FK_CaptivePrime_Serial_CSerialNumberRange] FOREIGN KEY ([Captive_SerialNumberRange_ID]) REFERENCES [sis].[SerialNumberRange] ([SerialNumberRange_ID])
    );


GO
CREATE NONCLUSTERED INDEX [IX_CaptivePrime_Serial_CaptivePrime_Serial]
    ON [sis].[CaptivePrime_Serial]([Captive_SerialNumber] ASC);

GO
CREATE NONCLUSTERED INDEX [XI_CaptivePrime_Serial_Prime_SerialNumber] ON [sis].[CaptivePrime_Serial]
(
	[Prime_SerialNumber] ASC
)INCLUDE([Captive_SerialNumberPrefix_ID],[Captive_SerialNumberRange_ID])

GO
CREATE NONCLUSTERED INDEX IX_CaptivePrime_Serial_Attachment_Type
ON [sis].[CaptivePrime_Serial] ([Attachment_Type])
INCLUDE ([Prime_SerialNumberPrefix_ID],[Captive_SerialNumberPrefix_ID])

GO
CREATE NONCLUSTERED INDEX IX_CaptivePrime_Serial_Prime_SerialNumberPrefix_ID_Attachment_Type
ON [sis].[CaptivePrime_Serial] ([Prime_SerialNumberPrefix_ID],[Attachment_Type])
INCLUDE ([Captive_SerialNumberPrefix_ID])
GO
CREATE NONCLUSTERED INDEX [IX_CaptiveSerialNumberRange_ID] ON [sis].[CaptivePrime_Serial]
(
	[Captive_SerialNumberRange_ID] ASC
)

GO
CREATE NONCLUSTERED INDEX [IX_PrimeSerialNumberRange_ID] ON [sis].[CaptivePrime_Serial]
(
	[Prime_SerialNumberRange_ID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_CaptivePrime_Serial_Media_ID]
ON [sis].[CaptivePrime_Serial] ([Media_ID])
GO
CREATE NONCLUSTERED INDEX [IX_NCL_CaptiveSerialNumberPrefix_ID] 
    ON [sis].[CaptivePrime_Serial] ([Captive_SerialNumberPrefix_ID])
GO
CREATE NONCLUSTERED INDEX [IX_NCL_PrimeSerialNumberPrefix_ID] 
    ON [sis].[CaptivePrime_Serial]([Prime_SerialNumberPrefix_ID])    