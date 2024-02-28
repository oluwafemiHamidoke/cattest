CREATE TABLE [SISWEB_OWNER_SHADOW].[LNKPARTSPDFPSID_BASE] (
    [PARTSPDF_ID]           INT         NOT NULL,
    [PSID]                  VARCHAR (8) NOT NULL,
    CONSTRAINT [PK_LNKPARTSPDFPSID] PRIMARY KEY CLUSTERED ([PARTSPDF_ID] ASC, [PSID] ASC)
);

GO
CREATE NONCLUSTERED INDEX idx_LNKPARTSPDFPSID_PARTSPDF_ID ON SISWEB_OWNER_SHADOW.LNKPARTSPDFPSID_BASE (PARTSPDF_ID ASC) include (PSID);

GO
EXECUTE sp_addextendedproperty @name = N'Previous Rotation', @value = N'From SISWEB_OWNER_SWAP on 2020-05-12 14:18:08 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SHADOW', @level1type = N'TABLE', @level1name = N'LNKPARTSPDFPSID_BASE';

GO
EXECUTE sp_addextendedproperty @name = N'Last Rotation', @value = N'From SISWEB_OWNER_SWAP on 2020-05-12 14:19:02 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SHADOW', @level1type = N'TABLE', @level1name = N'LNKPARTSPDFPSID_BASE';
