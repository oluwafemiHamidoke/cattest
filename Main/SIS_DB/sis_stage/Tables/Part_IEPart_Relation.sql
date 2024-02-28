CREATE TABLE [sis_stage].[Part_IEPart_Relation] (
    [Part_IEPart_Relation_ID]  INT          NULL,
    [Part_ID]                  INT          NOT NULL,
    [IEPart_ID]                INT          NOT NULL,
    [Sequence_Number]          INT          NOT NULL,
    [Reference_Number]         VARCHAR (50) NULL,
    [Graphic_Number]           VARCHAR (50) NULL,
    [Quantity]                 VARCHAR (50) NULL,
    [Serviceability_Indicator] VARCHAR (1)  NULL,
    [Parentage]                SMALLINT     NULL,
    [CCR_Indicator]            BIT          NULL,
    CONSTRAINT [PK_Part_IEPart_Relation] PRIMARY KEY CLUSTERED ([Part_ID] ASC, [IEPart_ID] ASC, [Sequence_Number] ASC) WITH (FILLFACTOR = 100)
);

GO
CREATE NONCLUSTERED INDEX IDX_Part_IEPart_Relation_ID
ON [sis_stage].[Part_IEPart_Relation] ([Part_IEPart_Relation_ID]);