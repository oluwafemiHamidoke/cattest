CREATE  TABLE [sis_stage].[ServiceLetterCompletion]
(
  [Media_ID]				[INT] NOT NULL, 
  [SerialNumberPrefix_ID]	[INT] NOT NULL, 
  [SerialNumberRange_ID]	[INT] NOT NULL, 
  [Completion_Date] [DATE] NOT NULL,
  CONSTRAINT [PK_ServiceLetterCompletion] PRIMARY KEY CLUSTERED ([Media_ID] ASC, [SerialNumberPrefix_ID] ASC, [SerialNumberRange_ID] ASC),
)
GO