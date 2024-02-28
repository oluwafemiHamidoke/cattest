CREATE TABLE [sis].[MediaSequence_Translation] (
    [MediaSequence_ID] INT             NOT NULL,
    [Language_ID]      INT             NOT NULL,
    [Modifier]         VARCHAR (250)   NULL,
    [Caption]          VARCHAR (4000)  NULL,
    [Title]            NVARCHAR (2000) NULL,
    CONSTRAINT [PK_MediaSequence_Translation] PRIMARY KEY CLUSTERED ([MediaSequence_ID] ASC, [Language_ID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_MediaSequence_Translation_Language] FOREIGN KEY ([Language_ID]) REFERENCES [sis].[Language_Details] ([Language_ID]),
    CONSTRAINT [FK_MediaSequence_Translation_MediaSequence] FOREIGN KEY ([MediaSequence_ID]) REFERENCES [sis].[MediaSequence_Base] ([MediaSequence_ID])
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'was [PartsManualSequence_Translation], https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4955/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'MediaSequence_Translation'
						   ,@level2type = NULL
						   ,@level2name = NULL;