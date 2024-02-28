CREATE TABLE [sis].[MediaSection_Translation] (
    [MediaSection_ID] INT            NOT NULL,
    [Language_ID]     INT            NOT NULL,
    [Name]            NVARCHAR (400) NULL,
    CONSTRAINT [PK_MediaSection_Translation] PRIMARY KEY CLUSTERED ([MediaSection_ID] ASC, [Language_ID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_MediaSection_Translation_Language] FOREIGN KEY ([Language_ID]) REFERENCES [sis].[Language_Details] ([Language_ID]),
    CONSTRAINT [FK_MediaSection_Translation_MediaSection] FOREIGN KEY ([MediaSection_ID]) REFERENCES [sis].[MediaSection] ([MediaSection_ID])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'was [PartsManualSecion_Translation], https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4955/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'MediaSection_Translation'
						   ,@level2type = NULL
						   ,@level2name = NULL;