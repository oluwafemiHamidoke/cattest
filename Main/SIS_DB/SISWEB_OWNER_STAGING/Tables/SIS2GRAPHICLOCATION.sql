CREATE TABLE [SISWEB_OWNER_STAGING].[SIS2GRAPHICLOCATION] (
    [GRAPHICCONTROLNUMBER] VARCHAR (25)  NOT NULL,
    [MIMETYPE]             VARCHAR (50)  NOT NULL,
    [LOCATION]             VARCHAR (50)  NOT NULL,
    [UPDATEDATETIME]       DATETIME2 (6) NOT NULL,
    [FILESIZEBYTE]         INT NULL,
    [LASTMODIFIEDDATE]     DATETIME2 (6) NULL,
     [LOCATIONHIGHRES]             VARCHAR (70)  NULL,
     [FILESIZEBYTEHIGHRES]          INT NULL,
    CONSTRAINT [SIS2GRAPHICLOCATION_SIS2GRAPHICLOCATION_PK] PRIMARY KEY CLUSTERED ([GRAPHICCONTROLNUMBER] ASC, [MIMETYPE] ASC)
);


GO
ALTER TABLE [SISWEB_OWNER_STAGING].[SIS2GRAPHICLOCATION] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO

