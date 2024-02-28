CREATE TABLE [SISWEB_OWNER_STAGING].[LNKSNPDATE] (
    [SNP]            VARCHAR(10)  NOT NULL, 
    [SNPUPDATEDATE]  DATE         NOT NULL, 
    CONSTRAINT [LNKSNPDATE_PK_LNKSNPDATE] PRIMARY KEY CLUSTERED ([SNP] ASC) 
);
