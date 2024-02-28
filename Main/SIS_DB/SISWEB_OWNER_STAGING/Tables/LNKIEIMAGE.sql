CREATE TABLE [SISWEB_OWNER_STAGING].[LNKIEIMAGE] (
    [IESYSTEMCONTROLNUMBER] VARCHAR (12)  NOT NULL,
    [GRAPHICCONTROLNUMBER]  VARCHAR (25)  NOT NULL,
    [GRAPHICSEQUENCENUMBER] SMALLINT      NOT NULL,
    [LASTMODIFIEDDATE]      DATETIME2 (6) NULL,
    CONSTRAINT [LNKIEIMAGE_PK_LNKIEIMAGE] PRIMARY KEY CLUSTERED ([IESYSTEMCONTROLNUMBER] ASC, [GRAPHICCONTROLNUMBER] ASC, [GRAPHICSEQUENCENUMBER] ASC)
);


GO
ALTER TABLE [SISWEB_OWNER_STAGING].[LNKIEIMAGE] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO

CREATE NONCLUSTERED INDEX IX_LNKIEIMAGE_IESCN ON SISWEB_OWNER_STAGING.LNKIEIMAGE (IESYSTEMCONTROLNUMBER ASC);
GO