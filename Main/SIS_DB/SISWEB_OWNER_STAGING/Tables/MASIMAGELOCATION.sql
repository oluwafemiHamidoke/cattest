CREATE TABLE [SISWEB_OWNER_STAGING].[MASIMAGELOCATION] (
    [GRAPHICCONTROLNUMBER] VARCHAR (25)  NOT NULL,
    [IMAGETYPE]            VARCHAR (1)   NOT NULL,
    [GRAPHICUPDATEDATE]    DATETIME2 (0) NOT NULL,
    [IMAGELOCATION]        VARCHAR (100) NOT NULL,
    [LASTMODIFIEDDATE]     DATETIME2 (6) NULL,
    CONSTRAINT [MASIMAGELOCATION_PK_MASIMAGELOCATION] PRIMARY KEY CLUSTERED ([GRAPHICCONTROLNUMBER] ASC, [IMAGETYPE] ASC)
);


GO
ALTER TABLE [SISWEB_OWNER_STAGING].[MASIMAGELOCATION] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO

