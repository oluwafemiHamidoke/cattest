CREATE TABLE [sis].[Media_Translation_HTML5] (
    [Media_ID]        INT             NOT NULL,
    [Language_ID]     INT             NOT NULL,
    [Media_Number]    NVARCHAR (50)   NOT NULL,
    [Title]           NVARCHAR (4000) NULL,
    [Published_Date]  DATE            NULL,
    [Updated_Date]    DATE            NULL,
    [Revision_Number] INT             NULL,
    CONSTRAINT [PK_Media_Translation_HTML5] PRIMARY KEY CLUSTERED ([Media_ID] ASC, [Language_ID] ASC),
    CONSTRAINT [FK_Media_Translation_HTML5_Language] FOREIGN KEY ([Language_ID]) REFERENCES [sis].[Language_Details] ([Language_ID]),
    CONSTRAINT [FK_Media_Translation_HTML5_Media] FOREIGN KEY ([Media_ID]) REFERENCES [sis].[Media_HTML5] ([Media_ID])
);




GO
CREATE NONCLUSTERED INDEX [IX_Media_Translation_HTML5_Media_Number]
    ON [sis].[Media_Translation_HTML5]([Media_Number] ASC)
    INCLUDE([Title], [Revision_Number]);

