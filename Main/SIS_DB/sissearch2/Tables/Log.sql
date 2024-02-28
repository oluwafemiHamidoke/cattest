CREATE TABLE [sissearch2].[Log](
	[LogID] [bigint] IDENTITY(1,1) NOT NULL,
	[LogDateTime] [datetime] NULL,
	[LogType] [varchar](100) NULL,
	[LapseTime] [bigint] NULL,
	[NameofSproc] [varchar](200) NULL,
	[LogMessage] [varchar](max) NULL,
	[DataValue] [bigint] NULL,
 CONSTRAINT [PK_Log_LogID_] PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)
);
