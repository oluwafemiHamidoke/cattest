CREATE TABLE [SISWEB_OWNER_SWAP].[LNKIEPARTPRODINSTANCE] (
    [ID]                      INT                NOT NULL,
    [MEDIANUMBER]             VARCHAR (8)        NOT NULL,
    [IESYSTEMCONTROLNUMBER]   VARCHAR (12)       NOT NULL,
    [PI_ID]                   INT                NOT NULL,
    CONSTRAINT [PK_LNKIEPARTPRODINSTANCE] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Previous Rotation', @value = N'From SISWEB_OWNER on 2020-05-08 12:20:00 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SWAP', @level1type = N'TABLE', @level1name = N'LNKIEPARTPRODINSTANCE';


GO
EXECUTE sp_addextendedproperty @name = N'Last Rotation', @value = N'From SISWEB_OWNER on 2020-05-08 12:23:11 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SWAP', @level1type = N'TABLE', @level1name = N'LNKIEPARTPRODINSTANCE';

