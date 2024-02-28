CREATE TABLE sis.SMCS_Translation
	(SMCS_ID     INT NOT NULL
	,Language_ID INT NOT NULL
	,Description NVARCHAR(192) NULL
	,CONSTRAINT PK_SMCS_Translation PRIMARY KEY CLUSTERED(SMCS_ID ASC,Language_ID ASC)
	,CONSTRAINT FK_SMCS_Translation_Language FOREIGN KEY(Language_ID) REFERENCES sis.Language_Details(Language_ID)
	,CONSTRAINT FK_SMCS_Translation_SMCS FOREIGN KEY(SMCS_ID) REFERENCES sis.SMCS(SMCS_ID));
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Primary Key',
    @level0type = N'SCHEMA',
    @level0name = N'sis',
    @level1type = N'TABLE',
    @level1name = N'SMCS_Translation',
    @level2type = N'COLUMN',
    @level2name = N'SMCS_ID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Primary Key',
    @level0type = N'SCHEMA',
    @level0name = N'sis',
    @level1type = N'TABLE',
    @level1name = N'SMCS_Translation',
    @level2type = N'COLUMN',
    @level2name = N'Language_ID'