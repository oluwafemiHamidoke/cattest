﻿CREATE TABLE [SISWEB_OWNER_STAGING].[LNKCCRGROUPPARTS]
(
    [ID]                    INT IDENTITY(1,1)       NOT NULL,
	[OPERATIONRID]          NUMERIC(10)             NOT NULL,
    [GROUPNUMBER]           VARCHAR(20)             NULL,
    [GROUPNAME]             VARCHAR(128)            NULL,
    [SNP]                   VARCHAR(10)             NOT NULL,
    [PSID]                  CHAR(8)                 NULL,
    [SPNRID]                NUMERIC(16)             NULL,
    [LASTMODIFIEDDATE]      DATETIME2(6)            NULL,
    CONSTRAINT [PK_LNKCCRGROUPPARTS] PRIMARY KEY ([ID] ASC)
);
GO

CREATE NONCLUSTERED INDEX IX_LNKCCRGROUPPARTS_PSID ON SISWEB_OWNER_STAGING.LNKCCRGROUPPARTS (PSID ASC);
GO

