Create Table [sis_stage].[ServiceFile_DisplayTerms_sis2Etl] (
    [ServiceFile_DisplayTerms_ID]  INT IDENTITY(1,1) NOT NULL,
    [ServiceFile_ID]               INT            NOT NULL,
    [Type]                         VARCHAR(8)     NOT NULL,
    CONSTRAINT [PK_ServiceFile_DisplayTerms_sis2Etl] PRIMARY KEY CLUSTERED([ServiceFile_DisplayTerms_ID] ASC),
    CONSTRAINT [UK_ServiceFile_DisplayTerms_sis2Etl] UNIQUE ([ServiceFile_ID] ASC, [Type] ASC),
    CONSTRAINT [FK_ServiceFile_DisplayTerms_File_sis2Etl] FOREIGN KEY ([ServiceFile_ID]) REFERENCES [sis_stage].[ServiceFile_sis2Etl] ([ServiceFile_ID])
);