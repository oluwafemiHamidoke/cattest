CREATE TABLE sis.SMCS
	(SMCS_ID          INT NOT NULL
	,SMCSCOMPCODE     CHAR(4) NOT NULL
	,CurrentIndicator BIT NOT NULL
	,[LastModified_Date] DATETIME2(0) NOT NULL DEFAULT (GETDATE())
	,CONSTRAINT PK_SMCS_1 PRIMARY KEY CLUSTERED(SMCS_ID ASC));

GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'SMCS'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'SMCS_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Natural Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'SMCS'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'SMCSCOMPCODE';

GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_SMCSCOMPCODE]
    ON [sis].[SMCS]([SMCSCOMPCODE] ASC);
GO
