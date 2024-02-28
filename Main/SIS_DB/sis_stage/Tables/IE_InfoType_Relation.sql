CREATE TABLE [sis_stage].[IE_InfoType_Relation] (
    [InfoType_ID] INT NOT NULL,
    [IE_ID]       INT NOT NULL,
    CONSTRAINT [PK_IE_InfoType_Relation] PRIMARY KEY CLUSTERED ([InfoType_ID] ASC, [IE_ID] ASC)
);

