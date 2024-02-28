﻿CREATE TABLE [SISWEB_OWNER_STAGING].[LNKCCRGROUPIESCN]
(
	[SNP]                   VARCHAR(10)     NOT NULL, 
    [OPERATIONRID]          NUMERIC(10)     NOT NULL, 
    [IESYSTEMCONTROLNUMBER] VARCHAR(12)     NOT NULL,
    [LASTMODIFIEDDATE]      DATETIME2(6)    NULL, 
    CONSTRAINT [PK_LNKCCRGROUPIESCN] PRIMARY KEY ([SNP] ASC, [OPERATIONRID] ASC, [IESYSTEMCONTROLNUMBER] ASC) 
);
GO
ALTER TABLE [SISWEB_OWNER_STAGING].[LNKCCRGROUPIESCN] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO