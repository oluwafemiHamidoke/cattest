CREATE TABLE [sis_stage].[SMCS_IE_Relation_Diff] (
    [Operation] VARCHAR (50) NOT NULL,
    [SMCS_ID]   INT          NOT NULL,
    [IE_ID]     INT          NOT NULL,
    [Media_ID]  INT          NOT NULL,
    CONSTRAINT [PK_SMCS_IE_Relation_Diff] PRIMARY KEY CLUSTERED ([SMCS_ID] ASC, [IE_ID] ASC, [Media_ID] ASC)
);

