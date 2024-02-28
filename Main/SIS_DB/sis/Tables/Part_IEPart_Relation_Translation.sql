CREATE TABLE [sis].[Part_IEPart_Relation_Translation] (
    [Language_ID]             INT             NOT NULL,
    [Part_IEPart_Name]        NVARCHAR (1000) NULL,
    [Part_IEPart_Relation_ID] INT             NOT NULL,
    [Part_IEPart_Modifier]    NVARCHAR (1000) NULL,
	[Part_IEPart_Note] nvarchar(10) NULL,
    CONSTRAINT [PK_Part_IEPart_Relation_Translation] PRIMARY KEY CLUSTERED ([Part_IEPart_Relation_ID] ASC, [Language_ID] ASC),
    CONSTRAINT [FK_Part_IEPart_Relation_Translation_Language] FOREIGN KEY ([Language_ID]) REFERENCES [sis].[Language_Details] ([Language_ID]),
    CONSTRAINT [FK_Part_IEPart_Relation_Translation_Part_IEPart_Relation] FOREIGN KEY ([Part_IEPart_Relation_ID]) REFERENCES [sis].[Part_IEPart_Relation] ([Part_IEPart_Relation_ID])
);