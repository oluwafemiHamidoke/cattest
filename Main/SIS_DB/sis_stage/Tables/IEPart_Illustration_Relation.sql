CREATE TABLE [sis_stage].[IEPart_Illustration_Relation] (
    [Illustration_Relation_ID] INT NULL,
    [Illustration_ID]          INT NOT NULL,
    [IEPart_ID]                INT NOT NULL,
    [Graphic_Number]           INT NOT NULL,
    CONSTRAINT [PK_Illustration_Relation] PRIMARY KEY CLUSTERED ([Illustration_ID] ASC, [IEPart_ID] ASC, [Graphic_Number] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_IEPart_Illustration_Relation_Illustration_Relation_ID]
    ON [sis_stage].[IEPart_Illustration_Relation]([Illustration_Relation_ID] ASC);

