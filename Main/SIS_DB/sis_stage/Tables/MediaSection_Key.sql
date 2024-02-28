CREATE TABLE sis_stage.MediaSection_Key
	(MediaSection_ID INT IDENTITY(1,1) NOT NULL
	,Media_ID        INT NOT NULL
	,Section_Number  INT NOT NULL
	,CONSTRAINT PK_MediaSection_Key PRIMARY KEY CLUSTERED(MediaSection_ID ASC));
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'renamed from [PartsManualSection_Key] https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4955/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis_stage'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'MediaSection_Key'
						   ,@level2type = NULL
						   ,@level2name = NULL;