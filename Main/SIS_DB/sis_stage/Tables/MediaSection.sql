CREATE TABLE sis_stage.MediaSection
	(MediaSection_ID INT NULL
	,Media_ID        INT NOT NULL
	,Section_Number  INT NOT NULL
	,CONSTRAINT PK_MediaSection PRIMARY KEY CLUSTERED(Media_ID ASC,Section_Number ASC));
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'renamed from [PartsManualSection] https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4955/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis_stage'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'MediaSection'
						   ,@level2type = NULL
						   ,@level2name = NULL;