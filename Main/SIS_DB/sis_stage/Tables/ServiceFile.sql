Create Table [sis_stage].[ServiceFile] (
    [ServiceFile_ID]            INT           NOT NULL,
    [InfoType_ID]               INT           NOT NULL,
    [ServiceFile_Name]          NVARCHAR(100) NULL,
    [Available_Flag]            CHAR(1)       NOT NULL,
    [Mime_Type]                 NVARCHAR(2)   NULL,
    [ServiceFile_Size]          INT           NULL,
    [Updated_Date]              DATETIME2     NOT NULL default getdate(),
    [Created_Date]              DATETIME2     NOT NULL default getdate(),
    [Insert_Date]               DATETIME2     NULL,
    CONSTRAINT [PK_ServiceFile] PRIMARY KEY CLUSTERED ([ServiceFile_ID] ASC)
);

GO
CREATE INDEX IX_ServiceFile_ServiceFile_Name ON [sis_stage].ServiceFile (ServiceFile_Name)