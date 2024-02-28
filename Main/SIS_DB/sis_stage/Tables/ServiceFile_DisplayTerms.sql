Create Table [sis_stage].[ServiceFile_DisplayTerms] (
    [ServiceFile_DisplayTerms_ID]  INT            NULL,
    [ServiceFile_ID]               INT            NOT NULL,
    [Type]                         VARCHAR(8)     NOT NULL,
    CONSTRAINT [PK_ServiceFile_DisplayTerms] PRIMARY KEY CLUSTERED([ServiceFile_ID] ASC, [Type] ASC)
);
