CREATE TABLE [admin].[Affiliation_Profile_Relation] (
    [Affiliation_ID]            INT NOT NULL,
    [Profile_ID]                INT NOT NULL,
    [Default_Profile_Indicator] BIT CONSTRAINT [DF_Affiliation_Profile_Relation_Default_Profile_Indicator] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Affiliation_Profile_Relation] PRIMARY KEY CLUSTERED ([Affiliation_ID] ASC, [Profile_ID] ASC),
    CONSTRAINT [FK_Affiliation_Profile_Relation_AccessProfile] FOREIGN KEY ([Profile_ID]) REFERENCES [admin].[AccessProfile] ([Profile_ID]),
    CONSTRAINT [FK_Affiliation_Profile_Relation_Affiliation] FOREIGN KEY ([Affiliation_ID]) REFERENCES [admin].[Affiliation] ([Affiliation_ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Affiliation_ID_Default_Profile_Indicator]
    ON [admin].[Affiliation_Profile_Relation]([Affiliation_ID] ASC, [Default_Profile_Indicator] ASC) WHERE ([Default_Profile_Indicator]=(1));

