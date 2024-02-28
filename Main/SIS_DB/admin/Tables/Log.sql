CREATE TABLE [admin].[Log](
	[LogID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProcessID] [uniqueidentifier] NOT NULL,
	[LogDateTime] [datetime] NULL,
	[LogType] [varchar](100) NULL,
	[NameofSproc] [varchar](200) NULL,
	[LogMessage] [varchar](max) NULL,
	[DataValue] [varchar](20) NULL,
 CONSTRAINT [PK_Log_LogID_] PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


