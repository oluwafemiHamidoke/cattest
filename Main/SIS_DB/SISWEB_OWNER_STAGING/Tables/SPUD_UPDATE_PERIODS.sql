﻿CREATE TABLE [SISWEB_OWNER_STAGING].[SPUD_UPDATE_PERIODS]
(
	[PROCESSTYPEID]     NUMERIC         NOT NULL, 
    [PROCESSTYPE]       VARCHAR(32)     NOT NULL, 
    [PERIODTYPE]        VARCHAR(32)     NOT NULL, 
    [UPDATEPERIOD]      VARCHAR(32)     NULL, 
    [ENABLED]           CHAR(1)         NOT NULL, 
    [LASTMODIFIEDDATE]  DATETIME2(6)    NULL, 
    CONSTRAINT [PK_SPUD_UPDATE_PERIODS] PRIMARY KEY CLUSTERED ([PROCESSTYPEID] ASC), 
    CONSTRAINT [CK_SUP_ENABLED] CHECK (ENABLED IN ('Y','N'))
);
