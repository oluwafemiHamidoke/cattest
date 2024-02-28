CREATE TABLE sis_stage.MediaSequence_Effectivity
	(MediaSequence_ID      INT NOT NULL
	,SerialNumberPrefix_ID INT NOT NULL
	,SerialNumberRange_ID  INT NOT NULL
    ,SerialNumberPrefix_Type CHAR (1) DEFAULT ('P') NOT NULL
	,CONSTRAINT PK_MediaSequence_Effectivity PRIMARY KEY CLUSTERED(MediaSequence_ID ASC,SerialNumberPrefix_ID ASC,SerialNumberRange_ID ASC));
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'renamed from [PartsManualSequence_Effectivity] https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4955/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis_stage'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'MediaSequence_Effectivity'
						   ,@level2type = NULL
						   ,@level2name = NULL;