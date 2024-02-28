CREATE TABLE [sis_stage].[Illustration_File_Key] (
    [Illustration_File_ID] INT           IDENTITY (1, 1) NOT NULL,
    [Illustration_ID]      INT           NOT NULL,
    [File_Location]        VARCHAR (150) NOT NULL,
    CONSTRAINT [PK_Illustration_File_Key] PRIMARY KEY CLUSTERED ([Illustration_File_ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Illustration_File_Key_Illustration_ID_File_Location]
    ON [sis_stage].[Illustration_File_Key]([Illustration_ID] ASC, [File_Location] ASC);

