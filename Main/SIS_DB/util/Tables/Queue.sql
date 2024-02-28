CREATE TABLE [util].[Queue] (
    [QueueID]          INT            IDENTITY (1, 1) NOT NULL,
    [SchemaName]       [sysname]      NOT NULL,
    [ObjectName]       [sysname]      NOT NULL,
    [Parameters]       NVARCHAR (MAX) NOT NULL,
    [QueueStartTime]   DATETIME2 (7)  NULL,
    [SessionID]        SMALLINT       NULL,
    [RequestID]        INT            NULL,
    [RequestStartTime] DATETIME       NULL,
    CONSTRAINT [PK_Queue] PRIMARY KEY CLUSTERED ([QueueID] ASC)
);

