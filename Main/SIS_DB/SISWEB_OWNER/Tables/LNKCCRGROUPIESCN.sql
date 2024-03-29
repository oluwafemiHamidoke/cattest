﻿CREATE TABLE [SISWEB_OWNER].[LNKCCRGROUPIESCN]
(
	[SNP]                   VARCHAR(10)     NOT NULL, 
    [OPERATIONRID]          NUMERIC(10)     NOT NULL, 
    [IESYSTEMCONTROLNUMBER] VARCHAR(12)     NOT NULL,
    [LASTMODIFIEDDATE]      DATETIME2(6)    NULL, 
    CONSTRAINT [PK_LNKCCRGROUPIESCN] PRIMARY KEY ([SNP] ASC, [OPERATIONRID] ASC, [IESYSTEMCONTROLNUMBER] ASC) 
);

GO

CREATE NONCLUSTERED INDEX [IDX_LNKCCRGROUPIESCN_SNP_IESYSTEMCONTROLNUMBER] ON [SISWEB_OWNER].[LNKCCRGROUPIESCN] ([SNP], [IESYSTEMCONTROLNUMBER]);
