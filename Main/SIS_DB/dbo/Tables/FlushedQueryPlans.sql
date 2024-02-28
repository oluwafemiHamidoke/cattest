CREATE TABLE [dbo].[FlushedQueryPlans] (
    [plan]                   XML           NULL,
    [query_hash]             CHAR (8)      NULL,
    [cpu_time]               INT           NULL,
    [logical_reads]          BIGINT        NULL,
    [sql_text]               VARCHAR (MAX) NULL,
    [statement_start_offset] INT           NULL,
    [statement_end_offset]   INT           NULL,
    [server_name]            VARCHAR (255) NULL,
    [collection_time]        DATETIME      NOT NULL
);



