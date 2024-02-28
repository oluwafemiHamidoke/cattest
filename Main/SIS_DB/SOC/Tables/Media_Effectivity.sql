CREATE TABLE SOC.Media_Effectivity (Media_ID              INT NOT NULL
								   ,SerialNumberPrefix_ID INT NOT NULL
								   ,SerialNumberRange_ID  INT NOT NULL
								   ,CONSTRAINT PK_Media_Effectivity_1 PRIMARY KEY CLUSTERED(Media_ID ASC,SerialNumberPrefix_ID ASC,SerialNumberRange_ID ASC)
								   ,CONSTRAINT FK_Media_Effectivity_Media FOREIGN KEY(Media_ID) REFERENCES SOC.Media(Media_ID)
								   ,CONSTRAINT FK_Media_Effectivity_SerialNumberPrefix FOREIGN KEY(SerialNumberPrefix_ID) REFERENCES SOC.SerialNumberPrefix(SerialNumberPrefix_ID)
								   ,CONSTRAINT FK_Media_Effectivity_SerialNumberRange FOREIGN KEY(SerialNumberRange_ID) REFERENCES SOC.SerialNumberRange(SerialNumberRange_ID));

GO

CREATE STATISTICS [SerialNumberPrefix_ID]
    ON [SOC].[Media_Effectivity]([SerialNumberPrefix_ID]);
GO

CREATE STATISTICS [SerialNumberRange_ID]
    ON [SOC].[Media_Effectivity]([SerialNumberRange_ID]);
GO

EXECUTE sp_addextendedproperty @name = N'MS_Description'
							  ,@value = N'Foreign Key REFERENCES SOC.Media(Media_ID)'
							  ,@level0type = N'SCHEMA'
							  ,@level0name = N'SOC'
							  ,@level1type = N'TABLE'
							  ,@level1name = N'Media_Effectivity'
							  ,@level2type = N'COLUMN'
							  ,@level2name = N'Media_ID';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description'
							  ,@value = N'https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4926/'
							  ,@level0type = N'SCHEMA'
							  ,@level0name = N'SOC'
							  ,@level1type = N'TABLE'
							  ,@level1name = N'Media_Effectivity';

GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Foreign Key REFERENCES SOC.SerialNumberPrefix(SerialNumberPrefix_ID)'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Media_Effectivity'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'SerialNumberPrefix_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Foreign Key REFERENCES SOC.SerialNumberRange(SerialNumberRange_ID)'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Media_Effectivity'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'SerialNumberRange_ID';