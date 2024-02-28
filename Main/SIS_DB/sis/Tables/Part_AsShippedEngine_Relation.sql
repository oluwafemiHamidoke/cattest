CREATE TABLE [sis].[Part_AsShippedEngine_Relation] (
    [Part_AsShippedEngine_Relation_ID] INT         NOT NULL,
    [AsShippedEngine_ID]               INT         NOT NULL,
    [Part_ID]                          INT         NOT NULL,
    [Quantity]                         INT         NOT NULL,
    [Sequence_Number]                  INT         NULL,
    [Change_Level_Number]              VARCHAR (4) NULL,
    [Assembly]                         VARCHAR (1) NULL,
    [Less_Indicator]                   VARCHAR (1) NULL,
    [Indentation]                      VARCHAR (1) NULL,
    CONSTRAINT [PK_Part_AsShippedEngine_Relation] PRIMARY KEY CLUSTERED ([Part_AsShippedEngine_Relation_ID] ASC),
    CONSTRAINT [FK_Part_AsShippedEngine_Relation_AsShippedEngine] FOREIGN KEY ([AsShippedEngine_ID]) REFERENCES [sis].[AsShippedEngine] ([AsShippedEngine_ID]),
    CONSTRAINT [FK_Part_AsShippedEngine_Relation_Part] FOREIGN KEY ([Part_ID]) REFERENCES [sis].[Part] ([Part_ID])
);
GO
CREATE NONCLUSTERED INDEX NCI_Part_AsShippedEngine_Relation_AsShippedEngine ON [sis].[Part_AsShippedEngine_Relation] 
([AsShippedEngine_ID] ASC) ;
GO
CREATE NONCLUSTERED INDEX NCI_Part_AsShippedEngine_Relation_Part ON [sis].[Part_AsShippedEngine_Relation]  
([Part_ID]);
GO
CREATE NONCLUSTERED INDEX IX_Part_AsSippedEngine_AsShippedEngine_ID ON [sis].[Part_AsShippedEngine_Relation]
(
    [AsShippedEngine_ID] ASC,
    [Part_ID] ASC
) INCLUDE ([Assembly],[Sequence_Number],[Change_Level_Number],[Less_Indicator],[Indentation])
