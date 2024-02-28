﻿CREATE TABLE [SISWEB_OWNER_SHADOW].[LNKCONSISTLIST_BASE] (
    [IESYSTEMCONTROLNUMBER]   VARCHAR (12)   NOT NULL,
    [PARTSEQUENCENUMBER]      SMALLINT       NOT NULL,
    [REFERENCENO]             VARCHAR (50)   NULL,
    [GRAPHNO]                 VARCHAR (50)   NULL,
    [PARTNUMBER]              VARCHAR (50)   NOT NULL,
    [ORGCODE]                 VARCHAR (12)   NOT NULL default 'CAT',
    [PARTNAME]                NVARCHAR (64)  NULL,
    [PARTMODIFIER]            NVARCHAR (512) NULL,
    [QUANTITY]                VARCHAR (24)   NULL,
    [NOTE]                    VARCHAR (10)   NULL,
    [COMMENTS]                NVARCHAR (512) NULL,
    [SERVICEABILITYINDICATOR] VARCHAR (1)    NULL,
    [PARENTAGE]               SMALLINT       NULL,
    [CCRINDICATOR]            VARCHAR (1)    NULL,
    [FILTERPARTINDICATOR]     VARCHAR (1)    NULL,
    [MAINTPARTINDICATOR]      VARCHAR (1)    NULL,
    [NPRINDICATOR]            VARCHAR (1)    NULL,
    [LASTMODIFIEDDATE]        DATETIME2 (6)  NULL,
    CONSTRAINT [PK_LNKCONSISTLIST] PRIMARY KEY CLUSTERED ([IESYSTEMCONTROLNUMBER] ASC, [PARTSEQUENCENUMBER] ASC)
);



GO

CREATE UNIQUE NONCLUSTERED INDEX [LNKCONSISTLIST_IESYSTEMCONTROLNUMBER_1540841090959371_PK]
    ON [SISWEB_OWNER_SHADOW].[LNKCONSISTLIST_BASE]([IESYSTEMCONTROLNUMBER] ASC, [PARTSEQUENCENUMBER] ASC, [LASTMODIFIEDDATE] ASC);
GO

CREATE INDEX [IX_LNKCONSISTLIST_PARTNUMBER] ON [SISWEB_OWNER_SHADOW].[LNKCONSISTLIST_BASE] ([PARTNUMBER]);
GO

CREATE INDEX [IX_LNKCONSISTLIST_PARTNAME] ON [SISWEB_OWNER_SHADOW].[LNKCONSISTLIST_BASE] ([PARTNAME]) INCLUDE ([PARTNUMBER]);
GO

CREATE NONCLUSTERED INDEX [IX_LNKCONSISTLIST_NUMBER_NAME] ON [SISWEB_OWNER_SHADOW].[LNKCONSISTLIST_BASE] ([PARTNUMBER],[PARTNAME]) INCLUDE ([QUANTITY],[SERVICEABILITYINDICATOR],[ORGCODE]);
GO

CREATE INDEX [IX_LNKCONSISTLIST_PARTNUMBER_ORGCODE]
ON [SISWEB_OWNER_SHADOW].[LNKCONSISTLIST_BASE] ([PARTNUMBER],[ORGCODE])
GO

CREATE INDEX IX_NCL_LNKCONSISTLIST_BASE_IESYSTEMCONTROLNUMBER_PARTNUMBER
ON [SISWEB_OWNER_SHADOW].[LNKCONSISTLIST_BASE] (IESYSTEMCONTROLNUMBER) INCLUDE (PARTNUMBER)
GO

EXECUTE sp_addextendedproperty @name = N'Previous Rotation', @value = N'From SISWEB_OWNER_SWAP on 2021-03-08 17:46:30 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SHADOW', @level1type = N'TABLE', @level1name = N'LNKCONSISTLIST_BASE';




GO

EXECUTE sp_addextendedproperty @name = N'Last Rotation', @value = N'From SISWEB_OWNER_SWAP on 2021-03-08 17:46:32 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SHADOW', @level1type = N'TABLE', @level1name = N'LNKCONSISTLIST_BASE';




GO

