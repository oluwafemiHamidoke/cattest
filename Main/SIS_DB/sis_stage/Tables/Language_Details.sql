CREATE TABLE [sis_stage].[Language_Details] (
    [Language_ID]               INT          NULL,
    [Language]                  VARCHAR (50) NOT NULL,
    [Language_Code]             VARCHAR (2)  NOT NULL,
    [Language_Tag]              VARCHAR (50) NOT NULL,
    [Legacy_Language_Indicator] VARCHAR (2)  NULL,
    [Default_Language]          BIT          DEFAULT ((0)) NOT NULL,
    [LastModifiedDate]          DATETIME     NULL,
    [Lang]						VARCHAR (50) NULL,
    CONSTRAINT [PK_Language_Details] PRIMARY KEY CLUSTERED ([Language_Tag] ASC)
    );


GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Modified according to https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4590/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis_stage'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Language_Details'
						   ,@level2type = NULL
						   ,@level2name = NULL;
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'Primary Key'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis_stage'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Language_Details'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Language_Tag';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'the two character code like ‘en’ '
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis_stage'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Language_Details'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Language_Code';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'the language indicator from previous SIS application'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis_stage'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Language_Details'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Legacy_Language_Indicator';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'a flag to indicate if this is the default for a given language'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis_stage'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'Language_Details'
						   ,@level2type = N'COLUMN'
						   ,@level2name = N'Default_Language';
GO
CREATE NONCLUSTERED INDEX [IX_Legacy_Language_Details_Indicator_E]
    ON [sis_stage].[Language_Details]([Legacy_Language_Indicator] ASC, [Default_Language] ASC) WHERE ([Legacy_Language_Indicator]='E' AND [Default_Language]=(1));

