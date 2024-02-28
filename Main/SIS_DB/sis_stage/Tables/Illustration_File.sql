CREATE TABLE [sis_stage].[Illustration_File] (
    [Illustration_File_ID] INT           NULL,
    [Illustration_ID]      INT           NOT NULL,
    [File_Location]        VARCHAR (150) NOT NULL,
    [File_Size_Byte]       INT           NULL,
    [Mime_Type]            VARCHAR (250) NULL,
     [File_Location_Highres]        VARCHAR (150)  NULL,
    [File_Size_Byte_Highres]       INT           NULL,
    CONSTRAINT [PK_Illustration_File] PRIMARY KEY CLUSTERED ([Illustration_ID] ASC, [File_Location] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_Illustration_File_Illustration_File_ID]
    ON [sis_stage].[Illustration_File]([Illustration_File_ID] ASC);

