CREATE TABLE [sis_stage].[IEPart_Illustration_Relation_Key] (
    [Illustration_Relation_ID] INT IDENTITY (1, 1) NOT NULL,
    [Illustration_ID]          INT NOT NULL,
    [IEPart_ID]                INT NOT NULL,
    [Graphic_Number]           INT NULL,
    CONSTRAINT [PK_Illustration_Relation_Key] PRIMARY KEY CLUSTERED ([Illustration_Relation_ID] ASC)
);