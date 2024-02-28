CREATE TABLE [sis_stage].[Media_Translation] (
    [Media_ID]        INT             NOT NULL,
    [Language_ID]     INT             NOT NULL,
    [Media_Number]    NVARCHAR (50)   NOT NULL,
    [Title]           NVARCHAR (4000) NULL,
    [Published_Date]  DATE            NULL,
    [Updated_Date]    DATE            NULL,
    [Revision_Number] INT             NULL,
    [Media_Origin]    VARCHAR(2)      NULL, 
	[LastModified_Date] DATE		  NULL,
    CONSTRAINT [PK_Media_Translation] PRIMARY KEY CLUSTERED ([Media_ID] ASC, [Language_ID] ASC)
);