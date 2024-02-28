Create Table [sis_stage].[ServiceFile_SearchCriteria_sis2Etl] (
    [ServiceFile_SearchCriteria_ID]     BIGINT IDENTITY(1, 1) NOT NULL,
    [ServiceFile_ID]                    INT                   NOT NULL,
    [InfoType_ID]                       INT                   NOT NULL,
    [Search_Type]                       VARCHAR(8)            NOT NULL,
    [Value]                             VARCHAR(100)          NULL,
    [Search_Value]                      VARCHAR(100)          NULL,
    [Begin_Range]                       INT                   NULL,
    [End_Range]                         INT                   NULL,
    [Num_Data]                          INT                   NULL,
    CONSTRAINT [PK_ServiceFile_SearchCriteria_sis2Etl] PRIMARY KEY NONCLUSTERED ([ServiceFile_SearchCriteria_ID] ASC),
    CONSTRAINT [FK_ServiceFile_SearchCriteria_InfoType_sis2Etl] FOREIGN KEY ([InfoType_ID]) REFERENCES [sis].[InfoType] ([InfoType_ID]),
    CONSTRAINT [FK_ServiceFile_SearchCriteria_ServiceFile_sis2Etl] FOREIGN KEY ([ServiceFile_ID]) REFERENCES [sis_stage].[ServiceFile_sis2Etl] ([ServiceFile_ID])
);
GO

CREATE NONCLUSTERED INDEX [IX_ServiceFile_SearchCriteria_sis2Etl_ServiceFile_ID]
ON [sis_stage].[ServiceFile_SearchCriteria_sis2Etl] ([ServiceFile_ID])
GO