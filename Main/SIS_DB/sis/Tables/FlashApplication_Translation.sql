Create Table [sis].[FlashApplication_Translation] (
    [FlashApplication_ID]        INT            NOT NULL,
    [Language_ID]                INT            NOT NULL,
    [Description]                NVARCHAR (720) NULL,
    CONSTRAINT [PK_FlashApplication_Translation] PRIMARY KEY CLUSTERED ([FlashApplication_ID] ASC, [Language_ID] ASC),
    CONSTRAINT [FK_FlashApplication_Translation_FlashApplication] FOREIGN KEY ([FlashApplication_ID]) REFERENCES [sis].[FlashApplication] ([FlashApplication_ID]),
    CONSTRAINT [FK_FlashApplication_Translation_Language] FOREIGN KEY ([Language_ID]) REFERENCES [sis].[Language_Details] ([Language_ID])
);
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
                           ,@value = N'Primary Key'
                           ,@level0type = N'SCHEMA'
                           ,@level0name = N'sis'
                           ,@level1type = N'TABLE'
                           ,@level1name = N'FlashApplication_Translation'
                           ,@level2type = N'COLUMN'
                           ,@level2name = N'FlashApplication_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
                           ,@value = N'Primary Key'
                           ,@level0type = N'SCHEMA'
                           ,@level0name = N'sis'
                           ,@level1type = N'TABLE'
                           ,@level1name = N'FlashApplication_Translation'
                           ,@level2type = N'COLUMN'
                           ,@level2name = N'Language_ID';