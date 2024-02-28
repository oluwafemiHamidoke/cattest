CREATE TABLE [sis].[StaticIllustration] (
    [StaticIllustration_ID]  INT          IDENTITY (1, 1) NOT NULL,
    [Graphic_Control_Number] VARCHAR (60) NOT NULL,
    CONSTRAINT [PK_StaticIllustration] PRIMARY KEY CLUSTERED ([StaticIllustration_ID] ASC)
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_StaticIllustration_Graphic_CN]
    ON [sis].[StaticIllustration]([Graphic_Control_Number] ASC);

