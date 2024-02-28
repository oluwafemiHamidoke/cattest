CREATE TABLE [SISWEB_OWNER_STAGING].[LNKNPRINFORECTYPE23_SWAP] (
    [PRIMARYSEQNO]   INT          NOT NULL,
    [RECORDTYPE]     VARCHAR (1)  NOT NULL,
    [SEQUENCENUMBER] INT          NOT NULL,
    [COLUMNDATA]     VARCHAR (64) NULL,
    [NPRINDICATOR]   VARCHAR (20) NULL,
    CONSTRAINT [LNKNPRINFORECTYPE23_SWAP_PK_LNKNPRINFORECTYPE23_SWAP] PRIMARY KEY CLUSTERED ([PRIMARYSEQNO] ASC, [RECORDTYPE] ASC, [SEQUENCENUMBER] ASC)
);
GO

CREATE NONCLUSTERED INDEX IX_LNIRT23_PSN_SWAP ON SISWEB_OWNER_STAGING.LNKNPRINFORECTYPE23_SWAP (PRIMARYSEQNO ASC);
GO