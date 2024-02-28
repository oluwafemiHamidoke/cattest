CREATE TABLE sis.MarketingOrg
	(MarketingOrg_ID   INT NOT NULL
	,MarketingOrg_Code VARCHAR(50) NOT NULL
	,CONSTRAINT PK_MarketingOrg PRIMARY KEY CLUSTERED(MarketingOrg_ID));
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'MarketingOrg'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'MarketingOrg_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Natural Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'MarketingOrg'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'MarketingOrg_Code';