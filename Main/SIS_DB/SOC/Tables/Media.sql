CREATE TABLE [SOC].[Media] (
    [Media_ID]     INT           IDENTITY (1, 1) NOT NULL,
    [Media_Number] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Media] PRIMARY KEY CLUSTERED ([Media_ID] ASC)
);



GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4926/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Media'
						   ,@level2type = NULL
						   ,@level2name = NULL;
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Eight characters – we gave them P0000000-P9999999 as their media numbers to use'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Media'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Media_Number';

GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'SOC'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Media'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Media_ID';
GO
CREATE NONCLUSTERED INDEX [IX_Media_Media_Number]
    ON [SOC].[Media]([Media_Number] ASC);

