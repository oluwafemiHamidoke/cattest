﻿CREATE TABLE [SISWEB_OWNER].[LNKNPRINFORECTYPE23] (
    [PRIMARYSEQNO]   INT          NOT NULL,
    [RECORDTYPE]     VARCHAR (1)  NOT NULL,
    [SEQUENCENUMBER] INT          NOT NULL,
    [COLUMNDATA]     VARCHAR (64) NULL,
    [NPRINDICATOR]   VARCHAR (20) NULL,
    CONSTRAINT [LNKNPRINFORECTYPE23_PK_LNKNPRINFORECTYPE23] PRIMARY KEY CLUSTERED ([PRIMARYSEQNO] ASC, [RECORDTYPE] ASC, [SEQUENCENUMBER] ASC)
);

