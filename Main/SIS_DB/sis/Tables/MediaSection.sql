CREATE TABLE sis.MediaSection
	(MediaSection_ID INT NOT NULL
	,Media_ID        INT NOT NULL
	,Section_Number  INT NOT NULL
	,CONSTRAINT PK_MediaSection PRIMARY KEY CLUSTERED(MediaSection_ID ASC)
	,CONSTRAINT FK_MediaSection_Media FOREIGN KEY(Media_ID) REFERENCES sis.Media(Media_ID));
GO
CREATE NONCLUSTERED INDEX IX_MediaSection_Media_ID ON sis.MediaSection (Media_ID ASC) INCLUDE (Section_Number );
GO
CREATE NONCLUSTERED INDEX IX_MediaSection_Media_MediaSection_ID ON sis.MediaSection (Media_ID ASC,MediaSection_ID ASC) INCLUDE (Section_Number );
GO

EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'was [PartsManualSecion], https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4955/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'MediaSection'
						   ,@level2type = NULL
						   ,@level2name = NULL;