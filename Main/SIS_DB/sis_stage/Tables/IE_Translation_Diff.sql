CREATE TABLE [sis_stage].[IE_Translation_Diff] (
    [Operation]       VARCHAR (50)    NOT NULL,
    [IE_ID]           INT             NOT NULL,
    [Language_ID]     INT             NOT NULL,
    [Title]           NVARCHAR (3072) NULL,
    [File_Location]   VARCHAR (8000)  NULL,
    [IEControlNumber] VARCHAR (12)    NULL,
    [File_Size_Byte]  INT             NULL,
    [Mime_Type]       VARCHAR (250)   NULL,
    [Published_Date]  DATETIME2 (7)   NULL,
    [Date_Updated]    DATETIME2 (0)   NULL,
	[EnglishControlNumber] VARCHAR (12) NULL, 
    [LastModified_Date] DATETIME2(0) NULL,
    CONSTRAINT [PK_IE_Translation_Diff] PRIMARY KEY CLUSTERED ([IE_ID] ASC, [Language_ID] ASC)
);



