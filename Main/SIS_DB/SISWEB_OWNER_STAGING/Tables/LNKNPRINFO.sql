﻿CREATE TABLE [SISWEB_OWNER_STAGING].[LNKNPRINFO] (
    [PARTNUMBER]               VARCHAR (20)  NOT NULL,
    [COUNTRYCODE]              VARCHAR (2)   NOT NULL,
    [ENGGCHANGELEVELNO]        VARCHAR (2)   NOT NULL,
    [PRIMARYSEQNO]             INT           NOT NULL,
    [PARTNUMBERDESCRIPTION]    VARCHAR (200) NULL,
    [NONRETURNABLEINDICATOR]   VARCHAR (1)   NULL,
    [PARTREPLACEMENTINDICATOR] VARCHAR (1)   NULL,
    [PACKAGEQUANTITY]          VARCHAR (8)   NULL,
    [WEIGHT]                   INT           NULL,
    [CANCELLEDNPRINFORMATION]  VARCHAR (20)  NULL,
    [NPRINDICATOR]             VARCHAR (20)  NULL,
    CONSTRAINT [LNKNPRINFO_PK_LNKNPRINFO] PRIMARY KEY CLUSTERED ([PARTNUMBER] ASC, [COUNTRYCODE] ASC, [ENGGCHANGELEVELNO] ASC, [PRIMARYSEQNO] ASC)
);
GO

CREATE NONCLUSTERED INDEX IX_LNKNPRINFO_PARTNUMBER ON SISWEB_OWNER_STAGING.LNKNPRINFO (PARTNUMBER ASC);
GO 

CREATE NONCLUSTERED INDEX IX_LNKNPRINFO_PSN ON SISWEB_OWNER_STAGING.LNKNPRINFO (PRIMARYSEQNO ASC);
GO 
