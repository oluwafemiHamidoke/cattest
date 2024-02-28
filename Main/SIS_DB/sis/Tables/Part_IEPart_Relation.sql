CREATE TABLE [sis].[Part_IEPart_Relation] (
    [Part_IEPart_Relation_ID]  INT          NOT NULL,
    [Part_ID]                  INT          NOT NULL,
    [IEPart_ID]                INT          NOT NULL,
    [Sequence_Number]          INT          NOT NULL,
    [Reference_Number]         VARCHAR (50) NULL,
    [Graphic_Number]           VARCHAR (50) NULL,
    [Quantity]                 VARCHAR (50) NULL,
    [Serviceability_Indicator] VARCHAR (1)  NULL,
    [Parentage]                SMALLINT     NULL,
    [CCR_Indicator]            BIT          NULL,
    [LastModified_Date] DATETIME2(0) NOT NULL DEFAULT(GETDATE()),
    CONSTRAINT [PK_Part_IEPart_Relation] PRIMARY KEY CLUSTERED ([Part_IEPart_Relation_ID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Part_Group_Relation_Part] FOREIGN KEY ([Part_ID]) REFERENCES [sis].[Part] ([Part_ID]),
    CONSTRAINT [FK_Part_IEPart_Relation_IEPart] FOREIGN KEY ([IEPart_ID]) REFERENCES [sis].[IEPart] ([IEPart_ID])
);


GO
CREATE NONCLUSTERED INDEX NCI_Part_IEPart_Relation_Part ON [sis].[Part_IEPart_Relation]  
([Part_ID] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_Part_IEPart_Relation_IEPart_ID] ON [sis].[Part_IEPart_Relation]
(
    [IEPart_ID] ASC
)INCLUDE(Part_ID, Sequence_Number, Reference_Number, Graphic_Number, Quantity, Serviceability_Indicator, Parentage, CCR_Indicator)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO