Create Table [sis].[ServiceFile] (
    [ServiceFile_ID]    INT           NOT NULL,
    [InfoType_ID]       INT           NOT NULL,
    [ServiceFile_Name]  NVARCHAR(100) NULL,
    [Available_Flag]    CHAR(1)       NOT NULL,
    [Mime_Type]         NVARCHAR(2)   NULL,
    [ServiceFile_Size]  INT           NULL,
    [Updated_Date]      DATETIME2     NOT NULL default GETDATE(),
    [Created_Date]      DATETIME2     NOT NULL default GETDATE(),
    [Insert_Date]       DATETIME2     NULL,
    [ServiceFile_Basename] AS (REVERSE(SUBSTRING(REVERSE(ServiceFile_Name), CHARINDEX('.', REVERSE(ServiceFile_Name)) + 1, 100))) PERSISTED
    CONSTRAINT [PK_ServiceFile] PRIMARY KEY CLUSTERED ([ServiceFile_ID] ASC),
	CONSTRAINT [FK_ServiceFile_InfoType] FOREIGN KEY ([InfoType_ID]) REFERENCES [sis].[InfoType] ([InfoType_ID])
);
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
                           ,@value = N'Primary Key'
                           ,@level0type = N'SCHEMA'
                           ,@level0name = N'sis'
                           ,@level1type = N'TABLE'
                           ,@level1name = N'ServiceFile'
                           ,@level2type = N'COLUMN'
                           ,@level2name = N'ServiceFile_ID';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
                           ,@value = N'Stores availbility status of file. Y - Yes, N - Not Available, R - Replaced'
                           ,@level0type = N'SCHEMA'
                           ,@level0name = N'sis'
                           ,@level1type = N'TABLE'
                           ,@level1name = N'ServiceFile'
                           ,@level2type = N'COLUMN'
                           ,@level2name = N'Available_Flag';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
                           ,@value = N'Stores mime type of the file. z - regular software file, h - html, c - css, T - text'
                           ,@level0type = N'SCHEMA'
                           ,@level0name = N'sis'
                           ,@level1type = N'TABLE'
                           ,@level1name = N'ServiceFile'
                           ,@level2type = N'COLUMN'
                           ,@level2name = N'Mime_Type';
GO
EXEC sp_addextendedproperty @name = N'MS_Description'
                           ,@value = N'Stores size of the file in bytes'
                           ,@level0type = N'SCHEMA'
                           ,@level0name = N'sis'
                           ,@level1type = N'TABLE'
                           ,@level1name = N'ServiceFile'
                           ,@level2type = N'COLUMN'
                           ,@level2name = N'ServiceFile_Size';
GO
Create nonclustered index IX_ServiceFile_ServiceFile_Name_InfoType_ID_Mime_Type on sis.ServiceFile 
(
    [InfoType_ID] ASC, 
    [Mime_Type] ASC, 
    [ServiceFile_Name] ASC
    );

GO
CREATE NONCLUSTERED INDEX [IX_ServiceFile_ServiceFile_Basename] ON [sis].[ServiceFile]
(
	ServiceFile_Basename ASC
) INCLUDE(ServiceFile_Name);