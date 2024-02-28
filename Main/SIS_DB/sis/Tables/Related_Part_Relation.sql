CREATE TABLE [sis].[Related_Part_Relation] (
    [Related_Part_Relation_ID] INT          NOT NULL,
    [Related_Part_ID]          INT          NOT NULL,
    [Part_ID]                  INT          NOT NULL,
    [Type_Indicator]           VARCHAR (10) NOT NULL,
    [Relation_Type]            VARCHAR (50) NULL,
    [LastModified_Date]        DATETIME     NULL,
    CONSTRAINT [PK_Related_Part_Relation] PRIMARY KEY CLUSTERED ([Related_Part_Relation_ID] ASC),
    CONSTRAINT [FK_Related_Part_Relation_Part] FOREIGN KEY ([Related_Part_ID]) REFERENCES [sis].[Part] ([Part_ID]),
    CONSTRAINT [FK_Related_Part_Relation_Related_Part] FOREIGN KEY ([Part_ID]) REFERENCES [sis].[Part] ([Part_ID])
);
Go
CREATE NONCLUSTERED INDEX NCI_Related_Part_Relation_Part ON [sis].[Related_Part_Relation] 
([Part_ID] ASC);