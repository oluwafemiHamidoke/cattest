CREATE TABLE [sis].[SupersessionChain_Part_Relation] (
    [SupersessionChain_ID] INT NOT NULL,
    [Part_ID]              INT NOT NULL,
    CONSTRAINT [PK_SupersessionChain_Part_Relation] PRIMARY KEY CLUSTERED ([SupersessionChain_ID] ASC, [Part_ID] ASC),
    CONSTRAINT [FK_SupersessionChain_Part_Relation_Part] FOREIGN KEY ([Part_ID]) REFERENCES [sis].[Part] ([Part_ID]),
    CONSTRAINT [FK_SupersessionChain_Part_Relation_SupersessionChain] FOREIGN KEY ([SupersessionChain_ID]) REFERENCES [sis].[SupersessionChain] ([SupersessionChain_ID])
);
GO
CREATE NONCLUSTERED INDEX NCI_SupersessionChain_Part_Relation_Part ON [sis].[SupersessionChain_Part_Relation] 
([Part_ID] ASC);