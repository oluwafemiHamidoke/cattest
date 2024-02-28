CREATE TABLE sis_stage.SMCS_Key
	(SMCS_ID      INT NOT NULL IDENTITY
	,SMCSCOMPCODE CHAR(4) NOT NULL
	,CONSTRAINT PK_SMCS_Key PRIMARY KEY(SMCS_ID));
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis_stage'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'SMCS_Key'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'SMCS_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Natural Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis_stage'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'SMCS_Key'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'SMCSCOMPCODE';