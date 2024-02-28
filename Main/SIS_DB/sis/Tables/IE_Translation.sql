/****** Object:  Table [sis].[IE_Translation]    Script Date: 8/17/2022 5:09:55 PM ******/
CREATE TABLE [sis].[IE_Translation](
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
	CONSTRAINT [PK_IE_Translation] PRIMARY KEY CLUSTERED ([IE_ID] ASC, [Language_ID] ASC),
    CONSTRAINT [FK_IE_Translation_IE] FOREIGN KEY ([IE_ID]) REFERENCES [sis].[IE] ([IE_ID]),
    CONSTRAINT [FK_IE_Translation_Language] FOREIGN KEY ([Language_ID]) REFERENCES [sis].[Language_Details] ([Language_ID])
);

GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'IE_Translation'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'IE_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'IE_Translation'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Language_ID';


