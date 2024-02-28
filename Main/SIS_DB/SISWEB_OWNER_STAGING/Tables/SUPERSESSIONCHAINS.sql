﻿CREATE TABLE [SISWEB_OWNER_STAGING].[SUPERSESSIONCHAINS](
	[PARTNUMBER] [varchar](20) NOT NULL,
	[LASTPARTNUMBER] [varchar](20) NOT NULL,
	[CHAIN] [varchar](4000) NOT NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IDX_SSCHAINS_LPNO ON SISWEB_OWNER_STAGING.SUPERSESSIONCHAINS (LASTPARTNUMBER ASC);
GO

CREATE NONCLUSTERED INDEX IDX_SSCHAINS_PNO ON SISWEB_OWNER_STAGING.SUPERSESSIONCHAINS (PARTNUMBER ASC);
GO