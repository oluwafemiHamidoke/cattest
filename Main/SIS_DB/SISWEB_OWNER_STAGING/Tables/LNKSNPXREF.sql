CREATE TABLE [SISWEB_OWNER_STAGING].LNKSNPXREF (
    SNP	VARCHAR(3) NOT NULL,
    PRODUCTCODE	VARCHAR(4) NOT NULL,
    PRIMESNP VARCHAR(3) NOT NULL
)

GO

CREATE INDEX IDX_SNP_PCODE_PSNP ON [SISWEB_OWNER_STAGING].[LNKSNPXREF] (SNP,PRODUCTCODE,PRIMESNP)
GO
