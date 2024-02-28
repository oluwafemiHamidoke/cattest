CREATE TABLE [sis].[Media_Translation] (
    [Media_ID]        INT             NOT NULL,
    [Language_ID]     INT             NOT NULL,
    [Media_Number]    NVARCHAR (50)   NOT NULL,
    [Title]           NVARCHAR (4000) NULL,
    [Published_Date]  DATE            NULL,
    [Updated_Date]    DATE            NULL,
    [Revision_Number] INT             NULL,
    [Media_Origin]    VARCHAR(2)      NULL, 
	[LastModified_Date] DATE		  NULL,
    CONSTRAINT [PK_Media_Translation] PRIMARY KEY CLUSTERED ([Media_ID] ASC, [Language_ID] ASC),
    CONSTRAINT [FK_Media_Translation_Language] FOREIGN KEY ([Language_ID]) REFERENCES [sis].[Language_Details] ([Language_ID]),
    CONSTRAINT [FK_Media_Translation_Media] FOREIGN KEY ([Media_ID]) REFERENCES [sis].[Media] ([Media_ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_Media_Translation_Media_Number]
    ON [sis].[Media_Translation]([Media_Number] ASC)
    INCLUDE([Title], [Revision_Number]);

GO
CREATE NONCLUSTERED INDEX [Media_Translation_Media_ID]
ON [sis].[Media_Translation] ([Media_ID])