CREATE TABLE [admin].[Organization] (
    [Organization_ID]            INT Identity(1,1)         NOT NULL,
    [TopLevel_Organization_Code] VARCHAR (10) NOT NULL DEFAULT 'UNASSIGNED',
    [Organization_Code]          VARCHAR (10) NOT NULL DEFAULT 'UNASSIGNED',
    [Organization_Name]          nVARCHAR (160) NOT NULL DEFAULT 'UNASSIGNED',
    [Created_By]                 NVARCHAR(50) DEFAULT '' NOT NULL,
    [Created_On]                 DATETIME2(1) DEFAULT GETUTCDATE() NOT NULL,
    [Last_Modified_By]           NVARCHAR(50) DEFAULT '' NOT NULL,
    [Last_Modified_On]           DATETIME2(1) DEFAULT GETUTCDATE() NOT NULL,
    CONSTRAINT [PK_Organization] PRIMARY KEY CLUSTERED ([Organization_ID] ASC)
);



