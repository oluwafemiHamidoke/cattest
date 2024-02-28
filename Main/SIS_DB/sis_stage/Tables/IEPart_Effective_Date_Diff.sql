CREATE TABLE [sis_stage].[IEPart_Effective_Date_Diff]
(	
	[Operation]				VARCHAR (50) NOT NULL,
	[IEPart_ID]				int not null,
	[Media_ID]				int not null,
	[SerialNumberPrefix_ID]	int not null,
	[SerialNumberRange_ID]	int not null,
	[DayEffective]			datetime not null,
	[DayNotEffective]		datetime null,
	
	PRIMARY KEY CLUSTERED ([Operation] ASC, [IEPart_ID] ASC, [SerialNumberPrefix_ID] ASC, [SerialNumberRange_ID] ASC, [Media_ID] ASC, [DayEffective] ASC),
	
)
