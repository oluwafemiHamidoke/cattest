Create Table [sis].[ServiceFile_DisplayTerms_Translation] (
    [ServiceFile_DisplayTerms_ID]  INT            NOT NULL,
    [Language_ID]            INT            NOT NULL,
    [Value_Type]             VARCHAR(5)     NULL,
    [Value]                  NVARCHAR(2000) NULL,
    [Display_Value]             NVARCHAR(2000) NULL,   
    CONSTRAINT [PK_ServiceFile_DisplayTerms_Translation] PRIMARY KEY CLUSTERED ([ServiceFile_DisplayTerms_ID] ASC, [Language_ID] ASC),
    CONSTRAINT [FK_ServiceFile_DisplayTerms_Translation_ServiceFile_DisplayTerms] FOREIGN KEY ([ServiceFile_DisplayTerms_ID]) REFERENCES [sis].[ServiceFile_DisplayTerms] ([ServiceFile_DisplayTerms_ID]),
    CONSTRAINT [FK_ServiceFile_DisplayTerms_Translation_Language] FOREIGN KEY ([Language_ID]) REFERENCES [sis].[Language_Details] ([Language_ID])
);
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
                           ,@value = N'Primary Key'
                           ,@level0type = N'SCHEMA'
                           ,@level0name = N'sis'
                           ,@level1type = N'TABLE'
                           ,@level1name = N'ServiceFile_DisplayTerms_Translation'
                           ,@level2type = N'COLUMN'
                           ,@level2name = N'ServiceFile_DisplayTerms_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
                           ,@value = N'Primary Key'
                           ,@level0type = N'SCHEMA'
                           ,@level0name = N'sis'
                           ,@level1type = N'TABLE'
                           ,@level1name = N'ServiceFile_DisplayTerms_Translation'
                           ,@level2type = N'COLUMN'
                           ,@level2name = N'Language_ID';
