CREATE TABLE sis.IE_MarketingOrg_Relation
	(IE_ID           INT NOT NULL
	,MarketingOrg_ID INT NOT NULL
	,CONSTRAINT PK_IE_MarketingOrg_Relation PRIMARY KEY CLUSTERED(IE_ID ASC,MarketingOrg_ID ASC)
	,CONSTRAINT FK_IE_MarketingOrg_Relation_IE FOREIGN KEY(IE_ID) REFERENCES sis.IE(IE_ID)
	,CONSTRAINT FK_IE_MarketingOrg_Relation_MarketingOrg FOREIGN KEY(MarketingOrg_ID) REFERENCES sis.MarketingOrg(MarketingOrg_ID));
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'IE_MarketingOrg_Relation'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'IE_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'IE_MarketingOrg_Relation'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'MarketingOrg_ID';