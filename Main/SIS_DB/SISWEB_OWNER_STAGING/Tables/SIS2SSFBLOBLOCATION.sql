CREATE TABLE [SISWEB_OWNER_STAGING].[SIS2SSFBLOBLOCATION] (
    [FILERID]               NUMERIC NOT NULL,
    [BLOBNAME]              VARCHAR (100)  NOT NULL,
    [LOCATION]              VARCHAR (50)  NOT NULL,
    [UPDATEDATETIME]        DATETIME2 (6) NOT NULL,
    [LASTMODIFIEDDATE]      DATETIME2 (6) NULL,
    CONSTRAINT [SIS2SSFBLOBLOCATION_SIS2SSFBLOBLOCATION_PK] PRIMARY KEY NONCLUSTERED ([FILERID] ASC)
);

GO
ALTER TABLE [SISWEB_OWNER_STAGING].[SIS2SSFBLOBLOCATION] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO
