CREATE TABLE [sis].[Illustration] (
    [Illustration_ID]        INT          NOT NULL,
    [Graphic_Control_Number] VARCHAR (60) NOT NULL,
    CONSTRAINT [PK_Illustration] PRIMARY KEY CLUSTERED ([Illustration_ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Illustration_Graphic_CN]
    ON [sis].[Illustration]([Graphic_Control_Number] ASC);

