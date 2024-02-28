CREATE TABLE [SISSEARCH].[LOG] (
    [LogID]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [LogDateTime] DATETIME      NULL,
    [LogType]     VARCHAR (100) NULL,
    [LapseTime]   BIGINT        NULL,
    [NameofSproc] VARCHAR (200) NULL,
    [LogMessage]  VARCHAR (MAX) NULL,
    [DataValue]   BIGINT  NULL,
    CONSTRAINT [PK_Log_LogID_] PRIMARY KEY CLUSTERED ([LogID] ASC)
);

