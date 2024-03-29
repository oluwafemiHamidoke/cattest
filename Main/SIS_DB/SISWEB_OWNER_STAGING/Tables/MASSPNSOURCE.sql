﻿CREATE TABLE [SISWEB_OWNER_STAGING].[MASSPNSOURCE]
(
	[SPNRID]            NUMERIC(16)     NOT NULL, 
    [SPN]               NVARCHAR(288)   NOT NULL, 
    [PSID]              CHAR(8)         NOT NULL,
    [LASTMODIFIEDDATE]  DATETIME2(6)    NULL,
    CONSTRAINT [PK_MASSPNSOURCE] PRIMARY KEY CLUSTERED ([SPNRID] ASC)
);
GO

CREATE NONCLUSTERED INDEX IX_MASSPNSOURCE_SPNRID_PSID ON SISWEB_OWNER_STAGING.MASSPNSOURCE (SPNRID ASC, PSID ASC);
GO
