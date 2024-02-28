CREATE TABLE [sis_stage].[Illustration] (
    [Illustration_ID]        INT          NULL,
    [Graphic_Control_Number] VARCHAR (60) NOT NULL,
    CONSTRAINT [PK_Illustration] PRIMARY KEY CLUSTERED ([Graphic_Control_Number] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Illustration_Illustration_ID]
    ON [sis_stage].[Illustration]([Illustration_ID] ASC);

