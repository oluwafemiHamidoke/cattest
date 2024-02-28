CREATE TABLE [sis].[Language_Details] (
    [Language_ID]               INT          NOT NULL,
    [Language]                  VARCHAR (50) NOT NULL,
    [Language_Code]             VARCHAR (2)  NOT NULL,
    [Language_Tag]              VARCHAR (50) NOT NULL,
    [Legacy_Language_Indicator] VARCHAR (2)  NULL,
    [Default_Language]          BIT          DEFAULT ((0)) NOT NULL,
    [LastModifiedDate]          DATETIME     NULL,
    [Lang]						VARCHAR (50) NULL,
    CONSTRAINT [PK_Language_Details] PRIMARY KEY CLUSTERED ([Language_ID] ASC) WITH (FILLFACTOR = 100)
    );

GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Modified according to https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4590/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Language_Details'
						   ,@level2type = NULL
						   ,@level2name = NULL;
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Language_Details'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Language_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'the two character code like ‘en’ '
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Language_Details'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Language_Code';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'the language indicator from previous SIS application'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Language_Details'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Legacy_Language_Indicator';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'a flag to indicate if this is the default for a given language'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Language_Details'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Default_Language';
GO
CREATE NONCLUSTERED INDEX [IX_Language_Details_Default]
    ON [sis].[Language_Details]([Language_Code] ASC)
    INCLUDE([Language_ID], [Default_Language], [Language], [Language_Tag], [Legacy_Language_Indicator]) WHERE ([Default_Language]=(1));
GO
