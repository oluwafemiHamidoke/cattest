CREATE TABLE [sis_stage].[Related_Part_Relation_Key] (
    [Related_Part_Relation_ID] INT          IDENTITY (1, 1) NOT NULL,
    [Related_Part_ID]          INT          NOT NULL,
    [Part_ID]                  INT          NOT NULL,
    [Type_Indicator]           VARCHAR (10) NOT NULL,
    CONSTRAINT [PK_Related_Part_Relation_Key] PRIMARY KEY CLUSTERED ([Related_Part_Relation_ID] ASC)
);