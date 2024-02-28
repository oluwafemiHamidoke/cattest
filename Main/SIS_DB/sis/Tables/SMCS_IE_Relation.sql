CREATE TABLE sis.SMCS_IE_Relation
	(SMCS_ID INT NOT NULL
	,IE_ID   INT NOT NULL
	,Media_ID INT  NOT NULL
	,CONSTRAINT PK_SMCS_IE_Relation PRIMARY KEY CLUSTERED(SMCS_ID ASC,IE_ID ASC,Media_ID ASC)
	,CONSTRAINT FK_SMCS_IE_Relation_IE FOREIGN KEY(IE_ID) REFERENCES sis.IE(IE_ID)
	,CONSTRAINT FK_SMCS_IE_Relation_SMCS FOREIGN KEY(SMCS_ID) REFERENCES sis.SMCS(SMCS_ID)
	,CONSTRAINT FK_SMCS_IE_Relation_Media_ID FOREIGN KEY(Media_ID) REFERENCES sis.[Media] ([Media_ID]));

GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'SMCS_IE_Relation'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'SMCS_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'SMCS_IE_Relation'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'IE_ID';
GO
Create nonclustered index IX_SMCS_IE_Relation_IE_ID on sis.SMCS_IE_Relation (IE_ID) ;
GO
CREATE NONCLUSTERED INDEX [SMCS_IE_Relation_Media_ID]
ON [sis].[SMCS_IE_Relation] ([Media_ID])