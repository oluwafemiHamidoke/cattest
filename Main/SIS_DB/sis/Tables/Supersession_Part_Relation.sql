CREATE TABLE [sis].[Supersession_Part_Relation] (
    [Supsersession_Part_Relation_ID] INT NOT NULL,
    [Supersession_Part_ID]           INT NOT NULL,
    [Part_ID]                        INT NOT NULL,
    CONSTRAINT [PK_Replacement_Part_Relation] PRIMARY KEY CLUSTERED ([Supsersession_Part_Relation_ID] ASC),
    CONSTRAINT [FK_Supersession_Part_Relation_Part] FOREIGN KEY ([Part_ID]) REFERENCES [sis].[Part] ([Part_ID]),
    CONSTRAINT [FK_Supersession_Part_Relation_Supersession_Part] FOREIGN KEY ([Supersession_Part_ID]) REFERENCES [sis].[Part] ([Part_ID])
);
GO
CREATE NONCLUSTERED INDEX NCI_Supersession_Part_Relation_Part ON [sis].[Supersession_Part_Relation] 
([Part_ID] ASC);
GO
CREATE NONCLUSTERED INDEX NCI_Supersession_Part_Relation_SupersessionPartID ON [sis].[Supersession_Part_Relation] 
([Supersession_Part_ID] ASC);