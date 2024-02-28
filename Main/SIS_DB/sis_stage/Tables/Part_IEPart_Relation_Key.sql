CREATE TABLE [sis_stage].[Part_IEPart_Relation_Key] (
    [Part_IEPart_Relation_ID] INT IDENTITY (1, 1) NOT NULL,
    [Part_ID]                 INT NOT NULL,
    [IEPart_ID]               INT NOT NULL,
    [Sequence_Number]         INT NOT NULL,
    CONSTRAINT [PK_Part_IEPart_Relation_Key] PRIMARY KEY CLUSTERED ([Part_IEPart_Relation_ID] ASC)
);

GO
CREATE NONCLUSTERED INDEX IDX_Part_IEPart_Relation_Key_Part_ID_IEPart_ID_Sequence_Number
ON [sis_stage].[Part_IEPart_Relation_Key] ([Part_ID],[IEPart_ID],[Sequence_Number]);