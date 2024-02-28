Create Table [sis_stage].[ServiceFile_DisplayTerms_Key] (
    [ServiceFile_DisplayTerms_ID]  INT            IDENTITY (1, 1)  NOT NULL,
    [ServiceFile_ID]               INT            NOT NULL,
    [Type]                         VARCHAR(8)     NOT NULL,
    CONSTRAINT [PK_ServiceFile_DisplayTerms_Key] PRIMARY KEY CLUSTERED([ServiceFile_DisplayTerms_ID] ASC),
    CONSTRAINT [UK_ServiceFile_DisplayTerms_Key] UNIQUE ([ServiceFile_ID] ASC, [Type] ASC)
);
