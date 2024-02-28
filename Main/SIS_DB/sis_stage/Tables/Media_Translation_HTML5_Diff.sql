CREATE TABLE [sis_stage].[Media_Translation_HTML5_Diff] (
    [Operation]       VARCHAR (50)    NOT NULL,
    [Media_ID]        INT             NOT NULL,
    [Language_ID]     INT             NOT NULL,
    [Media_Number]    NVARCHAR (50)   NOT NULL,
    [Title]           NVARCHAR (4000) NULL,
    [Published_Date]  DATE            NULL,
    [Updated_Date]    DATE            NULL,
    [Revision_Number] INT             NULL,
    CONSTRAINT [PK_Media_Translation_HTML5_Diff] PRIMARY KEY CLUSTERED ([Media_ID] ASC, [Language_ID] ASC) WITH (FILLFACTOR = 100)
);

