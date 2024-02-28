Create Table [sis_stage].[ServiceFile_Reference] (
    [ServiceFile_ID]            INT NOT NULL,
    [Referred_ServiceFile_ID]   INT NOT NULL,
    [Language_ID]               INT NOT NULL,
    CONSTRAINT [PK_ServiceFile_Reference] PRIMARY KEY CLUSTERED ([ServiceFile_ID] ASC, [Referred_ServiceFile_ID] ASC, [Language_ID] ASC)
);