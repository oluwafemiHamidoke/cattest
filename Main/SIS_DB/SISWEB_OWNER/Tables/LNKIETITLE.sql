﻿CREATE TABLE SISWEB_OWNER.LNKIETITLE
	(IESYSTEMCONTROLNUMBER VARCHAR(12) NOT NULL
	,IELANGUAGEINDICATOR   VARCHAR(2) NOT NULL
	,IETITLE               NVARCHAR(3072) NOT NULL
	,IECONTROLNUMBER       VARCHAR(12) NULL
	,IERID                 NUMERIC(16) NULL
	,GROUPTITLEINDICATOR   VARCHAR(1) NULL
	,LASTMODIFIEDDATE      DATETIME2(6) NULL
	,ENGLISHCONTROLNUMBER  VARCHAR(12) NULL
	,CONSTRAINT LNKIETITLE_PK_LNKIETITLE PRIMARY KEY CLUSTERED(IESYSTEMCONTROLNUMBER ASC,IELANGUAGEINDICATOR ASC));

GO

CREATE NONCLUSTERED INDEX nci_wi_LNKIETITLE_1DD0D5CC16A3BB00D768CF03A20A7733 ON SISWEB_OWNER.LNKIETITLE (IELANGUAGEINDICATOR,GROUPTITLEINDICATOR) WITH (ONLINE = ON);
GO

GO
CREATE NONCLUSTERED INDEX IX_LNKIETITLE_IELANGUAGEINDICATOR_IESYSTEMCONTROLNUMBER ON SISWEB_OWNER.LNKIETITLE (IELANGUAGEINDICATOR ASC,IESYSTEMCONTROLNUMBER ASC) INCLUDE (IETITLE);