﻿CREATE TABLE [SISWEB_OWNER].[LNKIESNP] (
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

CREATE NONCLUSTERED INDEX [IX_LNKIESNP_MEDIANUMBER]
    ON [SISWEB_OWNER].[LNKIESNP]([IESYSTEMCONTROLNUMBER] ASC, [MEDIANUMBER] ASC)
    INCLUDE([SNP], [BEGINNINGRANGE], [ENDRANGE]);
GO

CREATE NONCLUSTERED INDEX [IX_LNKIESNP_SNP_PBINDICATOR]
    ON [SISWEB_OWNER].[LNKIESNP]([SNP] ASC, [PBINDICATOR] ASC, [BEGINNINGRANGE] ASC, [ENDRANGE] ASC)
    INCLUDE([IESYSTEMCONTROLNUMBER], [MEDIANUMBER]);
GO

CREATE NONCLUSTERED INDEX [nci_wi_LNKIESNP_40774BF598B1C668ABC0DCFFB9D62C94]
    ON [SISWEB_OWNER].[LNKIESNP]([TYPEINDICATOR] ASC, [IESYSTEMCONTROLNUMBER] ASC)
    INCLUDE([BEGINNINGRANGE], [ENDRANGE], [SNP]);
GO

CREATE NONCLUSTERED INDEX [NCX_LNKIESNP_BEGINNINGRANGE_ENDRANGE]
    ON [SISWEB_OWNER].[LNKIESNP]([SNP] ASC, [BEGINNINGRANGE] ASC, [ENDRANGE] ASC)
    INCLUDE([IESYSTEMCONTROLNUMBER], [MEDIANUMBER]);
GO

CREATE NONCLUSTERED INDEX [NCX_SNP_MediaNumber_PBIIndicator]
    ON [SISWEB_OWNER].[LNKIESNP]([SNP] ASC, [MEDIANUMBER] ASC, [IESYSTEMCONTROLNUMBER] ASC);
GO

