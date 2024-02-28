CREATE TABLE [sis_stage].[Media_InfoType_Relation] (
    [Media_ID]    INT NOT NULL,
    [InfoType_ID] INT NOT NULL,
    CONSTRAINT [PK_Media_InfoType_Relation] PRIMARY KEY CLUSTERED ([Media_ID] ASC, [InfoType_ID] ASC)
);

