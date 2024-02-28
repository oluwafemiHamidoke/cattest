﻿CREATE TABLE [SISWEB_OWNER].[LNKPRODUCT] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [PRODUCTCODE]          VARCHAR (4)   NOT NULL,
    [SEQUENCENUMBER]       SMALLINT      NOT NULL,
    [SALESMODELNO]         VARCHAR (21)  NOT NULL,
    [SNP]                  VARCHAR (10)  NOT NULL,
    [SALESMODELSEQNO]      SMALLINT      NOT NULL,
    [STATUSINDICATOR]      VARCHAR (1)   NOT NULL,
    [CCRINDICATOR]         VARCHAR (1)   NOT NULL,
    [FREQUENCY]            VARCHAR (1)   NULL,
    [SHIPPEDDATE]          DATETIME2 (0) NULL,
    [CLASSICPARTINDICATOR] VARCHAR (1)   NOT NULL,
    [LASTMODIFIEDDATE]     DATETIME2 (6) NULL,
    CONSTRAINT [PK_LNKPRODUCT] PRIMARY KEY NONCLUSTERED ([ID] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [IX_LNKPRODUCT_SNP_PRODUCTCODE]
    ON [SISWEB_OWNER].[LNKPRODUCT]([SNP] ASC, [PRODUCTCODE] ASC, [SALESMODELNO] ASC, [SEQUENCENUMBER] ASC);
