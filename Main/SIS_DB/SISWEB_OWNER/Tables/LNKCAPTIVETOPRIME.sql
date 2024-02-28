﻿CREATE TABLE [SISWEB_OWNER].[LNKCAPTIVETOPRIME] (
    [MEDIANUMBER]         VARCHAR (8)   NOT NULL,
    [PRIMESERIALNUMBER]   VARCHAR (8)   NOT NULL,
    [CAPTIVESERIALNUMBER] VARCHAR (8)   NOT NULL,
    [ATTACHMENTTYPE]      VARCHAR (6)   NOT NULL,
    [LASTMODIFIEDDATE]    DATETIME2 (6) NULL,
    CONSTRAINT [LNKCAPTIVETOPRIME_PK_LNKCAPTIVETOPRIME] PRIMARY KEY CLUSTERED ([MEDIANUMBER] ASC, [PRIMESERIALNUMBER] ASC, [CAPTIVESERIALNUMBER] ASC)
);




GO

CREATE NONCLUSTERED INDEX [NCX_CAPTIVESERIALNUMBER] ON [SISWEB_OWNER].[LNKCAPTIVETOPRIME] ([CAPTIVESERIALNUMBER] ASC) include (ATTACHMENTTYPE);
GO

CREATE NONCLUSTERED INDEX [NCX_PRIMESERIALNUMBER]
    ON [SISWEB_OWNER].[LNKCAPTIVETOPRIME]([PRIMESERIALNUMBER] ASC, [ATTACHMENTTYPE] ASC);


GO
CREATE STATISTICS [FILTER_ATTACHMENTTYPE_EN]
    ON [SISWEB_OWNER].[LNKCAPTIVETOPRIME]([PRIMESERIALNUMBER], [ATTACHMENTTYPE]) WHERE ([ATTACHMENTTYPE]='EN');

