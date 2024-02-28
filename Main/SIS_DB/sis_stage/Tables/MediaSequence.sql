CREATE TABLE [sis_stage].[MediaSequence] (
    [MediaSequence_ID]         INT         NULL,
    [MediaSection_ID]          INT         NOT NULL,
    [IEPart_ID]                INT         NOT NULL,
    [IE_ID]                    INT         NOT NULL,
    [Sequence_Number]          INT         NOT NULL,
    [Serviceability_Indicator] VARCHAR (1) NULL,
	[Arrangement_Indicator] [varchar](1) NULL,
	[TypeChange_Indicator] [varchar](1) NULL,
	[NPR_Indicator] [varchar](1) NULL,
	[CCR_Indicator]            VARCHAR (1) NULL,
	[IESystemControlNumber] [varchar](12) NULL,
    [Part]                        VARCHAR (10) NOT NULL DEFAULT '1',
    [Of_Parts]                    VARCHAR (10) NOT NULL DEFAULT '1',
    [LastModified_Date]    DATETIME2(0) NULL,
    CONSTRAINT [PK_MediaSequence] PRIMARY KEY CLUSTERED ([MediaSection_ID] ASC, [IEPart_ID] ASC, [IE_ID] ASC, [Sequence_Number] ASC)
);




GO
EXEC sp_addextendedproperty @name = N'MS_Description'
						   ,@value = N'renamed from [PartsManualSequence] https://sis-cat-com.visualstudio.com/devops-infra/_workitems/edit/4955/'
						   ,@level0type = N'SCHEMA'
						   ,@level0name = N'sis_stage'
						   ,@level1type = N'TABLE'
						   ,@level1name = N'MediaSequence'
						   ,@level2type = NULL
						   ,@level2name = NULL;
GO
CREATE NONCLUSTERED INDEX [IX_MediaSequence_IEPart_ID]
    ON [sis_stage].[MediaSequence]([IEPart_ID] ASC)
    INCLUDE([MediaSequence_ID]);


GO
CREATE NONCLUSTERED INDEX [IX_MediaSequence_IE_ID]
    ON [sis_stage].[MediaSequence]([IE_ID] ASC)
    INCLUDE([MediaSequence_ID]);

