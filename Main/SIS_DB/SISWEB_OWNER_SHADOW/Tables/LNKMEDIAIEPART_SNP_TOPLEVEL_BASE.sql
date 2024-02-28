﻿CREATE TABLE [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART_SNP_TOPLEVEL_BASE] (
    [PSID]                  VARCHAR (8)     NOT NULL,
    [isTopLevel]            BIT             NULL,
    [MEDIANUMBER]           VARCHAR (8)     NOT NULL,
    [IESYSTEMCONTROLNUMBER] VARCHAR (12)    NOT NULL,
    [IEPARTNUMBER]          VARCHAR (40)    NULL,
    [ORGCODE]               VARCHAR (12)    NULL,
    [IEPARTNAME]            NVARCHAR (128)  NULL,
    [IESEQUENCENUMBER]      INT             NOT NULL,
    [IEPARTMODIFIER]        NVARCHAR (512)  NULL,
    [IECAPTION]             NVARCHAR (2048) NOT NULL,
    [SNP]                   VARCHAR  (10)   NULL
);

GO
CREATE CLUSTERED INDEX IX02_LNKMEDIAIEPART_SNP_TOPLEVEL ON
SISWEB_OWNER_SHADOW.LNKMEDIAIEPART_SNP_TOPLEVEL_BASE (MEDIANUMBER ASC,IESYSTEMCONTROLNUMBER ASC,PSID ASC, SNP ASC) WITH (STATISTICS_NORECOMPUTE = ON);

GO
CREATE NONCLUSTERED INDEX IDX_LNKMEDIAIEPART_SNP_TOPLEVEL_SNP
ON [SISWEB_OWNER_SHADOW].[LNKMEDIAIEPART_SNP_TOPLEVEL_BASE] ([SNP])
INCLUDE ([isTopLevel],[IEPARTNUMBER],[IEPARTNAME],[IEPARTMODIFIER],[IECAPTION])

GO
EXECUTE sp_addextendedproperty @name = N'Previous Rotation', @value = N'From SISWEB_OWNER_SWAP on 2020-04-24 06:41:27 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SHADOW', @level1type = N'TABLE', @level1name = N'LNKMEDIAIEPART_SNP_TOPLEVEL_BASE';

GO
EXECUTE sp_addextendedproperty @name = N'Last Rotation', @value = N'From SISWEB_OWNER_SWAP on 2020-04-24 07:17:26 +00:00', @level0type = N'SCHEMA', @level0name = N'SISWEB_OWNER_SHADOW', @level1type = N'TABLE', @level1name = N'LNKMEDIAIEPART_SNP_TOPLEVEL_BASE';
