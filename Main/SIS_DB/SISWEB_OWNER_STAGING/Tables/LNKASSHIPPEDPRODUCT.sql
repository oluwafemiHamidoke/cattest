﻿CREATE TABLE [SISWEB_OWNER_STAGING].[LNKASSHIPPEDPRODUCT] (
    [SERIALNUMBER]     VARCHAR (8)   NOT NULL,
    [EMDPROCESSEDDATE] DATETIME2 (0) NOT NULL,
    [BUILDDATE]        DATETIME2 (0) NOT NULL,
    [LASTMODIFIEDDATE] DATETIME2 (6) NULL,
    CONSTRAINT [LNKASSHIPPEDPRODUCT_PK_LAP1] PRIMARY KEY CLUSTERED ([SERIALNUMBER] ASC)
);


GO
ALTER TABLE [SISWEB_OWNER_STAGING].[LNKASSHIPPEDPRODUCT] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO
