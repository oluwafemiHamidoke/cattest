CREATE TABLE [sis].[StaticIllustration_File] (
    [StaticIllustration_File_ID] INT           IDENTITY (1, 1) NOT NULL,
    [StaticIllustration_ID]      INT           NOT NULL,
    [File_Location]              VARCHAR (150) NOT NULL,
    [File_Size_Byte]             INT           NULL,
    [Mime_Type]                  VARCHAR (250) NULL,
    CONSTRAINT [PK_StaticIllustration_File] PRIMARY KEY CLUSTERED ([StaticIllustration_File_ID] ASC),
    CONSTRAINT [FK_StaticIllustration_File_StaticIllustration] FOREIGN KEY ([StaticIllustration_ID]) REFERENCES [sis].[StaticIllustration] ([StaticIllustration_ID])
);

