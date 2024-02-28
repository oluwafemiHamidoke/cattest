Create Table [sis_stage].[ServiceFile_sis2Etl] (
    [ServiceFile_ID]    INT           NOT NULL,
    [InfoType_ID]       INT           NOT NULL,
    [ServiceFile_Name]  NVARCHAR(100) NULL,
    [Available_Flag]    CHAR(1)       NOT NULL,
    [Mime_Type]         NVARCHAR(2)   NULL,
    [ServiceFile_Size]  INT           NULL,
    [Updated_Date]      DATETIME2     NOT NULL default GETDATE(),
    [Created_Date]      DATETIME2     NOT NULL default GETDATE(),
    [Insert_Date]       DATETIME2     NULL,
    --[ServiceFile_Basename] AS (REVERSE(SUBSTRING(REVERSE(ServiceFile_Name), CHARINDEX('.', REVERSE(ServiceFile_Name)) + 1, 100))) PERSISTED
    CONSTRAINT [PK_ServiceFile_sis2Etl] PRIMARY KEY CLUSTERED ([ServiceFile_ID] ASC),
	CONSTRAINT [FK_ServiceFile_InfoType_sis2Etl] FOREIGN KEY ([InfoType_ID]) REFERENCES [sis].[InfoType] ([InfoType_ID])
);
GO

CREATE INDEX IX_ServiceFile_ServiceFile_Name_sis2Etl ON [sis_stage].ServiceFile_sis2Etl (ServiceFile_Name)