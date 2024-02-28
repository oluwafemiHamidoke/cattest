﻿CREATE TABLE [sis_stage].[IE_Translation_HTML5] (
    [IE_ID]           INT             NOT NULL,
    [Language_ID]     INT             NOT NULL,
    [Title]           NVARCHAR (3072) NULL,
    [File_Location]   VARCHAR (8000)  NULL,
    [IEControlNumber] VARCHAR (12)    NULL,
    [File_Size_Byte]  INT             NULL,
    [Mime_Type]       VARCHAR (250)   NULL,
    [Published_Date]  DATETIME2 (7)   NULL,
    [Date_Updated]    DATETIME2 (0)   NULL,
    CONSTRAINT [PK_IE_Translation_HTML5] PRIMARY KEY CLUSTERED ([IE_ID] ASC, [Language_ID] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);


