Create Table [sis].[ServiceFile_SearchCriteria] (
    [ServiceFile_SearchCriteria_ID]     BIGINT IDENTITY(1, 1) NOT NULL,
    [ServiceFile_ID]                    INT                   NOT NULL,
    [InfoType_ID]                       INT                   NOT NULL,
    [Search_Type]                       VARCHAR(8)            NOT NULL,
    [Value]                             VARCHAR(100)          NULL,
    [Search_Value]                      VARCHAR(100)          NULL,
    [Begin_Range]                       INT                   NULL,
    [End_Range]                         INT                   NULL,
    [Num_Data]                          INT                   NULL,
    CONSTRAINT [PK_ServiceFile_SearchCriteria] PRIMARY KEY NONCLUSTERED ([ServiceFile_SearchCriteria_ID] ASC),
    CONSTRAINT [FK_ServiceFile_SearchCriteria_InfoType] FOREIGN KEY ([InfoType_ID]) REFERENCES [sis].[InfoType] ([InfoType_ID]),
    CONSTRAINT [FK_ServiceFile_SearchCriteria_ServiceFile] FOREIGN KEY ([ServiceFile_ID]) REFERENCES [sis].[ServiceFile] ([ServiceFile_ID])
);
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
                           ,@value = N'Primary Key'
                           ,@level0type = N'SCHEMA'
                           ,@level0name = N'sis'
                           ,@level1type = N'TABLE'
                           ,@level1name = N'ServiceFile_SearchCriteria'
                           ,@level2type = N'COLUMN'
                           ,@level2name = N'ServiceFile_SearchCriteria_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
                           ,@value = N'Stores types of search. FN - File Name, SN - Searial Number, PN - Part Number'
                           ,@level0type = N'SCHEMA'
                           ,@level0name = N'sis'
                           ,@level1type = N'TABLE'
                           ,@level1name = N'ServiceFile_SearchCriteria'
                           ,@level2type = N'COLUMN'
                           ,@level2name = N'Search_Type';
GO
CREATE NONCLUSTERED INDEX [IX_ServiceFile_SearchCriteria_InfoType_ID_Search_Type_Value_Begin_Range_End_Range]
    ON [sis].[ServiceFile_SearchCriteria]([InfoType_ID] ASC, [Search_Type] ASC, [Value] ASC, Search_Value ASC, [Begin_Range] ASC, [End_Range] ASC) 
    INCLUDE ([ServiceFile_ID]);
GO
CREATE NONCLUSTERED INDEX [IX_ServiceFile_SearchCriteria_Begin_Range_End_Range]
    ON sis.ServiceFile_SearchCriteria ([Begin_Range] ASC, [End_Range] ASC);
GO
CREATE NONCLUSTERED INDEX IX_ServiceFile_SearchCriteria_ServiceFile_ID ON [sis].[ServiceFile_SearchCriteria]
([Search_Type] ASC,[Search_Value] ASC)
INCLUDE ([ServiceFile_ID],[Num_Data],[End_Range],[InfoType_ID])
GO
CREATE NONCLUSTERED INDEX [IX_ServiceFile_SearchCriteria_InfoType_ID_Search_Type_Num_Data]
    ON [sis].[ServiceFile_SearchCriteria] ([ServiceFile_ID],[InfoType_ID],[Search_Type])
    INCLUDE ([Num_Data])


