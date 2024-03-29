Create Table [SISWEB_OWNER_STAGING].[LNKFLASHAPPLICATIONCODE] (
    APPLICATIONCODE   INT               NOT NULL,
    APPLICATIONDESC   VARCHAR(48)       NOT NULL,
    LANGUAGEINDICATOR VARCHAR(2)        NOT NULL,
    LASTMODIFIEDDATE  DATETIME2(6)      NULL,
    [ISENGINERELATED] BIT               NULL , 
    CONSTRAINT [LNKFLASHAPPLICATIONCODE_PK_LNKFLASHAPPLICATIONCODE] PRIMARY KEY CLUSTERED ([APPLICATIONCODE] ASC, [LANGUAGEINDICATOR] ASC)
);
GO
ALTER TABLE [SISWEB_OWNER_STAGING].[LNKFLASHAPPLICATIONCODE] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO