Create Table [sis_stage].[ServiceFile_ReplacementHierarchy] (
    [ServiceFile_ID]                INT      NOT NULL,   
    [Replacing_ServiceFile_ID]      INT      NOT NULL,
    [Sequence_No]                   SMALLINT NOT NULL,
    CONSTRAINT [PK_ServiceFile_ReplacementHierarchy] PRIMARY KEY CLUSTERED ([ServiceFile_ID] ASC, [Replacing_ServiceFile_ID] ASC)
);
