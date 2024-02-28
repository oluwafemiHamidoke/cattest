﻿CREATE TABLE [SISWEB_OWNER_STAGING].[MASCCRMEDIA]
(
	[CCRMEDIARID]           NUMERIC(10)     NOT NULL, 
    [REPAIRTYPEINDICATOR]   CHAR(1)         NOT NULL, 
    [SNP]                   VARCHAR(10)     NOT NULL, 
    [BEGINNINGRANGE]        NUMERIC(5)      NOT NULL, 
    [ENDRANGE]              NUMERIC(5)      NOT NULL,
	[LASTMODIFIEDDATE]      DATETIME2(6)    NULL, 
    CONSTRAINT [PK_MASCCRMEDIA] PRIMARY KEY ([CCRMEDIARID] ASC)
);
GO
ALTER TABLE [SISWEB_OWNER_STAGING].[MASCCRMEDIA] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO

CREATE NONCLUSTERED INDEX IX_MASCCRMEDIA_SNPRANGE ON SISWEB_OWNER_STAGING.MASCCRMEDIA (SNP ASC, BEGINNINGRANGE ASC, ENDRANGE ASC);
GO

