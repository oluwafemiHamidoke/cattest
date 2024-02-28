CREATE TABLE [sis].[Media_InfoType_Relation] (
    [InfoType_ID] INT NOT NULL,
    [Media_ID]    INT NOT NULL,
    CONSTRAINT [PK_Media_InfoType_Relation] PRIMARY KEY CLUSTERED ([Media_ID] ASC, [InfoType_ID] ASC),
    CONSTRAINT [FK_Media_InfoType_Relation_InfoType] FOREIGN KEY ([InfoType_ID]) REFERENCES [sis].[InfoType] ([InfoType_ID]),
    CONSTRAINT [FK_Media_InfoType_Relation_Media] FOREIGN KEY ([Media_ID]) REFERENCES [sis].[Media] ([Media_ID])
);
GO

CREATE INDEX IDX_media_id ON [sis].[Media_InfoType_Relation] (Media_ID) INCLUDE (InfoType_ID)
GO


EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Media_InfoType_Relation'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'InfoType_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Media_InfoType_Relation'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Media_ID';
GO
