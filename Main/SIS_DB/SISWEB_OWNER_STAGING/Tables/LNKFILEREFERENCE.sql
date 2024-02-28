Create Table [SISWEB_OWNER_STAGING].[LNKFILEREFERENCE] (
    FILERID           NUMERIC(38)       NOT NULL,
    LANGUAGEINDICATOR VARCHAR(2)        NOT NULL,
    REFERENCEFILERID  NUMERIC(38)        NOT NULL,
    LASTMODIFIEDDATE  DATETIME2(6)      NULL,
    CONSTRAINT [LNKFILEREFERENCE_PK_LNKFILEREFERENCE] PRIMARY KEY CLUSTERED ([FILERID] ASC, [REFERENCEFILERID] ASC, [LANGUAGEINDICATOR] ASC)
);
GO
ALTER TABLE [SISWEB_OWNER_STAGING].[LNKFILEREFERENCE] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO