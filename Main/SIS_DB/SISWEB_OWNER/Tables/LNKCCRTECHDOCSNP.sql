﻿CREATE TABLE [SISWEB_OWNER].[LNKCCRTECHDOCSNP]
(
	[UPDATERID]         NUMERIC(10)     NOT NULL, 
    [SNP]               VARCHAR(10)     NOT NULL, 
    [BEGINNINGRANGE]    NUMERIC(5)      NOT NULL, 
    [ENDRANGE]          NUMERIC(5)      NOT NULL,
	[LASTMODIFIEDDATE]  DATETIME2(6)    NULL, 
    CONSTRAINT [PK_LNKCCRTECHDOCSNP] PRIMARY KEY ([UPDATERID] ASC, [SNP] ASC, [BEGINNINGRANGE] ASC, [ENDRANGE] ASC) 
);
