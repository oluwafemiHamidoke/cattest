CREATE TABLE [SISWEB_OWNER_SWAP].[LNKPARTSIESNP_LNKIEPSID_NORANGE] (
    [MEDIANUMBER]           VARCHAR (8)  NOT NULL,
    [IESYSTEMCONTROLNUMBER] VARCHAR (12) NOT NULL,
    [SNP]                   VARCHAR (10) NOT NULL,
    [PSID]                  VARCHAR (8)  NOT NULL,
    [N]                     BIGINT       NULL,
    CONSTRAINT [PK_LNKPARTSIESNP_LNKIEPSID_NORANGE] PRIMARY KEY CLUSTERED ([SNP] ASC, [PSID] ASC, [MEDIANUMBER] ASC, [IESYSTEMCONTROLNUMBER] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'Previous Rotation', @value = N'From SISWEB_OWNER on 2021-01-19 11:09:34 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SWAP', @level1type = N'TABLE', @level1name = N'LNKPARTSIESNP_LNKIEPSID_NORANGE';




GO
EXECUTE sp_addextendedproperty @name = N'Last Rotation', @value = N'From SISWEB_OWNER on 2021-01-19 11:09:35 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SWAP', @level1type = N'TABLE', @level1name = N'LNKPARTSIESNP_LNKIEPSID_NORANGE';



