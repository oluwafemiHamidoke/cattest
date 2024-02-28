CREATE TABLE sis.IE_Effectivity
	(IE_ID                 INT NOT NULL
	,SerialNumberPrefix_ID INT NOT NULL
	,SerialNumberRange_ID  INT NOT NULL
    ,[Media_ID]              INT CONSTRAINT [DF_IE_Effectivity_Media_ID] DEFAULT ((-1)) NOT NULL
	,CONSTRAINT [PK_IE_Effectivity] PRIMARY KEY CLUSTERED ([IE_ID] ASC, [SerialNumberPrefix_ID] ASC, [SerialNumberRange_ID] ASC, [Media_ID] ASC)
	,CONSTRAINT FK_IE_Effectivity_IE FOREIGN KEY(IE_ID) REFERENCES sis.IE(IE_ID)
	,CONSTRAINT [FK_IE_Effectivity_Media] FOREIGN KEY ([Media_ID]) REFERENCES [sis].[Media] ([Media_ID])
	,CONSTRAINT FK_IE_Effectivity_SerialNumberPrefix FOREIGN KEY(SerialNumberPrefix_ID) REFERENCES sis.SerialNumberPrefix(SerialNumberPrefix_ID)
	,CONSTRAINT FK_IE_Effectivity_SerialNumberRange FOREIGN KEY(SerialNumberRange_ID) REFERENCES sis.SerialNumberRange(SerialNumberRange_ID));

GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'IE_Effectivity'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'IE_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'IE_Effectivity'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'SerialNumberPrefix_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'IE_Effectivity'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'SerialNumberRange_ID';
GO
Create nonclustered index IX_IE_Effectivity_SerialNumberPrefix_ID on sis.IE_Effectivity (SerialNumberPrefix_ID)  ;
GO
Create nonclustered index IX_IE_Effectivity_SerialNumberRange_ID on sis.IE_Effectivity (SerialNumberRange_ID)  ;
GO
CREATE NONCLUSTERED INDEX IX_IE_Effectivity_Media_ID ON [sis].[IE_Effectivity] ([Media_ID])
GO
