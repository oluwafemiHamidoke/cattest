﻿CREATE TABLE [SISWEB_OWNER_STAGING].[LNKMEDIAIEPART] (
    [MEDIANUMBER]             VARCHAR (8)     NOT NULL,
    [IESYSTEMCONTROLNUMBER]   VARCHAR (12)    NOT NULL,
    [IEPARTNUMBER]            VARCHAR (20)    NULL,
    [IEPARTNAME]              NVARCHAR (128)  NULL,
    [IESEQUENCENUMBER]        SMALLINT        NOT NULL,
    [BASEENGCONTROLNO]        VARCHAR (12)    NOT NULL,
    [SECTIONNUMBER]           SMALLINT        NOT NULL,
    [IEPARTMODIFIER]          NVARCHAR (512)  NULL,
    [IECAPTION]               NVARCHAR (2048) NOT NULL,
    [IETYPE]                  VARCHAR (1)     NOT NULL,
    [SERVICEABILITYINDICATOR] VARCHAR (1)     NOT NULL,
    [IEUPDATEDATE]            DATETIME2 (0)   NOT NULL,
    [IECONTROLNUMBER]         VARCHAR (12)    NULL,
    [PART]                    VARCHAR (2)     NULL,
    [OFPARTS]                 VARCHAR (2)     NULL,
    [ARRANGEMENTINDICATOR]    VARCHAR (1)     NOT NULL,
    [CCRINDICATOR]            VARCHAR (1)     NOT NULL,
    [FILTERPARTINDICATOR]     VARCHAR (1)     NOT NULL,
    [MAINTPARTINDICATOR]      VARCHAR (1)     NOT NULL,
    [NPRINDICATOR]            VARCHAR (1)     NULL,
    [TYPECHANGEINDICATOR]     VARCHAR (1)     NULL,
    [LASTMODIFIEDDATE]        DATETIME2 (6)   NULL,
    CONSTRAINT [LNKMEDIAIEPART_PK_LNKMEDIAIEPART] PRIMARY KEY CLUSTERED ([MEDIANUMBER] ASC, [IESYSTEMCONTROLNUMBER] ASC) WITH (FILLFACTOR = 100)
);





GO
ALTER TABLE [SISWEB_OWNER_STAGING].[LNKMEDIAIEPART] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO

CREATE NONCLUSTERED INDEX IX_LNKMEDIAIEPART_MN_IPN_IES ON SISWEB_OWNER_STAGING.LNKMEDIAIEPART (MEDIANUMBER ASC, IEPARTNUMBER ASC, IESYSTEMCONTROLNUMBER ASC);
GO

CREATE NONCLUSTERED INDEX IX_LNKMEDIAIEPART_BECN ON SISWEB_OWNER_STAGING.LNKMEDIAIEPART (BASEENGCONTROLNO ASC) ;
GO

CREATE NONCLUSTERED INDEX IX_LNKMEDIAIEPART_IEPARTNUMBER ON SISWEB_OWNER_STAGING.LNKMEDIAIEPART (IEPARTNUMBER ASC) ;
GO

CREATE NONCLUSTERED INDEX IX_LNKMEDIAIEPART_IPN_AI ON SISWEB_OWNER_STAGING.LNKMEDIAIEPART (IEPARTNUMBER ASC, ARRANGEMENTINDICATOR ASC);
GO

CREATE NONCLUSTERED INDEX IX_LNKMEDIAIEPART_ISCN ON SISWEB_OWNER_STAGING.LNKMEDIAIEPART (IESYSTEMCONTROLNUMBER ASC);
GO

CREATE NONCLUSTERED INDEX IX_LNKMEDIAIEPART_MNFPI ON SISWEB_OWNER_STAGING.LNKMEDIAIEPART (MEDIANUMBER ASC, FILTERPARTINDICATOR ASC);
GO

CREATE NONCLUSTERED INDEX IX_LNKMEDIAIEPART_TCIND ON SISWEB_OWNER_STAGING.LNKMEDIAIEPART (TYPECHANGEINDICATOR ASC);
GO
