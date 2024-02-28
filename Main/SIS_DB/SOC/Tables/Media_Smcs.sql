CREATE TABLE SOC.Media_Smcs (Media_ID INT NOT NULL
							,Smcs_ID  INT NOT NULL
							,CONSTRAINT PK_Media_Smcs PRIMARY KEY(Media_ID,Smcs_ID)
							,CONSTRAINT FK_Media_Smcs_Media FOREIGN KEY(Media_ID) REFERENCES SOC.Media(Media_ID)
							,CONSTRAINT FK_Media_Smcs_Smcs FOREIGN KEY(Smcs_ID) REFERENCES SOC.Smcs(Smcs_ID));

GO

CREATE STATISTICS [Media_ID]
    ON [SOC].[Media_Smcs]([Media_ID]);
GO

CREATE STATISTICS [Smcs_ID]
    ON [SOC].[Media_Smcs]([Smcs_ID]);
GO

EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Foreign Key REFERENCES SOC.Media(Media_ID)'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Media_Smcs'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Media_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Foreign Key REFERENCES SOC.Smcs(Smcs_ID)'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Media_Smcs'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Smcs_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4926/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Media_Smcs'
						   ,@level2type = NULL
						   ,@level2name = NULL;