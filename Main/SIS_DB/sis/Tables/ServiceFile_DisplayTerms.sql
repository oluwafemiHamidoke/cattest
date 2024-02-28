Create Table [sis].[ServiceFile_DisplayTerms] (
    [ServiceFile_DisplayTerms_ID]  INT            NOT NULL,
    [ServiceFile_ID]               INT            NOT NULL,
    [Type]                         VARCHAR(8)     NOT NULL,
    CONSTRAINT [PK_ServiceFile_DisplayTerms] PRIMARY KEY CLUSTERED([ServiceFile_DisplayTerms_ID] ASC),
    CONSTRAINT [UK_ServiceFile_DisplayTerms] UNIQUE ([ServiceFile_ID] ASC, [Type] ASC),
    CONSTRAINT [FK_ServiceFile_DisplayTerms_File] FOREIGN KEY ([ServiceFile_ID]) REFERENCES [sis].[ServiceFile] ([ServiceFile_ID])
);
GO

EXEC sp_addextendedproperty @name = N'MS_Description'
                           ,@value = N'Primary Key'
                           ,@level0type = N'SCHEMA'
                           ,@level0name = N'sis'
                           ,@level1type = N'TABLE'
                           ,@level1name = N'ServiceFile_DisplayTerms'
                           ,@level2type = N'COLUMN'
                           ,@level2name = N'ServiceFile_DisplayTerms_ID';