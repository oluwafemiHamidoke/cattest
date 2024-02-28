CREATE TABLE [sis_stage].[SupersessionChain_Part_Relation] (
    [SupersessionChain_ID] INT NOT NULL,
    [Part_ID]              INT NOT NULL,
    CONSTRAINT [PK_SupersessionChain_Part_Relation] PRIMARY KEY CLUSTERED ([SupersessionChain_ID] ASC, [Part_ID] ASC)
);