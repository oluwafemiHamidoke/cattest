CREATE TABLE [sp_staging].[Log](
	[LogID]         [bigint] IDENTITY(1,1)  NOT NULL,
	[ProcessID]     [uniqueidentifier]      NOT NULL,
	[LogDateTime]   [datetime]              NULL,
	[LogType]       [varchar](100)          NULL,
	[NameofSproc]   [varchar](200)          NULL,
	[LogMessage]    [varchar](max)          NULL,
	[DataValue]     [varchar](20)           NULL,
 CONSTRAINT [PK_Log_LogID] PRIMARY KEY CLUSTERED ([LogID] ASC) 
 )
