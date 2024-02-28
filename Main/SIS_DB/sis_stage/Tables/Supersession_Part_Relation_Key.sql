CREATE TABLE [sis_stage].[Supersession_Part_Relation_Key] (
    [Supersession_Part_ID]           INT NOT NULL,
    [Part_ID]                        INT NOT NULL,
    [Supsersession_Part_Relation_ID] INT IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_Supersession_Part_Relation_Key] PRIMARY KEY CLUSTERED ([Supsersession_Part_Relation_ID] ASC)
);