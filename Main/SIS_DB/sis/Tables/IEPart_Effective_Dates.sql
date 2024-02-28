CREATE TABLE [sis].[IEPart_Effective_Date]
(
	[IEPart_ID]				int not null,
	[Media_ID]				int not null,
	[SerialNumberPrefix_ID]	int not null,
	[SerialNumberRange_ID]	int not null,
	[DayEffective]			datetime not null,
	[DayNotEffective]		datetime null,
	
	PRIMARY KEY CLUSTERED ([IEPart_ID] ASC, [SerialNumberPrefix_ID] ASC, [SerialNumberRange_ID] ASC, [Media_ID] ASC, [DayEffective] ASC),
	CONSTRAINT [FK_IEPart_Effective_Date_IEPart]	FOREIGN KEY ([IEPart_ID])				REFERENCES [sis].[IEPart] ([IEPart_ID]),
	CONSTRAINT [FK_IEPart_Effective_Date_SNP]		FOREIGN KEY ([SerialNumberPrefix_ID])	REFERENCES [sis].[SerialNumberPrefix] ([SerialNumberPrefix_ID]),
	CONSTRAINT [FK_IEPart_Effective_Date_SNR]		FOREIGN KEY ([SerialNumberRange_ID])	REFERENCES [sis].[SerialNumberRange] ([SerialNumberRange_ID]),
	CONSTRAINT [FK_IEPart_Effective_Date_Media]		FOREIGN KEY ([Media_ID])				REFERENCES [sis].[Media] ([Media_ID])
)
GO
CREATE NONCLUSTERED INDEX [IX_SerialNumberRange_ID] ON [sis].[IEPart_Effective_Date]
(
	[SerialNumberRange_ID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IEPart_Effective_Date_Media_ID]
ON [sis].[IEPart_Effective_Date] ([Media_ID])
GO
CREATE NONCLUSTERED INDEX [IX_NCL_SerialNumberPrefix_ID] 
	ON [sis].[IEPart_Effective_Date]([SerialNumberPrefix_ID])