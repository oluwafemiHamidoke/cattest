Create Table [sis].[ServiceFile_ReplacementHierarchy] (
    [ServiceFile_ID]                INT      NOT NULL,   
    [Replacing_ServiceFile_ID]      INT      NOT NULL,
    [Sequence_No]                   SMALLINT NOT NULL,
    CONSTRAINT [PK_ServiceFile_ReplacementHierarchy] PRIMARY KEY CLUSTERED ([ServiceFile_ID] ASC, [Replacing_ServiceFile_ID] ASC),
    CONSTRAINT [FK_ServiceFile_ReplacementHierarchy_ServiceFile] FOREIGN KEY ([ServiceFile_ID]) REFERENCES [sis].[ServiceFile] ([ServiceFile_ID]),
    CONSTRAINT [FK_ServiceFile_ReplacementHierarchy_Replacing_ServiceFile] FOREIGN KEY ([Replacing_ServiceFile_ID]) REFERENCES [sis].[ServiceFile] ([ServiceFile_ID])
);
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
                           ,@value = N'Primary Key'
                           ,@level0type = N'SCHEMA'
                           ,@level0name = N'sis'
                           ,@level1type = N'TABLE'
                           ,@level1name = N'ServiceFile_ReplacementHierarchy'
                           ,@level2type = N'COLUMN'
                           ,@level2name = N'ServiceFile_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
                           ,@value = N'Primary Key'
                           ,@level0type = N'SCHEMA'
                           ,@level0name = N'sis'
                           ,@level1type = N'TABLE'
                           ,@level1name = N'ServiceFile_ReplacementHierarchy'
                           ,@level2type = N'COLUMN'
                           ,@level2name = N'Replacing_ServiceFile_ID';