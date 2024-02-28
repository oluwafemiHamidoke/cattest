CREATE TABLE sis_stage.SMCS_Translation_Diff
	(Operation   VARCHAR(50) NOT NULL
	,SMCS_ID     INT NOT NULL
	,Language_ID INT NOT NULL
	,Description NVARCHAR(192) NULL
	,CONSTRAINT PK_SMCS_Translation_Diff PRIMARY KEY(SMCS_ID,Language_ID));

GO

EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis_stage'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'SMCS_Translation_Diff'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'SMCS_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis_stage'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'SMCS_Translation_Diff'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Language_ID';