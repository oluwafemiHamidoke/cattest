﻿CREATE TABLE [SISWEB_OWNER].[MASINFOTYPE] (
    [INFOTYPEID]          NUMERIC (3)    NOT NULL,
    [LANGUAGEINDICATOR]   VARCHAR (2)    NOT NULL,
    [INFOTYPE]            VARCHAR (8)    NOT NULL,
    [INFORMATIONTYPEDESC] NVARCHAR (720) NOT NULL,
    [ID]                  INT            IDENTITY (1, 1) NOT NULL,
    [LASTMODIFIEDDATE]    DATETIME2 (6)  NULL,
    CONSTRAINT [PK_MASINFOTYPE_] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

CREATE INDEX IX_SISWEB_OWNER_MASINFOTYPE ON SISWEB_OWNER.MASINFOTYPE (INFOTYPEID) include (LANGUAGEINDICATOR);
GO