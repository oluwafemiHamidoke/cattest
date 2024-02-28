CREATE TABLE [sis_stage].[Part_IEPart_Relation_Translation] (
    [Language_ID]             INT             NOT NULL,
    [Part_IEPart_Name]        NVARCHAR (1000) NULL,
    [Part_IEPart_Relation_ID] INT             NOT NULL,
    [Part_IEPart_Modifier]    NVARCHAR (1000) NULL,
	[Part_IEPart_Note] nvarchar(10) NULL,
    CONSTRAINT [PK_Part_IEPart_Relation_Translation] PRIMARY KEY CLUSTERED ([Part_IEPart_Relation_ID] ASC, [Language_ID] ASC)
);