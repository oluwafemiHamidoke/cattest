Create Table [sis_stage].[ServiceFile_DisplayTerms_Translation_Diff] (
    [Operation]                   VARCHAR (50)   NOT NULL,
    [ServiceFile_DisplayTerms_ID] INT            NOT NULL,
    [Language_ID]                 INT            NOT NULL,
    [Value_Type]                  VARCHAR(5)     NULL,
    [Value]                       NVARCHAR(2000) NULL,
    CONSTRAINT [PK_ServiceFile_DisplayTerms_Translation_Diff] PRIMARY KEY CLUSTERED ([ServiceFile_DisplayTerms_ID] ASC, [Language_ID] ASC)
);
