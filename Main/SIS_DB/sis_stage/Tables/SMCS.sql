CREATE TABLE sis_stage.SMCS
	(SMCS_ID          INT NULL
	,SMCSCOMPCODE     CHAR(4) NOT NULL
	,CurrentIndicator BIT NOT NULL
	,CONSTRAINT PK_SMCS PRIMARY KEY CLUSTERED(SMCSCOMPCODE ASC));
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Natural and Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis_stage'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'SMCS'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'SMCSCOMPCODE';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Surrogate Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis_stage'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'SMCS'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'SMCS_ID';