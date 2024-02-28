CREATE TABLE [sis_stage].[MediaSequence_Key] (
    [MediaSequence_ID] INT IDENTITY (1, 1) NOT NULL,
    [MediaSection_ID]  INT NOT NULL,
    [IEPart_ID]        INT NOT NULL,
    [IE_ID]            INT NOT NULL,
    [Sequence_Number]  INT NOT NULL,
    CONSTRAINT [PK_MediaSequence_Key] PRIMARY KEY CLUSTERED ([MediaSequence_ID] ASC)
);


GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'renamed from [PartsManualSequence_Key] https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4955/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis_stage'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'MediaSequence_Key'
						   ,@level2type = NULL
						   ,@level2name = NULL;