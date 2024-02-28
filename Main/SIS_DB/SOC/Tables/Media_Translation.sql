CREATE TABLE SOC.Media_Translation (Media_ID       INT NOT NULL
								   ,Language_ID    INT NOT NULL
								   ,Process_Date   DATETIMEOFFSET(0) NULL
								   ,Published_Date DATETIMEOFFSET(0) NULL
								   ,Title          NVARCHAR(4000) NULL
								   ,Version        TINYINT CONSTRAINT DF_Media_Translation_Version DEFAULT 0 NULL
								   ,File_Location  VARCHAR(150) NOT NULL
								   ,File_Size_Byte INT NULL
								   ,Mime_Type      VARCHAR(250) NULL
    CONSTRAINT PK_Media_Translation_1 PRIMARY KEY CLUSTERED(Media_ID ASC,Language_ID ASC)
								   ,CONSTRAINT FK_Media_Translation_Media FOREIGN KEY(Media_ID) REFERENCES SOC.Media(Media_ID));

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description'
							  ,@value = N'Just a number – we’re mimicking what comes out of ACM – P0000001-0_fr.pdf'
							  ,@level0type = N'SCHEMA'
							  ,@level0name = N'SOC'
							  ,@level1type = N'TABLE'
							  ,@level1name = N'Media_Translation'
							  ,@level2type = N'COLUMN'
							  ,@level2name = N'Version';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description'
							  ,@value = N'So far the largest media title I’ve seen is 51 characters for a title in French (Axe et bague du bras de la chargeuse – Remplace'
							  ,@level0type = N'SCHEMA'
							  ,@level0name = N'SOC'
							  ,@level1type = N'TABLE'
							  ,@level1name = N'Media_Translation'
							  ,@level2type = N'COLUMN'
							  ,@level2name = N'Title';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description'
							  ,@value = N'For consistency, copied from sis.Media_Translation'
							  ,@level0type = N'SCHEMA'
							  ,@level0name = N'SOC'
							  ,@level1type = N'TABLE'
							  ,@level1name = N'Media_Translation'
							  ,@level2type = N'COLUMN'
							  ,@level2name = N'Process_Date';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description'
							  ,@value = N'SHOULD BE Foreign Key REFERENCES sis.Language_Details(Language_ID) BUT IT IS NOT'
							  ,@level0type = N'SCHEMA'
							  ,@level0name = N'SOC'
							  ,@level1type = N'TABLE'
							  ,@level1name = N'Media_Translation'
							  ,@level2type = N'COLUMN'
							  ,@level2name = N'Language_ID';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description'
							  ,@value = N'Primary Key'
							  ,@level0type = N'SCHEMA'
							  ,@level0name = N'SOC'
							  ,@level1type = N'TABLE'
							  ,@level1name = N'Media_Translation'
							  ,@level2type = N'COLUMN'
							  ,@level2name = N'Media_ID';

GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Translation table for Media https://dev.azure.com/sis-cat-com/devops-infra/_workitems/edit/4926/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Media_Translation'
						   ,@level2type = NULL
						   ,@level2name = NULL;