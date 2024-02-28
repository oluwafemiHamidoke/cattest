CREATE TABLE [admin].[Permission] (
    [PermissionType_ID]          INT Identity(1,1)          NOT NULL,
    [PermissionType_Description] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_PermissionType] PRIMARY KEY CLUSTERED ([PermissionType_ID] ASC)
);

