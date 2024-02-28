﻿CREATE TABLE [SISWEB_OWNER].[SUPERSESSIONCHAINS] (
    [PARTNUMBER]              VARCHAR (50)   NOT NULL,
    [ORGCODE]                 VARCHAR (12)   NOT NULL default 'CAT',
    [LASTPARTNUMBER]          VARCHAR (40)   NOT NULL,
    [LASTORGCODE]             VARCHAR (12)   NOT NULL default 'CAT',
    [CHAIN]                   VARCHAR (4000) NOT NULL,
    [isExpandedMiningProduct] BIT            NOT NULL default  0,
    [ID]                      INT            IDENTITY (1, 1) NOT NULL,
    [LASTMODIFIEDDATE] DATETIME2 (6)  NULL,
    CONSTRAINT [PK_SUPERSESSIONCHAINS_] PRIMARY KEY CLUSTERED ([ID] ASC)
);




GO
CREATE NONCLUSTERED INDEX [nci_wi_SUPERSESSIONCHAINS_BFCA31565FFAD468B802FC14BE678A8D]
    ON [SISWEB_OWNER].[SUPERSESSIONCHAINS]([PARTNUMBER] ASC);

GO
CREATE NONCLUSTERED INDEX [nci_wi_SUPERSESSIONCHAINS_isExpandedMiningProduct]
    ON [SISWEB_OWNER].[SUPERSESSIONCHAINS]([isExpandedMiningProduct] ASC);

