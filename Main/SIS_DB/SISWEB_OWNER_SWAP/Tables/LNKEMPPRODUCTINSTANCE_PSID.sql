﻿CREATE TABLE [SISWEB_OWNER_SWAP].[LNKEMPPRODUCTINSTANCE_PSID](
    [SNP] VARCHAR(60) NULL,
    [LANGUAGEINDICATOR] VARCHAR(2) NOT NULL,
    [NUMBER] VARCHAR(60) NOT NULL,
    [MEDIANUMBER] VARCHAR(8) NOT NULL,
    [PARENTAGE] NUMERIC(1, 0) NOT NULL,
    [PARENTPRODUCTSTRUCTUREID] CHAR(8) NOT NULL,
    [PRODUCTSTRUCTUREID] CHAR(8) NOT NULL,
    [COUNT] INT,
    [PARTNUMBERCOUNT] INT
)


GO
CREATE CLUSTERED INDEX IX_LNKEMPPRODUCTINSTANCE_PSID_SNP_LANGUAGEINDICATOR_NUMBER ON
SISWEB_OWNER_SWAP.LNKEMPPRODUCTINSTANCE_PSID (SNP ASC, LANGUAGEINDICATOR ASC, NUMBER ASC);

GO
EXECUTE sp_addextendedproperty @name = N'Previous Rotation', @value = N'From SISWEB_OWNER on 2021-01-19 11:09:34 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SWAP', @level1type = N'TABLE', @level1name = N'LNKEMPPRODUCTINSTANCE_PSID';




GO
EXECUTE sp_addextendedproperty @name = N'Last Rotation', @value = N'From SISWEB_OWNER on 2021-01-19 11:09:35 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SWAP', @level1type = N'TABLE', @level1name = N'LNKEMPPRODUCTINSTANCE_PSID';





