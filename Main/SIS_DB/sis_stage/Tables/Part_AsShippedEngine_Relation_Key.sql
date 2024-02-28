CREATE TABLE [sis_stage].[Part_AsShippedEngine_Relation_Key] (
    [Part_AsShippedEngine_Relation_ID] INT IDENTITY (1, 1) NOT NULL,
    [AsShippedEngine_ID]               INT NOT NULL,
    [Part_ID]                          INT NOT NULL,
    [Sequence_Number]                  INT NULL,
    CONSTRAINT [PK_Part_AsShippedEngine_Relation_Key] PRIMARY KEY CLUSTERED ([Part_AsShippedEngine_Relation_ID] ASC)
);