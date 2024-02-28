-- this table stores the MediaBundle path for sis2go
CREATE TABLE [sis].[MediaBundle]
(
	Media_ID       int NOT NULL,
    Language_ID    int NOT NULL,
	File_Location  varchar(150) NOT NULL,
	File_Size_Byte int NULL,
	Updated_Date   date NOT NULL,
	CONSTRAINT [PK_Media_Bundle] PRIMARY KEY CLUSTERED 
	(
		[Media_ID] ASC,
		[Language_ID] ASC
	)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 100) ON [PRIMARY],
    CONSTRAINT [FK_MediaBundle_Media_Translation] FOREIGN KEY ([Media_ID],[Language_ID])
		REFERENCES [sis].[Media_Translation] ([Media_ID],[Language_ID]) 
		ON DELETE CASCADE
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_MediaBundle_Updated_Date]
    ON [sis].[MediaBundle]([Updated_Date] ASC)
    INCLUDE([Media_ID], [Language_ID]);
GO