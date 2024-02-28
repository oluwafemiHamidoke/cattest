﻿CREATE TABLE [SISWEB_OWNER].[LNKMEDIASECTION] (
    [MEDIANUMBER]              VARCHAR (8)    NOT NULL,
    [SECTIONNUMBER]            SMALLINT       NOT NULL,
    [SECTIONLANGUAGEINDICATOR] VARCHAR (2)    NOT NULL,
    [SECTIONNAME]              NVARCHAR (384) NOT NULL,
    [SAFETYINDICATOR]          VARCHAR (1)    NOT NULL,
    [LASTMODIFIEDDATE]         DATETIME2 (6)  NULL,
    CONSTRAINT [LNKMEDIASECTION_PK_LNKMEDIASECTION] PRIMARY KEY CLUSTERED ([MEDIANUMBER] ASC, [SECTIONNUMBER] ASC, [SECTIONLANGUAGEINDICATOR] ASC)
);

