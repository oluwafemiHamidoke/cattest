﻿CREATE VIEW [sis].[vw_LNKIEINFOTYPE_Active]
	WITH SCHEMABINDING
AS
SELECT [IESYSTEMCONTROLNUMBER]
	, [INFOTYPEID]
	, [LASTMODIFIEDDATE]
FROM [SISWEB_OWNER].[LNKIEINFOTYPE]
WHERE [INFOTYPEID] NOT IN (
		17
		, 18
		, 21
		, 33
		, 34
		)
GO

CREATE UNIQUE CLUSTERED INDEX [IX_vw_LNKIEINFOTYPE_Active] ON [sis].[vw_LNKIEINFOTYPE_Active] (
	[IESYSTEMCONTROLNUMBER] ASC
	, [INFOTYPEID] ASC
	)
	WITH (
			DATA_COMPRESSION = PAGE
			, STATISTICS_NORECOMPUTE = OFF
			, IGNORE_DUP_KEY = OFF
			, DROP_EXISTING = OFF
			, ONLINE = OFF
			) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_vw_LNKIEINFOTYPE_Active_INFOTYPEID]
	ON [sis].[vw_LNKIEINFOTYPE_Active] ([INFOTYPEID])
GO
