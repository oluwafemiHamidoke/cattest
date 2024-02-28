Create Table [sis_stage].[ServiceFile_DisplayTerms_Translation_sis2Etl] (
   [ServiceFile_DisplayTerms_ID]  INT            NOT NULL,
    [Language_ID]            INT            NOT NULL,
    [Value_Type]             VARCHAR(5)     NULL,
    [Value]                  NVARCHAR(2000) NULL,
    [Display_Value]             NVARCHAR(2000) NULL,   
    CONSTRAINT [PK_ServiceFile_DisplayTerms_Translation_sis2Etl] PRIMARY KEY CLUSTERED ([ServiceFile_DisplayTerms_ID] ASC, [Language_ID] ASC),
    CONSTRAINT [FK_ServiceFile_DisplayTerms_Translation_ServiceFile_DisplayTerms_sis2Etl] FOREIGN KEY ([ServiceFile_DisplayTerms_ID]) REFERENCES [sis_stage].[ServiceFile_DisplayTerms_sis2Etl] ([ServiceFile_DisplayTerms_ID]),
    CONSTRAINT [FK_ServiceFile_DisplayTerms_Translation_Language_sis2Etl] FOREIGN KEY ([Language_ID]) REFERENCES [sis].[Language] ([Language_ID])
);