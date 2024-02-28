CREATE TABLE [sis_stage].[MediaSequence_Translation] (
    [MediaSequence_ID] INT             NOT NULL,
    [Language_ID]      INT             NOT NULL,
    [Modifier]         VARCHAR (250)   NULL,
    [Caption]          VARCHAR (4000)  NULL,
    [Title]            NVARCHAR (2000) NULL,
    CONSTRAINT [PK_MediaSequence_Translation] PRIMARY KEY CLUSTERED ([MediaSequence_ID] ASC, [Language_ID] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'renamed from [PartsManualSequence_Translation] https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4955/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis_stage'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'MediaSequence_Translation'
						   ,@level2type = NULL
						   ,@level2name = NULL;