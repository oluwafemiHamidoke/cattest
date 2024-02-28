CREATE TABLE [SISWEB_OWNER_SWAP].[LNKPDFPRODUCTINSTANCE] (
    [PARTSPDF_ID]           INT    NOT NULL,
    [EMPPRODUCTINSTANCE_ID]    INT    NOT NULL,
    CONSTRAINT [PK_LNKPDFPRODUCTINSTANCE] PRIMARY KEY CLUSTERED ([PARTSPDF_ID] ASC, [EMPPRODUCTINSTANCE_ID] ASC)
);

GO
CREATE NONCLUSTERED INDEX idx_LNKPDFPRODUCTINSTANCE_PARTSPDF_ID_EMPPRODUCTINSTANCE_ID ON SISWEB_OWNER_SWAP.LNKPDFPRODUCTINSTANCE (PARTSPDF_ID ASC, EMPPRODUCTINSTANCE_ID ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Previous Rotation', @value = N'From SISWEB_OWNER on 2020-05-08 12:20:00 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SWAP', @level1type = N'TABLE', @level1name = N'LNKPDFPRODUCTINSTANCE';


GO
EXECUTE sp_addextendedproperty @name = N'Last Rotation', @value = N'From SISWEB_OWNER on 2020-05-08 12:23:11 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SWAP', @level1type = N'TABLE', @level1name = N'LNKPDFPRODUCTINSTANCE';
