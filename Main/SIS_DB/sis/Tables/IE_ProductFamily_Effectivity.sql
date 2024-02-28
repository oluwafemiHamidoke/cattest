CREATE TABLE sis.IE_ProductFamily_Effectivity
	(IE_ID            INT NOT NULL
	,ProductFamily_ID INT NOT NULL
	,Media_ID		  INT NOT NULL
	,CONSTRAINT PK_IE_ProductFamily_Effectivity PRIMARY KEY CLUSTERED(IE_ID ASC,ProductFamily_ID ASC,Media_ID ASC)
	,CONSTRAINT FK_IE_ProductFamily_Effectivity_IE FOREIGN KEY(IE_ID) REFERENCES sis.IE(IE_ID)
	,CONSTRAINT FK_IE_ProductFamily_Effectivity_ProductFamily FOREIGN KEY(ProductFamily_ID) REFERENCES sis.ProductFamily(ProductFamily_ID)
	,CONSTRAINT FK_IE_ProductFamily_Effectivity_Media FOREIGN KEY(Media_ID) REFERENCES sis.Media(Media_ID)
	);

GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'IE_ProductFamily_Effectivity'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'IE_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'IE_ProductFamily_Effectivity'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'ProductFamily_ID';
GO
CREATE NONCLUSTERED INDEX [IE_ProductFamily_Effectivity_Media_ID]
ON [sis].[IE_ProductFamily_Effectivity] ([Media_ID])						   