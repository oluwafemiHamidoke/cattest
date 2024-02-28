CREATE TABLE [sis_stage].[IE_InfoType_Relation_Diff] (
    [Operation]   VARCHAR (50) NOT NULL,
    [InfoType_ID] INT          NOT NULL,
    [IE_ID]       INT          NOT NULL,
    CONSTRAINT [PK_InfoType_Relation_Diff] PRIMARY KEY CLUSTERED ([InfoType_ID] ASC, [IE_ID] ASC)
);

