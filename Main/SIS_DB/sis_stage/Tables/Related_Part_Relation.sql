CREATE TABLE [sis_stage].[Related_Part_Relation] (
    [Related_Part_Relation_ID] INT          NULL,
    [Related_Part_ID]          INT          NOT NULL,
    [Part_ID]                  INT          NOT NULL,
    [Type_Indicator]           VARCHAR (10) NOT NULL,
    [Relation_Type]            VARCHAR (50) NULL,
    [LastModified_Date]        DATETIME     NULL,
    CONSTRAINT [PK_Related_Part_Relation] PRIMARY KEY CLUSTERED ([Related_Part_ID] ASC, [Part_ID] ASC, [Type_Indicator] ASC)
);