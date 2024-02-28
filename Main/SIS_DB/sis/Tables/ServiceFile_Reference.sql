Create Table [sis].[ServiceFile_Reference] (
    [ServiceFile_ID]            INT NOT NULL,
    [Referred_ServiceFile_ID]   INT NOT NULL,
    [Language_ID]               INT NOT NULL,
    CONSTRAINT [PK_ServiceFile_Reference] PRIMARY KEY CLUSTERED ([ServiceFile_ID] ASC, [Referred_ServiceFile_ID] ASC, [Language_ID] ASC),
    CONSTRAINT [FK_ServiceFile_Reference_Language] FOREIGN KEY ([Language_ID]) REFERENCES [sis].[Language_Details] ([Language_ID]),
    CONSTRAINT [FK_ServiceFile_Reference_ServiceFile] FOREIGN KEY ([ServiceFile_ID]) REFERENCES [sis].[ServiceFile] ([ServiceFile_ID]),
    CONSTRAINT [FK_ServiceFile_Reference_Referred_ServiceFile] FOREIGN KEY ([Referred_ServiceFile_ID]) REFERENCES [sis].[ServiceFile] ([ServiceFile_ID])
);
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
                           ,@value = N'Primary Key'
                           ,@level0type = N'SCHEMA'
                           ,@level0name = N'sis'
                           ,@level1type = N'TABLE'
                           ,@level1name = N'ServiceFile_Reference'
                           ,@level2type = N'COLUMN'
                           ,@level2name = N'ServiceFile_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
                           ,@value = N'Primary Key'
                           ,@level0type = N'SCHEMA'
                           ,@level0name = N'sis'
                           ,@level1type = N'TABLE'
                           ,@level1name = N'ServiceFile_Reference'
                           ,@level2type = N'COLUMN'
                           ,@level2name = N'Referred_ServiceFile_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
                           ,@value = N'Primary Key'
                           ,@level0type = N'SCHEMA'
                           ,@level0name = N'sis'
                           ,@level1type = N'TABLE'
                           ,@level1name = N'ServiceFile_Reference'
                           ,@level2type = N'COLUMN'
                           ,@level2name = N'Language_ID';