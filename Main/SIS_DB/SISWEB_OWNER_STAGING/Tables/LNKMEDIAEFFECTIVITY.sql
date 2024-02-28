﻿CREATE TABLE [SISWEB_OWNER_STAGING].[LNKMEDIAEFFECTIVITY] (
    [MEDIANUMBER]   VARCHAR (8)  NOT NULL,
    [TYPEINDICATOR] VARCHAR (1)  NOT NULL,
    [EFFECTIVITY]   VARCHAR (10) NOT NULL,
    CONSTRAINT [LNKMEDIAEFFECTIVITY_PK_LNKMEDIAEFFECTIVITY] PRIMARY KEY CLUSTERED ([MEDIANUMBER] ASC, [TYPEINDICATOR] ASC, [EFFECTIVITY] ASC)
);


GO
ALTER TABLE [SISWEB_OWNER_STAGING].[LNKMEDIAEFFECTIVITY] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO
