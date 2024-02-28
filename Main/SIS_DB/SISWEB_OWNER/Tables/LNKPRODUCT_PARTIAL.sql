﻿CREATE TABLE [SISWEB_OWNER].[LNKPRODUCT_PARTIAL] (
    [ID]                   INT           NOT NULL,
    [PRODUCTCODE]          VARCHAR (4)   NOT NULL,
    [SALESMODELNO]         VARCHAR (21)  NOT NULL,
    [SNP]                  VARCHAR (10)  NOT NULL,
    [STATUSINDICATOR]      VARCHAR (1)   NOT NULL,
    [CCRINDICATOR]         VARCHAR (1)   NOT NULL,
    [FREQUENCY]            VARCHAR (1)   NULL,
    [SHIPPEDDATE]          DATETIME2 (0) NULL,
    [CLASSICPARTINDICATOR] VARCHAR (1)   NOT NULL,
    [LASTMODIFIEDDATE]     DATETIME2 (6) NULL,
    CONSTRAINT [PK_LNKPRODUCT_PARTIAL] PRIMARY KEY NONCLUSTERED ([ID] ASC)
);