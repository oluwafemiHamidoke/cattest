CREATE TABLE [sis_stage].[IE_Illustration_Relation_Diff] (
    [Operation]       VARCHAR (50) NOT NULL,
    [Illustration_ID] INT          NOT NULL,
    [IE_ID]           INT          NOT NULL,
    [Graphic_Number]  INT          NOT NULL,
    CONSTRAINT [PK_IE_Illustration_Relation_Diff] PRIMARY KEY CLUSTERED ([Illustration_ID] ASC, [IE_ID] ASC, [Graphic_Number] ASC)
);

