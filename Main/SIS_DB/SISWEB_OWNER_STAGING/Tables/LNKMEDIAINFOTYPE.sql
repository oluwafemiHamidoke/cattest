﻿CREATE TABLE [SISWEB_OWNER_STAGING].[LNKMEDIAINFOTYPE] (
    [MEDIANUMBER]      VARCHAR (8)   NOT NULL,
    [INFOTYPEID]       SMALLINT      NOT NULL,
    [LASTMODIFIEDDATE] DATETIME2 (6) NULL,
    CONSTRAINT [LNKMEDIAINFOTYPE_PK_LNKMEDIAINFOTYPE] PRIMARY KEY CLUSTERED ([MEDIANUMBER] ASC, [INFOTYPEID] ASC)
);


GO
ALTER TABLE [SISWEB_OWNER_STAGING].[LNKMEDIAINFOTYPE] ENABLE CHANGE_TRACKING WITH (TRACK_COLUMNS_UPDATED = ON);
GO

