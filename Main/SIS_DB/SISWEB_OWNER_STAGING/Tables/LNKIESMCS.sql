CREATE TABLE [SISWEB_OWNER_STAGING].[LNKIESMCS] (
    [MEDIANUMBER]           VARCHAR (8)   NOT NULL,
    [IESYSTEMCONTROLNUMBER] VARCHAR (12)  NOT NULL,
    [SMCSCOMPCODE]          VARCHAR (4)   NOT NULL,
    [SMCSJOBCODE]           VARCHAR (3)   NOT NULL,
    [SMCSMODCODE]           VARCHAR (3)   NOT NULL,
    [SMCSTOOLCODE]          VARCHAR (4)   NOT NULL,
    [BASEIERID]             NUMERIC (16)  NULL,
    [LASTMODIFIEDDATE]      DATETIME2 (6) NULL,
    CONSTRAINT [PKCI_LNKIESMC] PRIMARY KEY CLUSTERED ([MEDIANUMBER] ASC, [IESYSTEMCONTROLNUMBER] ASC, [SMCSCOMPCODE] ASC, [SMCSJOBCODE] ASC, [SMCSMODCODE] ASC, [SMCSTOOLCODE] ASC)
);


GO
ALTER TABLE [SISWEB_OWNER_STAGING].[LNKIESMCS] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO
