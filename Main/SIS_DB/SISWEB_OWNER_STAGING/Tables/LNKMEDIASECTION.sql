﻿CREATE TABLE [SISWEB_OWNER_STAGING].[LNKMEDIASECTION] (
    [MEDIANUMBER]              VARCHAR (8)    NOT NULL,
    [SECTIONNUMBER]            SMALLINT       NOT NULL,
    [SECTIONLANGUAGEINDICATOR] VARCHAR (2)    NOT NULL,
    [SECTIONNAME]              NVARCHAR (384) NOT NULL,
    [SAFETYINDICATOR]          VARCHAR (1)    NOT NULL,
    [LASTMODIFIEDDATE]         DATETIME2 (6)  NULL,
    CONSTRAINT [LNKMEDIASECTION_PK_LNKMEDIASECTION] PRIMARY KEY CLUSTERED ([MEDIANUMBER] ASC, [SECTIONNUMBER] ASC, [SECTIONLANGUAGEINDICATOR] ASC)
);


GO
ALTER TABLE [SISWEB_OWNER_STAGING].[LNKMEDIASECTION] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO

