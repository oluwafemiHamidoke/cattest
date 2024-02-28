CREATE TABLE [sis_stage].[Illustration_Key] (
    [Illustration_ID]        INT          IDENTITY (1, 1) NOT NULL,
    [Graphic_Control_Number] VARCHAR (60) NOT NULL,
    CONSTRAINT [PK_Illustration_Key] PRIMARY KEY CLUSTERED ([Illustration_ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Illustration_Key_Graphic_Control_Number]
    ON [sis_stage].[Illustration_Key]([Graphic_Control_Number] ASC);

