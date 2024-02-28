CREATE TABLE sis.InfoType_Translation
	(InfoType_ID INT NOT NULL
	,Language_ID INT NOT NULL
	,Description NVARCHAR(720) NULL
	,CONSTRAINT PK_InfoType_Translation PRIMARY KEY CLUSTERED(InfoType_ID,Language_ID)
	,CONSTRAINT FK_InfoType_Translation_InfoType FOREIGN KEY(InfoType_ID) REFERENCES sis.InfoType(InfoType_ID)
	,CONSTRAINT FK_InfoType_Translation_Language FOREIGN KEY(Language_ID) REFERENCES sis.Language_Details(Language_ID));
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'InfoType_Translation'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'InfoType_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'InfoType_Translation'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Language_ID';