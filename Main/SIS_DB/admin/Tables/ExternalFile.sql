CREATE TABLE [admin].[ExternalFile]
(
	[ExternalFile_ID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](50) NOT NULL,
	[File_Location] [nvarchar](500) NOT NULL,
	CONSTRAINT [PK_ExternalFile_ID] PRIMARY KEY CLUSTERED ([ExternalFile_ID] ASC)
)
