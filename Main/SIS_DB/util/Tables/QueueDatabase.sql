CREATE TABLE [util].[QueueDatabase] (
    [QueueID]           INT           NOT NULL,
    [DatabaseName]      [sysname]     NOT NULL,
    [DatabaseOrder]     INT           NULL,
    [DatabaseStartTime] DATETIME2 (7) NULL,
    [DatabaseEndTime]   DATETIME2 (7) NULL,
    [SessionID]         SMALLINT      NULL,
    [RequestID]         INT           NULL,
    [RequestStartTime]  DATETIME      NULL,
    CONSTRAINT [PK_QueueDatabase] PRIMARY KEY CLUSTERED ([QueueID] ASC, [DatabaseName] ASC),
    CONSTRAINT [FK_QueueDatabase_Queue] FOREIGN KEY ([QueueID]) REFERENCES [util].[Queue] ([QueueID])
);

