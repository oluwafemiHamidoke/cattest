CREATE TABLE [sis_stage].[MediaSection_Translation] (
    [MediaSection_ID] INT            NOT NULL,
    [Language_ID]     INT            NOT NULL,
    [Name]            NVARCHAR (400) NULL,
    CONSTRAINT [PK_MediaSection_Translation] PRIMARY KEY CLUSTERED ([MediaSection_ID] ASC, [Language_ID] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'renamed from [PartsManualSection_Translation] https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4955/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis_stage'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'MediaSection_Translation'
						   ,@level2type = NULL
						   ,@level2name = NULL;