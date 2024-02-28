CREATE TABLE [sis_stage].[Supersession_Part_Relation] (
    [Supersession_Part_ID]           INT NOT NULL,
    [Part_ID]                        INT NOT NULL,
    [isExpandedMiningProduct]        BIT NOT NULL,
    [Supsersession_Part_Relation_ID] INT NULL,
    CONSTRAINT [PK_Supersession_Part_Relation] PRIMARY KEY CLUSTERED ([Part_ID] ASC, [Supersession_Part_ID] ASC)
);