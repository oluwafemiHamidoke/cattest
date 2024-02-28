﻿CREATE TABLE [SISWEB_OWNER_STAGING].[LNKCCRUPDATES]
(
	[UPDATERID]             NUMERIC(10)     NOT NULL, 
    [OPERATIONRID]          NUMERIC(10)     NOT NULL, 
    [UPDATETYPEINDICATOR]   CHAR(1)         NOT NULL, 
    [IESYSTEMCONTROLNUMBER] VARCHAR(12)     NOT NULL, 
    [LASTMODIFIEDDATE]      DATETIME2(6)    NULL,
    CONSTRAINT [PK_LNKCCRUPDATES] PRIMARY KEY ([UPDATERID] ASC)
);
GO
ALTER TABLE [SISWEB_OWNER_STAGING].[LNKCCRUPDATES] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO

CREATE NONCLUSTERED INDEX IX_LNKCCRUPDATES_ISCNO ON SISWEB_OWNER_STAGING.LNKCCRUPDATES (IESYSTEMCONTROLNUMBER ASC);
GO

CREATE NONCLUSTERED INDEX IX_LNKCCRUPDATES_OPERRID ON SISWEB_OWNER_STAGING.LNKCCRUPDATES (OPERATIONRID ASC);
GO