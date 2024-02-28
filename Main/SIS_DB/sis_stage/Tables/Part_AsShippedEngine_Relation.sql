CREATE TABLE [sis_stage].[Part_AsShippedEngine_Relation] (
    [Part_AsShippedEngine_Relation_ID] INT         NULL,
    [AsShippedEngine_ID]               INT         NOT NULL,
    [Part_ID]                          INT         NOT NULL,
    [Quantity]                         INT         NOT NULL,
    [Sequence_Number]                  INT         NOT NULL,
    [Change_Level_Number]              VARCHAR (4) NULL,
    [Assembly]                         VARCHAR (1) NULL,
    [Less_Indicator]                   VARCHAR (1) NULL,
    [Indentation]                      VARCHAR (1) NULL,
    CONSTRAINT [PK_Part_AsShippedEngine_Relation] PRIMARY KEY CLUSTERED ([AsShippedEngine_ID] ASC, [Part_ID] ASC, [Sequence_Number] ASC)
);