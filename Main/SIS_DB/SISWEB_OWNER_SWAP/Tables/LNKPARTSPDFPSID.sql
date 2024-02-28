CREATE TABLE [SISWEB_OWNER_SWAP].[LNKPARTSPDFPSID] (
    [PARTSPDF_ID]           INT         NOT NULL,
    [PSID]                  VARCHAR (8) NOT NULL,
    CONSTRAINT [PK_LNKPARTSPDFPSID] PRIMARY KEY CLUSTERED ([PARTSPDF_ID] ASC, [PSID] ASC)
);

GO
CREATE NONCLUSTERED INDEX idx_LNKPARTSPDFPSID_PARTSPDF_ID ON SISWEB_OWNER_SWAP.LNKPARTSPDFPSID (PARTSPDF_ID ASC) include (PSID);

GO
EXECUTE sp_addextendedproperty @name = N'Previous Rotation', @value = N'From SISWEB_OWNER on 2020-05-08 12:20:00 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SWAP', @level1type = N'TABLE', @level1name = N'LNKPARTSPDFPSID';


GO
EXECUTE sp_addextendedproperty @name = N'Last Rotation', @value = N'From SISWEB_OWNER on 2020-05-08 12:23:11 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SWAP', @level1type = N'TABLE', @level1name = N'LNKPARTSPDFPSID';
