﻿CREATE TABLE [SISWEB_OWNER_STAGING].[SIS2MEDIAEFFECTIVITY] (
    [MEDIANUMBER]      VARCHAR (8)  NOT NULL,
    [TYPEINDICATOR]    VARCHAR (1)  NOT NULL,
    [EFFECTIVITY]      VARCHAR (10) NOT NULL,
    [LASTMODIFIEDDATE] VARCHAR (50) NULL,
    CONSTRAINT [SIS2MEDIAEFFECTIVITY_SIS2MEDIAEFFECTIVITY_PK] PRIMARY KEY CLUSTERED ([MEDIANUMBER] ASC, [TYPEINDICATOR] ASC, [EFFECTIVITY] ASC)
);


GO
ALTER TABLE [SISWEB_OWNER_STAGING].[SIS2MEDIAEFFECTIVITY] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO

