Create Table [sis_stage].[ServiceFile_SearchCriteria] (
    [ServiceFile_SearchCriteria_ID]     BIGINT IDENTITY(1, 1) NOT NULL,
    [ServiceFile_ID]                    INT                   NOT NULL,
    [InfoType_ID]                       INT                   NOT NULL,
    [Search_Type]                       VARCHAR(8)            NOT NULL,
    [Value]                             VARCHAR(100)         NULL,
    [Begin_Range]                       INT                   NULL,
    [End_Range]                         INT                   NULL,
    [Num_Data]                          INT                   NULL,
    [Search_Value]                             VARCHAR(100)         NULL,
    CONSTRAINT [PK_ServiceFile_SearchCriteria] PRIMARY KEY CLUSTERED ([ServiceFile_SearchCriteria_ID] ASC)
);