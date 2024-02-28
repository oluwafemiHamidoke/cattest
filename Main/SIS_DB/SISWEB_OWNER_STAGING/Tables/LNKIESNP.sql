﻿CREATE TABLE [SISWEB_OWNER_STAGING].[LNKIESNP] (
    [IESYSTEMCONTROLNUMBER] VARCHAR (12)     NOT NULL,
    [SNP]                   VARCHAR (10)     NOT NULL,
    [BEGINNINGRANGE]        INT              NOT NULL,
    [ENDRANGE]              INT              NOT NULL,
    [MEDIANUMBER]           VARCHAR (8)      NOT NULL,
    [TYPEINDICATOR]         VARCHAR (1)      NOT NULL,
    [PBINDICATOR]           VARCHAR (1)      NOT NULL,
    [BASEIERID]             NUMERIC (16)     NULL,
    [ID]                    NUMERIC (38, 10) NOT NULL,
    [LASTMODIFIEDDATE]      DATETIME2 (6)    NULL,
    CONSTRAINT [LNKIESNP_LNKIESNP_PK] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
ALTER TABLE [SISWEB_OWNER_STAGING].[LNKIESNP] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO

CREATE NONCLUSTERED INDEX IDX_LNKIESNP_MEDIANUMBER_SNP ON SISWEB_OWNER_STAGING.LNKIESNP (MEDIANUMBER ASC, SNP ASC) ;
GO

CREATE NONCLUSTERED INDEX IDX_LNKIESNP_MEDIANUMBER_ISCNT ON SISWEB_OWNER_STAGING.LNKIESNP (MEDIANUMBER ASC, IESYSTEMCONTROLNUMBER ASC) ;
GO

CREATE NONCLUSTERED INDEX IX_LNKIESNP_ISCNT ON SISWEB_OWNER_STAGING.LNKIESNP (IESYSTEMCONTROLNUMBER ASC) ;
GO

CREATE NONCLUSTERED INDEX IX_LNKIESNP_MEDIANUMBERT ON SISWEB_OWNER_STAGING.LNKIESNP (MEDIANUMBER ASC) ;
GO

CREATE NONCLUSTERED INDEX IX_LNKIESNP_SNPT ON SISWEB_OWNER_STAGING.LNKIESNP (SNP ASC) ;
GO

CREATE NONCLUSTERED INDEX IX_LNKIESNP_S_TI_PIT ON SISWEB_OWNER_STAGING.LNKIESNP (SNP ASC, TYPEINDICATOR ASC, PBINDICATOR ASC);
GO