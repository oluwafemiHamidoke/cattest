CREATE  TABLE [sis].[ServiceLetterCompletion]
(
  [Media_ID]				[INT] NOT NULL, 
  [SerialNumberPrefix_ID]	[INT] NOT NULL, 
  [SerialNumberRange_ID]	[INT] NOT NULL, 
  [Completion_Date] [DATE] NOT NULL,
  CONSTRAINT [PK_ServiceLetterCompletion] PRIMARY KEY CLUSTERED ([Media_ID] ASC, [SerialNumberPrefix_ID] ASC, [SerialNumberRange_ID] ASC),
  CONSTRAINT [FK_ServiceLetterCompletion_SerialNumberPrefix]  FOREIGN KEY ( [SerialNumberPrefix_ID] ) REFERENCES [sis].[SerialNumberPrefix] ([SerialNumberPrefix_ID]),
  CONSTRAINT [FK_ServiceLetterCompletion_SerialNumberRange]  FOREIGN KEY ( [SerialNumberRange_ID] ) REFERENCES [sis].[SerialNumberRange] ([SerialNumberRange_ID])
)
GO
CREATE NONCLUSTERED INDEX [IX_SerialNumberRange_ID] ON [sis].[ServiceLetterCompletion]
(
	[SerialNumberRange_ID] ASC
)
GO
CREATE NONCLUSTERED INDEX [IX_NCL_SerialNumberPrefix_ID] 
  ON [sis].[ServiceLetterCompletion]([SerialNumberPrefix_ID])