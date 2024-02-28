Create Table [sis_stage].[ServiceFile_DisplayTerms_Translation] (
    [ServiceFile_DisplayTerms_ID] INT            NOT NULL,
    [Language_ID]                 INT            NOT NULL,
    [Value_Type]                  VARCHAR(5)     NULL,
    [Value]                       NVARCHAR(2000) NULL,
    [Display_Value]                       NVARCHAR(2000) NULL,
    CONSTRAINT [PK_ServiceFile_DisplayTerms_Translation] PRIMARY KEY CLUSTERED ([ServiceFile_DisplayTerms_ID] ASC, [Language_ID] ASC)
);
