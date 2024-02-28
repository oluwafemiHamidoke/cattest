CREATE TABLE sis.Illustration_File
	(Illustration_File_ID INT NOT NULL
	,Illustration_ID      INT NOT NULL
	,File_Location        VARCHAR(150) NOT NULL
	,File_Size_Byte       INT NULL
	,Mime_Type            VARCHAR(250) NULL
	,Graphic_Type AS	CASE 
							WHEN Mime_Type ='image/png' THEN 'P'
							WHEN Mime_Type ='image/gif' THEN 'G'
							WHEN Mime_Type ='image/svg+xml' THEN 'S'
							WHEN Mime_Type ='image/jpeg' THEN 'J'
							WHEN Mime_Type ='application/octet-stream' THEN '3'
							WHEN Mime_Type ='image/webp' THEN 'W'
						END
	,File_Location_Highres        VARCHAR(150)  NULL
	,File_Size_Byte_Highres       INT NULL
	,CONSTRAINT PK_Illustration_File PRIMARY KEY CLUSTERED(Illustration_File_ID ASC)
	,CONSTRAINT FK_Illustration_File_Illustration FOREIGN KEY(Illustration_ID) REFERENCES sis.Illustration(Illustration_ID));

GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Illustration_File'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Illustration_File_ID';
GO

CREATE NONCLUSTERED INDEX [IX_Illustration_File_Illustration_ID]
ON [sis].[Illustration_File] ([Illustration_ID])
INCLUDE ([File_Location],[Mime_Type])
