CREATE TABLE [admin].[ExternalFile_Translation](
	[ExternalFile_ID] [int] NOT NULL,
	[Language_ID] [int] NOT NULL,
	[File_Location] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_ExternalFile_Translation] PRIMARY KEY CLUSTERED 
(
	[ExternalFile_ID] ASC,
	[Language_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [admin].[ExternalFile_Translation]  WITH CHECK ADD  CONSTRAINT [FK_ExternalFile_Translation_ExternalFile_ID] FOREIGN KEY([ExternalFile_ID])
REFERENCES [admin].[ExternalFile] ([ExternalFile_ID])
GO

ALTER TABLE [admin].[ExternalFile_Translation] CHECK CONSTRAINT [FK_ExternalFile_Translation_ExternalFile_ID]
GO

ALTER TABLE [admin].[ExternalFile_Translation]  WITH CHECK ADD  CONSTRAINT [FK_ExternalFile_Translation_Language_ID] FOREIGN KEY([Language_ID])
REFERENCES [sis].[Language] ([Language_ID])
GO

ALTER TABLE [admin].[ExternalFile_Translation] CHECK CONSTRAINT [FK_ExternalFile_Translation_Language_ID]
GO