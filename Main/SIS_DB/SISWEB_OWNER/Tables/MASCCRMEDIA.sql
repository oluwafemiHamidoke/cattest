﻿CREATE TABLE [SISWEB_OWNER].[MASCCRMEDIA]
(
	[CCRMEDIARID]           NUMERIC(10)     NOT NULL, 
    [REPAIRTYPEINDICATOR]   CHAR(1)         NOT NULL, 
    [SNP]                   VARCHAR(10)     NOT NULL, 
    [BEGINNINGRANGE]        NUMERIC(5)      NOT NULL, 
    [ENDRANGE]              NUMERIC(5)      NOT NULL,
	[LASTMODIFIEDDATE]      DATETIME2(6)    NULL, 
    CONSTRAINT [PK_MASCCRMEDIA] PRIMARY KEY ([CCRMEDIARID] ASC)
);

GO

CREATE INDEX [IX_MASCCRMEDIA_SNPRANGE] ON [SISWEB_OWNER].[MASCCRMEDIA] ([SNP], [BEGINNINGRANGE], [ENDRANGE])
