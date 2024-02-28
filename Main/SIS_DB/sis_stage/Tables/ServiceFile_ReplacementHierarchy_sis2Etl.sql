Create Table [sis_stage].[ServiceFile_ReplacementHierarchy_sis2Etl] (
    [ServiceFile_ID]                INT      NOT NULL,   
    [Replacing_ServiceFile_ID]      INT      NOT NULL,
    [Sequence_No]                   SMALLINT NOT NULL,
    CONSTRAINT [PK_ServiceFile_ReplacementHierarchy_sis2Etl] PRIMARY KEY CLUSTERED ([ServiceFile_ID] ASC, [Replacing_ServiceFile_ID] ASC),
    CONSTRAINT [FK_ServiceFile_ReplacementHierarchy_ServiceFile_sis2Etl] FOREIGN KEY ([ServiceFile_ID]) REFERENCES [sis_stage].[ServiceFile_sis2Etl] ([ServiceFile_ID]),
    CONSTRAINT [FK_ServiceFile_ReplacementHierarchy_Replacing_ServiceFile_sis2Etl] FOREIGN KEY ([Replacing_ServiceFile_ID]) REFERENCES [sis_stage].[ServiceFile_sis2Etl] ([ServiceFile_ID])
);
GO