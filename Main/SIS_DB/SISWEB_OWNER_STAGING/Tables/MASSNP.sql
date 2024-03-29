﻿CREATE TABLE [SISWEB_OWNER_STAGING].[MASSNP](
	[CAPTIVESERIALNUMBERPREFIX] [varchar](10) NOT NULL,
	[BEGINNINGRANGE] [numeric](5, 0) NOT NULL,
	[ENDRANGE] [numeric](5, 0) NOT NULL,
	[PRIMESERIALNUMBERPREFIX] [varchar](10) NOT NULL,
	[MEDIANUMBER] [char](8) NOT NULL,
	[DOCUMENTTITLE] [varchar](512) NOT NULL,
	[CONFIGURATIONTYPE] [char](1) NOT NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX IX_SISWEB_OWNER_STAGING_MASSNP_CAPTIVESERIALNUMBERPREFIX
ON [SISWEB_OWNER_STAGING].[MASSNP] ([CAPTIVESERIALNUMBERPREFIX])
INCLUDE ([BEGINNINGRANGE],[ENDRANGE],[PRIMESERIALNUMBERPREFIX],[MEDIANUMBER]);
GO

CREATE NONCLUSTERED INDEX IX_MASSNP_CSNP_PSNP
ON SISWEB_OWNER_STAGING.MASSNP (CAPTIVESERIALNUMBERPREFIX ASC, PRIMESERIALNUMBERPREFIX ASC);
GO

CREATE NONCLUSTERED INDEX IX_MASSNP_MEDIANUMBER
ON SISWEB_OWNER_STAGING.MASSNP (MEDIANUMBER ASC);
GO
