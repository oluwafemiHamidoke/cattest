CREATE TABLE [sis].[FlashApplication] (
    [FlashApplication_ID] INT NOT NULL,
    [Is_Engine_Related] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_FlashApplication] PRIMARY KEY CLUSTERED ([FlashApplication_ID] ASC)
);
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
                           ,@value = N'Primary Key'
                           ,@level0type = N'SCHEMA'
                           ,@level0name = N'sis'
                           ,@level1type = N'TABLE'
                           ,@level1name = N'FlashApplication'
                           ,@level2type = N'COLUMN'
                           ,@level2name = N'FlashApplication_ID';