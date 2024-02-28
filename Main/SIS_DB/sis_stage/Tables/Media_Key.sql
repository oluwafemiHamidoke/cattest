CREATE TABLE [sis_stage].[Media_Key] (
    [Media_ID]     INT          IDENTITY (1, 1) NOT NULL,
    [Media_Number] VARCHAR (50) NOT NULL,
    [Source]       VARCHAR (50) NULL,
    CONSTRAINT [PK_Media_Key] PRIMARY KEY CLUSTERED ([Media_ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Media_Key_Media_Number]
    ON [sis_stage].[Media_Key]([Media_Number] ASC);

