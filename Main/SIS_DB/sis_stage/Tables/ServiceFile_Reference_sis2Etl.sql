Create Table [sis_stage].[ServiceFile_Reference_sis2Etl] (
    [ServiceFile_ID]            INT NOT NULL,
    [Referred_ServiceFile_ID]   INT NOT NULL,
    [Language_ID]               INT NOT NULL,
    CONSTRAINT [PK_ServiceFile_Reference_sis2Etl] PRIMARY KEY CLUSTERED ([ServiceFile_ID] ASC, [Referred_ServiceFile_ID] ASC, [Language_ID] ASC),
    CONSTRAINT [FK_ServiceFile_Reference_Language_sis2Etl] FOREIGN KEY ([Language_ID]) REFERENCES [sis].[Language] ([Language_ID]),
    CONSTRAINT [FK_ServiceFile_Reference_ServiceFile_sis2Etl] FOREIGN KEY ([ServiceFile_ID]) REFERENCES [sis_stage].[ServiceFile_sis2Etl] ([ServiceFile_ID]),
    CONSTRAINT [FK_ServiceFile_Reference_Referred_ServiceFile_sis2Etl] FOREIGN KEY ([Referred_ServiceFile_ID]) REFERENCES [sis_stage].[ServiceFile_sis2Etl] ([ServiceFile_ID])
);
GO